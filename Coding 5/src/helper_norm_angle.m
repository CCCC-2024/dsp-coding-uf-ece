function w0 = helper_norm_angle(w0)
% 归一到 [-pi, pi]
    while w0 >  pi, w0 = w0 - 2*pi; end
    while w0 < -pi, w0 = w0 + 2*pi; end
end
