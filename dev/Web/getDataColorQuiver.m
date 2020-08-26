function [x, y, z, u, v, nrColors, colorScale] = getDataColorQuiver(myData, plotOptions)
%prepare the data to plot colorquiver
% EXAMPLE:
% [x,y] = meshgrid(-10:10);
% u = x;
% v = y;
% z = sqrt(u.^2+v.^2);
% arrowScale = 0.1;
% plotOptions.colorScale = [0 15];
% plotOptions.arrowScale = arrowScale;
% plotOptions.colorMapStyle = 'jet'
% plotOptions.nrColors = 15
% data.x = x;
% data.y = y;
% data.u = u;
% data.v = v;
% data.z = z;

dataset = myData.dataset;
xVar    = myData.selection.xVar;
yVar    = myData.selection.yVar;
uVar    = myData.selection.uVar;
vVar    = myData.selection.vVar;
zVar    = myData.selection.zVar;
x       = dataset.(xVar).data;
y       = dataset.(yVar).data;
z       = dataset.(zVar).data;
u       = dataset.(uVar).data;
v       = dataset.(vVar).data;

%repeat the data
[x,y] =  Util.repeatData(x, y, z);
dataset.(xVar).data = x;
dataset.(yVar).data = y;

plotOptions = Util.setDefault(plotOptions,'colorMapStyle', 'jet');

plotOptions = Util.setDefault(plotOptions,'nrColors', 8);
%verifiy if the value is a number - is necesary for web app
plotOptions = Util.setDefaultNumberField(plotOptions,'nrColors');

plotOptions = Util.setDefault(plotOptions,'colorScale', [0 1]);
%verifiy if the value is a number - is necesary for web app
plotOptions = Util.setDefaultNumberField(plotOptions,'colorScale');

plotOptions = Util.setDefault(plotOptions,'arrowScale', 1);
%verifiy if the value is a number - is necesary for web app
plotOptions = Util.setDefaultNumberField(plotOptions,'arrowScale');

plotOptions.colorMap = UtilPlot.colormapIMDC(plotOptions.colorMapStyle, plotOptions.nrColors);
nrColors = size(plotOptions.colorMap,1);

% make index for colors
colorScale = plotOptions.colorScale;
if length(colorScale)==2
    colorScale = linspace(colorScale(1),colorScale(2),nrColors+1);
end;

%check if there is a subset selection
plotOptions = Util.setDefault(plotOptions,'subsetIndex','');

if ~isempty(plotOptions.subsetIndex)
    subset = myData.subset;
    
    x  = WebDataset.getData(dataset.(xVar), subset, subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVar), subset, subset.currentIndex);
    z  = WebDataset.getData(dataset.(zVar), subset, subset.currentIndex);
    u  = WebDataset.getData(dataset.(uVar), subset, subset.currentIndex);
    v  = WebDataset.getData(dataset.(vVar), subset, subset.currentIndex);
    
    % scale vector lengths
    u = u .*plotOptions.arrowScale;
    v = v .*plotOptions.arrowScale;
else
    % scale vector lengths
    u = u .*plotOptions.arrowScale;
    v = v .*plotOptions.arrowScale;
end;
