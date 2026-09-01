function result = harmonic_analysis(t, x, opts)
%HARMONIC_ANALYSIS  短窗谐波分析（约 10 周期）+ 跨窗聚合
    if nargin < 3 || isempty(opts), opts = struct(); end
    if ~isfield(opts, 'maxFreqHz'),    opts.maxFreqHz = 1975; end
    if ~isfield(opts, 'f0_nom'),       opts.f0_nom = 50; end
    if ~isfield(opts, 'f0_search'),    opts.f0_search = 5; end
    if ~isfield(opts, 'maxOrder'),     opts.maxOrder = 50; end
    if ~isfield(opts, 'windowCycles'), opts.windowCycles = 10; end
    if ~isfield(opts, 'hopCycles'),    opts.hopCycles = 10; end
    if ~isfield(opts, 'padSec'),       opts.padSec = 1.0; end
    if ~isfield(opts, 'searchHalfWidthHz'), opts.searchHalfWidthHz = 2.0; end

    t = t(:);
    x = double(x);
    fs = 1 / median(diff(t));
    n = size(x, 1);
    nPh = size(x, 2);

    winSamp = max(16, round(opts.windowCycles / opts.f0_nom * fs));
    hopSamp = max(1, round(opts.hopCycles / opts.f0_nom * fs));
    nfft = max(winSamp, round(opts.padSec * fs));
    nfft = 2^nextpow2(nfft);

    w = hann(winSamp, 'periodic');
    wSum = sum(w);
    if wSum < eps
        error('harmonic_analysis: 窗和为 0');
    end

    starts = 1:hopSamp:(n - winSamp + 1);
    nWin = numel(starts);
    if nWin < 5
        error('harmonic_analysis: 有效短窗过少 (%d)', nWin);
    end

    result = struct();
    result.fs = fs;
    result.f0_nom = opts.f0_nom;
    result.maxFreqHz = opts.maxFreqHz;
    result.n = n;
    result.nWindows = nWin;
    result.windowSec = winSamp / fs;
    result.hopSec = hopSamp / fs;
    result.method = 'short_window_rms';
    result.searchHalfWidthHz = max(opts.searchHalfWidthHz, 3 * (fs / nfft));
    result.freqGridHz = fs / nfft;
    result.phase = cell(nPh, 1);

    fAxis = (0:nfft/2)' * (fs / nfft);
    keep = fAxis <= opts.maxFreqHz + 1;
    fPlot = fAxis(keep);

    for p = 1:nPh
        xp = x(:, p);
        fundWin = nan(nWin, 1);
        f0Win = nan(nWin, 1);
        maxHnom = min(opts.maxOrder, floor(opts.maxFreqHz / opts.f0_nom));
        hMagWin = nan(nWin, maxHnom);
        thdWin = nan(nWin, 1);
        thd10Win = nan(nWin, 1);
        thd15Win = nan(nWin, 1);
        magAcc = zeros(nnz(keep), 1);
        nAcc = 0;
        for iw = 1:nWin
            seg = xp(starts(iw):starts(iw)+winSamp-1);
            seg = seg - mean(seg);
            segw = seg .* w;
            X = fft(segw, nfft);
            half = nfft/2 + 1;
            mag = abs(X(1:half)) * 2 / wSum;
            mag(1) = mag(1) / 2;
            magUse = mag(keep);
            fLo = opts.f0_nom - opts.f0_search;
            fHi = opts.f0_nom + opts.f0_search;
            band = (fPlot >= fLo) & (fPlot <= fHi);
            if ~any(band), continue; end
            tmp = magUse; tmp(~band) = 0;
            [peakV, ix] = max(tmp);
            f0w = fPlot(ix);
            [vHat, dHat] = parabolic_refine(magUse, ix);
            if ~isnan(dHat)
                f0w = f0w + dHat * (fs / nfft);
                peakV = vHat;
            end
            if peakV < eps || f0w < fLo || f0w > fHi, continue; end
            f0Win(iw) = f0w;
            fundWin(iw) = peakV;
            maxH = min(maxHnom, floor(opts.maxFreqHz / max(f0w, eps)));
            for h = 1:maxH
                fh = h * f0w;
                halfW = max(opts.searchHalfWidthHz, 3 * (fs / nfft));
                if h >= 2, halfW = min(halfW, 0.45 * f0w); end
                b2 = (fPlot >= fh - halfW) & (fPlot <= fh + halfW);
                if ~any(b2), continue; end
                idx = find(b2);
                [~, local] = max(magUse(idx));
                j = idx(local);
                hv = magUse(j);
                [vHat, ~] = parabolic_refine(magUse, j);
                if ~isnan(vHat), hv = vHat; end
                hMagWin(iw, h) = hv;
            end
            hMagWin(iw, 1) = peakV;
            row = hMagWin(iw, 1:maxH);
            row(~isfinite(row)) = 0;
            if peakV > eps && maxH >= 2
                thdWin(iw) = sqrt(sum(row(2:end).^2)) / peakV * 100;
                h10 = min(10, maxH); h15 = min(15, maxH);
                thd10Win(iw) = sqrt(sum(row(2:h10).^2)) / peakV * 100;
                thd15Win(iw) = sqrt(sum(row(2:h15).^2)) / peakV * 100;
            end
            magAcc = magAcc + magUse;
            nAcc = nAcc + 1;
        end
        valid = isfinite(fundWin) & fundWin > 0;
        nOk = nnz(valid);
        if nOk < 5
            error('harmonic_analysis: 相%d 有效窗过少 (%d/%d)', p, nOk, nWin);
        end
        fundMag = sqrt(mean(fundWin(valid).^2));
        fundFreq = mean(f0Win(valid));
        maxH = min(maxHnom, floor(opts.maxFreqHz / max(fundFreq, eps)));
        hOrder = (1:maxH)';
        hMag = zeros(maxH, 1);
        hFreq = (1:maxH)' * fundFreq;
        for h = 1:maxH
            col = hMagWin(valid, h);
            col = col(isfinite(col) & col >= 0);
            if isempty(col), hMag(h) = 0; else, hMag(h) = sqrt(mean(col.^2)); end
        end
        hMag(1) = fundMag; hFreq(1) = fundFreq;
        if fundMag > eps && maxH >= 2
            thd = sqrt(sum(hMag(2:end).^2)) / fundMag * 100;
            h10 = min(10, maxH); h15 = min(15, maxH);
            thd10 = sqrt(sum(hMag(2:h10).^2)) / fundMag * 100;
            thd15 = sqrt(sum(hMag(2:h15).^2)) / fundMag * 100;
        else
            thd = NaN; thd10 = NaN; thd15 = NaN;
        end
        thd_mean = mean(thdWin(valid & isfinite(thdWin)));
        thd_mean10 = mean(thd10Win(valid & isfinite(thd10Win)));
        thd_mean15 = mean(thd15Win(valid & isfinite(thd15Win)));
        ph = struct();
        if nAcc > 0, ph.f = fPlot; ph.mag = magAcc / nAcc;
        else, ph.f = fPlot; ph.mag = zeros(size(fPlot)); end
        ph.fundFreq = fundFreq; ph.fundMag = fundMag;
        ph.hOrder = hOrder; ph.hFreq = hFreq; ph.hMag = hMag;
        ph.THD_percent = thd; ph.THD10_percent = thd10; ph.THD15_percent = thd15;
        ph.THD_mean_percent = thd_mean; ph.THD_mean10_percent = thd_mean10;
        ph.THD_mean15_percent = thd_mean15;
        ph.method = 'short_window_rms'; ph.nWindowsOk = nOk; ph.nWindows = nWin;
        ph.f0_std = std(f0Win(valid));
        result.phase{p} = ph;
    end
    f0s = cellfun(@(ph) ph.fundFreq, result.phase);
    result.f0 = mean(f0s);
end

function [vHat, dHat] = parabolic_refine(mag, j)
    vHat = NaN; dHat = NaN;
    n = numel(mag);
    if j <= 1 || j >= n, return; end
    a = mag(j-1); b = mag(j); c = mag(j+1);
    if ~(b >= a && b >= c), return; end
    den = a - 2*b + c;
    if den >= -eps, return; end
    delta = 0.5 * (a - c) / den;
    if ~isfinite(delta) || abs(delta) > 0.5, return; end
    v = b - 0.25 * (a - c) * delta;
    if ~isfinite(v) || v < b, return; end
    vHat = v; dHat = delta;
end
