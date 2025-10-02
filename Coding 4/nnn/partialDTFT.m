function Zn = partialDTFT(x, freq, Fs)
% partialDTFT computes the partial DTFT magnitude of a signal.
%
% Inputs:
%   x    : Nx1 vector of audio samples. [cite: 71, 72]
%   freq : Kx1 vector of frequencies (Hz) at which to compute the DTFT. [cite: 73]
%   Fs   : Sampling frequency (Hz). [cite: 74]
%
% Output:
%   Zn   : Kx1 vector of DTFT magnitudes at the requested frequencies. [cite: 75]

% Ensure input 'x' is a column vector for consistency
x = x(:);

% Get the number of samples N and number of frequencies K
N = length(x);
K = length(freq);

% Initialize the output vector
Zn = zeros(K, 1);

% Create the time vector n from 0 to N-1
n = (0:N-1)';

% Loop through each requested frequency
for k = 1:K
    % Get the current frequency from the freq vector
    f_k = freq(k);
    
    % Calculate the complex exponential term for this frequency
    % The formula is e^(-j * 2 * pi * f_k * n / Fs)
    exp_term = exp(-1j * 2 * pi * f_k * n / Fs);
    
    % Compute the DTFT for this frequency by taking the dot product
    % of the signal x and the complex exponential term.
    dtft_val = x' * exp_term;
    
    % The magnitude of the result is the absolute value
    Zn(k) = abs(dtft_val);
end

end