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
        elseif length(transect) > 1 % if multiple datablocks exist with same id take longest one and fill up with shorter one
            for k = 1 : length(transect)
                lengthOfData(k) = length(transect(k).height);
            end
            new_x = unique([transect.seawardDistance]);
            [u, v] = intersect(new_x , transect(find(lengthOfData==min(lengthOfData))).seawardDistance);
            new_h(v) = transect(find(lengthOfData==min(lengthOfData))).height;
            [w, q] = intersect(new_x , transect(find(lengthOfData==max(lengthOfData))).seawardDistance);
            new_h(q) = transect(find(lengthOfData==max(lengthOfData))).height;
            transect=transect(find(lengthOfData==max(lengthOfData)));
            transect.seawardDistance = new_x;
            transect.height = new_h;            
        end
        [c, ia, ib] = intersect(seawardDistanceArray, transect.seawardDistance);
        datablock(j, ia) = transect.height(ib);
    end
    nc_varput(filename, 'height', datablock, [i-1, 0, 0], [1, size(datablock)]); % (/i-1, 0, 0/) -> in fortran
end

