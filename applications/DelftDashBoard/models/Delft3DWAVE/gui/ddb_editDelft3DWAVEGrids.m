function ddb_editDelft3DWAVEGrids

ddb_refreshScreen('Grids');

strings={'Computational grid','Bathymetry','Spectral resolution','Nesting'};
callbacks={@ddb_editDelft3DWAVEComputationalgrid,@ddb_editDelft3DWAVEBathymetry,@ddb_editDelft3DWAVESpectralresolution,@ddb_editDelft3DWAVENesting};
tabpanel(gcf,'tabpanel2','create',[350 35 635 90],strings,callbacks);

ddb_editDelft3DWAVEComputationalgrid;

