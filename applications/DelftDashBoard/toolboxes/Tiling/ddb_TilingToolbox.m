function ddb_TilingToolbox

ddb_refreshScreen('Toolbox');

strings={'Bathymetry','Shoreline'};
callbacks={@ddb_TilingBathymetry,@ddb_TilingShoreline};

tabpanel(gcf,'tabpanel2','create',[50 20 910 140],strings,callbacks);

ddb_TilingBathymetry;
