function ddb_bathymetryToolbox

%strings={'Export','Combine Datasets'};
%callbacks={@ddb_bathymetryExport,@ddb_bathymetryCombineDatasets};
%width=[100 150];
strings={'Export'};
callbacks={@ddb_bathymetryExport};
width=[100];
tabpanel(gcf,'tabpanel2','create',[20 20 990 140],strings,callbacks,width);
ddb_bathymetryExport;
