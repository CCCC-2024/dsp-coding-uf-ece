function tf = is_linear_phase_fir(b)
% 简易线相位判定（FIR）：系数关于中点对称或反对称（容差）
    b = b(:).'; 
    tol = 1e-6;
    tf = false;
    N = numel(b);
    % 对称
    if max(abs(b - fliplr(b))) < tol
        tf = true; return;
    end
    % 反对称
    if max(abs(b + fliplr(b))) < tol
        tf = true; return;
    end
end
