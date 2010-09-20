function ddb_ModelMakerToolbox

strings={'Quick Mode','Grid','Bathymetry','Boundary Conditions','Initial Conditions'};
callbacks={@ddb_modelMakerQuickMode,@ddb_modelMakerGrid,@ddb_modelMakerBathymetry,@ddb_modelMakerBoundaryConditions,@ddb_modelMakerInitialConditions};
width=[100 100 100 120 120];
tabpanel(gcf,'tabpanel2','create','position',[20 20 990 140],'strings',strings,'callbacks',callbacks,'width',width);
ddb_modelMakerQuickMode;
