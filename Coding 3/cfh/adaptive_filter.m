function [y, s] = adaptive_filter(x, y0, s0, a3)

% Equation for the internal state 's'
% s[n] = (x[n] - y[n-1]) - a3*s[n-1]
s_new = (x - y0) - a3 * s0;

% Equation for the output 'y'
% y[n] = (1-a3)*s[n] + y[n-1]
y_new = (1 - a3) * s_new + y0;

% Assign outputs
s = s_new;
y = y_new;

end