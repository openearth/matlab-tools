function [x, y, z] = getDataContourFigure(myData, plotOptions)
%prepare the data to generate the contour figure from the web app
dataset = myData.dataset;
xVar    = myData.selection.xVar;
yVar    = myData.selection.yVar;
zVar    = myData.selection.zVar;
x       = dataset.(xVar).data;
y       = dataset.(yVar).data;
z       = dataset.(zVar).data;

z     = double(z);

% y = y - y(1);

%repeat the data
[x,y] =  Util.repeatData(x, y, z);
% sizeY = size(y);
% depth = repmat( dataset.Depth.data, 1, sizeY(2));
% y = depth - y;
% y(y<0) = NaN;

dataset.(xVar).data = x;
dataset.(yVar).data = y;

conf = Configuration;
[xStart xEnd] = UtilPlot.getLimsXData(dataset.(xVar).data, xVar, plotOptions);

plotOptions = Util.setDefault(plotOptions,'xInterval',1);
%verifiy if the value is a number
plotOptions = Util.setDefaultNumberField(plotOptions,'xInterval');

if any(strcmpi(dataset.(xVar).longname, conf.TIME_VARS))
    %Determine if X variable is Time to apply pcolor patch
    limitsOptions.xData = dataset.(xVar).data;
    limitsOptions.xLim  = [xStart xEnd];
    options.start       = xStart;
    options.end         = xEnd;
    
    plotOptions = Util.setDefault(plotOptions,'intervalOption', 'days');
    
    %Get the xtick
    limitsOptions.xTick = UtilPlot.getXtick(options, plotOptions);
    
    limitsOptions.scaleMinX = true;
    %Transform the X data
    transformedData = UtilPlot.transformData(limitsOptions);
    
    if isempty(plotOptions.customTickType)
        dataset.(xVar).data = transformedData.xData;
    end;
    
    x = dataset.(xVar).data;
end;

if isfield(myData, 'subset')
    subset = myData.subset;
    
    x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
    z  = WebDataset.getData(dataset.(zVar),subset,subset.currentIndex);
end;
