function setFigureIcon(fig, iconFile)
% Set the window icon of a figure. Uses the Icon property (R2025a+) and
% falls back to the JavaFrame for older MATLAB versions.
if isprop(fig,'Icon')
    set(fig,'Icon',iconFile);
else
    fh = get(fig,'JavaFrame'); % Get Java Frame
    fh.setFigureIcon(javax.swing.ImageIcon(iconFile));
end
