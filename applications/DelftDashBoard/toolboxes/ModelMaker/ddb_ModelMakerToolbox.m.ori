function ddb_ModelMakerToolbox

strings={'Quick Mode','Grid','Bathymetry','Boundary Conditions','Initial Conditions'};
callbacks={@ddb_modelMakerQuickMode,@ddb_modelMakerGrid,@ddb_modelMakerBathymetry,@ddb_modelMakerBoundaryConditions,@ddb_modelMakerInitialConditions};
%tabpanel(gcf,'tabpanel2','create','position',[20 20 990 140],'strings',strings,'callbacks',callbacks,'width',width);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[10 10 990 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_modelMakerQuickMode;
