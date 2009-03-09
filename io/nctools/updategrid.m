function [grid] = updategrid(grid, filename,tidefile)
%UPDATEGRID
%
%See also:

    % TODO: insert function header here
    % First part: update grid with information from raaien.txt
    disp(['Extracting info from ' filename])
    % create a new transect structure
    transect = createtransectstruct();
    % read all data except first line
    data = dlmread(filename, '\t', 1,0);
    transect.areacode = data(:,1);
    transect.metre = floor(data(:,2) / 10); 
    transect.x = data(:,3)./100;
    transect.y = data(:,4)./100;
    % from 0.1 degrees to radiants and from pos clockwise 0 north to pos
    % counterclockwise 0 east
    transect.angle = 0.5*pi - 2*pi*(data(:,5)/(100*360)); 
    transect.id = transect.areacode*1000000 + transect.metre;
    transect.GRAD = round(data(:,5)./100);

    % find points in the transect which are also in the grid
    [c, ia, ib] = intersect(transect.id, grid.id);
    if (length(c) ~= length(grid.id))
        warning('found grids which are not present in meta information or vice versa'); 
        % assert.m is not compatible
    end
    nnodata = length(setdiff(transect.id, grid.id));
    if (nnodata)
        msg = sprintf('found %d transects in metadata without data', nnodata);
        warning(msg);
    end
    nnodata = length(setdiff(grid.id, transect.id));
    if (nnodata)
        msg = sprintf('found %d transects in data without metadata', nnodata);
        warning(msg);
    end    
    
    %remove points without metadata
    grid.id = grid.id(ib);
    grid.areacode = grid.areacode(ib);
    grid.areaname = grid.areaname(ib,:);
    grid.coastwardDistance = grid.coastwardDistance(ib);
    
        
    % use the angle to compute the coordinates in projected cartesian
    % coordinates. (for jarkus Amersfoort RD new)
    relativeX = cos(transect.angle(ia)) * grid.seawardDistance;
    relativeY = sin(transect.angle(ia)) * grid.seawardDistance;
    X = repmat(transect.x(ia),1,size(relativeX,2)) + relativeX;
    Y = repmat(transect.y(ia),1,size(relativeY,2)) + relativeY;
    % store all coordinates
    grid.X = X;
    grid.Y = Y;
    % and the origins.
    grid.x_0 = transect.x(ia);
    grid.y_0 = transect.y(ia);
    % assign angle of coastline to grid
    grid.angle = transect.GRAD(ia); 
    
    %% Second part: update grid with information from TIDEINFO.txt
    disp(['Extracting info from ' tidefile])
    tideinfo = load(tidefile);
    % create a new transect structure
    transect = createtransectstruct();
    transect.areacode = tideinfo(:,1);
    transect.metre = tideinfo(:,2); 
    transect.id = transect.areacode*1000000 + transect.metre;
    transect.MHW = tideinfo(:,3);
    transect.MLW = tideinfo(:,4);
    % find points in the transect which are also in the grid
    [u, v, w] = intersect(transect.id, grid.id);
    % assign MHW and MLW to grid
    grid.MHW = transect.MHW(v); 
    grid.MLW = transect.MLW(v); 
    
end