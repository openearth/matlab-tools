function ddb_ModelMakerToolbox_quickMode_Delft3DWAVE(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE_DELFT3DWAVE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_quickMode_Delft3DWAVE(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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
    ddb_plotModelMaker('activate');
    if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
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
    end
    
end

%%
function drawGridOutline
handles=getHandles;
setInstructions({'','','Use mouse to draw grid outline on map'});
UIRectangle(handles.GUIHandles.mapAxis,'draw','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline,'onstart',@deleteGridOutline, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);

%%
function updateGridOutline(x0,y0,dx,dy,rotation,h)

setInstructions({'Left-click and drag markers to change corner points','Right-click and drag YELLOW marker to move entire box', ...
    'Right-click and drag RED markers to rotate box (note: rotating grid in geographic coordinate systems is NOT recommended!)'});

handles=getHandles;

handles.Toolbox(tb).Input.gridOutlineHandle=h;

handles.Toolbox(tb).Input.xOri=x0;
handles.Toolbox(tb).Input.yOri=y0;
handles.Toolbox(tb).Input.rotation=rotation;
handles.Toolbox(tb).Input.nX=round(dx/handles.Toolbox(tb).Input.dX);
handles.Toolbox(tb).Input.nY=round(dy/handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.lengthX=dx;
handles.Toolbox(tb).Input.lengthY=dy;

setHandles(handles);

gui_updateActiveTab;

%%
function deleteGridOutline
handles=getHandles;
if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

%%
function editGridOutline

handles=getHandles;

if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

handles.Toolbox(tb).Input.lengthX=handles.Toolbox(tb).Input.dX*handles.Toolbox(tb).Input.nX;
handles.Toolbox(tb).Input.lengthY=handles.Toolbox(tb).Input.dY*handles.Toolbox(tb).Input.nY;

lenx=handles.Toolbox(tb).Input.dX*handles.Toolbox(tb).Input.nX;
leny=handles.Toolbox(tb).Input.dY*handles.Toolbox(tb).Input.nY;
h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.Toolbox(tb).Input.xOri,'y0',handles.Toolbox(tb).Input.yOri,'dx',lenx,'dy',leny,'rotation',handles.Toolbox(tb).Input.rotation, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.gridOutlineHandle=h;

setHandles(handles);

%%
function editResolution

handles=getHandles;

lenx=handles.Toolbox(tb).Input.lengthX;
leny=handles.Toolbox(tb).Input.lengthY;

dx=handles.Toolbox(tb).Input.dX;
dy=handles.Toolbox(tb).Input.dY;

nx=round(lenx/max(dx,1e-9));
ny=round(leny/max(dy,1e-9));

handles.Toolbox(tb).Input.nX=nx;
handles.Toolbox(tb).Input.nY=ny;

handles.Toolbox(tb).Input.lengthX=nx*dx;
handles.Toolbox(tb).Input.lengthY=ny*dy;

if ~isempty(handles.Toolbox(tb).Input.gridOutlineHandle)
    try
        delete(handles.Toolbox(tb).Input.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.Toolbox(tb).Input.xOri,'y0',handles.Toolbox(tb).Input.yOri,'dx',handles.Toolbox(tb).Input.lengthX,'dy',handles.Toolbox(tb).Input.lengthY, ...
    'rotation',handles.Toolbox(tb).Input.rotation, ...
    'ddx',handles.Toolbox(tb).Input.dX,'ddy',handles.Toolbox(tb).Input.dY);
handles.Toolbox(tb).Input.gridOutlineHandle=h;

setHandles(handles);

%%
function generateGrid

handles=getHandles;

npmax=20000000;

if handles.Toolbox(tb).Input.nX*handles.Toolbox(tb).Input.nY<=npmax
    
    [filename, pathname, filterindex] = uiputfile('*.grd', 'Grid File Name',[handles.Model(md).Input.attname '.grd']);
    
    for ii=1:handles.Model(md).Input.nrgrids
        if strcmpi(filename(1:end-4),handles.Model(md).Input.domains(ii).gridname)
            ddb_giveWarning('text','A domain with this name already exists. Try again.');
            return
        end
    end
    
    if pathname~=0
        
        wb = waitbox('Generating grid ...');pause(0.1);
        
        xori=handles.Toolbox(tb).Input.xOri;
        nx=handles.Toolbox(tb).Input.nX;
        dx=handles.Toolbox(tb).Input.dX;
        yori=handles.Toolbox(tb).Input.yOri;
        ny=handles.Toolbox(tb).Input.nY;
        dy=handles.Toolbox(tb).Input.dY;
        rot=pi*handles.Toolbox(tb).Input.rotation/180;
        zmax=handles.Toolbox(tb).Input.zMax;
        
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
        x(2)=x(1)+nx*dx*cos(pi*handles.Toolbox(tb).Input.rotation/180);
        y(2)=y(1)+nx*dx*sin(pi*handles.Toolbox(tb).Input.rotation/180);
        x(3)=x(2)+ny*dy*cos(pi*(handles.Toolbox(tb).Input.rotation+90)/180);
        y(3)=y(2)+ny*dy*sin(pi*(handles.Toolbox(tb).Input.rotation+90)/180);
        x(4)=x(3)+nx*dx*cos(pi*(handles.Toolbox(tb).Input.rotation+180)/180);
        y(4)=y(3)+nx*dx*sin(pi*(handles.Toolbox(tb).Input.rotation+180)/180);
        
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
        
        [xx,yy,zz,ok]=ddb_getBathy(handles,xlb,ylb,'bathymetry',handles.screenParameters.backgroundBathymetry,'maxcellsize',dmin);
        
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
        
        handles.Model(md).Input.nrgrids=handles.Model(md).Input.nrgrids+1;
        nrgrids=handles.Model(md).Input.nrgrids;
        handles.Model(md).Input.gridnames{nrgrids}=filename(1:end-4);
        handles.Model(md).Input.domains=ddb_initializeDelft3DWAVEDomain(handles.Model(md).Input.domains,nrgrids);
        handles.activeWaveGrid=nrgrids;
        OPT.option = 'write'; OPT.x = x; OPT.y = y; OPT.z = z; OPT.filename = filename;
        handles = ddb_generateGridDelft3DWAVE(handles,nrgrids,OPT);
        if nrgrids>1
            handles.Model(md).Input.domains(nrgrids).nestgrid=handles.Model(md).Input.domains(1).gridname;
        else
            handles.Model(md).Input.domains(nrgrids).nestgrid='';
        end

        % Plot new domain
        handles=ddb_Delft3DWAVE_plotGrid(handles,'plot','wavedomain',nrgrids,'active',1);

        setHandles(handles);

        % Refresh all domains
        ddb_plotDelft3DWAVE('update','wavedomain',0,'active',1);

    end
    
else
    GiveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
end

%%
function generateBathymetry
handles=getHandles;
[filename, pathname, filterindex] = uiputfile('*.dep', 'Depth File Name',[handles.Model(md).Input(ad).attName '.dep']);
if pathname~=0
    handles=ddb_generateBathymetryDelft3DFLOW(handles,ad,filename);
end
setHandles(handles);
