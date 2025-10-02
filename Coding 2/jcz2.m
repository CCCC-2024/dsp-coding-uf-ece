
% coding2_case2.m
% Author: Chengzhen Jiang (UF ECE)
% Course: DSP Coding #02 — Convolutions and Impulse Responses
% Note: comments are simple on purpose; tiny grammar mistakes are ok.

clear; clc; close all; rng(42);

%% ===== Load mission data =====
% Put get_surveillance.p and the unzipped audio/ folder in this same path.
% TODO: replace with your real UFID digits as a string, no spaces.
UFID = '22806708';
[z1, z2, z3, h1, h2, h3, fs] = get_surveillance(UFID);

%% ===== Problem 1: A1 and delay1 (samples) in z1 for template h1 =====
[A1, delay1] = est_A_delay_conv(z1, h1);
save('case2_problem1.mat', 'A1', 'delay1');
fprintf('P1 -> A1 = %.6f, delay1 = %d samples\n', A1, delay1);

%% ===== Problem 2: A2 and delay2 (samples) in z2 for template h2 (noisy) =====
% robust delay via normalized cross-corr (NCC), then LS amplitude
[A2, delay2] = est_A_delay_ncc(z2, h2);
save('case2_problem2.mat', 'A2', 'delay2');
fprintf('P2 -> A2 = %.6f, delay2 = %d samples\n', A2, delay2);

%% ===== Problem 3 (revised, stricter; fewer false hits) =====
M3 = numel(h3);

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

save('case2_problem3.mat','signalCount','delay3');
fprintf('P3 -> signalCount = %d (thr=%.3f, dist=%d)\n', ...
        signalCount, minHeight, minDist);

%% ===== (Optional) quick plots for check; set to false for clean run =====
if false
    figure; plot(abs(rho3)); grid on; xlabel('start index (samples)'); ylabel('|rho|');
    title('NCC for z3 vs h3'); hold on; plot(locs, abs(pks), 'o'); hold off;
end

%% ===== Helpers (tiny, keep simple) =====
function [A, delay] = est_A_delay_conv(z, h)
% Find best alignment by matched filter conv(z, flip(h)).
% Index map: peak at start_index + M, so delay = idx - M (0-based)
    M = numel(h);
    r = conv(z, fliplr(h));                % matched filter output
    [~, idx] = max(abs(r));                % allow negative scale
    delay = idx - M;                       % 0-based delay in samples
    % LS amplitude on the aligned window (keeps sign)
    s = delay + (1:M);
    s = max(1, s(1)) : min(numel(z), s(end));
    hz = z(s); htrim = h(1:numel(hz));     % guard edges just in case
    A = (htrim(:)' * hz(:)) / max((htrim(:)' * htrim(:)), eps);
end

function [A, delay] = est_A_delay_ncc(z, h)
% Delay via normalized cross-corr (one value per valid start).
% Then amplitude via LS projection at that delay.
    [rho, ~] = ncc_valid(z, h);
    [~, loc] = max(abs(rho));
    delay = loc - 1;                       % 0-based
    M = numel(h);
    s = delay + (1:M);
    hz = z(s);
    A = (h(:)' * hz(:)) / max((h(:)' * h(:)), eps);
end

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

% ===== Fallback peak picker (not used): simple greedy without findpeaks =====
% function locs = pick_peaks_greedy(v, minDist, thr)
%     v = v(:)'; locs = [];
%     i = 1; N = numel(v);
%     while i <= N
%         if v(i) >= thr
%             winEnd = min(N, i+minDist-1);
%             [~, k] = max(v(i:winEnd));
%             locs(end+1) = i + k - 1; %#ok<AGROW>
%             i = winEnd + 1;  % skip
%         else
%             i = i + 1;
%         end
%     end
% end
