function subfaults_geo=calculate_subfault_geometry(subfaults, coordinate_specification, varargin)
%calculate_subfault_geometry - locate the fault planes in 3d space
%
% Inputs:
%    subfaults - structure, containing arrays for each column read from a
%           subfault file (can create this using read_ucsb_fault.m)
%    coordinate specification - ('centroid', 'top center','bottom center',
%           'noaa sift'), string that specifies the
%           location on the fault where lat/lon and depth are specified.
%
% Outputs:
%    subfaults - In the same format as the subfaults structure that was
%    input, but contains the geometry info needed for plotting.
%
% Basic sub-fault specification.
% 
%     Note that the coodinate specification is in reference to the fault 
%         
%     :Coordinates of Fault Plane:
% 
%     The attributes *centers* and *corners* are described by the figure below.
% 
%     *centers(1,2,3)* refer to the points labeled 1,2,3 below.
%       In particular the centroid is given by *centers(2)*.
%       Each will be an array *(x, y, depth)*.
% 
%     *corners(1,2,3,4)* refer to the points labeled a,b,c,d resp. below.
%       Each will be an array *(x, y, depth)*.
%     
% 
%     Top edge    Bottom edge
%       a ----------- b          ^ 
%       |             |          |         ^
%       |             |          |         |
%       |             |          |         | along-strike direction
%       |             |          |         |
%       1------2------3          | length  |
%       |             |          |
%       |             |          |
%       |             |          |
%       |             |          |
%       d ----------- c          v
%       <------------->
%            width
% 
%       <-- up dip direction
%
% Other m-files required: none
% Subfunctions: dist_latlong2meters, deg2rad
%
% See also: read_subfault

% This code was adapted from functions in CLawpack 5.3.0, which were 
% written in Python for GeoClaw by Dave George and Randy LeVeque. 
% See www.clawpack.org:
% M. J. Berger, D. L. George, R. J. LeVeque and K. M. Mandli, 
% The GeoClaw software for depth-averaged flows with adaptive refinement, 
% Advances in Water Resources 34 (2011), pp. 1195-1206.
% 
% Written in Matlab by SeanPaul La Selle, USGS102015
% Last updated 14 July, 2015

%------------- BEGIN CODE --------------
names = fieldnames(subfaults); 

% Create cells for corner/center data 
corners_cell = cell(length(subfaults.latitude),1);
centers_cell = corners_cell;

% iterate through to calculate geometry for each subfault, and add each   
% subfault to subfaults_geo
for f = 1:length(subfaults.latitude)
    mval=structfun(@(x)(x(f)),subfaults);
    for n = 1:length(names)
        subfault.(names{n}) = mval(n);
    end
    %Simple conversion factor of latitude to meters
    [~,dym] = dist_latlong2meters(0., 1.,0.);
    lat2meter = dym;

