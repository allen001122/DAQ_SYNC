function [lagSec, info] = coherence_scan_lag(refU, tgtU, fs, opts)
%COHERENCE_SCAN_LAG  无先验的全范围粗定位（R2016b 兼容，不依赖工具箱）
%
%   [lagSec, info] = coherence_scan_lag(refU, tgtU, fs, opts)
%
%   在整个可能的平移范围内扫描「扣除工频及各次谐波后的带内相干度」，取最大处
%   作为粗偏移。与全带互相关的区别在于：工频及其谐波对「平移整数个工频周期」
%   完全免疫，全带相关面在整周期方向上近乎水平；而非谐波共模内容对平移敏感，
%   相干度在全范围内只有唯一峰，因此本函数给出的粗位置不存在整周期模糊。
%
%   本函数不用于给出最终偏移（分辨率只有窗长量级），只用于给 refine_coarse_lag
%   提供一个可信的起点。约定与 coarse_align 一致：参考索引 = 目标索引 + lagSec*fs
%
%   opts（可选）：
%     .loHz/.hiHz    保留频段，默认 200 / 1000
%     .scanStepSec   扫描步长，默认 0.25 s
%     .scanChunkSec  单点所用段长，默认 10 s
%     .scanMaxSec    扫描范围封顶（±秒），默认 120
%     .minScanRatio  主峰/次峰相干度比门限，默认 1.5
%
%   info.peakCoh / .ratio / .ok / .nPoints

    if nargin < 4 || isempty(opts), opts = struct(); end
    if ~isfield(opts, 'loHz'),         opts.loHz = 200; end
    if ~isfield(opts, 'hiHz'),         opts.hiHz = 1000; end
    if ~isfield(opts, 'scanStepSec'),  opts.scanStepSec = 0.25; end
    if ~isfield(opts, 'scanChunkSec'), opts.scanChunkSec = 10; end
    if ~isfield(opts, 'scanMaxSec'),   opts.scanMaxSec = 120; end
    if ~isfield(opts, 'minScanRatio'), opts.minScanRatio = 1.5; end

    r1 = double(refU(:, 1));
    t1 = double(tgtU(:, 1));
    nR = numel(r1); nT = numel(t1);

    info = struct('peakCoh', NaN, 'ratio', NaN, 'ok', false, 'nPoints', 0);
    lagSec = NaN;

    nMid = min(numel(r1), round(20 * fs));
    iMid = max(1, floor((numel(r1) - nMid) / 2) + 1);
    f0 = estimate_f0_local(r1(iMid:(iMid + nMid - 1)), fs);

    chunk = round(opts.scanChunkSec * fs);
    maxSh = min(nR, nT) - chunk - 2;
    if maxSh < round(fs)
        chunk = floor(min(nR, nT) / 2);
        maxSh = min(nR, nT) - chunk - 2;
    end
    if maxSh < 100
        fprintf('      [扫描] 数据过短，无法建立相干扫描\n');
        return;
    end
    cap = round(opts.scanMaxSec * fs);
    if maxSh > cap
        fprintf('      [扫描] 范围封顶 ±%g s（opts.scanMaxSec）\n', opts.scanMaxSec);
        maxSh = cap;
    end
    step = max(1, round(opts.scanStepSec * fs));

    nseg = 2 ^ round(log2(2.0 * fs));
    nseg = min(nseg, 2 ^ floor(log2(max(chunk / 4, 1024))));
    if nseg < 1024
        fprintf('      [扫描] 可用窗长过短\n');
        return;
    end
    w = kaiser_win_local(nseg, 14);
    fAx = (0:(nseg / 2))' * (fs / nseg);
    keep = (fAx >= opts.loHz) & (fAx <= opts.hiHz);
    for k = 0:(floor(opts.hiHz / f0) + 1)
        keep = keep & ~(abs(fAx - k * f0) < 2.0);
    end
    if ~any(keep)
        fprintf('      [扫描] 陷波后频段为空\n');
        return;
    end

    shifts = (-maxSh:step:maxSh)';
    coh = nan(numel(shifts), 1);
    for i = 1:numel(shifts)
        sh = shifts(i);
        if sh >= 0
            a0 = 1; b0 = 1 + sh;
        else
            a0 = 1 - sh; b0 = 1;
        end
        n = min(nT - a0 + 1, nR - b0 + 1);
        nch = min(chunk, n);
        if nch < 2 * nseg, continue; end
        off = floor((n - nch) / 2);
        [Sxx, Syy, Sxy] = welch_cross_local( ...
            t1(a0+off : a0+off+nch-1), r1(b0+off : b0+off+nch-1), w, nseg);
        c = (abs(Sxy) .^ 2) ./ max(Sxx .* Syy, realmin);
        coh(i) = median(c(keep));
    end
    if all(isnan(coh))
        fprintf('      [扫描] 所有平移处重叠均不足\n');
        return;
    end

    [pk, ip] = max(coh);
    lagSec = shifts(ip) / fs;
    guard = abs(shifts - shifts(ip)) < 1.5 * nseg;
    sec = max(coh(~guard & ~isnan(coh)));
    if isempty(sec), sec = 0; end
    ratio = pk / max(sec, eps);

    info.peakCoh = pk;
    info.ratio = ratio;
    info.nPoints = sum(~isnan(coh));
    info.ok = isfinite(ratio) && ratio >= opts.minScanRatio;
    fprintf('      [扫描] 粗位置 %+.4f s  相干度 %.3f  次峰 %.3f  主峰/次峰 %.1f  扫描点 %d  通过 %d\n', ...
        lagSec, pk, sec, ratio, info.nPoints, info.ok);
