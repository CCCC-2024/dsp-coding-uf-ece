% =========================================================================
% Main Script for Case File #3: The Trail
% =========================================================================
clear;
clc;
close all;

%% 1. Load Data
% Replace with your actual UFID to get your mission data
ufid = '22806708'; 
z = get_trail(ufid);

%% 2. Initialization
% --- Filter Parameters ---
% These values are chosen by "guess and check". 
% Good starting points are often close to 1 for smoothin.
% You can tune these after seeing the plots.
a2 = 0.95; % For integrator_filter (0 < a2 < 1)
a3 = 0.9;  % For adaptive_filter (0 < a3 < 1)

% --- Storage Arrays ---
% Get the length of the signal
N = length(z);

% Initialize output arrays with zeros
y_avg = zeros(1, N);
y_int = zeros(1, N);
y_adapt = zeros(1, N);
s_adapt = zeros(1, N); % To store the slope from the adaptive filter

%% 3. Real-Time Filtering Loop
% We start at n=3 because the running average filter needs 3 initial points.
for n = 3:N
    % --- Problem 1: Running Average Filter ---
    y_avg(n) = running_average_filter(z(n), z(n-1), z(n-2));
    
    % --- Problem 2: Integrator-Type Filter ---
    % The previous output y_int(n-1) is used as an input
    y_int(n) = integrator_filter(z(n), y_int(n-1), a2);
    
    % --- Problem 3: Adaptive Filter ---
    % The previous output and slope are used as inputs
    [y_adapt(n), s_adapt(n)] = adaptive_filter(z(n), y_adapt(n-1), s_adapt(n-1), a3);
end

%% 4. Visualization (Recommended)
figure;
hold on;
plot(z, 'k.', 'DisplayName', 'Noisy Observations (z)'); % Plot original signal as black dots
plot(y_avg, 'b', 'LineWidth', 2, 'DisplayName', 'Running Average');
plot(y_int, 'r', 'LineWidth', 2, 'DisplayName', 'Integrator');
plot(y_adapt, 'g', 'LineWidth', 2, 'DisplayName', 'Adaptive');
hold off;

title('Filter Performance Comparison');
xlabel('Sample Number (n)');
ylabel('Signal Value');
legend;
grid on;

%% 5. Save Results for Submission
% This creates a .mat file with the required variables.
save('case3_results.mat', 'y_avg', 'y_int', 'y_adapt', 'a2', 'a3');

disp('Processing complete. Results saved to case3_results.mat');