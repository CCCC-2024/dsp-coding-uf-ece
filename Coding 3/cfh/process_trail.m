% Main script to process the signal trail from Case File #3 (Corrected Version)

clear; clc; close all;

% --- Parameters ---
% These values are tuned by visual inspection of the plots.
% Higher values lead to more smoothing but increase lag.
% Lower values track the signal more closely but are noisier.
a2 = 0.96; % Parameter for the integrator filter
a3 = 0.98; % Parameter for the adaptive filter


% --- Load Data ---
try
    z = get_trail('23686378');
catch ME
    error('Please ensure get_trail.p is in the MATLAB path or current directory.');
end

% --- Initialization ---
N = length(z);
y_avg = zeros(size(z));
y_int = zeros(size(z));
y_adapt = zeros(size(z));

% State variable for the adaptive filter's slope
s_adapt_state = zeros(size(z)); 

% --- Real-Time Filtering Loop ---
% This loop processes one sample at a time, as required.

for n = 1:N
    % Current input sample
    x_current = z(n);

    % 1. Running Average Filter (Corrected Edge Case Handling)
    if n == 1
        x1 = 0;
        x2 = 0;
    elseif n == 2
        x1 = z(n-1); % Safely access z(1)
        x2 = 0;
    else
        x1 = z(n-1);
        x2 = z(n-2);
    end
    y_avg(n) = running_average_filter(x_current, x1, x2);

    % 2. Integrator Filter (Corrected Edge Case Handling)
    if n == 1
        y0_int = 0; % Previous output is 0 for the first sample
    else
        y0_int = y_int(n-1); % Safely access previous output
    end
    y_int(n) = integrator_filter(x_current, y0_int, a2);

    % 3. Adaptive Filter (Corrected Edge Case Handling)
    if n == 1
        y0_adapt = 0; % Previous output is 0 for the first sample
        s0_adapt = 0; % Previous slope is 0 for the first sample
    else
        y0_adapt = y_adapt(n-1);     % Safely access previous output
        s0_adapt = s_adapt_state(n-1); % Safely access previous slope
    end
    [y_adapt(n), s_adapt_state(n)] = adaptive_filter(x_current, y0_adapt, s0_adapt, a3);
end


% --- Visualization ---
figure('Name', 'Signal Trail Filtering Results', 'NumberTitle', 'off');
t = 1:N;
plot(t, z, 'k.', 'MarkerSize', 8, 'DisplayName', 'Noisy Measurements (z)');
hold on;
plot(t, y_avg, 'b-', 'LineWidth', 1.5, 'DisplayName', 'Running Average');
plot(t, y_int, 'r-', 'LineWidth', 1.5, 'DisplayName', sprintf('Integrator (a_2=%.2f)', a2));
plot(t, y_adapt, 'g-', 'LineWidth', 2, 'DisplayName', sprintf('Adaptive (a_3=%.2f)', a3));
hold off;

grid on;
title('Real-Time Filtering of Suspect''s Signal Trail');
xlabel('Time Step (n)');
ylabel('Position');
legend('show', 'Location', 'northwest');
set(gca, 'FontSize', 12);


% --- Save Results ---
save('case3_results.mat', 'y_avg', 'y_int', 'y_adapt', 'a2', 'a3');

fprintf('Processing complete.\n');
fprintf('Results saved to case3_results.mat\n');