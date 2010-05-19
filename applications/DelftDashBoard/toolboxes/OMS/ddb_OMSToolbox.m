function ddb_oMSToolbox

ddb_refreshScreen('Toolbox');

strings={'Parameters','Stations','Maps'};
callbacks={@ddb_editOMSParameters,@ddb_editOMSStations,@ddb_editOMSMaps};

tabpanel(gcf,'tabpanel2','create',[50 20 910 140],strings,callbacks);

ddb_editOMSParameters;
