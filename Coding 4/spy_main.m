% spy_main.m  -- Minimal runner for Coding #04
clear; clc; close all;

% ---- 1) load case file ----
UFID = '22806708';
[X, zn, freq, Fs] = get_spy_audio(UFID);

% ---- 2) compute match ----
indexMatch = findMatchingAudio(X, zn, freq, Fs);

% ---- 3) save deliverable .mat ----
save('indexMatch.mat', 'indexMatch');

% ---- 4) quick visual check (optional but helpful) ----
%   Overlay the partial DTFT magnitudes of the noisy signal and the chosen column.
Mz = partialDTFT(zn, freq, Fs);
Mx_best = partialDTFT(X(:, indexMatch), freq, Fs);

figure('Color','w','Name','Partial DTFT magnitude check');
subplot(2,1,1);
stem(freq, Mz, 'filled'); grid on;
xlabel('Frequency (Hz)'); ylabel('|Z(\omega)|'); title('Noisy audio (zn) magnitude at target freqs');

subplot(2,1,2);
stem(freq, Mx_best, 'filled'); grid on;
xlabel('Frequency (Hz)'); ylabel('|X_i(\omega)|');
title(sprintf('Best match column = %d', indexMatch));

fprintf('\n=> indexMatch = %d (saved to indexMatch.mat)\n', indexMatch);
