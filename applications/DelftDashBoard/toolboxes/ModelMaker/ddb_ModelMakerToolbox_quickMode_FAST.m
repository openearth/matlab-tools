function ddb_ModelMakerToolbox_quickMode_FAST(varargin)
%DDB_MODELMAKERTOOLBOX_QUICKMODE_FAST  One line description goes here.

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2014 Deltares
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
% wd: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: ddb_ModelMakerToolbox_quickMode.m 10436 2014-03-24 22:26:17Z ormondt $
% $Date: 2014-03-24 23:26:17 +0100 (Mon, 24 Mar 2014) $
% $Author: ormondt $
% $Revision: 10436 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode.m $
% $Keywords: $

%%
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    if ~isempty(handles.toolbox.modelmaker.polygonHandle)
        setInstructions({'','','Draw polygon to outline area in which depth contours will be scanned'});
    end
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch opt
        case{'drawdemoutline'}
            setInstructions({'','','Use mouse to draw image outline on map'});
            gui_rectangle(handles.GUIHandles.mapAxis,'draw','Tag','modelmakerdemoutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeDEMOnMap,'onstart',@deleteDEMOutline);
        case{'generateimage'}
            generateImage;
        case{'editdemoutline'}
            editOutline;
        case{'drawpolygon'}
            drawPolygon;
        case{'makedem'}
            makeDEM;
        case{'loaddem'}
            loadDEM;
            editOutline;
        case{'loadpoints'}
            loadPoints;
            % moved from ddb_FAST_domain.m
        case{'createpoints'}
            createPoints;
        case{'runfast'}
            runFAST;
    end
    
end


%%
function changeDEMOnMap(x0,y0,dx,dy,rotation,h)

setInstructions({'','Left-click and drag markers to change corner points','Right-click and drag yellow marker to move entire box'});

handles=getHandles;
handles.toolbox.modelmaker.dem.outlinehandle=h;
handles.toolbox.modelmaker.dem.xlim(1)=x0;
handles.toolbox.modelmaker.dem.ylim(1)=y0;
handles.toolbox.modelmaker.dem.xlim(2)=x0+dx;
handles.toolbox.modelmaker.dem.ylim(2)=y0+dy;

setHandles(handles);

gui_updateActiveTab;

%%
function editOutline
handles=getHandles;
if ~isempty(handles.toolbox.modelmaker.dem.outlinehandle)
    try
        delete(handles.toolbox.modelmaker.dem.outlinehandle);
    end
end

if handles.toolbox.modelmaker.dem.xlim(2)<handles.toolbox.modelmaker.dem.xlim(1)
    handles.toolbox.modelmaker.dem.xlim=fliplr(handles.toolbox.modelmaker.dem.xlim);
end
if handles.toolbox.modelmaker.dem.ylim(2)<handles.toolbox.modelmaker.dem.ylim(1)
    handles.toolbox.modelmaker.dem.ylim=fliplr(handles.toolbox.modelmaker.dem.ylim);
end
    
x0=handles.toolbox.modelmaker.dem.xlim(1);
y0=handles.toolbox.modelmaker.dem.ylim(1);
dx=handles.toolbox.modelmaker.dem.xlim(2)-x0;
dy=handles.toolbox.modelmaker.dem.ylim(2)-y0;

h=gui_rectangle(handles.GUIHandles.mapAxis,'plot','Tag','modelmakerdemoutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',0,'callback',@changeDEMOnMap, ...
    'onstart',@deleteDEMOutline,'x0',x0,'y0',y0,'dx',dx,'dy',dy);
handles.toolbox.modelmaker.dem.outlinehandle=h;
setHandles(handles);

%%
function deleteDEMOutline
handles=getHandles;
if ~isempty(handles.toolbox.modelmaker.dem.outlinehandle)
    try
        delete(handles.toolbox.modelmaker.dem.outlinehandle);
    end
end

%%
function drawPolygon

handles=getHandles;
ddb_zoomOff;
h=findobj(gcf,'Tag','modelmakerpolygon');
if ~isempty(h)
    delete(h);
end

handles.toolbox.modelmaker.polygonX=[];
handles.toolbox.modelmaker.polygonY=[];
handles.toolbox.modelmaker.polyLength=0;

handles.toolbox.modelmaker.polygonhandle=gui_polyline('draw','tag','modelmakerpolygon','marker','o', ...
    'createcallback',@createPolygon,'changecallback',@changePolygon, ...
    'closed',1);

setHandles(handles);

%%
function createPolygon(h,x,y)
handles=getHandles;
handles.toolbox.modelmaker.polygonhandle=h;
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
setHandles(handles);
gui_updateActiveTab;

%%
function deletePolygon
handles=getHandles;
handles.toolbox.modelmaker.polygonX=[];
handles.toolbox.modelmaker.polygonY=[];
handles.toolbox.modelmaker.polyLength=0;
h=findobj(gcf,'Tag','bathymetrypolygon');
if ~isempty(h)
    delete(h);
end
setHandles(handles);

%%
function changePolygon(h,x,y,varargin)
handles=getHandles;
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
setHandles(handles);

%%
function loadPolygon
handles=getHandles;
[x,y]=landboundary('read',handles.toolbox.modelmaker.polygonFile);
handles.toolbox.modelmaker.polygonX=x;
handles.toolbox.modelmaker.polygonY=y;
handles.toolbox.modelmaker.polyLength=length(x);
h=findobj(gca,'Tag','modelmakerpolygon');
delete(h);
h=gui_polyline('plot','x',x,'y',y,'tag','modelmakerpolygon','marker','o', ...
        'changecallback',@changePolygon);
handles.toolbox.modelmaker.polygonhandle=h;
setHandles(handles);

%%
function makeDEM

handles=getHandles;

% Check if bathymetry datasets have been selected
if handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets==0
    ddb_giveWarning('text','First select one or more bathymetry datasets!');
    return
end

[filename, pathname, filterindex] = uiputfile('*.asc', 'DEM File Name',handles.toolbox.modelmaker.dem.demfile);
if pathname~=0
    if ~strcmpi(pathname(1:end-1),pwd)
        filename=[pathname filename];
    end
else
    return
end

% Create DEM grid
dx=handles.toolbox.modelmaker.dem.dx/60/60; % convert dx to decimal degrees
dy=handles.toolbox.modelmaker.dem.dy/60/60; % convert dy to decimal degrees
xx=handles.toolbox.modelmaker.dem.xlim(1):dx:handles.toolbox.modelmaker.dem.xlim(2);
yy=handles.toolbox.modelmaker.dem.ylim(1):dy:handles.toolbox.modelmaker.dem.ylim(2);
[xg,yg]=meshgrid(xx,yy);
zg=zeros(size(xg));
zg(zg==0)=NaN;

% Selected dataset
for ii=1:handles.toolbox.modelmaker.bathymetry.nrSelectedDatasets
    nr=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).number;
    datasets(ii).name=handles.bathymetry.datasets{nr};
    datasets(ii).startdates=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).startDate;
    datasets(ii).searchintervals=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).searchInterval;
    datasets(ii).zmin=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMin;
    datasets(ii).zmax=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).zMax;
    datasets(ii).verticaloffset=handles.toolbox.modelmaker.bathymetry.selectedDatasets(ii).verticalLevel;
