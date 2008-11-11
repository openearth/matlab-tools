function [grid] = transect2grid(transectStruct)
    % TODO: define function header here ....
    %Define a grid to store all transect data on
    % TODO: Replace this by a transect independent grid structure or better
    % a classdef if that can be used.
    
    % we have to determine how much data we want to allocate to store all
    % transects.
    % find all id's
    [transect_ids, unique_indices] = unique([transectStruct.id], 'first');
    [transect_ids, sorted_indices] = sort(transect_ids);
    
    grid.id = transect_ids;

    % find areacodes per id corresponding names
    unique_transectStruct = transectStruct(unique_indices);
    sorted_unique_transectStruct = unique_transectStruct(sorted_indices);
    grid.areacode = [sorted_unique_transectStruct.areacode];
    grid.areaname = char({sorted_unique_transectStruct.areaname});
    grid.coastwardDistance = [sorted_unique_transectStruct.metre];
    
    % find all years
    grid.year = sort(unique([transectStruct.year]));
    % find seaward distance vector
    minSeawardDistance = min(cellfun(@min, {transectStruct.seawardDistance}));
    maxSeawardDistance = max(cellfun(@max, {transectStruct.seawardDistance}));
    grid.seawardDistance = minSeawardDistance:5:maxSeawardDistance;

    
    % display result
    disp(['created a ' num2str(length(grid.seawardDistance)) ' by ' num2str(length(grid.id)) ' by ' num2str(length(grid.year)) ' grid.']);
end
