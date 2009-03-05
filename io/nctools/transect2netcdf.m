function transect2netcdf(filename, transectStruct)
%TRANSECT2NETCDF
%
%See also:

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
        elseif length(transect) > 1 % if more than one dataset per year and per ray is present, the data is merged
            for k = 1 : length(transect)
                maximum(k) = max(transect(k).seawardDistance);
            end            
            jarkus_id = find(maximum==min(maximum)); % most landward datapoints are jarkus
            doorlood_id = find(maximum==max(maximum)); % most seaward datapoints are doorlodingen (considered less reliable)                       
            new_x = unique([transect.seawardDistance]); % make new unique grid
            [u, v] = intersect(new_x , transect(doorlood_id).seawardDistance); % find ids of doorlodingen
            new_h(v) = transect(doorlood_id).height; % interpolate them on new grid
            [w, q] = intersect(new_x , transect(jarkus_id).seawardDistance); % find ids of vaklodingen
            new_h(q) = transect(jarkus_id).height; % interpolate them on grid (and overwrite doorlodingen)
            transect=transect(jarkus_id); % keep structure of jarkus
            transect.seawardDistance = new_x; % assign new grid
            transect.height = new_h; % assign new heights
        end
        [c, ia, ib] = intersect(seawardDistanceArray, transect.seawardDistance);
        datablock(j, ia) = transect.height(ib);
    end
    nc_varput(filename, 'height', datablock, [i-1, 0, 0], [1, size(datablock)]); % (/i-1, 0, 0/) -> in fortran
end

