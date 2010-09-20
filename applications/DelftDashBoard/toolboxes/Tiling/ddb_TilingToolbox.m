function ddb_TilingToolbox

ddb_refreshScreen('Toolbox');

strings={'Bathymetry','Shoreline'};
callbacks={@ddb_TilingBathymetry,@ddb_TilingShoreline};
width=[100 100];

tabpanel(gcf,'tabpanel2','create','position',[50 20 910 140],'strings',strings,'callbacks',callbacks,'width',width);

ddb_TilingBathymetry;
