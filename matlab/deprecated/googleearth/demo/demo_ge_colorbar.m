function demo_ge_colorbar()
 error('%s has been deprecated',mfilename)

PosLong = [5 6 7 8];
PosLat = [53 52 51 50];
 
Z=100*randn(100000,1);

labels = {'wheat','grass','sugar beet','farmland'};
kmlStr = ge_colorbar(PosLong,PosLat,Z,...
                    'cBarBorderWidth',1,...
                      'cBarFormatStr','%+7.2f',...
                           'numUnits',4,...
                           'labels',labels,...
                               'name','click the icon to see the colorbar',...
                               'cMap',rand(104,3));

                           
kmlFileName = 'demo_ge_colorbar.kml'; 

ge_output(kmlFileName,kmlStr,'name',kmlFileName)