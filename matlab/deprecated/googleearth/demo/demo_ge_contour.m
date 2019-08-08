function demo_ge_contour()
 error('%s has been deprecated',mfilename)

figure
[X,Y] = meshgrid(1:20,1:20);
numLevels = 10;
Z = peaks(20);

[C,h] = contour(X,Y,Z,numLevels);
colormap jet

kmlStr = ge_contour(X,Y,Z,...
                   'cMap',rand(100,3),...
              'numLevels',numLevels,...
              'lineWidth',1);
                    
ge_output('demo_ge_contour.kml',kmlStr);