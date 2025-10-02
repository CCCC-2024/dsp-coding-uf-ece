function tf = is_linear_phase_fir(b)
% ��������λ�ж���FIR����ϵ�������е�Գƻ򷴶Գƣ��ݲ
    b = b(:).'; 
    tol = 1e-6;
    tf = false;
    N = numel(b);
    % �Գ�
    if max(abs(b - fliplr(b))) < tol
        tf = true; return;
    end
    % ���Գ�
    if max(abs(b + fliplr(b))) < tol
        tf = true; return;
    end
end
