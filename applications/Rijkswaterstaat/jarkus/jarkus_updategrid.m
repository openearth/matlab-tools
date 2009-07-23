function [grid] = jarkus_updategrid(grid, filename, tidefile)
%JARKUS_UPDATEGRID update Jarkus grid struct
%
%     [grid] = jarkus_updategrid(grid, filename, tidefile)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF 

    % TODO: insert function header here
    % First part: update grid with information from raaien.txt
    disp(['Extracting info from ' filename])
    % create a new transect structure
    transect       = jarkus_createtransectstruct();
    % read all data except first line
    data           = dlmread(filename, '\t', 1,0);
    transect.areaCode = data(:,1);
    transect.alongshoreCoordinate = floor(data(:,2) / 10); 
    transect.x     = data(:,3)./100;
    transect.y     = data(:,4)./100;
    % from 0.1 degrees to radiants and from pos clockwise 0 north to pos
    % counterclockwise 0 east
    transect.angle = 0.5*pi - 2*pi*(data(:,5)/(100*360)); 
    transect.id    = transect.areaCode*1000000 + transect.alongshoreCoordinate;
    transect.grad  = round(data(:,5)./100);

    % find points in the transect which are also in the grid
    [c, ia, ib] = intersect(transect.id, grid.id);
    if (length(c) ~= length(grid.id))
        warning('JARKUS:inconsistency', 'found grids which are not present in meta information or vice versa'); 
        % assert.m is not compatible
    end
    nnodata = length(setdiff(transect.id, grid.id));
    if (nnodata)
        msg = sprintf('found %d transects in metadata without data', nnodata);
        warning('JARKUS:inconsistency', msg);
    end
    nnodata = length(setdiff(grid.id, transect.id));
    if (nnodata)
        msg = sprintf('found %d transects in data without metadata', nnodata);
        warning('JARKUS:inconsistency', msg);
    end    
    
    %% remove points without metadata
    grid.id                   = grid.id(ib);
    grid.areaCode             = grid.areaCode(ib);
    grid.areaName             = grid.areaName(ib,:);
    grid.alongshoreCoordinate = grid.alongshoreCoordinate(ib);
    
        
    % use the angle to compute the coordinates in projected cartesian
    % coordinates. (for jarkus Amersfoort RD new)
    relativeX  = cos(transect.angle(ia)) * grid.crossShoreCoordinate;
    relativeY  = sin(transect.angle(ia)) * grid.crossShoreCoordinate;
    X          = repmat(transect.x(ia),1,size(relativeX,2)) + relativeX;
    Y          = repmat(transect.y(ia),1,size(relativeY,2)) + relativeY;
    % store all coordinates
    grid.X     = X;
    grid.Y     = Y;
    % and the origins.
    grid.x_0   = transect.x(ia);
    grid.y_0   = transect.y(ia);
    % assign angle of coastline to grid
    grid.angle = transect.grad(ia); 
    
    %% Second part: update grid with information from TIDEINFO.txt
    disp(['Extracting info from ' tidefile])
    tideinfo                      = load(tidefile);
    % create a new transect structure
    transect                      = jarkus_createtransectstruct();
    transect.areaCode             = tideinfo(:,1);
    transect.alongshoreCoordinate = tideinfo(:,2); 
    transect.id                   = transect.areaCode*1000000 + transect.alongshoreCoordinate;
    transect.meanHighWater        = tideinfo(:,3);
    transect.meanLowWater         = tideinfo(:,4);
    % find points in the transect which are also in the grid
    [c, ia, ib] = intersect(grid.id, transect.id);
    % assign MHW and MLW to grid
    grid.meanHighWater = zeros(size(grid.id)) * nan;
    grid.meanLowWater = zeros(size(grid.id)) * nan;
    grid.meanHighWater(ia)            = transect.meanHighWater(ib); 
    grid.meanLowWater(ia)             = transect.meanLowWater(ib); 
    
end % end function jarkus_updategrid
