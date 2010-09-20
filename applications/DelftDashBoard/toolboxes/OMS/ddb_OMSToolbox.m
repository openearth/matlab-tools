function ddb_OMSToolbox

ddb_refreshScreen('Toolbox');

strings={'Parameters','Stations','Maps'};
callbacks={@ddb_editOMSParameters,@ddb_editOMSStations,@ddb_editOMSMaps};

tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks,'width',width);

ddb_editOMSParameters;
