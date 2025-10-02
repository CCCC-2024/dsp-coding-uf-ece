% run_case3.m — driver script (not for submission)
clear; clc; close all;

% ===== Parameters (you can tune visually) =====
a2 = 0.96;   % integrator filter param (as in full-score ref)
a3 = 0.98;   % adaptive filter param (as in full-score ref)

% ===== Load data =====
z = get_trail('22806708');   

N = numel(z);
y_avg   = zeros(N,1);
y_int   = zeros(N,1);
y_adapt = zeros(N,1);
s_state = zeros(N,1);        % slope state for adaptive

% ===== Real-time loop (edge cases same as ref) =====
for n = 1:N
    x0 = z(n);

    % P1: running average with safe history
    if n == 1
        x1 = 0; x2 = 0;
    elseif n == 2
        x1 = z(n-1); x2 = 0;
    else
        x1 = z(n-1); x2 = z(n-2);
    end
    y_avg(n) = running_average_filter(x0, x1, x2);

    % P2: integrator (y0 = previous output or 0 for first)
    if n == 1, y0_int = 0; else, y0_int = y_int(n-1); end
    y_int(n) = integrator_filter(x0, y0_int, a2);

    % P3: adaptive (y0/s0 = previous states or 0 for first)
    if n == 1, y0_ad = 0; s0_ad = 0;
    else,      y0_ad = y_adapt(n-1); s0_ad = s_state(n-1);
    end
    [y_adapt(n), s_state(n)] = adaptive_filter(x0, y0_ad, s0_ad, a3);
end

% ===== Plots =====
figure('Name','Case#3 Results');
subplot(3,1,1);
plot(z,'k.','MarkerSize',6); hold on; plot(y_avg,'b','LineWidth',1.3); grid on;
title('P1: Running Avg'); legend('z','y\_avg');

subplot(3,1,2);
plot(z,'k.','MarkerSize',6); hold on; plot(y_int,'r','LineWidth',1.3); grid on;
title(sprintf('P2: Integrator (a2=%.2f)',a2)); legend('z','y\_int');

subplot(3,1,3);
plot(z,'k.','MarkerSize',6); hold on; plot(y_adapt,'g','LineWidth',1.6); grid on;
title(sprintf('P3: Adaptive (a3=%.2f)',a3)); legend('z','y\_adapt');

% ===== Save required variables =====
save('case3_results.mat','y_avg','y_int','y_adapt','a2','a3');
fprintf('Saved to case3_results.mat (y_avg, y_int, y_adapt, a2, a3)\n');