end

[xg,yg,zg]=ddb_ModelMakerToolbox_generateBathymetry(handles,xg,yg,zg,datasets);

handles.toolbox.modelmaker.dem.x=xx;
handles.toolbox.modelmaker.dem.y=yy;
handles.toolbox.modelmaker.dem.z=zg;

handles.toolbox.modelmaker.dem.demfile=filename;

arcgridwrite(filename,xg,yg,zg);

setHandles(handles);

%%
function loadDEM

handles=getHandles;


[filename, pathname, filterindex] = uigetfile('*.asc', 'DEM File Name',handles.toolbox.modelmaker.dem.demfile);
if pathname~=0
    if ~strcmpi(pathname(1:end-1),pwd)
        filename=[pathname filename];
    end
else
    return
end

handles.toolbox.modelmaker.dem.demfile=filename;

% Create DEM grid
filedata=arcgrid('read',filename);
dx=filedata.CellSize(1);
dy=filedata.CellSize(2);
defval=filedata.NoData;
ncol=filedata.NCols;
nrow=filedata.NRows;
handles.toolbox.modelmaker.dem.xlim(1)=filedata.XCorner+0.5*dx;
handles.toolbox.modelmaker.dem.ylim(1)=filedata.YCorner+0.5*dy;
handles.toolbox.modelmaker.dem.xlim(2)=filedata.XCorner+(ncol-0.5)*dx;
handles.toolbox.modelmaker.dem.ylim(2)=filedata.YCorner+(nrow-0.5)*dy;
handles.toolbox.modelmaker.dem.dx=dx*60.*60.;
handles.toolbox.modelmaker.dem.dy=dy*60.*60.;
filedata.Data(filedata.Data==defval)=NaN;

