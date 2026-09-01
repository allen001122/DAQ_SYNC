function info = verify_zero_crossing(refT, refU, tgtT, tgtU, corrTime, f0, opts)
%VERIFY_ZERO_CROSSING  用过零点独立核验对齐结果（R2016b 兼容，不依赖工具箱）
%
%   info = verify_zero_crossing(refT, refU, tgtT, tgtU, corrTime, f0, opts)
%
%   把目标电压的每个采样点按 corrTime 放到参考时钟上，然后在段首、段中、段末
%   各取若干个工频周波，比较两侧上升过零点的时刻差。正确对齐时该差值应为微秒
%   量级（065 真实数据实测 1.6~2.2 微秒）。
%
%   这是一个与相干法机理完全不同的独立佐证，而且是所有诊断量里最容易向人解释
%   的一个——两条波形的过零点差了多少微秒，画个图就能看懂。
%
%   注意其边界：近正弦的工频电压对「平移整数个工频周期」几乎不变，因此过零点
%   残差小并不能单独证明整周期正确；整周期由 refine_coarse_lag 的判别裕度与
%   三设备闭合保证，本函数只核验亚周期部分。
%
%   opts（可选）：
%     .nCycles   每处取用的周波数，默认 5
%     .tolUs     残差告警门限（微秒），默认 50
%     .maxGapCyc 过零点配对的最大间隔（周波），默认 0.4。超过即视为无对应，
%                不做配对——按序号硬配会在边界处整列错位半个周波。
%
%   info.rms_us / .max_us   段首/中/末三处的残差（1x3）
%   info.worst_rms_us       三处中最大的 RMS
%   info.nPairs             三处各自用到的过零点对数
%   info.ok                 worst_rms_us <= tolUs

    if nargin < 7 || isempty(opts), opts = struct(); end
    if ~isfield(opts, 'nCycles'),   opts.nCycles = 5; end
    if ~isfield(opts, 'tolUs'),     opts.tolUs = 50; end
    if ~isfield(opts, 'maxGapCyc'), opts.maxGapCyc = 0.4; end

    refT = refT(:); tgtT = tgtT(:); corrTime = corrTime(:);
    nPh = min(size(refU, 2), size(tgtU, 2));
    Tc = 1 / f0;
    maxGap = opts.maxGapCyc * Tc;

    info = struct();
    info.rms_us = nan(1, 3);
    info.max_us = nan(1, 3);
    info.nPairs = zeros(1, 3);

    % 只在两侧都覆盖的时间区间内取样
    t0 = max(corrTime(1), refT(1));
    t1 = min(corrTime(end), refT(end));
    if ~(t1 > t0)
        info.worst_rms_us = NaN;
        info.ok = false;
        return;
    end
    span = t1 - t0;
    segLen = opts.nCycles * Tc;
    if span < 3 * segLen
        segLen = max(2 * Tc, span / 3);
    end
    starts = [t0 + 0.02 * span, t0 + 0.5 * span - segLen / 2, t1 - 0.02 * span - segLen];
    starts = max(t0, min(starts, t1 - segLen));

    for k = 1:3
        ta = starts(k); tb = ta + segLen;
        errs = [];
        % 目标侧：落在 [ta,tb] 内的样本（corrTime 递增，可用二分）
        iA = lower_bound(corrTime, ta);
        iB = upper_bound(corrTime, tb);
        jA = lower_bound(refT, ta);
        jB = upper_bound(refT, tb);
        if iB - iA < 8 || jB - jA < 8
            continue;
        end
        for p = 1:nPh
            zt = rising_zeros(corrTime(iA:iB), tgtU(iA:iB, p));
            zr = rising_zeros(refT(jA:jB),    refU(jA:jB, p));
            if numel(zt) < 2 || numel(zr) < 2
                continue;
            end
            % 最近邻配对，超过 maxGap 视为无对应（按序号硬配会整列错位）
            for i = 1:numel(zt)
                [g, j] = min(abs(zr - zt(i)));
                if g <= maxGap
                    errs(end+1, 1) = (zr(j) - zt(i)) * 1e6; %#ok<AGROW>
                end
            end
        end
        if ~isempty(errs)
            info.rms_us(k) = sqrt(mean(errs .^ 2));
            info.max_us(k) = max(abs(errs));
            info.nPairs(k) = numel(errs);
        end
    end

    v = info.rms_us(isfinite(info.rms_us));
    if isempty(v)
        info.worst_rms_us = NaN;
        info.ok = false;
    else
        info.worst_rms_us = max(v);
        info.ok = info.worst_rms_us <= opts.tolUs;
    end
end


% =====================================================================
function z = rising_zeros(t, x)
%RISING_ZEROS  上升过零点时刻（线性插值）
    t = t(:); x = double(x(:));
    x = x - mean(x);
    i = find(x(1:end-1) < 0 & x(2:end) >= 0);
    if isempty(i)
        z = [];
        return;
    end
    d = x(i+1) - x(i);
    r = zeros(size(i));
    ok = abs(d) > 0;
    r(ok) = -x(i(ok)) ./ d(ok);
    z = t(i) + r .* (t(i+1) - t(i));
end


function i = lower_bound(t, v)
%LOWER_BOUND  第一个 t(i) >= v 的下标（t 须非递减）
    lo = 1; hi = numel(t) + 1;
    while lo < hi
        mid = floor((lo + hi) / 2);
        if t(mid) < v, lo = mid + 1; else, hi = mid; end
    end
    i = min(max(lo, 1), numel(t));
end


function i = upper_bound(t, v)
%UPPER_BOUND  最后一个 t(i) <= v 的下标（t 须非递减）
    lo = 0; hi = numel(t);
    while lo < hi
        mid = ceil((lo + hi) / 2);
        if t(mid) <= v, lo = mid; else, hi = mid - 1; end
    end
    i = min(max(lo, 1), numel(t));
end
