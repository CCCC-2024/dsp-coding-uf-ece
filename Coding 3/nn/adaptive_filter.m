function [y, s] = adaptive_filter(x, y0, s0, a3)
% ADAPTIVE_FILTER Implements an adaptive filter that corrects itself.
%
% Inputs:
%   x : Current input sample (scalar).
%   y0: Previous output sample (scalar).
%   s0: Previous slope estimate (scalar).
%   a3: Filter parameter, chosen by you (0 < a3 < 1).
%
% Outputs:
%   y : Current output sample (scalar).
%   s : Updated slope estimate (scalar).

% Equation for the new slope s[n], derived from the block diagram:
% s[n] = x[n] - y[n-1] - a3*s[n-1]
s = x - y0 - a3 * s0;

% Equation for the new output y[n], which uses the newly computed slope s:
% y[n] = (1-a3)*s[n] + y[n-1]
y = (1 - a3) * s + y0;

end