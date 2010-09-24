function ddb_editD3DFlowMonitoring

ddb_refreshScreen('Monitoring');

strings={'Stations','Cross Sections','Drogues'};
callbacks={@ddb_editD3DFlowObservationPoints,@ddb_editD3DFlowCrossSections,@ddb_editD3DFlowDrogues};
%tabpanel(gcf,'tabpanel2','create','position',[50 20 800 140],'strings',strings,'callbacks',callbacks);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[40 10 800 140],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

ddb_editD3DFlowObservationPoints;

