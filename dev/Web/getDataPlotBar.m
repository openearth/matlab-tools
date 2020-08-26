function [x, y] = getDataPlotBar(myData)

dataset = myData.dataset;
xVar    = myData.selection.xVar;
yVar    = myData.selection.yVar;
x       = dataset.(xVar).data;
y       = dataset.(yVar).data;


%check if there is a subset selection
if isfield(myData, 'subset')
    subset = myData.subset;
    
    x = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
    y = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);    
    
    [xDataTemp,mask] = unique(x);
    if length(xDataTemp)~=length(y)
        x = xDataTemp;
        y = y(mask,:);
        warning(['Replicated X data deleted in var ',dataset.(xVar).longname,'.']);
    end;
else
    %veryfy duplicated data
    [xDataTemp,mask] = unique(x);
    if length(xDataTemp)~=length(y)
        x = xDataTemp;
        y = y(mask,:);
        warning(['Replicated X data deleted in var ',dataset.(xVar).longname,'.']);
    end;
end;
