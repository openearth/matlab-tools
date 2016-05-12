function ddb_ModelMakerToolbox_XBeach_quickMode_transects(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_XBeach(varargin)
%
%   Input:
%   varargin =
%
%
%
%
%   Example
%   ddb_ModelMakerToolbox_quickMode
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

%%
handles=getHandles;
% ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    setHandles(handles);
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box)', 'Note: make sure origin is offshore and x direction is cross-shore'});
    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'drawline'}
            drawPolyline;
        case('drawtransects')
            drawTransects;
        case{'generategrid'}
            generatemodel;
        case('delete')
            deleteGridOutline
    end
    
end

%%
function drawPolyline
handles=getHandles;
h = UIPolyline(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, 'onstart',@deleteGridOutline, ...
    'Tag', 'XB')
handles.toolbox.modelmaker.xb_trans.handle1=h;
setHandles(handles);

%%
function updateGridOutline(x,y,h)
setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box'});

handles=getHandles;

% 
setappdata(h,'x',x);
setappdata(h,'y',y);
handles.toolbox.modelmaker.xb_trans.handle1=h;
handles.toolbox.modelmaker.xb_trans.X=x;
handles.toolbox.modelmaker.xb_trans.Y=y;
setHandles(handles);
gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle1)
    try
        delete(handles.toolbox.modelmaker.xb_trans.handle1);
    end
end
catch
end
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle2)
    try
        delete(handles.toolbox.modelmaker.xb_trans.handle2);
    end
end
catch
end
setHandles(handles);

%%
function drawTransects

handles=getHandles;

% Delete
try
if ~isempty(handles.toolbox.modelmaker.xb_trans.handle2)
    try
        delete(handles.toolbox.modelmaker.xb_trans.handle2);
    end
end
catch
end

%% Get information
hg = handles.toolbox.modelmaker.xb_trans.handle1;
X=getappdata(hg,'x');
Y=getappdata(hg,'y');

ntransects = length(X)-1;

