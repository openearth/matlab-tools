function ddb_ModelMakerToolbox_quickMode_DFlowFM(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_quickMode(varargin)
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

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_ModelMakerToolbox_quickMode_DFlowFM.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_DFlowFM.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    
    % New tab selected
    ddb_refreshScreen;
    
    % setUIElements('modelmakerpanel.quickmode');
    setHandles(handles);
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
        setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
            'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
    end
else
    
    % Options selected
    opt=lower(varargin{1});
    switch opt
        case{'drawgridoutline'}
            drawGridOutline;
        case{'editgridoutline'}
            editGridOutline;
        case{'editresolution'}
            editResolution;
        case{'generategrid'}
            generateGrid;
        case{'generatebathymetry'}
            generateBathymetry;
        case{'generateopenboundaries'}
            generateOpenBoundaries;
        case{'generateboundaryconditions'}
            generateBoundaryConditions;
        case{'generateinitialconditions'}
            generateInitialConditions;
    end
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

% Start
setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});
handles = getHandles;

% Update grid
handles.toolbox.modelmaker.gridOutlineHandle=h;
handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;

% Close
setHandles(handles);
gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

%%
function editGridOutline

% Start
handles=getHandles;

% Delete grid
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

% Update grid
handles.toolbox.modelmaker.lengthX=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
handles.toolbox.modelmaker.lengthY=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',lenx,'dy',leny,'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);

% Close
handles.toolbox.modelmaker.gridOutlineHandle=h;
setHandles(handles);

%%
function editResolution

% Start
handles=getHandles;

% Values
lenx    = handles.toolbox.modelmaker.lengthX;
leny    = handles.toolbox.modelmaker.lengthY;
dx      = handles.toolbox.modelmaker.dX;
dy      = handles.toolbox.modelmaker.dY;
nx      = round(lenx/max(dx,1e-9));
ny      = round(leny/max(dy,1e-9));
handles.toolbox.modelmaker.nX       = nx;
handles.toolbox.modelmaker.nY       = ny;
handles.toolbox.modelmaker.lengthX  =nx*dx;
handles.toolbox.modelmaker.lengthY  =ny*dy;
lenx    =handles.toolbox.modelmaker.lengthX;
leny    =handles.toolbox.modelmaker.lengthY;

% Delete
if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

% Draw
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

% Finish
setHandles(handles);

%%
function generateGrid

% Start
handles     = getHandles;
npmax       = 20000000;

% Generate grid; not too big
if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=npmax
    
    % Values
    wb      = waitbox('Generating grid ...'); pause(0.1);
    xori    = handles.toolbox.modelmaker.xOri;
    nx      = handles.toolbox.modelmaker.nX;
    dx      = handles.toolbox.modelmaker.dX;
    yori    = handles.toolbox.modelmaker.yOri;
    ny      = handles.toolbox.modelmaker.nY;
    dy      = handles.toolbox.modelmaker.dY;
    rot     = pi*handles.toolbox.modelmaker.rotation/180;
    zmax    = handles.toolbox.modelmaker.zMax;
    
    % Find minimum grid resolution (in metres)
    dmin=min(dx,dy);
    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        dmin = dmin*111111;
    end

    % Find coordinates of corner points
    x(1)= xori;
    y(1)= yori;
    x(2)= x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
    y(2)= y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
    x(3)= x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
    y(3)= y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
    x(4)= x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
    y(4)= y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);
    
    % Limits for the bathy
    xl(1)= min(x);
    xl(2)= max(x);
    yl(1)= min(y);
    yl(2)= max(y);
    dbuf = (xl(2)-xl(1))/20;
    xl(1)= xl(1)-dbuf;
    xl(2)= xl(2)+dbuf;
    yl(1)= yl(1)-dbuf;
    yl(2)= yl(2)+dbuf;
    
    % Get bathy
    coord   = handles.screenParameters.coordinateSystem;
    iac     = strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
    dataCoord.name = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type = handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    [xlb,ylb]= ddb_coordConvert(xl,yl,coord,dataCoord);
    [xx,yy,zz,ok]= ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
    
    % xx and yy are in coordinate system of bathymetry (usually WGS 84)
    % convert bathy grid to active coordinate system
    if ~strcmpi(dataCoord.name,coord.name) || ~strcmpi(dataCoord.type,coord.type)
        dmin=min(dx,dy);
        [xg,yg]=meshgrid(xl(1):dmin:xl(2),yl(1):dmin:yl(2));
        [xgb,ygb]=ddb_coordConvert(xg,yg,coord,dataCoord);
        zz=interp2(xx,yy,zz,xgb,ygb);
    else
        xg=xx;
        yg=yy;
    end
    
    % Generate grid
    [x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);
    close(wb);
    
    % Adapt for FM, plot and clsoe
    handles=ddb_ModelMakerToolbox_DFlowFM_generateGrid(handles,ad,x,y,z)
    setHandles(handles);
else
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end

%%
function generateBathymetry

% Start
handles=getHandles;

% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,datasets);

% Finish
setHandles(handles);

%%
function generateOpenBoundaries

% Start
handles=getHandles;

% Find boundaries
maxdist     = handles.toolbox.modelmaker.sectionLengthMetres;
minlev      = handles.toolbox.modelmaker.zMax;
boundaries  = [];
boundarysections = findBoundarySections(handles.model.dflowfm.domain(ad).netstruc,maxdist,minlev,handles.screenParameters.coordinateSystem.type);
handles.model.dflowfm.domain(ad).boundarynames = {''};

% Name boundaries
for ib=1:length(boundarysections)
    boundaries  = ddb_DFlowFM_initializeBoundary(boundaries,boundarysections(ib).x,boundarysections(ib).y,['bnd' num2str(ib,'%0.3i')],ib, handles.model.dflowfm.domain(ad).tstart,handles.model.dflowfm.domain(ad).tstop);
    handles.model.dflowfm.domain(ad).boundarynames{ib}=['bnd' num2str(ib,'%0.3i')];
end

% Save files
handles.model.dflowfm.domain(ad).boundaries         = boundaries;
handles.model.dflowfm.domain(ad).nrboundaries       = length(boundaries);
handles = ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);
ddb_DFlowFM_saveBoundaryPolygons('.\',handles.model.dflowfm.domain(ad).boundaries);
handles.model.dflowfm.domain(ad).extforcefile='forcing.ext';
ddb_DFlowFM_saveExtFile(handles);

% Finish
setHandles(handles);

%%
function generateBoundaryConditions

% Start
handles = getHandles;
wb      = waitbox('Generating Boundary Conditions ...');
ad      = 1;

% Make the tides
boundaries = handles.model.dflowfm.domain(ad).boundaries;
for ipol=1:length(boundaries)
    [boundaries(ipol) error] = ddb_ModelMakerToolbox_Delft3DFM_generateBoundaryConditions(handles, boundaries(ipol));
    if error == 1; 
        ddb_giveWarning('Warning',['Delft Dashboard was unable to generate the tides']);    
    end
end

 % Save the data
ddb_DFlowFM_saveBCfile(boundaries);
handles.model.dflowfm.domain(ad).boundaries=boundaries;
ddb_DFlowFM_saveExtFile(handles);
setHandles(handles);
fclose('all');

% Finish
setHandles(handles);
close(wb);
