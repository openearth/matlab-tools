function [x, y] = getDataPlotHorizontalLine(myData)
dataset   = myData.dataset;
xVariable = myData.selection.xVar;
yVariable = myData.selection.yVar;

x = dataset.(xVariable).data;
y = dataset.(yVariable).data;

%check if there is a subset selection
if isfield(myData, 'subset')
    subset = myData.subset;
    %extract subset data selection
    x  = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);
end;
