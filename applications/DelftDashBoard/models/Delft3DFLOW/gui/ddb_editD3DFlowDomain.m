function ddb_editD3DFlowDomain

ddb_refreshScreen('Domain');

strings={'Grid','Bathymetry','Dry Points','Thin Dams','Structures'};
callbacks={@ddb_editD3DFlowGrid,@ddb_editD3DFlowBathymetry,@ddb_editD3DFlowDryPoints,@ddb_editD3DFlowThinDams,@ddb_editD3DFlowStructures};

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 800 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editD3DFlowGrid;

