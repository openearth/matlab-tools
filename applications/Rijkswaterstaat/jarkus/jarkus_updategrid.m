function [grid, msg] = jarkus_updategrid(grid, raaienfile, tidefile)
%JARKUS_UPDATEGRID   update Jarkus grid struct with jarkus_raaien.txt & jarkus_tideinfo.txt
%
%     [grid] = jarkus_updategrid(grid, raaienfile, tidefile)
%
% See web : <a href="http://www.watermarkt.nl/kustenzeebodem/">www.watermarkt.nl/kustenzeebodem/</a>
% See also: JARKUS_TRANSECT2GRID  , JARKUS_NETCDF2GRID, JARKUS_UPDATEGRID, 
%           JARKUS_TRANSECT2NETCDF, JARKUS_GRID2NETCDF

if nargin < 2
   raaienfile = 'jarkus_raaien.txt';
end
if nargin < 3
   tidefile   = 'jarkus_tideinfo.txt';
end

% TODO: insert function header here

%% First part: update grid with information from jarkus_raaien.txt
    
    disp(['Extracting info from ' raaienfile])
    % create a new transect structure
    transect                      = jarkus_createtransectstruct();

%% read all data except first line
%  replace with function jarkus_raaien

    data                          = dlmread(raaienfile, '\t', 1,0);
    
    % the positioning of 19 transects in the areas Voorne (11) and Goeree
    % (12) have been in the years after 1965. The old ones all end at 1,
    % whereas the current ones (and all the others) end at 0. The next
    % lines of code filter the "1" transects from the data, in order to
    % keep only the "0" transects.
    idx1 = mod(data(:,2), 10) ~= 0;
    filteredid = data(idx1,1)*1e6 + floor(data(idx1,2)/10);
    msg = sprintf('Due to repositioning of a small number of transects in the period between 1965 and 1970, the position of the following transects can be incorrect in the first years of the measured period:%s', sprintf(' %i', sort(filteredid)));
    idx = true(size(idx1));
    for ix = find(idx1(:)')
        idx(data(:,1)==data(ix,1) & data(:,2)==floor(data(ix,2)/10)*10) = false;
    end
    data = data(idx,:);
    
    transect.areaCode             =                data(:,1);      % kustvak
    transect.alongshoreCoordinate =          floor(data(:,2) / 10);% metrering
    transect.x                    =                data(:,3)./100; % x
    transect.y                    =                data(:,4)./100; % y
    % from 0.1 degrees to radiants and 
    % from pos clockwise 0 north to pos counterclockwise 0 east
    transect.grad                 =          round(data(:,5)./100);
    transect.angle                = 0.5*pi - 2*pi*(data(:,5)/(100*360)); 

    transect.id                   = transect.areaCode*1e6 + transect.alongshoreCoordinate;

%% find points in the transect which are also in the grid
    
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
        
%% use the angle to compute the coordinates in projected cartesian
%  coordinates. (for jarkus Amersfoort RD new)

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
    tideinfo                      = jarkus_tideinfo(tidefile);
    
%% create a new transect structure
    
    transect                      = jarkus_createtransectstruct();
    transect.areaCode             = tideinfo.areaCode;
    transect.alongshoreCoordinate = tideinfo.alongshoreCoordinate;
    transect.id                   = transect.areaCode*1000000 + transect.alongshoreCoordinate;
    transect.meanHighWater        = tideinfo.MHW;
    transect.meanLowWater         = tideinfo.LMW;
    % find points in the transect which are also in the grid
    [c, ia, ib] = intersect(grid.id, transect.id);

%% assign MHW and MLW to grid

    grid.meanHighWater = zeros(size(grid.id)) * nan;
    grid.meanLowWater  = zeros(size(grid.id)) * nan;
    grid.meanHighWater(ia)            = transect.meanHighWater(ib); 
    grid.meanLowWater(ia)             = transect.meanLowWater(ib); 
    
end % end function jarkus_updategrid
