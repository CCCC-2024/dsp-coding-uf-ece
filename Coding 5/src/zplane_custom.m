function zplane_custom(z, p)
    th = linspace(0,2*pi,512);
    plot(cos(th), sin(th), 'k--'); hold on; axis equal; grid on;
    if ~isempty(z); plot(real(z), imag(z), 'o', 'MarkerSize',7, 'LineWidth',1.2); end
    if ~isempty(p); plot(real(p), imag(p), 'x', 'MarkerSize',8, 'LineWidth',1.2); end
    xlabel('Re\{z\}'); ylabel('Im\{z\}');
    legend({'Unit circle','Zeros','Poles'},'Location','best');
end
