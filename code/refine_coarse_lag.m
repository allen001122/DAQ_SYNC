function [lagSec, info] = refine_coarse_lag(refU, tgtU, fs, lag0Sec, opts)
%REFINE_COARSE_LAG  消除粗对齐的整周期模糊（R2016b 兼容，不依赖任何工具箱）
%
    if nargin < 5 || isempty(opts), opts = struct(); end
    if ~isfield(opts, 'loHz'),      opts.loHz = 200; end
    if ~isfield(opts, 'hiHz'),      opts.hiHz = 1000; end
    if ~isfield(opts, 'maxLagSec'), opts.maxLagSec = 3.0; end
    if ~isfield(opts, 'segSec'),    opts.segSec = 120; end
    if ~isfield(opts, 'winSec'),    opts.winSec = 8.0; end
    if ~isfield(opts, 'minMargin'), opts.minMargin = 8; end
    if ~isfield(opts, 'minCoh'),    opts.minCoh = 0.10; end
    if ~isfield(opts, 'segPos'),    opts.segPos = 'mid'; end

    refU = double(refU);
    tgtU = double(tgtU);
    nPh = min(size(refU, 2), size(tgtU, 2));

    if isfield(opts, 'f0') && ~isempty(opts.f0)
        f0 = opts.f0;
    else
        f0 = estimate_f0(refU(:, 1), fs);
    end
    Tc = 1 / f0;

    sh = round(lag0Sec * fs);
    if sh >= 0
        aStart = 1; bStart = 1 + sh;
    else
        aStart = 1 - sh; bStart = 1;
    end
    nA = size(tgtU, 1) - aStart + 1;
    nB = size(refU, 1) - bStart + 1;
    n = min(nA, nB);
    nWant = round(opts.segSec * fs);
    if n > nWant
        if strcmp(opts.segPos, 'head')
            off = 0;
        elseif strcmp(opts.segPos, 'tail')
            off = n - nWant;
        else
            off = floor((n - nWant) / 2);
        end
        aStart = aStart + off; bStart = bStart + off; n = nWant;
    end
    nsegWant = 2 ^ nextpow2(round(opts.winSec * fs));
    nsegMax  = 2 ^ floor(log2(max(n / 4, 1024)));
    nseg = min(nsegWant, nsegMax);
    if nseg < 1024 || nseg > n
        error('refine_coarse_lag: 可用重叠段过短（%d 点），无法建立整周期判据', n);
    end
    maxLagCap = 0.25 * nseg / fs;
    if opts.maxLagSec > maxLagCap
        opts.maxLagSec = maxLagCap;
    end

    w = kaiser_win(nseg, 14);
    fAx = (0:(nseg / 2))' * (fs / nseg);
    keep = (fAx >= opts.loHz) & (fAx <= opts.hiHz);
    for k = 0:(floor(opts.hiHz / f0) + 1)
        keep = keep & ~(abs(fAx - k * f0) < 2.0);
    end
    if ~any(keep)
        error('refine_coarse_lag: 陷波后频段为空，请检查 loHz/hiHz 与 f0');
    end

    lagAxis = ((0:(nseg - 1))' - nseg / 2) / fs;
    sel = abs(lagAxis) <= opts.maxLagSec;

    phaseLag = nan(1, nPh);
    phaseMargin = nan(1, nPh);
    phaseCoh = nan(1, nPh);

    for p = 1:nPh
        a = tgtU(aStart:(aStart + n - 1), p);
        b = refU(bStart:(bStart + n - 1), p);
        [Sxx, Syy, Sxy, nAvg] = welch_cross(a, b, w, nseg);
        coh = (abs(Sxy) .^ 2) ./ max(Sxx .* Syy, realmin);
        if max(coh) > 1 + 1e-6
            error('refine_coarse_lag: 相干度超过 1，计算异常');
        end
        phaseCoh(p) = median(coh(keep));
        G = zeros(size(Sxy));
        G(keep) = Sxy(keep) ./ sqrt(Sxx(keep) .* Syy(keep));
        cc = real(ifft(full_spec(G, nseg)));
        cc = circshift(cc, nseg / 2);
        c = cc(sel);
        ll = lagAxis(sel);
        c = c / max(abs(c));
        [pk, ip] = max(c);
        d = ll(ip);
        nb = zeros(1, 4); kk = [-2 -1 1 2];
        for i = 1:4
            [~, j] = min(abs(ll - (d + kk(i) * Tc)));
            nb(i) = c(j);
        end
        far = abs(ll - d) > 0.005;
        fl = std(c(far));
        phaseLag(p) = sh / fs - d;
        phaseMargin(p) = (pk - max(nb)) / max(fl, eps);
    end

    lagSec = median(phaseLag);
    spreadCyc = (max(phaseLag) - min(phaseLag)) / Tc;

    info = struct();
    info.f0 = f0;
    info.lag0Sec = lag0Sec;
    info.lagSec = lagSec;
    info.correctionSec = lagSec - lag0Sec;
    info.cycleShift = info.correctionSec / Tc;
    info.phaseLag = phaseLag;
    info.phaseMargin = phaseMargin;
    info.phaseCoh = phaseCoh;
    info.margin = min(phaseMargin);
    info.coherence = min(phaseCoh);
    info.phaseSpreadCycles = spreadCyc;
    info.nAvg = nAvg;
    info.band = [opts.loHz, opts.hiHz];
    info.winSec = nseg / fs;
    info.segSec = n / fs;
    info.segPos = opts.segPos;
    info.maxLagSec = opts.maxLagSec;
    info.atSearchEdge = abs(lagSec - lag0Sec) > 0.9 * opts.maxLagSec;
    info.ok = (info.margin >= opts.minMargin) && ...
              (info.coherence >= opts.minCoh) && ...
              (spreadCyc < 0.25) && ~info.atSearchEdge;

    fprintf('    整周期校正: %+.6f s (%+.2f 个工频周期)  f0=%.4f Hz\n', ...
        info.correctionSec, info.cycleShift, f0);
    fprintf('      相干度 %.3f | 判别裕度 %.1f 倍本底 | 三相分散 %.3f 周期 | 段长 %.0f s 窗 %.2f s×%d | 搜索±%.2f s | 通过 %d\n', ...
        info.coherence, info.margin, spreadCyc, info.segSec, info.winSec, nAvg, ...
        opts.maxLagSec, info.ok);
    if info.atSearchEdge
        fprintf('      ** 警告：结果落在搜索边界，真实偏移可能在范围之外，请加大 maxLagSec/winSec **\n');
    end
    if abs(info.cycleShift) > 0.25
        fprintf('      ** 注意：原粗对齐偏离 %.2f 个工频周期，已修正 **\n', info.cycleShift);
    end
    if ~info.ok
        fprintf('      ** 警告：判据未通过，整周期结果不可信，请人工复核 **\n');
    end
end

function [Sxx, Syy, Sxy, nAvg] = welch_cross(a, b, w, nseg)
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
    if nAvg < 3
        error('refine_coarse_lag: 可平均的窗数过少 (%d)', nAvg);
    end
    Sxx = Sxx / nAvg; Syy = Syy / nAvg; Sxy = Sxy / nAvg;
end

function X = full_spec(H, nseg)
    X = zeros(nseg, 1);
    m = nseg / 2 + 1;
    X(1:m) = H;
    X((m + 1):nseg) = conj(H((m - 1):-1:2));
end

function w = kaiser_win(N, beta)
    n = (0:(N - 1))';
    r = 2 * n / (N - 1) - 1;
    w = besseli(0, beta * sqrt(max(1 - r .^ 2, 0))) / besseli(0, beta);
end

function f0 = estimate_f0(x, fs)
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
        d = 0;
        if den < 0
            d = 0.5 * (a - c) / den;
            if abs(d) > 0.5, d = 0; end
        end
        f0 = f(i) + d * (fs / N);
    end
end
