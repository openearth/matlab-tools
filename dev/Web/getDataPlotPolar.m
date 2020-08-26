function [x, y] = getDataPlotPolar(myData)
dataset   = myData.dataset;
xVariable = myData.selection.xVar;
yVariable = myData.selection.yVar;

x = dataset.(xVariable).data;
y = dataset.(yVariable).data;

%check if there is a subset selection
if isfield(myData, 'subset')
    subset = myData.subset;
    %time  = WebDataset.getData(dataset.Time,subset,plotOptions.subsetIndex);
    x = WebDataset.getData(dataset.(xVariable),subset,subset.currentIndex);
    y = WebDataset.getData(dataset.(yVariable),subset,subset.currentIndex);    
end;