%     subfault.length = subfaults.length{f}_dimensions(1)*1000; % need to convert from km to m
%     subfault.width = subfault_dimensions(2)*1000;

    % Setup coordinate arrays
    corners = zeros(4,3);
    centers = zeros(3,3);

    % Set depths
    if strcmp(coordinate_specification,'centroid')
        centers(1,3) = subfault.depth-0.5*subfault.width*sin(deg2rad(subfault.dip));
        centers(2,3) = subfault.depth;
        centers(3,3) = subfault.depth+ 0.5*subfault.width*sin(deg2rad(subfault.dip));
    elseif strcmp(coordinate_specification,'top center') || strcmp(coordinate_specification,'noaa sift')
        centers(1,3) = subfault.depth;
        centers(2,3) = subfault.depth+0.5*subfault.width*sin(deg2rad(subfault.dip));
        centers(3,3) = subfault.depth+subfault.width*sin(deg2rad(subfault.dip));
    elseif strcmp(coordinate_specification,'bottom center')
        centers(1,3) = subfault.depth-subfault.width*sin(deg2rad(subfault.dip));
        centers(2,3) = subfault.depth-0.5*subfault.width*sin(deg2rad(subfault.dip));
        centers(3,3) = subfault.depth;
    else
        disp('Invalid location used, specify correct coordinate specification')
        break
    end
    
    corners(1,3) = centers(1,3);
    corners(4,3) = centers(1,3);
    corners(2,3) = centers(2,3);
    corners(3,3) = centers(3,3);

    % Locate fault plane in 3d space
    % Vector *up_dip* goes from bottom edge to top edge, in meters,
    % from point 2 to point 0 in the figure in the docstring.

    up_dip = [-subfault.width * cos(deg2rad(subfault.dip)) * ...
        cos(deg2rad(subfault.strike))/...
        (lat2meter * cos(deg2rad(subfault.latitude))),...
        subfault.width * cos(deg2rad(subfault.dip)) *...
        sin(deg2rad(subfault.strike))/lat2meter];

    if strcmp(coordinate_specification,'centroid')
        centers(1,1:2) = [subfault.longitude + 0.5 * up_dip(1), subfault.latitude + 0.5 * up_dip(2)];
        centers(2,1:2) = [subfault.longitude, subfault.latitude];
        centers(3,1:2) = [subfault.longitude - 0.5 * up_dip(1),...
            subfault.latitude  - 0.5 * up_dip(2)];
    elseif strcmp(coordinate_specification,'top center')
        centers(1,1:2) = [subfault.longitude, subfault.latitude];
        centers(2,1:2) = [subfault.longitude - 0.5 * up_dip(1),subfault.latitude - 0.5 * up_dip(2)];
        centers(3,1:2) = [subfault.longitude - up_dip(1),subfault.latitude - up_dip(2)];
    elseif strcmp(coordinate_specification,'noaa sift') || strcmp(coordinate_specification,'bottom center')
        % Non-rotated lcoations of center-line coordinates
        centers(1,1:2) = [subfault.longitude + up_dip(1),subfault.latitude + up_dip(2)];
        centers(2,1:2) = [subfault.longitude + 0.5 * up_dip(1),subfault.latitude + 0.5 * up_dip(2)];
        centers(3,1:2) = [subfault.longitude, subfault.latitude];
    else
        disp('Invalid location used, specify correct coordinate specification')
        break
    end
    
    % Calculate coordinates of corners:
    % Vector *strike* goes along the top edge from point 1 to point a
    % in the figure in the docstring.

    up_strike = [0.5 * subfault.length * sin(deg2rad(subfault.strike))...
        / (lat2meter * cos(deg2rad(centers(3,2))))...
        , 0.5 * subfault.length * cos(deg2rad(subfault.strike))/ lat2meter];

    corners(1,1:2) = [centers(1,1) + up_strike(1),centers(1,2) + up_strike(2)];
    corners(2,1:2) = [centers(3,1) + up_strike(1),centers(3,2)+ up_strike(2)];
    corners(3,1:2) = [centers(3,1)- up_strike(1), centers(3,2) - up_strike(2)];
    corners(4,1:2) = [centers(1,1)- up_strike(1),centers(1,2) - up_strike(2)];
    
    % add subfault to subfaults_geo structure
    corners_cell{f} = corners;
    centers_cell{f} = centers;
    
end

subfaults_geo = subfaults;
subfaults_geo.corners = corners_cell;
subfaults_geo.centers = centers_cell;


end

function [dxm, dym] = dist_latlong2meters(dx, dy, latitude)
    %Convert distance from degrees longitude-latitude to meters.

    %Takes the distance described by *dx* and *dy* in degrees and converts it into
    %distances in meters.

    %returns (float, float)

    if ~exist('latitude', 'var')
        latitude = 0.0;
    end

    Rearth = 6367500.0;  % eath radius [m]
    dym = Rearth * deg2rad(dy);
    dxm = Rearth * cos(deg2rad(latitude)) * deg2rad(dx);
end

function y = deg2rad(x)
    %Convert degrees to radians
    y = x * pi/180;
end