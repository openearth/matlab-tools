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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
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
    
    %Options selected
    
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

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});

handles=getHandles;

handles.toolbox.modelmaker.gridOutlineHandle=h;

handles.toolbox.modelmaker.xOri=x0;
handles.toolbox.modelmaker.yOri=y0;
handles.toolbox.modelmaker.rotation=rotation;
handles.toolbox.modelmaker.nX=round(dx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(dy/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.lengthX=dx;
handles.toolbox.modelmaker.lengthY=dy;

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

handles=getHandles;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

handles.toolbox.modelmaker.lengthX=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
handles.toolbox.modelmaker.lengthY=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;

lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',lenx,'dy',leny,'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function editResolution

handles=getHandles;

lenx=handles.toolbox.modelmaker.lengthX;
leny=handles.toolbox.modelmaker.lengthY;

dx=handles.toolbox.modelmaker.dX;
dy=handles.toolbox.modelmaker.dY;

nx=round(lenx/max(dx,1e-9));
ny=round(leny/max(dy,1e-9));

handles.toolbox.modelmaker.nX=nx;
handles.toolbox.modelmaker.nY=ny;

handles.toolbox.modelmaker.lengthX=nx*dx;
handles.toolbox.modelmaker.lengthY=ny*dy;

lenx=handles.toolbox.modelmaker.lengthX;
leny=handles.toolbox.modelmaker.lengthY;

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.dX,'ddy',handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

% setUIElement('modelmakerpanel.quickmode.editmmax');
% setUIElement('modelmakerpanel.quickmode.editnmax');

%%
function generateGrid

handles=getHandles;

npmax=20000000;

if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=npmax
    
    wb = waitbox('Generating grid ...');pause(0.1);
    
    xori=handles.toolbox.modelmaker.xOri;
    nx=handles.toolbox.modelmaker.nX;
    dx=handles.toolbox.modelmaker.dX;
    yori=handles.toolbox.modelmaker.yOri;
    ny=handles.toolbox.modelmaker.nY;
    dy=handles.toolbox.modelmaker.dY;
    rot=pi*handles.toolbox.modelmaker.rotation/180;
    zmax=handles.toolbox.modelmaker.zMax;
    
    % Find minimum grid resolution (in metres)
    dmin=min(dx,dy);
    if strcmpi(handles.screenParameters.coordinateSystem.type,'geographic')
        dmin=dmin*111111;
    end
    %    dmin=dmin/2;
    %     dmin=15000;
    
    % Find coordinates of corner points
    x(1)=xori;
    y(1)=yori;
    x(2)=x(1)+nx*dx*cos(pi*handles.toolbox.modelmaker.rotation/180);
    y(2)=y(1)+nx*dx*sin(pi*handles.toolbox.modelmaker.rotation/180);
    x(3)=x(2)+ny*dy*cos(pi*(handles.toolbox.modelmaker.rotation+90)/180);
    y(3)=y(2)+ny*dy*sin(pi*(handles.toolbox.modelmaker.rotation+90)/180);
    x(4)=x(3)+nx*dx*cos(pi*(handles.toolbox.modelmaker.rotation+180)/180);
    y(4)=y(3)+nx*dx*sin(pi*(handles.toolbox.modelmaker.rotation+180)/180);
    
    xl(1)=min(x);
    xl(2)=max(x);
    yl(1)=min(y);
    yl(2)=max(y);
    dbuf=(xl(2)-xl(1))/20;
    xl(1)=xl(1)-dbuf;
    xl(2)=xl(2)+dbuf;
    yl(1)=yl(1)-dbuf;
    yl(2)=yl(2)+dbuf;
    
    % Convert limits to cs of bathy data
    coord=handles.screenParameters.coordinateSystem;
    iac=strmatch(lower(handles.screenParameters.backgroundBathymetry),lower(handles.bathymetry.datasets),'exact');
    dataCoord.name=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.name;
    dataCoord.type=handles.bathymetry.dataset(iac).horizontalCoordinateSystem.type;
    
    [xlb,ylb]=ddb_coordConvert(xl,yl,coord,dataCoord);
    
    [xx,yy,zz,ok]=ddb_getBathymetry(handles.bathymetry,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
    
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
    
    [x,y,z]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,xg,yg,zz);
    
    close(wb);
    
    handles=ddb_generateGridDFlowFM(handles,ad,x,y,z);
    
    setHandles(handles);
    
else
    ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end

%%
function generateBathymetry
handles=getHandles;
% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
handles=ddb_ModelMakerToolbox_DFlowFM_generateBathymetry(handles,datasets);
setHandles(handles);

%%
function generateOpenBoundaries

handles=getHandles;

maxdist=handles.toolbox.modelmaker.sectionLengthMetres;
minlev=handles.toolbox.modelmaker.zMax;

boundaries=[];

boundarysections=findBoundarySections(handles.model.dflowfm.domain(ad).netstruc,maxdist,minlev,handles.screenParameters.coordinateSystem.type);

handles.model.dflowfm.domain(ad).boundarynames={''};

for ib=1:length(boundarysections)
    boundaries = ddb_DFlowFM_initializeBoundary(boundaries,boundarysections(ib).x,boundarysections(ib).y,['bnd' num2str(ib,'%0.3i')],ib, ...
        handles.model.dflowfm.domain(ad).tstart,handles.model.dflowfm.domain(ad).tstop);
    handles.model.dflowfm.domain(ad).boundarynames{ib}=['bnd' num2str(ib,'%0.3i')];
end

handles.model.dflowfm.domain(ad).boundaries=boundaries;
handles.model.dflowfm.domain(ad).nrboundaries=length(boundaries);

handles=ddb_DFlowFM_plotBoundaries(handles,'plot','active',1);

%% Save file
ddb_DFlowFM_saveBoundaryPolygons('.\',handles.model.dflowfm.domain(ad).boundaries);

%% External forcing file
handles.model.dflowfm.domain(ad).extforcefile='forcing.ext';
ddb_DFlowFM_saveExtFile(handles);

setHandles(handles);

%%
function generateBoundaryConditions

wb = waitbox('Generating Boundary Conditions ...');

try
    
    handles=getHandles;
    ii=handles.toolbox.modelmaker.activeTideModelBC;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    %% Find constituents
    % Make one vector with all boundary points
    xb=[];
    yb=[];
    boundaries=handles.model.dflowfm.domain(ad).boundaries;
    
    for ipol=1:length(boundaries)
        xb=[xb boundaries(ipol).x];
        yb=[yb boundaries(ipol).y];
    end
    
    cs.name='WGS 84';
    cs.type='Geographic';
    
    [xb,yb]=ddb_coordConvert(xb,yb,handles.screenParameters.coordinateSystem,cs);
    
    [ampz,phasez,conList] = readTideModel(tidefile,'type','h','x',xb,'y',yb,'constituent','all');
    ip=0;
    for ipol=1:length(boundaries)
        for jj=1:length(boundaries(ipol).x)
            boundaries(ipol).nodes(jj).components=[];
            ip=ip+1;
            for ic=1:size(ampz,1)
                boundaries(ipol).nodes(jj).components(ic).component=conList{ic};
                boundaries(ipol).nodes(jj).components(ic).amplitude=ampz(ic,ip);
                boundaries(ipol).nodes(jj).components(ic).phase=phasez(ic,ip);
            end
            ddb_DFlowFM_writeComponentsFile(boundaries,ipol,jj);
        end
    end
    handles.model.dflowfm.domain(ad).boundaries=boundaries;
    
    setHandles(handles);
    
end

close(wb);


%%
function generateInitialConditions
handles=getHandles;
f=str2func(['ddb_generateInitialConditions' handles.model.dflowfm.name]);
try
    handles=feval(f,handles,ad,'ddb_test','ddb_test');
catch
    ddb_giveWarning('text',['Initial conditions generation not supported for ' handles.model.dflowfm.longName]);
    return
end
if ~isempty(handles.model.dflowfm.domain(ad).grdFile)
    attName=handles.model.dflowfm.domain(ad).attName;
    handles.model.dflowfm.domain(ad).iniFile=[attName '.ini'];
    handles.model.dflowfm.domain(ad).initialConditions='ini';
    handles.model.dflowfm.domain(ad).smoothingTime=0.0;
    handles=feval(f,handles,ad,handles.model.dflowfm.domain(ad).iniFile);
else
    ddb_giveWarning('Warning','First generate or load a grid');
end
setHandles(handles);

