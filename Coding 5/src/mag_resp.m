function [w, H] = mag_resp(b, a, Nw)
% 频响采样
    if nargin<3, Nw = 2048; end
    w = linspace(0, pi, Nw).';
    H = freqz(b, a, w);
end
