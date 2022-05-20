function demo_ge_imagesc()%% Demo ge_imagesc
 error('%s has been deprecated',mfilename)

load('flujet.mat')

data = X;

x = linspace(-20,30.0,size(data,2));
y = linspace(10,50,size(data,1));
cLimLow = min(min(data));
cLimHigh = max(max(data));
altitude = 1000000;
polyAlpha = '55';
%kmlTargetDir = ['..',filesep,'kml',filesep];
kmlFileName = 'demo_ge_imagesc.kml';

Ix = 1+round(rand(10,1)*(numel(data)-1));
data(Ix)=NaN;
figure
imagesc(x,y,data,[cLimLow cLimHigh]);


output = ge_imagesc(x,y,data,...
                  'imageURL','flujet.png',...
                 'lineColor','00000000',...
                 'lineWidth',0.1,...
                   'cLimLow',cLimLow,...
                  'cLimHigh',cLimHigh,...
             'dataFormatStr','%+010.6f',...
                  'altitude',altitude,...
              'altitudeMode','absolute');

output2 = ge_colorbar(x(end),y(1),data,...
                            'numUnits',20,...
                             'cLimLow',cLimLow,...
                            'cLimHigh',cLimHigh,...
                       'cBarFormatStr','%+07.4f');

ge_output(kmlFileName,[output2 output],'name',kmlFileName);
                                           
                                           