handles.toolbox.modelmaker.dem.x=filedata.x;
handles.toolbox.modelmaker.dem.y=fliplr(filedata.y);
handles.toolbox.modelmaker.dem.z=flipud(filedata.Data');

setHandles(handles);

%%
function createPoints

handles=getHandles;

[filename, pathname, filterindex] = uiputfile('*.dat', 'FAST Input File Name',handles.model.fast.domain.domainfile);
if pathname~=0
    if ~strcmpi(pathname(1:end-1),pwd)
        filename=[pathname filename];
    end
else
    return
end
filexyz=[filename(1:length(filename)-4) '.xyz'] 

handles.model.fast.domain.domainfile=filename;

x=handles.toolbox.modelmaker.dem.x;
y=handles.toolbox.modelmaker.dem.y;
z=handles.toolbox.modelmaker.dem.z;

wb=waitbox('Creating FAST points ...');
try
    fast=fast_generateinput('xd',x,'yd',y,'zd',z,'interval',handles.toolbox.modelmaker.distance, ...
        'contourdepth',handles.toolbox.modelmaker.depthcontour,'dirbin',handles.toolbox.modelmaker.dirbin, ...
        'radbin',handles.toolbox.modelmaker.radbin,'maximumradius',handles.toolbox.modelmaker.maxrad, ...
        'maxelev',handles.toolbox.modelmaker.maxelevation);
catch
    close(wb);
    ddb_giveWarning('text','Something went wrong while creating FAST points!');
    return
end
close(wb);

handles=ddb_FAST_pointsstruc2domain(handles,fast);

handles.model.fast.domain.nrpoints=length(handles.model.fast.domain.points);
handles.model.fast.domain.activepoint=1;
handles.model.fast.domain.activepoints=1;

hmax=2;
period=900;
handles=ddb_FAST_initializeBoundaryConditions(handles,hmax,period);

ddb_FAST_saveDomainFile(fast,filename);
ddb_FAST_saveXYZFile(fast,filexyz,period);

handles=ddb_FAST_updatePointNames(handles);

handles=ddb_FAST_plotPoints(handles,'plot');

save([filename(1:end-4) '.mat'],'-struct','fast');

setHandles(handles);

%%
function loadPoints
handles=getHandles;
if isempty(handles.toolbox.modelmaker.dem.demfile)
    ddb_giveWarning('text','First load or create the DEM datasets!');
    return
end

handles=ddb_FAST_loadPoints(handles);
   
%hmax=2;
period=900;
% hmax niet meer gebruiken; staat al in de file
% handles=ddb_FAST_initializeBoundaryConditions(handles,hmax,period);
for ip=1:handles.model.fast.domain.nrpoints
    handles.model.fast.domain.points(ip).period=period;
    handles.model.fast.domain.activehmax=handles.model.fast.domain.points(ip).hmax;
    handles.model.fast.domain.activeperiod=period;
end
%
% For consistency and screen update
%
handles.toolbox.modelmaker.depthcontour=handles.model.fast.domain.contourdepth;
handles.toolbox.modelmaker.distance=handles.model.fast.domain.pinterval;
handles.toolbox.modelmaker.maxrad=handles.model.fast.domain.lenmax;
handles.toolbox.modelmaker.dirbin=handles.model.fast.domain.dphi;
handles.toolbox.modelmaker.radbin=handles.model.fast.domain.dx;
handles.toolbox.modelmaker.maxelevation=handles.model.fast.domain.zmax;

handles=ddb_FAST_plotPoints(handles,'plot');
setHandles(handles);

%%
function runFAST

handles=getHandles;
hmax=[];
fast=handles.model.fast.domain;
% In case hmax values has changed load and check hmax data from XYZ-file
filename=handles.model.fast.domain.domainfile;
filexyz=[filename(1:length(filename)-4) '.xyz'];
period=handles.model.fast.domain.activeperiod; 
% parameter period below is as yet a dummy paramater
fast=ddb_FAST_loadcheckXYZFile(handles,fast,filexyz,period);

% Assume same output grid as bathymetry grid

xdem=handles.toolbox.modelmaker.dem.x;
ydem=handles.toolbox.modelmaker.dem.y;
zdem=handles.toolbox.modelmaker.dem.z;

wb=waitbox('Running FAST ...');
try
    zg=fast_run(handles.model.fast.domain,hmax,xdem,ydem);
catch
    close(wb);
    ddb_giveWarning('text','Something went wrong while running FAST!');
    return
end
close(wb);

% arcgridwrite('sendai_test_output.asc',xdem,ydem',zg);
zmask=compzmask(xdem,ydem,zdem);
zg=zg.*zmask;
% arcgridwrite('sendai_test_output2.asc',xdem,ydem',zg);
zg(zg<=0.1)=NaN;
arcgridwrite('sendai_test_output3.asc',xdem,ydem',zg);


% figure(250)
% clf
% inund=10-handles.toolbox.modelmaker.dem.z;
% inund(inund<0)=NaN;
% inund(inund>10)=NaN;
% pcolor(xdem,ydem,inund);shading flat;colorbar;hold on
% axis equal
% 
% figure(300)
% clf
% pcolor(xdem,ydem,zg);shading flat;colorbar;hold on
% axis equal

%% Superoverlay
xmin=xdem(1);
xmax0=xdem(end);
ymin=ydem(1);
ymax0=ydem(end);
dx=xdem(2)-xdem(1);
dy=ydem(2)-ydem(1);
npx0=(xmax0-xmin)/dx+1;
npy0=(ymax0-ymin)/dy+1;

npx=roundup(npx0,256);
npy=roundup(npy0,256);

ii=0:20;
tilesizes=256*2.^ii;
npmax=max(npx,npy);
ii=find(tilesizes>=npmax,1,'first');
npmax=tilesizes(ii);

ntx=npmax/256;
nty=npmax/256;

itiles{1}=zeros(ntx,nty);

s=sparse(npmax,npmax);

kmlfile='sendai_test.kml';
s(1:size(zg,1),1:size(zg,2))=zg;
xmin=xdem(1);
ymin=ydem(1);
colorlimits=[0 20];
folder='sendai2';
name='sendai';
colorbarlabel='inundation height (m)';
superoverlay(kmlfile,s,xmin,ymin,dx,dy,'name',name,'colorlimits',colorlimits,'directory',folder,'transparency',1,'colorbarlabel',colorbarlabel);
