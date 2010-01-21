%fews_plot_test   Test for plotting in google earth

% 
lat = [0:100];
lon = [0:100];
[loni,lati] = meshgrid(lon,lat);
dist = sqrt(loni.^2+lati.^2);
sinx = sin(dist/20);

KMLpcolor  (lati,loni,sinx,... % at corners for z !!
                   'fileName','3D_test.kml',...
                    'kmlName','depth [m]',...
                  'lineAlpha',.6,...
                       'cLim',[0 2],...
                  'lineWidth',0,... % to prevent rastering of the pixels (WHY?)
                'polyOutline',true,...
                   'polyFill',true);

