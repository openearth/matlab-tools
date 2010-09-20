function ddb_editD3DFlowMonitoring

ddb_refreshScreen('Monitoring');

strings={'Stations','Cross Sections','Drogues'};
callbacks={@ddb_editD3DFlowObservationPoints,@ddb_editD3DFlowCrossSections,@ddb_editD3DFlowDrogues};
tabpanel(gcf,'tabpanel2','create','position',[50 20 800 140],'strings',strings,'callbacks',callbacks);

ddb_editD3DFlowObservationPoints;

