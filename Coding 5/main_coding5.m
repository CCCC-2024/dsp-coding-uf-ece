% main_coding5.m
% Coding #05 – Frequency/Magnitude/Phase & Filter Properties
% UFID 固定：22806708
% 运行后自动：判定P1、拟合P2、保存 case5_results.mat、生成图到 /plots

clear; clc; close all;
addpath(genpath('src'));

ufid_str = "22806708"; 

if ~exist('plots','dir'); mkdir plots; end

%% ---------- Problem 1: Filter Identification ----------
% 给定接口：返回 (b,a)
[b1, a1] = get_filter_info(char(ufid_str));

% 基本性质
[z1, p1, ~] = tf2zpk(b1, a1);
stable = all(abs(p1) < 1 - 1e-9);                   % 稳定性
is_fir  = numel(a1)==1 || all(abs(a1(2:end))<1e-12);
linph   = false;
if is_fir
    linph = is_linear_phase_fir(b1);
end
minph   = is_minimum_phase(z1);                     % 最小相位（所有零点在单位圆内）
invertible = minph && all(abs(abs(z1)-1) > 1e-6);   % 无单位圆零点，且最小相位

% 类型判定（低/高/带通/带阻/全通）
[wgrid, Hgrid] = mag_resp(b1, a1, 4096);
filter_type_id = classify_filter_type(wgrid, abs(Hgrid)); % 1 LP / 2 HP / 3 AP / 4 BP / 5 BS

% 六个标量
filter_type          = filter_type_id;
stability_type       = double(stable);              % 1 稳定 / 0 不稳定
fir_type             = double(is_fir);              % 1 FIR / 0 IIR
linear_phase_type    = double(linph);               % 1 线性相位 / 0 非
invertible_type      = double(invertible);          % 1 可逆   / 0 不可逆
minimum_phase_type   = double(minph);               % 1 最小相位 / 0 非

% 可视化（自检）
figure; zplane_custom(z1,p1);
title('P1 z-plane'); saveas(gcf, fullfile('plots','P1_zplane.png'));

figure; plot(wgrid, 20*log10(max(abs(Hgrid),1e-12))); grid on;
xlabel('\omega (rad/sample)'); ylabel('|H| (dB)'); title('P1 Magnitude');
saveas(gcf, fullfile('plots','P1_mag.png'));

% ---------- Problem 2: Reconstruct Bandpass ----------
[y2, x2, Y2, X2, w2] = get_filtered_audio(char(ufid_str));

% 目标幅度：D = |Y|/|X|
D_full = abs(Y2) ./ max(abs(X2), 1e-12);
D_full = D_full ./ max(D_full + 1e-12);     % 归一化

% 统一到单侧 [0, pi]：如果有负频，只取 w>=0 的一半
if any(w2 < 0)
    mask = (w2 >= 0);
    w = w2(mask);
    D = D_full(mask);
else
    w = w2;
    D = D_full;
end

% 把端点夹到 (1e-3, pi-1e-3)
w = max(min(w, pi-1e-3), 1e-3);

% 中心角频率 wc：取峰值所在位置（规范到 [-pi, pi]）
[~, idx_pk] = max(D);
wc = helper_norm_angle(w(idx_pk));

% 用低阶 IIR 带通拟合
orders = 2:2:10;
[b2, a2, best_err, best_ord] = fit_bandpass(w, D, orders);

% 拟合可视化（注意 freqz 用同一侧 w）
Hfit = abs(freqz(b2, a2, w));
figure;
plot(w, D, 'LineWidth',1); hold on;
plot(w, Hfit / max(Hfit + 1e-12), 'LineWidth',1); % 同样归一化作“形状”对比
grid on; xlabel('\omega (rad/sample)'); ylabel('Magnitude (norm.)');
legend('Target |Y|/|X|','Designed |H|');
title(sprintf('P2 Fit (best order = %d, err=%.3g)', best_ord, best_err));
saveas(gcf, fullfile('plots','P2_fit_mag.png'));

[z2, p2, ~] = tf2zpk(b2, a2);
figure; zplane_custom(z2,p2);
title('P2 z-plane'); saveas(gcf, fullfile('plots','P2_zplane.png'));

% 时域自检
y2_hat = filter(b2, a2, x2);
mse_t  = mean((y2(:)-y2_hat(:)).^2);
fprintf('P2: time-domain MSE = %.4g\n', mse_t);


%% ---------- 导出唯一 .mat ----------
save('case5_results.mat', ...
    'filter_type','stability_type','fir_type','linear_phase_type', ...
    'invertible_type','minimum_phase_type', ...          % P1(6标量)
    'b2','a2','wc');                                     % P2(b,a,wc)

% 注：要求 P2 变量名是 b,a,wc。为避免覆盖 P1 的 b1,a1，上面临时命名为 b2,a2；
b = b2; a = a2;           
save('case5_results.mat', 'b','a','-append'); % 追加并覆盖为规范名

fprintf('\n[OK] 所有结果已导出到 case5_results.mat ，图见 /plots\n');
