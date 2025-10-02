function tf = is_minimum_phase(z)
% 最小相位：所有零点模 < 1（严格在单位圆内）
    if isempty(z), tf = true; return; end
    tf = all(abs(z) < 1 - 1e-9);
end
