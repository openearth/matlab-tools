function grid_orth_getSandBalance_test2
% GRID_ORTH_GETSANDBALANCE_TEST2  This script tests the sediment budget script
clc;
fclose all;

%% NB: first put polygons in a directory called polygons ... next run sand balance
OPT.dataset         = 'd:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\nc_files\elevation_data\multibeam\';
OPT.ldburl          = 'http://opendap.deltares.nl/thredds/dodsC/opendap/deltares/landboundaries/holland.nc';
OPT.workdir         = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\';
OPT.polygondir      = 'D:\checkouts\VO-rawdata\projects\151027_maasvlakte_2\scripts\sedbudget\mv\polygons\';
OPT.searchinterval  = 0;                                % acceptable interval to include data from (in days)
OPT.min_coverage    = [50 90];                          % coverage percentage (can be several, e.g. [50 75 90]

if 1
    try rmdir(fullfile(OPT.workdir, 'coverage'),  's'); end
    try rmdir(fullfile(OPT.workdir, 'datafiles'), 's'); end
    try rmdir(fullfile(OPT.workdir, 'results'),   's'); end
end

grid_orth_getSandBalance(OPT);