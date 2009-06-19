function [grid] = jarkus_transect2grid(transectStruct)
%JARKUS_TRANSECT2GRID converts Jarkus transect struct to Jarkus grid struct
%
%    [grid] = jarkus_transect2grid(transect)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

    % TODO: define function header here ....
    %Define a grid to store all transect data on
    % TODO: Replace this by a transect independent grid structure or better
    % a classdef if that can be used.
    
    % we have to determine how much data we want to allocate to store all
    % transects.
    % find all id's
    [transectIdArray, uniqueIdArray] = unique([transectStruct.id]);
    [transectIdArray, sortedIdArray] = sort(transectIdArray);
    
    grid.id = transectIdArray;

    % find areacodes per id corresponding names
    uniqueTransectStruct       = transectStruct(uniqueIdArray);
    sortedUniqueTransectStruct = uniqueTransectStruct(sortedIdArray);
    grid.areaCode              = [sortedUniqueTransectStruct.areaCode];
    grid.areaName              = char({sortedUniqueTransectStruct.areaName});
    grid.alongshoreCoordinate  = [sortedUniqueTransectStruct.alongshoreCoordinate];
    
    % find all years
    grid.year                  = sort(unique([transectStruct.year]));
    % compute cross-shore grid
    minCrossShoreCoordinate    = min(cellfun(@min, {transectStruct.crossShoreCoordinate}));
    maxCrossShoreCoordinate    = max(cellfun(@max, {transectStruct.crossShoreCoordinate}));
    grid.crossShoreCoordinate  = minCrossShoreCoordinate:5:maxCrossShoreCoordinate;

    
    % display result
    disp(['created a ' num2str(length(grid.crossShoreCoordinate)) ' by ' num2str(length(grid.id)) ' by ' num2str(length(grid.year)) ' grid.']);

end % end function jarkus_transect2grid