end

function [Sxx, Syy, Sxy] = welch_cross_local(a, b, w, nseg)
    n = numel(a);
    step = nseg / 2;
    Sxx = zeros(nseg / 2 + 1, 1); Syy = Sxx; Sxy = complex(Sxx, 0);
    nAvg = 0;
    for s = 1:step:(n - nseg + 1)
        sa = a(s:(s + nseg - 1)); sa = (sa - mean(sa)) .* w;
        sb = b(s:(s + nseg - 1)); sb = (sb - mean(sb)) .* w;
        A = fft(sa); B = fft(sb);
        A = A(1:(nseg / 2 + 1)); B = B(1:(nseg / 2 + 1));
        Sxx = Sxx + abs(A) .^ 2;
        Syy = Syy + abs(B) .^ 2;
        Sxy = Sxy + A .* conj(B);
        nAvg = nAvg + 1;
    end
    if nAvg < 1, nAvg = 1; end
    Sxx = Sxx / nAvg; Syy = Syy / nAvg; Sxy = Sxy / nAvg;
end

function w = kaiser_win_local(N, beta)
    n = (0:(N - 1))';
    r = 2 * n / (N - 1) - 1;
    w = besseli(0, beta * sqrt(max(1 - r .^ 2, 0))) / besseli(0, beta);
end

function f0 = estimate_f0_local(x, fs)
    n = min(numel(x), round(20 * fs));
    seg = x(1:n); seg = seg - mean(seg);
    w = 0.5 - 0.5 * cos(2 * pi * (0:(n - 1))' / n);
    N = 2 ^ nextpow2(n);
    X = abs(fft(seg .* w, N));
    X = X(1:(N / 2 + 1));
    f = (0:(N / 2))' * (fs / N);
    b = (f > 45) & (f < 55);
    Xb = X; Xb(~b) = 0;
    [~, i] = max(Xb);
    f0 = 50;
    if i > 1 && i < numel(X)
        a = X(i - 1); bb = X(i); c = X(i + 1);
        den = a - 2 * bb + c;
        if den < 0
            d = 0.5 * (a - c) / den;
            if abs(d) <= 0.5, f0 = f(i) + d * (fs / N); end
        end
    end
end
