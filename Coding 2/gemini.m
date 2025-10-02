%% Clean up the environment
clear;
clc;
close all;

%% Setup - Don't forget to change your UFID
% Make sure get_surveillance.p and the audio folder are in the same directory
ufid = '22806708'; % !!! REPLACE THIS WITH YOUR UFID !!!
[z1, z2, z3, h1, h2, h3, fs] = get_surveillance(ufid);


%% Problem 1: Amplitude & Delay in z1
% We use cross-correlation to find where h1 is inside z1.
% The peak of the correlation tells us the position (delay) and its
% strength (amplitude).

% --- Calculate cross-correlation ---
% 'lags' vector tells us the sample shift for each correlation value
[corr_z1h1, lags1] = xcorr(z1, h1);

% --- Find the delay ---
% Find the maximum value in the correlation result.
% 'max_idx' is the index where the peak occurs.
[~, max_idx1] = max(corr_z1h1);
% The delay is the lag at that peak index.
delay1 = lags1(max_idx1);

% --- Find the amplitude ---
% The amplitude A1 is the peak correlation value divided by the energy of h1.
% Energy is just the sum of squares of the signal.
energy_h1 = sum(h1.^2);
max_corr_1 = corr_z1h1(max_idx1);
A1 = max_corr_1 / energy_h1;

% --- Save the result ---
save('case2_problem1.mat', 'A1', 'delay1');

fprintf('Problem 1 Results:\n');
fprintf('  A1 = %f\n', A1);
fprintf('  delay1 = %d samples\n\n', delay1);
%% Problem 2: Amplitude & Delay in z2 (with noise)
% The method is exactly the same as Problem 1.
% Cross-correlation is great because it can find signals even when there's
% a lot of noise. The noise doesn't correlate with our template h2, so it
% mostly cancels out.

% --- Calculate cross-correlation ---
[corr_z2h2, lags2] = xcorr(z2, h2);

% --- Find the delay ---
[~, max_idx2] = max(corr_z2h2);
delay2 = lags2(max_idx2);

% --- Find the amplitude ---
energy_h2 = sum(h2.^2);
max_corr_2 = corr_z2h2(max_idx2);
A2 = max_corr_2 / energy_h2;

% --- Save the result ---
save('case2_problem2.mat', 'A2', 'delay2');

fprintf('Problem 2 Results:\n');
fprintf('  A2 = %f\n', A2);
fprintf('  delay2 = %d samples\n\n', delay2);
%% Problem 3: Counting Occurrences in z3
M3 = numel(h3);
function [rho, idx0] = ncc_valid(z, h)
% Normalized cross-correlation for every valid start index.
% rho(k) = <h, z(k:k+M-1)> / (||h|| * ||z(k:k+M-1)||)
    z = z(:).'; h = h(:).';              % row
    M = numel(h);
    Hn = norm(h);
    num = conv(z, fliplr(h), 'valid');   % dot for each start
    energy = conv(z.^2, ones(1,M), 'valid');
    den = Hn * sqrt(max(energy, eps));
    rho = num ./ den;
    idx0 = 0:(numel(z)-M);               % 0-based start indices
end
% signed NCC (not abs). if template may invert, run once with -h3 as well.
[rho3, ~] = ncc_valid(z3, h3);     % one value per valid start

% robust, adaptive threshold using median + MAD (works OK in noise)
base = abs(rho3);
mu  = median(base);
sig = 1.4826 * median(abs(base - mu));     % robust std approx
minHeight = min(0.95, max(0.60, mu + 4*sig));  % push >=0.60; cap at 0.95

% non-maximum suppression window ~= template length
minDist = max(1, round(M3));   % stricter than 0.8*M3

% also require prominence, so shoulders are not counted
[pks, locs] = findpeaks(rho3, ...
    'MinPeakDistance',   minDist, ...
    'MinPeakHeight',     minHeight, ...
    'MinPeakProminence', 0.08);

delay3 = (locs - 1).';          % 0-based start indices
signalCount = numel(delay3);
% --- Save the result ---
save('case2_problem3.mat', 'signalCount', 'delay3');

fprintf('Problem 3 Results:\n');
fprintf('  Found %d occurrences of the signal.\n', signalCount);
fprintf('  Delays are at samples:'); fprintf(' %d', delay3); fprintf('\n'); 

% Optional: Plot the correlation to see the peaks we found. It's a good
% way to check if our threshold and distance settings make sense.
