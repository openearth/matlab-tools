function demo_ge_colorbar()

PosLong = [5 6 7 8];
PosLat = [53 52 51 50];
 
Z=100*randn(100000,1);

labels = {'wheat','grass','sugar','fat'};
kmlStr = ge_colorbar(PosLong,PosLat,Z,...
                    'cBarBorderWidth',1,...
                      'cBarFormatStr','%+7.2f',...
                           'numUnits',4,...
                           'labels',labels,...
                               'name','click the icon to see the colorbar',...
                               'cMap','winter');

                           
kmlFileName = 'demo_ge_colorbar.kml'; 

ge_output(kmlFileName,kmlStr,'name',kmlFileName)