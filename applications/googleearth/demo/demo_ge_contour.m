function demo_ge_contour()

[X,Y] = meshgrid(1:20,1:20);
numLevels = 10;
Z = peaks(20);

if strcmp(devenv,'matlab')
    [C,h] = contour(X,Y,Z,numLevels);
    colormap jet
elseif strcmp(devenv,'octave')
    contour(X,Y,Z,numLevels);
end

kmlStr = ge_contour(X,Y,Z,...
                   'cMap','jet',...
              'numLevels',numLevels,...
              'lineWidth',1);
                    
ge_output('demo_ge_contour.kml',kmlStr);