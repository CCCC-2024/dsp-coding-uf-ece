function type_id = classify_filter_type(w, Mag)
% 返回：1=LP, 2=HP, 3=AP, 4=BP, 5=BS
    Mag = Mag(:); w = w(:);
    Mag = Mag./max(Mag+1e-12);
    % 全通：幅度近似常数
    if std(Mag) < 0.02
        type_id = 3; return; % All-pass
    end
    % 分段均值粗判
    K = numel(Mag);
    m_lo = mean(Mag(1:round(0.15*K)));        % 近DC
    m_hi = mean(Mag(round(0.85*K):end));      % 近pi
    % 峰谷位置
    [~,ipk] = max(Mag); [~,ival] = min(Mag);
    % 带通/带阻：峰值不在端点
    if ipk > 0.1*K && ipk < 0.9*K
        type_id = 4; return; % BP
    end
    if ival > 0.2*K && ival < 0.8*K && m_lo>0.6 && m_hi>0.6
        type_id = 5; return; % BS
    end
    % 低/高通
    if m_lo > 0.6 && m_hi < 0.4
        type_id = 1; return; % LP
    elseif m_lo < 0.4 && m_hi > 0.6
        type_id = 2; return; % HP
    end
    % 据端点比较
    type_id = (m_lo >= m_hi) + 1; % m_lo>=m_hi → LP(1)，否则HP(2)
end
