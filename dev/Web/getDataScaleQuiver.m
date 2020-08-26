function [x, y, u, v] = getDataScaleQuiver(myData, plotOptions)
%Prepare data to plot Scale Quiver
%initialize variables
dataset = myData.dataset;
xVar    = myData.selection.xVar;
yVar    = myData.selection.yVar;
uVar    = myData.selection.uVar;
vVar    = myData.selection.vVar;

x = dataset.(xVar).data;
y = dataset.(yVar).data;
u = dataset.(uVar).data;
v = dataset.(vVar).data;

%verify if the arrowScale option is present
plotOptions = Util.setDefault(plotOptions,'arrowScale',1);
%verifiy if the value is a number
plotOptions = Util.setDefaultNumberField(plotOptions,'arrowScale');
if ~isempty(plotOptions.arrowScale)
    u = dataset.(uVar).data .*plotOptions.arrowScale;
    v = dataset.(vVar).data .*plotOptions.arrowScale;
end;

%check if there is a subset selection
if isfield(myData, 'subset')
    subset = myData.subset;
    x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
    
    %u = x .*str2double(plotOptions.arrowScale);
    %v = y .*str2double(plotOptions.arrowScale);
end;

%check the U and V size to avoid size problems
%TODO - remove later
sizeX = size(x);
sizeY = size(y);
sizeU = size(u);
sizeV = size(v);
if sizeU(2) > sizeX(2)
    u = u(:,1);
end;
if sizeV(2) > sizeY(2)
    v = v(:,1);
end;
%end;
