function [x,y,z,connections] = getDataPlotTriangle(myData)
%Prepare data to apply patch

dataset = myData.dataset;
xVar    = myData.selection.xVar;
yVar    = myData.selection.yVar;
zVar    = myData.selection.zVar;
connectionVar    = myData.selection.connectionVar;

x = dataset.(xVar).data;
y = dataset.(yVar).data;
z = dataset.(zVar).data;
connections = dataset.(connectionVar).data;

%repeat the data
[x,y] =  Util.repeatData(x, y, z);
dataset.(xVar).data = x;
dataset.(yVar).data = y;

if isfield(myData, 'subset')
    subset = myData.subset;
    
    x  = WebDataset.getData(dataset.(xVar),subset,subset.currentIndex);
    y  = WebDataset.getData(dataset.(yVar),subset,subset.currentIndex);
    z  = WebDataset.getData(dataset.(zVar),subset,subset.currentIndex);
    connections = WebDataset.getData(dataset.(connVar),subset,subset.currentIndex);
end;
