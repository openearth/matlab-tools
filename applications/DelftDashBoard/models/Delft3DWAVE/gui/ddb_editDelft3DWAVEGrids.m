function ddb_editDelft3DWAVEGrids

ddb_refreshScreen('Grids');

strings={'Computational grid','Bathymetry','Spectral resolution','Nesting'};
callbacks={@ddb_editDelft3DWAVEComputationalgrid,@ddb_editDelft3DWAVEBathymetry,@ddb_editDelft3DWAVESpectralresolution,@ddb_editDelft3DWAVENesting};

%tabpanel(gcf,'tabpanel2','create','position',[350 35 635 90],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[340 25 635 90],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editDelft3DWAVEComputationalgrid;
