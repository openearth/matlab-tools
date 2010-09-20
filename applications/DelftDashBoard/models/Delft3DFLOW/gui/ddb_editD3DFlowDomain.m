function ddb_editD3DFlowDomain

ddb_refreshScreen('Domain');

strings={'Grid','Bathymetry','Dry Points','Thin Dams','Structures'};
callbacks={@ddb_editD3DFlowGrid,@ddb_editD3DFlowBathymetry,@ddb_editD3DFlowDryPoints,@ddb_editD3DFlowThinDams,@ddb_editD3DFlowStructures};
tabpanel(gcf,'tabpanel2','create','position',[50 20 800 140],'strings',strings,'callbacks',callbacks);

ddb_editD3DFlowGrid;

