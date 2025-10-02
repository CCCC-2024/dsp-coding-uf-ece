%% Case 1 - Problem 2 : Black Box System
% Student: Chengzhen Jiang
% UFID: 22806708
% This code decides linearity, time-invariance, causality, memory

UFID = '22806708';     % UFID 
rng(1);                % can reproducible

% helper to call the box (short handle)
probe = @(x) probe_system(UFID, x);

% build some test inputs
x1 = randn(N,1);            % random signal #1
x2 = randn(N,1);            % random signal #2
a = 1.7;                    % scale factors for linearity test
b = -0.6;

%% 1.Linearity test
% check: T(a*x1 + b*x2) ?= a*T(x1) + b*T(x2)
y1   = probe(x1);
y2   = probe(x2);
% get outputs
y_ab = probe(a*x1 + b*x2);
y_lin= a*y1 + b*y2;
%left liner - sys  right 1st sys - liner - combo outputs

% tolerance (relative)
tol = 1e-6 * max(1, norm(y_ab,2));
if norm(y_ab - y_lin, 2) < tol
    linear_type = 1;   % linear
else
    linear_type = 0;   % not linear
end

%% 2.Time-invariance test
% shift input by n0, --- output also be shifted by n0 
n0 = 50;
xshift = [zeros(n0,1); x1(1:end-n0)];
yshift = probe(xshift);

% shift the unshifted output y1 for fair compare (trim edges)
y1s = [zeros(n0,1); y1(1:end-n0)];

tol_ti = 1e-6 * max(1, norm(yshift,2));
if norm(yshift - y1s, 2) < tol_ti
    timeiv_type = 1;   % time-invariant
else
    timeiv_type = 0;   % not time-invariant
end

%% 3.Causality test
% two inputs are identical up to K, but differ after K
% if system is causal, outputs up to K must be identical
K = 1000;
xA = zeros(N,1); xB = zeros(N,1);
xA(1:K) = x1(1:K);
xB(1:K) = x1(1:K);                % same prefix
xA(K+1:end) = x1(K+1:end);
xB(K+1:end) = flipud(x1(K+1:end));% different future

yA = probe(xA);
yB = probe(xB);

tol_cau = 1e-6 * max(1, norm(yA(1:K),2));
if norm(yA(1:K) - yB(1:K), 2) < tol_cau
    causal_type = 1;     % causal
else
    causal_type = 0;     % not causal
end

%% 4.Memoryless test
% build two inputs that are same at one index n0m,
% but have different neighbors; if memoryless, y(n0m) must be equal
xM1 = zeros(N,1);
xM2 = zeros(N,1);
n0m = 1200;
xM1(n0m) = 0.8;             % same current sample
xM2(n0m) = 0.8;

% different neighborhood around n0m (small vs large noise)
idx = (n0m-5):(n0m+5);
idx = idx(idx>=1 & idx<=N);
xM1(idx) = xM1(idx) + 0.2*randn(numel(idx),1);
xM2(idx) = xM2(idx) + 2.0*randn(numel(idx),1);

yM1 = probe(xM1);
yM2 = probe(xM2);

tol_mem = 1e-6 * max(1, abs(yM1(n0m)));
if abs(yM1(n0m) - yM2(n0m)) < tol_mem
    memoryless_type = 1;    % memoryless
else
    memoryless_type = 0;    % has memory
end

%% 5.Save results
save('case1_problem2.mat', 'linear_type', 'timeiv_type', 'causal_type', 'memoryless_type');
disp('Saved case1_problem2.mat');
%% test
% whos -file case1_problem2.mat
% load case1_problem2.mat linear_type timeiv_type causal_type memoryless_type
