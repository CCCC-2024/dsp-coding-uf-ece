function y = running_average_filter(x0, x1, x2)
% 3-point running average (pure real-time)
% same behavior as full-score reference; with tiny hygiene.
    if ~isfinite(x0), x0 = 0; end
    if ~isfinite(x1), x1 = 0; end
    if ~isfinite(x2), x2 = 0; end
    y = (x0 + x1 + x2) / 3;
end
