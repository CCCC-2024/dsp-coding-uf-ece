function Zn = partialDTFT(x, freq, Fs)
% partialDTFT - compute DTFT mag only on given freqs (Hz).
% only need magnitudes (unitless), phase not used here.
% Inputs:
%   X          : Nx10 matrix of known audio sequences
%   freq       : Kx1 vector of frequencies (Hz)
%   Fs         : Sampling frequency (Hz)
% Output:
%   Zn   : Kx1 magnitudes |X(w_k)| (no normalize)

    % quick checks (not very strict)
    if isempty(x) || isempty(freq) || isempty(Fs)
        error('Inputs x, freq, Fs must be provided.');
    end
    x    = x(:);          % make column
    freq = freq(:);       % make column

    N = length(x);
    n = (0:N-1);          % time index

    % DTFT at w_k = 2*pi*freq_k/Fs -> sum x[n]*exp(-j*w_k*n)
    W = exp(-1j*2*pi * (freq./Fs) * n);   % K-by-N
    Xw = W * x;                            % K-by-1 complex
    Zn = abs(Xw);                          % mag only, unitless
end
