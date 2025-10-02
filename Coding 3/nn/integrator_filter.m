function y = integrator_filter(x, y0, a2)
% INTEGRATOR_FILTER Implements a first-order recursive filter.
%
% Inputs:
%   x : Current input sample (scalar).
%   y0: Previous output sample (scalar).
%   a2: Filter parameter, chosen by you (0 < a2 < 1).
%
% Output:
%   y : Current output sample (scalar).

% The equation is derived from the provided block diagram.
% y[n] = (1-a2)*x[n] + a2*y[n-1]
y = (1 - a2) * x + a2 * y0;

end