function grid_orth_getSandBalance_test2
% GRID_ORTH_GETSANDBALANCE_TEST2  This script tests the sediment budget script

clc

%% NB: first put polygons in a directory called polygons
%% next run sand balance
OPT.dataset         = 'd:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\nc_files\elevation_data\multibeam\';
OPT.tag             = 'd:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\nc_files\elevation_data\multibeam\';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\';
OPT.polygondir      = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\polygons\';
OPT.polygon         = [];
OPT.cellsize        = [];                               % left empty will be determined automatically
OPT.datathinning    = 1;                                % stride with which to skip through the data
OPT.inputtimes      = [];                               % starting points (in Matlab epoch time) 
OPT.starttime       = [];
OPT.searchinterval  = 0;                                % acceptable interval to include data from (in days)
OPT.min_coverage    = 25;                               % coverage percentage (can be several, e.g. [50 75 90]
OPT.plotresult      = 1;
OPT.warning         = 1;
OPT.postProcessing  = 1;
OPT.whattodo        = 1;
OPT.type            = 1;
OPT.counter         = 0;
OPT.urls            = [];
OPT.x_ranges        = [];
OPT.y_ranges        = [];

grid_orth_getSandBalance(OPT);