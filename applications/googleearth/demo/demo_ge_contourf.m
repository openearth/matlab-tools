function demo_ge_contourf()

close all

[X,Y] = meshgrid(1:20,1:20);

Z = peaks(20);
cMapStr = 'summer';

lineValues = [-8:3:4];
figure
subplot(1,2,1)
imagesc(X(1,:),Y(:,1),Z,[min(lineValues),max(lineValues)])
set(gca,'Ydir','normal')
axis image
colorbar
subplot(1,2,2)
[C,h] = contourf(X,Y,Z,lineValues);
colorbar
axis image
colormap(cMapStr)

figure
kmlStr = ge_contourf(X,Y,Z,...
                    'cMap','jet',...
               'lineValues',lineValues,...
               'polyAlpha','ff',...
                    'cMap',cMapStr,...
                 'lineColor','ff000000');
%              
% kmlStr = [kmlStr,ge_colorbar(0,10,0,...
%                     'cBarBorderWidth',1,...
%                       'cBarFormatStr','%+7.2f',...
%                            'numUnits',numLevels,...
%                            'cLimLow',lineValues(1),...
%                            'cLimHigh',lineValues(end),...
%                                'name','click the icon to see the colorbar',...
%                                'cMap',cMapStr)];

                
if any(strcmp(devenv,{'octave','matlab'}))
    ge_output(['demo_ge_contourf_',devenv,'.kml'],kmlStr);
else
    ge_output('demo_ge_contourf_other.kml',kmlStr);
end