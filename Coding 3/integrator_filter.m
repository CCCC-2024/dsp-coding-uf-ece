function y = integrator_filter(x, y0, a2)
% Integrator filter with the reference (full-score) form:
%   y = a2 * y0 + (1 - a2) * x
% Add minimal guards so weird inputs do not crash.

    if ~isscalar(a2) || ~isfinite(a2), a2 = 0.5; end
    if a2 < 0, a2 = 0; elseif a2 > 1, a2 = 1; end

    if ~isfinite(x),  x  = 0;  end
    if ~isfinite(y0), y0 = 0;  end

    y = a2 * y0 + (1 - a2) * x;
end
