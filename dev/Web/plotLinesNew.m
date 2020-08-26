function [aLine, x, y] = plotLinesNew(ax, myData, plotOptions)
%plot lines from web interface

dataset   = myData.dataset;
xVariable = myData.selection.xVar;
yVariable = myData.selection.yVar;

x = dataset.(xVariable).data;
y = dataset.(yVariable).data;


%start to build the line configuration for each line in
%plot
[plotProperty plotPropertyValue] = UtilPlot.buildLinePropertiesNew(plotOptions);

if isfield(myData, 'subset')
    subset = myData.subset;
    
    if length(subset.group(subset.currentIndex).indexVec) > 1
        varSize = length(subset.group(subset.currentIndex).indexVec{2});
        x1 = repmat(x, 1, varSize);
        y1 = repmat(y, 1, varSize);
        
        dataset.(xVariable).data = x1;
        dataset.(yVariable).data = y1;
    end;
    
    %substract data
    x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
end;

%make the plot
aLine = plot(ax,x,y);

%set the custom properties plot
for zz=1:length(plotProperty)
    set(aLine, plotProperty{zz}, plotPropertyValue{zz})
end;