% Get locations of the model
for ii = 1:ntransects;
    dx = abs((X(ii+1)-X(ii)));     dy = abs((Y(ii+1)-Y(ii)));
    coast(ii) = (atand( dy / dx));
    
    % Based on
    dx_2(ii) = X(ii+1) - X(ii); dy_2(ii) = Y(ii+1) - Y(ii);

    % Based on degrees
    xorg(ii) = (X(ii+1) + X(ii))/2;
    yorg(ii) = (Y(ii+1) + Y(ii))/2;
    distances(ii) = ((X(ii+1) - X(ii)).^2 + (Y(ii+1) - Y(ii)).^2).^0.5;
    dx = X(ii+1) - X(ii); dy = Y(ii+1) - Y(ii);
   
    if dx > 0 && dy < 0 
    xback(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy < 0
    xback(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx >= 0 && dy >= 0
    xback(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy > 0
    xback(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
end

% Keep coast, X, Y and distance
for ii = 1:length(distances);
    if ii == 1;
    distances_cum(ii) = distances(ii);
    else
    distances_cum(ii) = distances_cum(ii-1) + distances(ii);
    end
end

if handles.toolbox.modelmaker.transects ~= 0
    distances_total = sum(distances);
    ntransects = handles.toolbox.modelmaker.transects;
    ndivide = handles.toolbox.modelmaker.transects + 1;
    for jj = 1:ntransects
        distances_wanted = max(distances_cum)/ndivide * jj;
        xoff2(jj) = interp1(distances_cum,xoff,distances_wanted);
        yoff2(jj) = interp1(distances_cum,yoff,distances_wanted);
        xback2(jj) = interp1(distances_cum,xback,distances_wanted);
        yback2(jj) = interp1(distances_cum,yback,distances_wanted);
        coast2(jj) = interp1(distances_cum,coast,distances_wanted);
        distances2(jj) = distances_wanted;
    end
    
    id = (~isnan(xoff2) & ~isnan(xback2) & ~isnan(yoff2) & ~isnan(yback2));
    xoff = xoff2(id); xback = xback2(id);
    yoff = yoff2(id); yback = yback2(id);
    coast = coast2(id); distances = distances2(id); ntransects = length(xoff);
    
    for jj = 1:length(distances);
        if jj == 1;
        distances0(jj) = distances(jj);
        else
        distances0(jj) = distances(jj)-distances(jj-1);
        end
    end
    average_dx = round(nanmean(distances0(2:end)), 1);
else
    ntransects = length(X)-1;
    average_dx = round(nanmean(distances), 1);
end

% Plotting
for ii = 1:ntransects
    h2(ii) = plot([xoff(ii) xback(ii)], [yoff(ii), yback(ii)], 'k', 'linewidth', 2);
end
handles.toolbox.modelmaker.xb_trans.handle2 = h2;

% Determine average range

% Determine average depth
% Find coordinates of corner points
x = [xback xoff];
y = [yback yoff];

% Sizes
xl(1)=min(x);
xl(2)=max(x);
yl(1)=min(y);
yl(2)=max(y);
dbuf=(xl(2)-xl(1))/20;
xl(1)=xl(1)-dbuf;
xl(2)=xl(2)+dbuf;
yl(1)=yl(1)-dbuf;
yl(2)=yl(2)+dbuf;

% Coordinate coversion
coord=handles.screenParameters.coordinateSystem;
iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
[xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);

% Get bathymetry in box around model grid
[xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',1000);  
id = ~isnan(zz); [xx,yy]=ddb_coordConvert(xx,yy,dataCoord,coord);
F1 = scatteredInterpolant(xx(id),yy(id),zz(id),'natural','none');
zoff = F1(xoff, yoff); average_z = round(nanmean(zoff),1);

% Set values
handles.toolbox.modelmaker.average_z = average_z;
handles.toolbox.modelmaker.average_dx = average_dx;

setHandles(handles);

%%
function generatemodel
handles=getHandles;
X = handles.toolbox.modelmaker.xb_trans.X;
Y = handles.toolbox.modelmaker.xb_trans.Y;
ntransects = length(X)-1;

% Get locations of the model
for ii = 1:ntransects;
    dx = abs((X(ii+1)-X(ii)));     dy = abs((Y(ii+1)-Y(ii)));
    coast(ii) = (atand( dy / dx));
    
    % Based on
    dx_2(ii) = X(ii+1) - X(ii); dy_2(ii) = Y(ii+1) - Y(ii);

    % Based on degrees
    xorg(ii) = (X(ii+1) + X(ii))/2;
    yorg(ii) = (Y(ii+1) + Y(ii))/2;
    distances(ii) = ((X(ii+1) - X(ii)).^2 + (Y(ii+1) - Y(ii)).^2).^0.5;
    dx = X(ii+1) - X(ii); dy = Y(ii+1) - Y(ii);
   
    if dx > 0 && dy < 0 
    xback(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy < 0
    xback(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx > 0 && dy > 0
    xback(ii) = xorg(ii) - sind(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) - cosd(360-coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) + sind(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) + cosd(360-coast(ii)) * handles.toolbox.modelmaker.nX;
    end
    
    if dx < 0 && dy > 0
    xback(ii) = xorg(ii) + sind(coast(ii)) * handles.toolbox.modelmaker.nY;
    yback(ii) = yorg(ii) + cosd(coast(ii)) * handles.toolbox.modelmaker.nY;
    xoff(ii) = xorg(ii) - sind(coast(ii)) * handles.toolbox.modelmaker.nX;
    yoff(ii) = yorg(ii) - cosd(coast(ii)) * handles.toolbox.modelmaker.nX;
    end
end

% Keep coast, X, Y and distance
for ii = 1:length(distances);
    if ii == 1;
    distances_cum(ii) = distances(ii);
    else
    distances_cum(ii) = distances_cum(ii-1) + distances(ii);
    end
end

if handles.toolbox.modelmaker.transects ~= 0
    distances_total = sum(distances);
    ntransects = handles.toolbox.modelmaker.transects;
    ndivide = handles.toolbox.modelmaker.transects + 1;
    for jj = 1:ntransects
        distances_wanted = max(distances_cum)/ndivide * jj;
        xoff2(jj) = interp1(distances_cum,xoff,distances_wanted);
        yoff2(jj) = interp1(distances_cum,yoff,distances_wanted);
        xback2(jj) = interp1(distances_cum,xback,distances_wanted);
        yback2(jj) = interp1(distances_cum,yback,distances_wanted);
        coast2(jj) = interp1(distances_cum,coast,distances_wanted);
        distances2(jj) = distances_wanted;
    end
    for jj = 1:ntransects+1;
    
    id = (~isnan(xoff2) & ~isnan(xback2) & ~isnan(yoff2) & ~isnan(yback2));
    xoff = xoff2(id); xback = xback2(id);
    yoff = yoff2(id); yback = yback2(id);
    coast = coast2(id); distances = distances2(id); ntransects = length(xoff);
    end
    
    for jj = 1:length(distances);
        if jj == 1;
        distances0(jj) = distances(jj);
        else
        distances0(jj) = distances(jj)-distances(jj-1);
        end
    end
    average_dx = round(nanmean(distances0(2:end)), 1);
else
    ntransects = length(xoff);
    average_dx = round(nanmean(distances), 1);
end

% Set values
handles.toolbox.modelmaker.xb_trans.ntransects = ntransects;
handles.toolbox.modelmaker.xb_trans.xoff = xoff;
handles.toolbox.modelmaker.xb_trans.yoff = yoff;
handles.toolbox.modelmaker.xb_trans.xback = xback;
handles.toolbox.modelmaker.xb_trans.yback = yback;
handles.toolbox.modelmaker.xb_trans.distances = distances;
handles.toolbox.modelmaker.xb_trans.coast = coast;

% Generating models
wb = waitbox('Generating XBeach transect models')
handles=ddb_ModelMakerToolbox_XBeach_generateTransects(handles);
close(wb)
cd ..
save('distances.txt', 'distances','-ascii')
A = [xoff; yoff; xback; yback; coast];
save('settings.txt', 'A','-ascii')