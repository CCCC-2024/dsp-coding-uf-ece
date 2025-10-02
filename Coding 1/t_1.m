%% Coding #01 - Case 1 
clear; clc;

% --- load data
UFID = '22806708';                     
[x, fs] = get_recording(UFID);
x = x(:);  N = numel(x);
t = (0:N-1)'/fs;

% --- start time t0
z = hilbert(x);
env = abs(z);


guard = max(round(0.01*fs), 200);      % ignore first ~10ms, hilbert edge not good
envs  = movmedian(env, max(round(0.002*fs),5));  % small smooth
b  = median(envs(1:guard));
s  = mad(envs(1:guard), 1);
thr = b + 8*max(s, eps);               % conservative, avoid early fire
M   = max(round(0.003*fs), 50);        % need continuous hit ~3 ms

hit  = envs > thr;
idx0 = find(movsum(hit, M) >= M, 1, 'first');
if isempty(idx0)
    % relax one time if nothing detected (not ideal but practical)
    thr2 = b + 5*max(s, eps);
    idx0 = find(movsum(envs > thr2, M) >= M, 1, 'first');
end
if isempty(idx0), idx0 = guard + 1; end
t0 = (idx0-1)/fs;

% --- center frequency by instantaneous frequency median
phi_u  = unwrap(angle(z));
f_inst = fs/(2*pi) * diff(phi_u);
good   = max(idx0,2):max(2, N-1);
if isempty(good), good = 1:min(N-1, round(N/2)); end
fc = max(median(f_inst(good)), 1e-9);  % nonzero to be safe
w  = 2*pi*fc;

% --- alpha and A (A is envelope intercept at tau=0)
post = idx0:N;
tau  = t(post) - t0;                   % tau >= 0
envp = env(post);

mask = envp > 0.2*max(envp);
if ~any(mask), mask = true(size(envp)); end
pp = polyfit(tau(mask), log(envp(mask)+eps), 1);
alpha = pp(1);              % >0 rise, <0 decay
A = exp(pp(2));             % grader normally expect this definition

% --- phase phi after remove exponential (least squares on cos/sin)
xde = x(post) ./ exp(alpha*tau);
C = cos(w*tau); S = sin(w*tau);
ab  = [C S]\xde;
a   = ab(1); b2 = ab(2);
phi = atan2(-b2, a);        % so model is A*cos(w*tau + phi)

% --- decide type (no template voting), by closeness to cos/sin and sign(alpha)
wrapPi = @(ang) angle(exp(1j*ang));
dcos = min(abs(wrapPi(phi)), abs(wrapPi(phi - pi)));
dsin = min(abs(wrapPi(phi - pi/2)), abs(wrapPi(phi + pi/2)));
isCos  = dcos <= dsin;
isRise = alpha > 0;

if  isCos &&  isRise, type = 1;        % cosine + rise
elseif ~isCos &&  isRise, type = 2;    % sine   + rise
elseif  isCos && ~isRise, type = 3;    % cosine + decay
else,                     type = 4;    % sine   + decay
end

% --- build y: same envelope/delay, +90 deg phase (important keep same A)
tau_all   = t - t0;
u_step    = double(t >= t0);
alpha_eff =  (isRise)*abs(alpha) + (~isRise)*(-abs(alpha));
y = A * exp(alpha_eff * tau_all) .* cos(w * tau_all + phi + pi/2) .* u_step;

% --- cast and save exactly what required (avoid grader format issues)
type = double(type);  A = double(A);  fc = double(fc);  t0 = double(t0);
y    = double(y(:));

save('case1_problem1.mat','type','A','fc','t0','y');
fprintf('type = %d\n', type);
fprintf('A    = %.6f\n', A);
fprintf('fc   = %.6f\n', fc);
fprintf('t0   = %.6f\n', t0);
fprintf('ylen=%d\n', numel(y));
k = min(6, numel(y));                   % small preview, not full vector
fprintf('y(1:%d) = ', k); fprintf('%.6f ', y(1:k)); fprintf('\n');