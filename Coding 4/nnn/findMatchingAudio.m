function indexMatch = findMatchingAudio(X, Z, freq, Fs)
% findMatchingAudio identifies the audio sequence in X that best matches Z.
%
% Inputs:
%   X        : Nx10 matrix of known audio sequences. [cite: 94, 99]
%   Z        : Nx1 vector of the audio sequence to match. [cite: 95, 100]
%   freq     : Kx1 vector of frequencies (Hz). [cite: 96, 101]
%   Fs       : Sampling frequency (Hz). [cite: 97, 102]
%
% Output:
%   indexMatch : Scalar integer (1-10), the column in X that best matches Z. [cite: 98, 103, 104]

% First, compute the DTFT magnitudes for the noisy signal Z
Zn_noisy = partialDTFT(Z, freq, Fs);

% Get the number of candidate sequences (should be 10)
num_sequences = size(X, 2);

% Initialize a vector to store the similarity scores (errors)
errors = zeros(num_sequences, 1);

% Loop through each column (sequence) of X
for i = 1:num_sequences
    % Get the current audio sequence from X
    current_sequence = X(:, i);
    
    % Compute its DTFT magnitudes at the given frequencies
    Zn_candidate = partialDTFT(current_sequence, freq, Fs);
    
    % Calculate the Sum of Squared Differences (SSD) between the noisy
    % signal's magnitudes and the current candidate's magnitudes.
    % We normalize by the number of frequencies to make the error independent
    % of the number of notes checked.
    errors(i) = sum((Zn_noisy - Zn_candidate).^2);
end

% Find the index of the minimum error. This index corresponds to the
% best matching sequence.
[~, indexMatch] = min(errors);

end