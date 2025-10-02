function y = running_average_filter(x0, x1, x2)
% RUNNING_AVERAGE_FILTER Computes a 3-point running average.
%
% Inputs:
%   x0: Most recent input sample (current).
%   x1: Previous input sample.
%   x2: Input sample two steps ago.
%
% Output:
%   y: Filtered output (scalar).

% The output is the arithmetic mean of the three most recent inputs.
y = (x0 + x1 + x2) / 3;

end