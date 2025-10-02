% stress_check.m  (在当前目录直接运行)
clear; load indexMatch.mat; %#ok<LOAD> % 只是确认变量存在
UFID = '22860708'; % 用你自己已经成功的 UFID
[X, zn, freq, Fs] = get_spy_audio(UFID);

tries = 8; idxs = zeros(tries,1);
for t = 1:tries
    gain = 0.5 + 1.5*rand;           % 随机幅度缩放
    noise = 0.02*randn(size(zn));    % 小噪声
    phase = exp(1j*2*pi*rand);       % 随机相位（用于解释；幅值不变）
    zt = real( gain*(zn + noise) );  % 仅加噪声与增益

    idxs(t) = findMatchingAudio(X, zt, freq, Fs);
end
disp(idxs)             % 大概率全是 2
fprintf('mode = %d, unique = %s\n', mode(idxs), mat2str(unique(idxs)))  % 稳定匹配就通过
