function cmap = cmap_direction(n)
    % cmap_direction  Cyclic colormap for angles (0–360°)
    %
    % n = number of colors (e.g. 256)

    if nargin < 1
        n = 256;
    end

    hue = linspace(0, 1, n+1);   % +1 to close the loop
    hue(end) = [];               % remove duplicate endpoint

    sat = ones(1, n);            % full saturation
    val = ones(1, n);            % full brightness

    cmap = hsv2rgb([hue(:), sat(:), val(:)]);
end