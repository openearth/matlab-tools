function transect2netcdf(filename, transectStruct)
%TRANSECT2NETCDF
%
%See also:

% TODO: define the function header here ...
function transect = mergetransects(transects)
    % create sorting columns, most precise data at the end
    col1 = arrayfun(@(x) (-max(x.seawardDistance)), transects); % most landward maximum seaward last
    col2 = arrayfun(@(x) (x.dateBathy), transects); % latest dates at the end
    col3 = arrayfun(@(x) (x.dateTopo), transects); % latest dates at the end
    col4 = arrayfun(@(x) (x.n), transects); % largest at the end
    
    [a, ia] = sortrows([col1;col2;col3;col4]);
    transect=transects(1);
    new_x = sort(unique([transects.seawardDistance]));
    new_h = zeros(size(new_x)) * NaN;
    for k = 1 : length(transects)
        [c, ia, ib] = intersect(new_x , transects(k).seawardDistance); % find ids transect k
        new_h(ia) = transects(k).height(ib);
    end
    transect.seawardDistance = new_x; % assign new grid
    transect.height = new_h; % assign new heights
end

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
            transect = mergetransects(transect);
        end
        [c, ia, ib] = intersect(seawardDistanceArray, transect.seawardDistance);
        datablock(j, ia) = transect.height(ib);
    end
    nc_varput(filename, 'height', datablock, [i-1, 0, 0], [1, size(datablock)]); % (/i-1, 0, 0/) -> in fortran
end

end