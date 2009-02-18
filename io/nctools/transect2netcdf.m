function transect2netcdf(filename, transectStruct)
% TODO: define the function header here ...


%% Lookup variables
% This assumes a grid already has been saved to the file
yearArray = nc_varget(filename, 'year');
transectIdArray = nc_varget(filename, 'id');
seawardDistanceArray = nc_varget(filename, 'seaward_distance');
missing = nc_attget(filename, 'height', '_FillValue');
%% Write data to file
% Loop over time first, this is most efficient if it's the slowest
% moving dimension.
for i = 1 : length(yearArray)
    year = yearArray(i);
    %block to store to netcdf. Storing more data at once is faster. But
    %it will require more memory.
    transectsForYearStruct = transectStruct([transectStruct.year] == year);
    datablock = repmat(missing, length(transectIdArray), length(seawardDistanceArray));
    for j = 1 : length(transectIdArray)
        id = transectIdArray(j);
        transect = transectsForYearStruct([transectsForYearStruct.id] == id);
        if isempty(transect)
            continue
        elseif length(transect) > 1
            for k = 1 : length(transect)
                lengthOfData(k) = length(transect(k).height);
            end
            transect = transect(find(lengthOfData==max(lengthOfData))); %HACK: take the longest. This should not happen if data is sound.
        end
        [c, ia, ib] = intersect(seawardDistanceArray, transect.seawardDistance);
        datablock(j, ia) = transect.height(ib);
    end
    nc_varput(filename, 'height', datablock, [i-1, 0, 0], [1, size(datablock)]); % (/i-1, 0, 0/) -> in fortran
end

