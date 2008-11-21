% function convertjarkus()
% Insert header doc here....

% This script can be used to convert jarkus transect (raai) files into
% netcdf

% A few entities are used here:
% jarkus transects: as read from the jarkus transect file
% transect: assumed to be measurements along a seaward angle
% grid: in this case a curvilinear structured grid 
% netcdf output: a netcdf file following the cf convention where results
% are stored.

% 
% Transect
% A transect is considered to be a set of measurements allong a line. This
% line has a local seaward coordinate 

% Jarkus transect
% A jarkus transect is measured by rijkswaterstaat. Starting from a pole in
% the coast measurements are taken along a line seaward, both on the coast
% and in the water. 
% The data is related to area's, regions in the Netherlands
% Each raai has a region specific distance within the region along the
% coastline (metrering).

% Grid
% The grid which contains the data for the transects is curvilinear
% structured. Each point in the grid has a seperate geographic coordinate.
% The grid is considered to be curvilinear, it follows the coastline. 
% The grid is structured, all points are related to 2 dimensions (seaward,
% along the coast)

% Netcdf output
% The netcdf file is stored according to the CF convention

% Input:
% Data is stored in https://repos.deltares.nl/repos/mcdata/trunk/rws/jarkus
% raw/transects/total/raaien.txt -> table with indexes of transects, contains
%   index, relative coordinate, coordinate in EPSG:28992, angle
% raw/transects/total/*.txt -> all jarkus transect data

%% Define library settings
addpath mexnc % native netcdf interface
addpath snctools % convenience matlab toolbox
setpref ('SNCTOOLS', 'USE_JAVA', false); % I couldnt get java to work correctly. 

%% Define path settings
dataType='Transects';
dataSet='rijkswaterstaat/jarkus';
rawDataDir='d:\checkouts\OpenEarthRawData\trunk';
outputDir='d:\download';
dataDir = [rawDataDir filesep dataSet ];
rawFileDir = [dataDir filesep 'raw' filesep 'total'];
rawFileArray = dir([dataDir filesep 'raw' filesep 'total' filesep '*.txt']);       % lists all available area data files (15 areas with transect data)


%% Allocate structure for dataset. 
% This might be faster with a preallocated size
transectStruct = createtransectstruct();
transectStruct(:) = [];
%% Loop over all files
for i = 1:length(rawFileArray)
    filename = [rawFileDir filesep rawFileArray(i).name];
    disp(['reading ' filename])
    % transectStruct are jarkus specific Arrays. Concatenate them into a big transectStruct
    % structure Array.
    try
        transectStruct = [transectStruct jarkus2transect(filename)];
    catch 
        s = lasterror;
        % catch only my errors for which no identifiers are defined
        % native matlab errors will be rethrown
        if ~isempty(s.identifier)
           rethrow
        end
    end
        
end

%% define a grid based on the transectStruct
grid = transect2grid(transectStruct);
grid = updategrid(grid, [rawFileDir filesep 'raaien.txt']); % this file contains extra information

%% store grid and transects to a netcdf file
grid2netcdf('output.nc', grid);
% extract a curvilinear grid definition from the transectStruct x grid H(time, transect, length) where
% time is the year, transect is the transect and lenght is the difference along
% the line starting from the measurement pole.
transect2netcdf('output.nc', transectStruct)







