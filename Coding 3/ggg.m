case3_main(); 
z = get_trail('22806708');
function y = running_average_filter(x0, x1, x2)
% 3-point running average (pure real-time)
% no built-in filter, only simple arithmetic
    y = (x0 + x1 + x2) / 3;
end
function y = integrator_filter(x, y0, a2)
% First-order recursive smoother (like EMA)
% 0 < a2 < 1, bigger a2 means faster but more noise
    y = (1 - a2) * y0 + a2 * x;
end
function [y, s] = adaptive_filter(x, y0, s0, a3)
% Minimal adaptive tracker (single-parameter alpha-beta like)
% Predict with previous slope, then correct both by same gain
    y_pred = y0 + s0;
    e = x - y_pred;
    y = y_pred + a3 * e;
    s = s0 + a3 * e;
end
function case3_main()
% Case #3 driver: real-time loop, plots, save .mat
% Comments in simple English, little grammar mistake is ok.

    % ===== Load data =====
    z = get_trail('12345678'); % <-- replace by YOUR UFID

    N = numel(z);
    y_avg   = zeros(N,1);
    y_int   = zeros(N,1);
    y_adapt = zeros(N,1);

    % ----- hyper-parameters you will tune by plot -----
    a2 = 0.25;  % Problem 2 (0<a2<1)
    a3 = 0.30;  % Problem 3 (0<a3<1)

    % ===== init states =====
    % handle dropout: treat NaN as hold-last (ZOH). If first is NaN, set 0.
    sanitize = @(x,prev) ( (isnan(x) || isinf(x)) * prev + (~(isnan(x)||isinf(x))) * x );
    if isnan(z(1)) || isinf(z(1)), z(1) = 0; end

    % P1 memory
    x2 = z(1);  % x[n-2]
    x1 = z(1);  % x[n-1]

    % P2 state
    y_prev = z(1);  % can also start 0, but warm-start often looks nicer

    % P3 states
    y0 = z(1);
    s0 = 0;         % initial slope guess

    % ===== main real-time loop =====
    for n = 1:N
        x0 = z(n);
        if n > 1
            x0 = sanitize(z(n), z(n-1));
        else
            x0 = sanitize(z(n), 0);
        end

        % --- Problem 1: 3-point average ---
        if n == 1
            y_avg(n) = running_average_filter(x0, x0, x0);
        elseif n == 2
            y_avg(n) = running_average_filter(x0, x1, x1);
        else
            y_avg(n) = running_average_filter(x0, x1, x2);
        end

        % update history for next round
        x2 = x1; x1 = x0;

        % --- Problem 2: integrator-like recursive filter ---
        y_now = integrator_filter(x0, y_prev, a2);
        y_int(n) = y_now;
        y_prev = y_now;

        % --- Problem 3: adaptive filter with slope ---
        [y_new, s_new] = adaptive_filter(x0, y0, s0, a3);
        y_adapt(n) = y_new;
        y0 = y_new; s0 = s_new;
    end

    % ===== quick plots for tuning =====
    figure('Name','Case#3 Results');
    subplot(3,1,1); plot(z,'Color',[0.6 0.6 0.6]); hold on; plot(y_avg,'LineWidth',1.2);
    grid on; title('P1: Running Avg (gray=z)');
    legend({'z','y\_avg'});

    subplot(3,1,2); plot(z,'Color',[0.6 0.6 0.6]); hold on; plot(y_int,'LineWidth',1.2);
    grid on; title(sprintf('P2: Integrator (a2=%.2f)',a2));
    legend({'z','y\_int'});

    subplot(3,1,3); plot(z,'Color',[0.6 0.6 0.6]); hold on; plot(y_adapt,'LineWidth',1.2);
    grid on; title(sprintf('P3: Adaptive (a3=%.2f)',a3));
    legend({'z','y\_adapt'});

    % ===== save mat as required =====
    save('case3_results.mat', 'y_avg','y_int','y_adapt','a2','a3');
    fprintf('Saved to case3_results.mat (y_avg, y_int, y_adapt, a2, a3)\n');
end
