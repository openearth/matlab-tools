function [grid] = updategrid(grid, filename)
    % TODO: insert function header here
    % update a grid with information from raaien.txt
    disp(filename)
    % create a new transect structure
    transect = createtransectstruct();
    % read all data except first line
    data = dlmread(filename, '\t', 1,0);
    transect.areacode = data(:,1);
    transect.metre = floor(data(:,2) / 10); 
    transect.x = data(:,3);
    transect.y = data(:,4);
    % from 0.1 degrees to radiants and from pos clockwise 0 north to pos
    % counterclockwise 0 east
    transect.angle = 0.5*pi - 2*pi*(data(:,5)/(100*360)); 
    transect.id = transect.areacode*1000000 + transect.metre;

    % find points in the transect which are also in the grid
    [c, ia, ib] = intersect(transect.id, grid.id);
    assert(length(c) == length(grid.id));

    % use the angle to compute the coordinates in projected cartesian
    % coordinates. (for jarkus Amsersfoort RD new)
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
end