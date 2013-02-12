function jarkus_transect2netcdf(filename, transectStruct)
%jarkus_TRANSECT2NETCDF converts Jarkus transect struct to netCDF-CF file
%
%    jarkus_transect2netcdf(filename, transect)
%
% to be called after JARKUS_GRID2NETCDF.
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

% TODO: define the function header here ...
function transect = mergetransects(transects)
    % mergetransects combines several transects of the same period to one
    % transect. 
    %
    %    mergetransects(transects)
    %
    % 
    % See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
    % See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
    %           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 
    % 
    
    % create sorting columns, most precise data at the end
    col1 = arrayfun(@(x) (-max(x.crossShoreCoordinate)), transects); % most landward maximum seaward last
    col2 = arrayfun(@(x) (x.timeBathy), transects); % latest dates at the end
    col3 = arrayfun(@(x) (x.timeTopo),  transects); % latest dates at the end
    col4 = arrayfun(@(x) (x.n),         transects); % largest at the end
    
    [a, ia]   = sortrows([col1;col2;col3;col4]);
    transect  = transects(1);
    newX      = sort(unique([transects.crossShoreCoordinate]));
    newH      = zeros(size(newX)) * NaN;
    newOrigin = zeros(size(newX)) * NaN;
    for k = 1 : length(transects)
        [c, ia, ib]   = intersect(newX , transects(k).crossShoreCoordinate); % find ids transect k
        newH(ia)      = transects(k).altitude(ib);
        newOrigin(ia) = transects(k).origin(ib);
    end
    transect.crossShoreCoordinate = newX; % assign new grid
    transect.altitude             = newH; % assign new altitudes
    transect.origin               = newOrigin; % assign new origins
end

%% Lookup variables
% This assumes a grid already has been saved to the file
yearArray                 = nc_varget(filename, 'time');
transectIdArray           = nc_varget(filename, 'id');
crossShoreCoordinateArray = nc_varget(filename, 'cross_shore');
try
    missing = nc_attget(filename, 'altitude', '_FillValue');
catch
    missing = -9999;
end
%% Write data to file
% Loop over time first, this is most efficient if it's the slowest
% moving dimension.
for i = 1 : length(yearArray)
    year = yearArray(i);
    %block to store to netcdf. Storing more data at once is faster. But
    %it will require more memory.
    transectsForYearStruct = transectStruct([transectStruct.time] == year);
     altitudeBlock = repmat(missing, length(transectIdArray), length(crossShoreCoordinateArray));
       originBlock = nan(length(transectIdArray), length(crossShoreCoordinateArray)); % use nan for missing here (only a short)
     minCrossBlock = nan(size(transectIdArray)); % defaults to nan
     maxCrossBlock = nan(size(transectIdArray)); % defaults to nan
     minAltitBlock = nan(size(transectIdArray)); % defaults to nan
     maxAltitBlock = nan(size(transectIdArray)); % defaults to nan
     timeTopoBlock = nan(size(transectIdArray)); % write 1 per transect
    timeBathyBlock = nan(size(transectIdArray)); % write 1 per transect
    
    for j = 1 : length(transectIdArray)
        id = transectIdArray(j);
        transect = transectsForYearStruct([transectsForYearStruct.id] == id);
        if isempty(transect)
            continue
        elseif length(transect) > 1 % if more than one dataset per year and per ray is present, the data is merged
            transect = mergetransects(transect);
        end
        [c, ia, ib] = intersect(crossShoreCoordinateArray, transect.crossShoreCoordinate);
         altitudeBlock(j, ia) = transect.altitude(ib);
         minCrossBlock(j)     = min(ia);
         maxCrossBlock(j)     = max(ia);
         minAltitBlock(j)     = min(transect.altitude(ib));
         minAltitBlock(j)     = max(transect.altitude(ib));
           originBlock(j, ia) = transect.origin(ib);
         timeTopoBlock(j)     = transect.timeTopo;
        timeBathyBlock(j)     = transect.timeBathy;
        
    end
    % should this be in jarkus_transect
    nc_varput(filename, 'min_cross_shore_measurement', minCrossBlock , [i-1, 0], [1, length(minCrossBlock)])
    nc_varput(filename, 'max_cross_shore_measurement', maxCrossBlock , [i-1, 0], [1, length(maxCrossBlock)])
    nc_varput(filename, 'min_altitude_measurement', minAltitBlock , [i-1, 0], [1, length(minAltitBlock)])
    nc_varput(filename, 'max_altitude_measurement', minAltitBlock , [i-1, 0], [1, length(minAltitBlock)])
    nc_varput(filename, 'time'      , year          , [i-1      ], [1                        ]);
    nc_varput(filename, 'time_topo' , timeTopoBlock , [i-1, 0   ], [1, length(timeTopoBlock) ]);
    nc_varput(filename, 'time_bathy', timeBathyBlock, [i-1, 0   ], [1, length(timeBathyBlock)]);
    nc_varput(filename, 'altitude'  , altitudeBlock , [i-1, 0, 0], [1,   size(altitudeBlock) ]); % (/i-1, 0, 0/) -> in fortran
    nc_varput(filename, 'origin'    , originBlock   , [i-1, 0, 0], [1,   size(originBlock)   ]); % (/i-1, 0, 0/) -> in fortran
    
end

end % jarkus_transect2netcdf