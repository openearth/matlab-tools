function [area_pol, volume_pol, varargout] = EHY_dethyps(x,y,z,filPol,varargin)

% Function EHY_dethyps
% 
% determine hysometric curve inside a polygon based upon scatter data
% positive direction upwards

%% Initialisation
OPT.interface = [];
OPT           = setproperty(OPT,varargin);

%% Create triangulation network, determine incentres, depth at centers and areas of the triangle 
TR          = delaunayTriangulation(x,y);
centre      = incenter (TR);
no_points   = size     (TR,1);
for i_pnt = 1: no_points 
    area (i_pnt) = polyarea(x(TR.ConnectivityList(i_pnt,:)),y(TR.ConnectivityList(i_pnt,:)));
    level(i_pnt) = mean(z(TR.ConnectivityList(i_pnt,:)));
end

%% load the polygon and determine which points inside
[pol]     = readldb  (filPol);
inside    = inpolygon(centre(:,1),centre(:,2),pol.x,pol.y);
area      = area  (inside);
level     = level (inside);
no_points = length(area);

%% Maximum and minimum depth inside polygon
if isempty (OPT.interface)
    min_level = min(level);
    max_level = max(level);
    OPT.interface = min_level:(max_level - min_level)/100.:max_level;
    varargout{1} = OPT.interface;
end
no_interfaces = length(OPT.interface);

%% Cycle over interfaces
area_pol   (1:no_interfaces) = 0.;
volume_pol (1:no_interfaces) = 0.;
for i_interface = 1: no_interfaces
    
    % Determine areas and volumes inside a polygon below a certain interface
    for i_point = 1: no_points
        if level(i_point) <= OPT.interface(i_interface)
            area_pol   (i_interface) = area_pol   (i_interface) + area (i_point);
            volume_pol (i_interface) = volume_pol (i_interface) + (OPT.interface(i_interface) - level(i_point))*area (i_point);
        end
    end
end
