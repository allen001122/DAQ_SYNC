function out = compose_derived(tTotal, Xtotal, terms, spec)
%COMPOSE_DERIVED  以总量时间轴为网格，最近邻选点后按系数线性组合。
%
%   tTotal, Xtotal  总量电流与其时间
%   terms(i).t / .X / .coeff / .channel
%   spec.totalChannel  与 tTotal 同一通道时不再二次选点
%
% 算法：公共区间 + nearest_pick + 线性组合。本体与改名前相同。

    if nargin < 4
        spec = struct();
    end
    tTotal = tTotal(:);
    nTerm = numel(terms);

    tFirst = tTotal(1);
    tLast = tTotal(end);
    for i = 1:nTerm
        tt = terms(i).t(:);
        tFirst = max(tFirst, tt(1));
        tLast = min(tLast, tt(end));
    end
    if tLast <= tFirst
        error('路径A：无公共时间区间');
    end

    [tTotal, Xtotal] = crop_by_time(tTotal, Xtotal, tFirst, tLast);
    acc = zeros(size(Xtotal));
    nn_info = struct();
    trim = struct();
    out = struct();
    out.t = tTotal;
    out.t_common = [tFirst, tLast];

    totalUsed = false;
    for i = 1:nTerm
        ch = terms(i).channel;
        coeff = terms(i).coeff;
        tt = terms(i).t(:);
        XX = terms(i).X;
        [tt, XX] = crop_by_time(tt, XX, tFirst, tLast);
        if isfield(spec, 'totalChannel') && strcmp(ch, spec.totalChannel)
            info = struct('residual_us', zeros(size(tTotal)), ...
                'max_abs_us', 0, 'rms_us', 0, ...
                'idx', (1:numel(tTotal))', 'n', numel(tTotal));
            tnn = tTotal;
            XX = Xtotal;
            totalUsed = true;
        else
            [tnn, XX, info] = nearest_pick(tTotal, tt, XX);
        end
        acc = acc + coeff * XX;
        nn_info.(ch) = info;
        trim.(ch) = struct('method', 'nearest_pick', 'max_abs_us', info.max_abs_us);
        out.(['t_' ch]) = tnn;
        out.([ch 'I']) = XX;
    end
    if ~totalUsed
        acc = acc + Xtotal;
    end

    if isfield(spec, 'derivedTarget') && ~isempty(spec.derivedTarget)
        derName = spec.derivedTarget;
    else
        derName = 'derived';
    end
    out.([derName 'I']) = acc;
    if isfield(spec, 'totalChannel') && ~isempty(spec.totalChannel)
        out.(['t_' spec.totalChannel]) = tTotal;
        out.([spec.totalChannel 'I']) = Xtotal;
    end
    out.n = numel(tTotal);
    out.nn_info = nn_info;
    out.trim = trim;
    out.spec = spec;
end

function [t, X] = crop_by_time(t, X, t0, t1)
    mask = (t >= t0) & (t <= t1);
    t = t(mask);
    X = X(mask, :);
end
