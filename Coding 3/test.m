% verify_case3.m  — checks for y_avg, y_int, y_adapt
clear; clc;

% ==== 0) Load your results and raw z ====
S = load('case3_results.mat');      % must contain y_avg, y_int, y_adapt, a2, a3
z = get_trail('22806708');          % <-- use the same UFID as run_case3

fprintf('--- UNIT TESTS ---\n');

% ==== 1) P1 unit test: 3-point average on simple seq ====
x = [1; 2; 4; 8];
y_exp = zeros(4,1);
for n=1:4
    if n==1, y_exp(n) = (x(1)+x(1)+x(1))/3;
    elseif n==2, y_exp(n) = (x(2)+x(1)+x(1))/3;
    else, y_exp(n) = (x(n)+x(n-1)+x(n-2))/3;
    end
end
y_got = zeros(4,1);
x2=x(1); x1=x(1);
for n=1:4
    x0=x(n);
    if n==1
        y_got(n)=running_average_filter(x0,x0,x0);
    elseif n==2
        y_got(n)=running_average_filter(x0,x1,x1);
    else
        y_got(n)=running_average_filter(x0,x1,x2);
    end
    x2=x1; x1=x0;
end
fprintf('P1 unit max abs err: %.3g (expect 0)\n', max(abs(y_got - y_exp)));

% ==== 2) P2 unit test: EMA step closed-form ====
a2u = 0.3; N = 12;
x = ones(N,1); y_prev = 0; y2 = zeros(N,1);
for n=1:N
    y2(n) = integrator_filter(x(n), y_prev, a2u);
    y_prev = y2(n);
end
y_true = 1 - (1-a2u).^(1:N)';   % from zero init
fprintf('P2 unit max abs err: %.3g (expect ~0)\n', max(abs(y2 - y_true)));

% ==== 3) P3 unit test: ramp slope recovery ====
a3u = 0.3; N = 200; m = 0.5; b = 2;
x = (0:N-1)'*m + b;
y=0; s=0; Y=zeros(N,1); Slope=zeros(N,1);
for n=1:N
    [y,s] = adaptive_filter(x(n), y, s, a3u);
    Y(n) = y; Slope(n) = s;
end
est_slope = mean(Slope(end-50:end));   % last 50 samples
fprintf('P3 unit slope est: %.3f (true %.3f)\n', est_slope, m);

% ==== 4) Recompute on your z and compare to saved ====
fprintf('\n--- RECOMPUTE & COMPARE WITH SAVED RESULTS ---\n');
N = numel(z);
y_avg2=zeros(N,1); y_int2=zeros(N,1); y_adapt2=zeros(N,1);

sanitize = @(x,prev) ( (isnan(x)||isinf(x)) * prev + (~(isnan(x)||isinf(x))) * x );
if isnan(z(1))||isinf(z(1)), z(1)=0; end

x2=z(1); x1=z(1);          % P1 states
y_prev=z(1);               % P2
y0=z(1); s0=0;             % P3

for n=1:N
    x0 = z(n);
    if n>1, x0 = sanitize(z(n), z(n-1)); else, x0 = sanitize(z(n), 0); end

    % P1
    if n==1
        y_avg2(n)=running_average_filter(x0,x0,x0);
    elseif n==2
        y_avg2(n)=running_average_filter(x0,x1,x1);
    else
        y_avg2(n)=running_average_filter(x0,x1,x2);
    end
    x2=x1; x1=x0;

    % P2
    y_now = integrator_filter(x0, y_prev, S.a2);
    y_int2(n)=y_now; y_prev=y_now;

    % P3
    [y_new,s_new]=adaptive_filter(x0,y0,s0,S.a3);
    y_adapt2(n)=y_new; y0=y_new; s0=s_new;
end

fprintf('max|y_{avg}   - recompute| : %.3g\n', max(abs(S.y_avg   - y_avg2)));
fprintf('max|y_{int}   - recompute| : %.3g\n', max(abs(S.y_int   - y_int2)));
fprintf('max|y_{adapt} - recompute| : %.3g\n', max(abs(S.y_adapt - y_adapt2)));

% ==== 5) Invariants & quality metrics ====
fprintf('\n--- INVARIANTS ---\n');
% P1 bounded by last-three window
viol = 0;
for n=3:N
    mn = min([z(n), z(n-1), z(n-2)]);
    mx = max([z(n), z(n-1), z(n-2)]);
    if S.y_avg(n) < mn - 1e-9 || S.y_avg(n) > mx + 1e-9
        fprintf('P1 violate at n=%d: y=%.3g not in [%.3g, %.3g]\n', n, S.y_avg(n), mn, mx);
        viol = viol+1; if viol>5, break; end
    end
end
if viol==0, fprintf('P1 ok\n'); end

% P2 step <= gap and toward x
viol=0; yprev=S.y_int(1);
for n=2:N
    step = S.y_int(n) - yprev;
    gap  = z(n) - yprev;
    if step*gap < -1e-9 || abs(step) - abs(gap) > 1e-9
        fprintf('P2 violate at n=%d (step/gap)\n', n);
        viol=viol+1; if viol>5, break; end
    end
    yprev = S.y_int(n);
end
if viol==0, fprintf('P2 ok\n'); end

% P3 correction toward x and bounded
viol=0; yprev=y_adapt2(1); sprev=0;
for n=2:N
    ypred = yprev + sprev;
    e = z(n) - ypred;
    ycorr = ypred + S.a3*e;
    if (ycorr-ypred)*e < -1e-9 || abs(ycorr-ypred) - abs(e) > 1e-9
        fprintf('P3 violate at n=%d (correction)\n', n);
        viol=viol+1; if viol>5, break; end
    end
    sprev = sprev + S.a3*e;  % follow same update
    yprev = ycorr;
end
if viol==0, fprintf('P3 ok\n'); end

% ==== 6) Quality metrics and a zoom plot ====
fprintf('\n--- QUALITY METRICS ---\n');
print_metrics(z, S.y_avg,   'y_{avg}');
print_metrics(z, S.y_int,   'y_{int}');
print_metrics(z, S.y_adapt, 'y_{adapt}');

figure('Name','Zoom-in (first 200 samples)');
idx = 1:min(200, N);
plot(z(idx), 'Color', [0.7 0.7 0.7]); hold on;
plot(S.y_avg(idx), 'LineWidth',1.1);
plot(S.y_int(idx), 'LineWidth',1.1);
plot(S.y_adapt(idx), 'LineWidth',1.1);
grid on; legend('z','y\_avg','y\_int','y\_adapt');
title('Zoom-in: first 200 samples');

% ---------- local function at END OF SCRIPT ----------
function print_metrics(z, y, name)
    zc = z - mean(z); yc = y - mean(y);
    MAXLAG = 30;
    [c, lags] = xcorr(zc, yc, MAXLAG, 'coeff');
    [~,k] = max(c);
    lag = lags(k);                % >0 means y lags z by 'lag' samples
    rv  = var(z - y);
    fprintf('%s: res_var=%.4g, xcorr_peak_lag=%d samples\n', name, rv, lag);
end

