function [b_best, a_best, err_best, ord_best] = fit_bandpass(w, D, orders)
% 用低阶 IIR 带通拟合目标幅度“形状” D(w)，w ∈ (0, π)
% 策略：
%  1) 用半高宽估计通带 [w1, w2]；
%  2) 逐阶尝试 butter(n/2,'bandpass')；
%  3) 误差用 MSE，避免 dB 在极小值处发散。

    w = w(:); D = D(:);
    % 归一化（再归一次，增强稳健性）
    D = D ./ max(D + 1e-12);

    % 1) 半高宽估计
    [~, ipk] = max(D);
    D3 = max(D) * sqrt(0.5);                 % ≈ -3 dB 等效
    iL = find(D(1:ipk) <= D3, 1, 'last'); if isempty(iL), iL = max(1, ipk-3); end
    iR = ipk + find(D(ipk:end) <= D3, 1, 'first'); if isempty(iR), iR = min(numel(D), ipk+3); end
    w1 = max(1e-3, w(iL));
    w2 = min(pi-1e-3, w(iR));

    % 宽度太窄/非法时放宽
    if ~(w2 > w1) || (w2 - w1) < 1e-3
        w1 = max(1e-3, w(max(1, ipk-5)));
        w2 = min(pi-1e-3, w(min(numel(w), ipk+5)));
    end
    Wn = sort([w1 w2]/pi);                    % 归一到 (0,1)

    % 2) 逐阶尝试
    err_best = inf; b_best = 1; a_best = 1; ord_best = orders(1);
    for n = orders
        try
            [bz, az] = butter(n/2, Wn, 'bandpass');
            H = abs(freqz(bz, az, w));
            H = H ./ max(H + 1e-12);         % 只比“形状”，统一峰值
            err = mean( (H - D).^2 );        % 线性域 MSE，避免 dB 发散
            if err < err_best * (1 - 1e-9)
                err_best = err; b_best = bz; a_best = az; ord_best = n;
            end
        catch
            % Wn 非法等情况，跳过
        end
    end

    % 若仍失败，扩大带宽再试一次
    if isinf(err_best)
        Wn = [max(1e-3, Wn(1)*0.7), min(0.999, Wn(2)*1.3)];
        for n = orders
            try
                [bz, az] = butter(n/2, Wn, 'bandpass');
                H = abs(freqz(bz, az, w));
                H = H ./ max(H + 1e-12);
                err = mean( (H - D).^2 );
                if err < err_best * (1 - 1e-9)
                    err_best = err; b_best = bz; a_best = az; ord_best = n;
                end
            catch
            end
        end
    end
end
