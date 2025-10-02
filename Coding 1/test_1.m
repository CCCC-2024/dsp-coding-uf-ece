%% Part 1: Setup and load the data
clear; close all; clc;

% --- My Information ---
ufid = '22806708';

% --- Get The Signal ---
[x, fs] = get_recording(ufid);
n_samples = length(x);
t = (0:n_samples-1) / fs; % make time axis

%% Part 2: Visualize for Analysis - Time Domain
% plot is still necessary for check our code result, and for judge the type
figure('Name', 'Time Waveform (for check and judge)');
plot(t, x);
grid on;
title('The Intercepted Signal (Time-Domain Waveform)');
xlabel('Time (sec)');
ylabel('Amplitude');
zoom on;

%% Part 3: Visualize for Analysis - Frequency Domain
X_fft = fft(x);
P2 = abs(X_fft/n_samples);
P1 = P2(1:floor(n_samples/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:floor(n_samples/2))/n_samples;

figure('Name', 'Frequency Spectrum (for check and judge)');
plot(f, P1);
grid on;
title('Signal Amplitude Spectrum (Frequency)');
xlabel('Frequency (Hz)');
ylabel('Amplitude |P1(f)|');
zoom on;

%% Part 4: Auto Parameter Estimate and Manual Confirm
% Follow your good idea, we let computer find the exact parameter

% --- Calculate the t0 ---
threshold = 0.01 * max(abs(x)); % set a threshold for avoid noise
n0 = find(abs(x) > threshold, 1, 'first'); % find the start sample point n0
t0 = (n0 - 1) / fs; % calculate the exact time t0

% --- Aalculate the fc ---
[~, peak_index] = max(P1); % find the peak index in spectrum
fc = f(peak_index); % get the exact frequency from f vector

% --- Calculate the A ---
% For signal not decay, max amplitude is at end.
% max(abs(x)) is a good estimate.
A = max(abs(x));

% --- Manual confirm for type ---
% To judge if signal is rise/decay, sine/cosine, is more reliable to see the plot shape.
% This is the only parameter I need fill in by self from the plot.
% From our last analysis, this signal is Type 1 (rise cosine).
type = 1; % I must confirm this value (1, 2, 3, or 4) by my final judge

% Print the result in command window, for my check
fprintf('Type is: %d \n', type);
fprintf('Amplitude (A)   : %.4f\n', A);
fprintf('Frequency (fc)  : %.2f Hz\n', fc);
fprintf('Delay (t0)      : %.6f s\n', t0);
fprintf('----------------------------------\n');


%% Part 5: Reconstruct The Signal and Save It
y = zeros(size(t));         % init the y vector
indices = t >= t0;          % find the time point after delay

% use the type to choose correct formula for reconstruct signal y (+90 degree phase)
if type == 1 % original is rise cosine -> y is negative rise sine
    y(indices) = -A * sin(2*pi*fc*(t(indices)-t0)) .* (1+exp(0.5*pi*(t(indices)-t0)));
elseif type == 2 % original is rise sine -> y is rise cosine
    y(indices) = A * cos(2*pi*fc*(t(indices)-t0)) .* (1+exp(0.5*pi*(t(indices)-t0)));
elseif type == 3 % original is decay cosine -> y is negative decay sine
    y(indices) = -A * sin(2*pi*fc*(t(indices)-t0)) .* exp(-9*pi*(t(indices)-t0));
elseif type == 4 % original is decay sine -> y is decay cosine
    y(indices) = A * cos(2*pi*fc*(t(indices)-t0)) .* exp(-9*pi*(t(indices)-t0));
else
    error('Your type is not valid, must be 1, 2, 3, or 4');
end

% --- Save result as homework requirement ---
save('case1_problem1.mat', 'type', 'A', 'fc', 't0', 'y');

disp(' ');
disp('Finish. The final file case1_problem1.mat is generated.');