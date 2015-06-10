function [x,y,z]=ddb_ModelMakerToolbox_makeRectangularGrid(handles)
%ddb_ModelMakerToolbox_makeRectangularGrid creates rectangular grid for model maker toolbox
%
% function can be called by ddb_ModelMakerToolbox_Delft3DFLOW_generateGrid,
% ddb_ModelMakerToolbox_Delft3DWAVE_generateGrid, and ddb_ModelMakerToolbox_DFlowFM_generateGrid
% First a larger grid is made which is later used in MakeRectangularGrid
% The larger model used ddb_getBathymetry to get 'active' bathy
%
%   Syntax:
%   [x,y,z] = ddb_ModelMakerToolbox_makeRectangularGrid(handles)
%
%   Output:
%   x        = x of grid
%   y        = y of grid
%   z        = z of grid
%
%   Example
%   ddb_ModelMakerToolbox_makeRectangularGrid
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Get handles from Dashboard
xori=handles.toolbox.modelmaker.xOri;
nx=handles.toolbox.modelmaker.nX;
dx=handles.toolbox.modelmaker.dX;
yori=handles.toolbox.modelmaker.yOri;
ny=handles.toolbox.modelmaker.nY;
dy=handles.toolbox.modelmaker.dY;
rot=pi*handles.toolbox.modelmaker.rotation/180;
zmax=handles.toolbox.modelmaker.zMax;

%% Find minimum grid resolution (in metres)
dmin=min(dx,dy);
if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    dmin=dmin*111111;
end

%% Find coordinates of corner points
x(1)=xori;
y(1)=yori;
x(2)=x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
y(2)=y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
x(3)=x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
y(3)=y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
x(4)=x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
y(4)=y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);

%% If grid is rotated and geographic - determine x and y in UTM
if~rot==0 & strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')

    [xori_utm,yori_utm, utm_zone] = deg2utm(xori,yori)

    [sx, azi1, azi2] = geoddistance(x(1), y(1), x(2), y(2))
    [sy, azi1, azi2] = geoddistance(x(2), y(2), x(3), y(3))
    
    % Distance
    dx_utm = sx / nx;
    dy_utm = sy / ny;
    
    % UTM coordi of points in lat lon
    x_utm(1)=   xori_utm;
    y_utm(1)=   yori_utm;
    [x_utm(2) y_utm(2)] =  deg2utm(x(2),y(2))
    [x_utm(3) y_utm(3)] =  deg2utm(x(3),y(3))
    [x_utm(4) y_utm(4)] =  deg2utm(x(4),y(4))
    
    % Limits
    x_utm_l(1) = min(x_utm); x_utm_l(2) = max(x_utm);
    y_utm_l(1) = min(y_utm); y_utm_l(2) = max(y_utm);
    dbuf = (x_utm(2)-x_utm(1))/20;
    x_utm_l(1) = x_utm_l(1)-dbuf;
    x_utm_l(2) = x_utm_l(2)+dbuf;
    y_utm_l(1) = y_utm_l(1)-dbuf;
    y_utm_l(2) = y_utm_l(2)+dbuf;

end

xl(1)=min(x);
xl(2)=max(x);
yl(1)=min(y);
yl(2)=max(y);
dbuf=(xl(2)-xl(1))/20;
xl(1)=xl(1)-dbuf;
xl(2)=xl(2)+dbuf;
yl(1)=yl(1)-dbuf;
yl(2)=yl(2)+dbuf;

%% Convert limits to cs of bathy data
if ~rot==0 & strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    coord_utm.name = 'WGS 84 / UTM zone '
    coord_utm.name = [coord_utm.name utm_zone.number utm_zone.NS]
    coord_utm.type = 'Cartesian'
    
    coord.name = 'WGS 84'
    coord.type = 'Geographic'
else
    coord=handles.screenParameters.coordinateSystem;
end

iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

% Get bathymetry in box around model grid
[xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
figure; pcolor(xx,yy,zz); shading flat;

% xx and yy are in coordinate system of bathymetry (usually WGS 84)
% convert bathy grid to active coordinate system
if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
%     dmin=min(dx,dy);
%     [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
%     [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
%     zz=interp2(xx,yy,zz,xgb,ygb);
%       TO DO: FIX
elseif ~rot==0 & strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
	dmin=min(dx_utm,dy_utm);
    [xg, yg]    = meshgrid(x_utm_l(1):dmin:x_utm_l(2),y_utm_l(1):dmin:y_utm_l(2));
    [xgb,ygb]   = ddb_coordConvert(xg,yg,coord_utm,dataCoord);
    zz=griddata(xx,yy,zz,ygb,xgb);   
else
    xg=xx;
    yg=yy;
end
   
%% Get coordinates of rectangular grid
%% Convert limits to cs of bathy data
if ~rot==0 & strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
    [x,y,z]=MakeRectangularGrid(xori_utm,yori_utm,nx,ny,dx_utm,dy_utm,rot,zmax,xg,yg,zz);
else
    [x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);
end

% If rotated and geograpic: back
[x,y]=ddb_coordConvert(x,y,coord_utm,dataCoord);
