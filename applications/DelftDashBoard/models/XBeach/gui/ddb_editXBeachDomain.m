function ddb_editXBeachDomain

ddb_refreshScreen('Domain');

strings={'Grid','Bathymetry'};
callbacks={@ddb_editXBeachGrid,@ddb_editXBeachBathymetry};
tabpanel(gcf,'tabpanel2','create','position',[50 20 900 140],'strings',strings,'callbacks',callbacks);

ddb_editXBeachGrid;

