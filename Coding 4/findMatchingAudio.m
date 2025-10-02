function indexMatch = findMatchingAudio(X, Z, freq, Fs)
% using partial DTFT mags on given freqs only (no full FFT).
% Idea: remove noise floor a bit, compress dyn range, focus on peaks,
% do zero-mean corr + peak overlap and fuse them.
%
% Inputs:
%   X          : Nx10 matrix of known audio sequences
%   Z          : Nx1 vector of audio sequence to match 
%   freq       : Kx1 vector of frequencies (Hz)
%   Fs         : Sampling frequency (Hz)
% Out:
%   indexMatch : scalar integer, the column in X that best matches Z

    % ---- operator for DTFT samples ----
    Z = Z(:);
    N = numel(Z);
    n = (0:N-1);
    W = exp(-1j*2*pi * (freq(:)./Fs) * n);    % K x N

    % ---- magnitudes on those K bins ----
    Mz = abs(W * Z);          % K x 1
    MX = abs(W * X);          % K x M

    % ---- remove floor (median as rough floor) ----
    Mz = max(Mz - median(Mz), 0);
    MX = max(MX - median(MX,1), 0);

    % ---- compress big spikes (more stable) ----
    Mz = log1p(Mz);
    MX = log1p(MX);

    % ---- focus on top-K peaks from Z (not all bins) ----
    Kpeaks = min(7, numel(Mz));           % 5~9 also ok
    [~, zOrd] = maxk(Mz, Kpeaks);
    mask = false(size(Mz)); mask(zOrd) = true;

    z_k = Mz(mask);        % Kp x 1
    X_k = MX(mask, :);     % Kp x M

    % ---- zero-mean corr (remove DC/baseline drift) ----
    z_k_zm = z_k - mean(z_k);
    Mz_zm  = Mz  - mean(Mz);
    X_k_zm = X_k - mean(X_k,1);
    MX_zm  = MX  - mean(MX,1);

    % (a) corr on top-K
    corr_topk = (z_k_zm.' * X_k_zm) ./ ((norm(z_k_zm)+eps) * (vecnorm(X_k_zm)+eps));
    % (b) corr on all bins
    corr_all  = (Mz_zm.'  * MX_zm ) ./ ((norm(Mz_zm)+eps)  * (vecnorm(MX_zm)+eps));

    % (c) peak-set overlap (how many peaks same place)
    overlap = zeros(1, size(MX,2));
    for i = 1:size(MX,2)
        [~, xiOrd] = maxk(MX(:,i), Kpeaks);
        overlap(i) = numel(intersect(zOrd, xiOrd)) / Kpeaks;   % 0..1
    end

    % ---- fuse scores (weights are simple, works fine) ----
    w1 = 0.5; w2 = 0.3; w3 = 0.2;
    score = w1*corr_topk + w2*corr_all + w3*overlap;

    [~, indexMatch] = max(score);  % return 1..M
end
