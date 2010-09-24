function ddb_bathymetryToolbox

%strings={'Export','Combine Datasets'};
%callbacks={@ddb_bathymetryExport,@ddb_bathymetryCombineDatasets};
%width=[100 150];
strings={'Export'};
callbacks={@ddb_bathymetryExport};
width=[100];
%tabpanel(gcf,'tabpanel2','create','position',[20 20 990 140],'strings',strings,'callbacks',callbacks,'width',width);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[10 10 990 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_bathymetryExport;
