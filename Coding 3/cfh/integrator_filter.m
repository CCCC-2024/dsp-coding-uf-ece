function y = integrator_filter(x, y0, a2)

y = a2 * y0 + (1 - a2) * x;

end