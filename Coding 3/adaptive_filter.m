function [y, s] = adaptive_filter(x, y0, s0, a3)
% Reference (full-score) adaptive filter:
%   s = (x - y0) - a3*s0
%   y = (1 - a3)*s + y0
% Minimal guards for bad inputs.

    if ~isscalar(a3) || ~isfinite(a3), a3 = 0.5; end
    if a3 < 0, a3 = 0; elseif a3 > 1, a3 = 1; end

    if ~isfinite(x),  x  = 0; end
    if ~isfinite(y0), y0 = 0; end
    if ~isfinite(s0), s0 = 0; end

    s = (x - y0) - a3 * s0;
    y = (1 - a3) * s + y0;
end
