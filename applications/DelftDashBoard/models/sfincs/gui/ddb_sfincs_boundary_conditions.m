function ddb_sfincs_boundary_conditions(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2017 Deltares
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

% $Id: ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m 10447 2014-03-26 07:06:47Z ormondt $
% $Date: 2014-03-26 08:06:47 +0100 (Wed, 26 Mar 2014) $
% $Author: ormondt $
% $Revision: 10447 $
% $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/applications/DelftDashBoard/toolboxes/ModelMaker/ddb_ModelMakerToolbox_quickMode_Delft3DWAVE.m $
% $Keywords: $

%%
ddb_zoomOff;


if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotsfincs('update','active',1,'visible',1);
    handles=getHandles;
    h=handles.model.sfincs.boundaryspline.handle;
    if ~isempty(h)
        set(h,'visible','on');
    end
    h=handles.model.sfincs.depthcontour.handle;
    if ~isempty(h)
        set(h,'visible','on');
    end
        
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'drawboundaryspline'}
            draw_boundary_spline;
        case{'deleteboundaryspline'}
            delete_boundary_spline;
        case{'loadboundaryspline'}
            load_boundary_spline;
        case{'saveboundaryspline'}
            save_boundary_spline;
        case{'updatedepthcontour'}
            update_depth_contour;
        case{'snapboundarysplinetodepthcontour'}
            snap_boundary_spline_to_depth_contour;            
            
        case{'createflowboundarypoints'}
            create_flow_boundary_points;
        case{'removeflowboundarypoints'}
            remove_flow_boundary_points;
        case{'loadflowboundarypoints'}
            load_flow_boundary_points;
        case{'saveflowboundarypoints'}
            save_flow_boundary_points;
        case{'snapboundarypointstodepthcontour'}
            snap_boundary_points_to_depth_contour;            
            

        case{'createwaveboundarypoints'}
            create_wave_boundary_points;
        case{'removewaveboundarypoints'}
            remove_wave_boundary_points;
        case{'loadwaveboundarypoints'}
            load_wave_boundary_points;
        case{'savewaveboundarypoints'}
            save_wave_boundary_points;
        case{'saveboundaryconditions'}
            save_boundary_conditions;

        case{'generatebcafile'}
            generate_bca_file;
        case{'generatetides'}
            generate_tides;
            
    end
    
end

%%
function draw_boundary_spline

setInstructions({'','Click on map to draw boundary spline','Use right-click to end coast line'});

ddb_zoomOff;

gui_polyline('draw','Tag','sfincsboundaryspline','Marker','o','createcallback',@create_boundary_spline,'changecallback',@change_boundary_spline, ...
    'type','spline','closed',0);

%%
function create_boundary_spline(h,x,y,nr)

delete_boundary_spline;

handles=getHandles;
handles.model.sfincs.boundaryspline.handle=h;
handles.model.sfincs.boundaryspline.x=x;
handles.model.sfincs.boundaryspline.y=y;
handles.model.sfincs.boundaryspline.length=length(x);
handles.model.sfincs.boundaryspline.changed=1;
setHandles(handles);

gui_updateActiveTab;

%%
function load_boundary_spline
handles=getHandles;

delete_boundary_spline

clear data
data = tekal('read', handles.model.sfincs.boundaryspline.filename,'loaddata') ;
% assumed is that only 1 single polyline is given!
% also assumed that polygon is in same CRS as current CRS!

x = data.Field.Data(:,1);  
y = data.Field.Data(:,2);  

handles.model.sfincs.boundaryspline.x=x;
handles.model.sfincs.boundaryspline.y=y;
handles.model.sfincs.boundaryspline.length=length(x);
handles.model.sfincs.boundaryspline.changed=1;

gui_polyline('plot','x',x,'y',y,'Tag','sfincsboundaryspline','Marker','o','createcallback',@create_boundary_spline,'changecallback',@change_boundary_spline, ...
    'type','spline','closed',0);
setHandles(handles);

%%
function delete_boundary_spline

handles=getHandles;

h=handles.model.sfincs.boundaryspline.handle;
if ~isempty(h)
    try
        delete(h);
    end
end

handles.model.sfincs.boundaryspline.handle=[];
handles.model.sfincs.boundaryspline.x=[];
handles.model.sfincs.boundaryspline.y=[];
handles.model.sfincs.boundaryspline.changed=0;
handles.model.sfincs.boundaryspline.length=0;

setHandles(handles);

%%
function save_boundary_spline

handles=getHandles;
x=handles.model.sfincs.boundaryspline.x;
y=handles.model.sfincs.boundaryspline.y;
fid=fopen(handles.model.sfincs.boundaryspline.filename,'wt');
fprintf(fid,'%s\n','BL01');
fprintf(fid,'%i %i\n',length(x),2);
for j=1:length(x)
    fprintf(fid,'%17.10e %17.10e\n',x(j),y(j));
end
fclose(fid);
setHandles(handles);

%%
function change_boundary_spline(h,x,y,nr)

handles=getHandles;

handles.model.sfincs.boundaryspline.handle=h;
handles.model.sfincs.boundaryspline.x=x;
handles.model.sfincs.boundaryspline.y=y;
handles.model.sfincs.boundaryspline.length=length(x);
handles.model.sfincs.boundaryspline.changed=1;

setHandles(handles);

%%
function update_depth_contour

handles=getHandles;

xz=handles.GUIData.x;
yz=handles.GUIData.y;
zz=handles.GUIData.z;

h=handles.model.sfincs.depthcontour.handle;
if ~isempty(h)
    try
        delete(h);
    end
end

val=handles.model.sfincs.depthcontour.value;

[c,h]=contour(xz,yz,zz, [val val]);
set(h,'Color','r','LineWidth',2);
set(h,'Tag','datadepthcontour');
set(h,'HitTest','off');

handles.model.sfincs.depthcontour.handle=h;

setHandles(handles);

%%
function snap_boundary_spline_to_depth_contour
handles=getHandles;

h=handles.model.sfincs.boundaryspline.handle;
if ~isempty(h)
    try
        delete(h);
    end
end

xz=handles.GUIData.x;
yz=handles.GUIData.y;
zz=handles.GUIData.z;

val=handles.model.sfincs.depthcontour.value;

[c,~]=contour(xz,yz,zz, [val val]);

%
if isempty(c)
    ddb_giveWarning('text',['No contour found for depth: ',num2str(val)]);    
end
    
%
xtmp = c(1,:);
ytmp = c(2,:);

id = find(xtmp == val);
xtmp(id) = NaN;
ytmp(id) = NaN;

xtmp = xtmp(~isnan(xtmp));
ytmp = ytmp(~isnan(ytmp));

x = handles.model.sfincs.boundaryspline.x;
y = handles.model.sfincs.boundaryspline.y;

xchanged = x;
ychanged = y;

% snap boundary spline to nearest depth contour point
if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
    distmax = 100000; %100km
else %geographic
    distmax = 1.0;  %point needs to be found within 100km
end

for id = 1:handles.model.sfincs.boundaryspline.length

    [index, distance, twoout] = nearxy(xtmp',ytmp',x(id),y(id),distmax);

    if ~isempty(index)
        [mindistance,idmindistance] = min(distance);

        idwanted = index(idmindistance);

        xchanged(id) = xtmp(idwanted);
        ychanged(id) = ytmp(idwanted);        
    end
end

% figure; hold on; plot(xtmp, ytmp,'k.');plot(x, y,'b.'); plot(xchanged, ychanged,'ro')

handles.model.sfincs.boundaryspline.x = xchanged;
handles.model.sfincs.boundaryspline.y = ychanged;
handles.model.sfincs.boundaryspline.length=length(xchanged);
handles.model.sfincs.boundaryspline.changed=1;

gui_polyline('plot','x',xchanged,'y',ychanged,'Tag','sfincsboundaryspline','Marker','o','createcallback',@create_boundary_spline,'changecallback',@change_boundary_spline, ...
    'type','spline','closed',0);

setHandles(handles);


%%
function create_flow_boundary_points

handles=getHandles;

xs=handles.model.sfincs.boundaryspline.x;
ys=handles.model.sfincs.boundaryspline.y;

cstype=handles.screenParameters.coordinateSystem.type;
[xp,yp]=spline2d(xs,ys,handles.model.sfincs.boundaryspline.flowdx,cstype);

merge=0;
if ~isempty(handles.model.sfincs.domain(ad).flowboundarypoints.x)
    % Boundary points already exist
    ButtonName = questdlg('Merge with existing boundary points ?', ...
        'Merge Points', ...
        'Cancel', 'No', 'Yes', 'Yes');
    switch ButtonName,
        case 'Cancel',
            return;
        case 'No',
            merge=0;
        case 'Yes',
            merge=1;
    end
end

if merge
    handles.model.sfincs.domain(ad).flowboundarypoints.x=[handles.model.sfincs.domain(ad).flowboundarypoints.x xp];
    handles.model.sfincs.domain(ad).flowboundarypoints.y=[handles.model.sfincs.domain(ad).flowboundarypoints.y yp];
else
    handles.model.sfincs.domain(ad).flowboundarypoints.x=xp;
    handles.model.sfincs.domain(ad).flowboundarypoints.y=yp;
end

handles.model.sfincs.domain(ad).flowboundarypoints.length=length(handles.model.sfincs.domain(ad).flowboundarypoints.x);

%if isempty(handles.model.sfincs.domain(ad).input.bndfile)
handles.model.sfincs.domain(ad).input.bndfile='sfincs.bnd';
handles.model.sfincs.domain(ad).input.bzsfile='sfincs.bzs';
% handles.model.sfincs.domain(ad).flowboundarypoints.time=[handles.model.sfincs.domain(ad).input.tref;handles.model.sfincs.domain(ad).input.tstop];
% handles.model.sfincs.domain(ad).flowboundarypoints.zs=zeros(2,length(xp))+handles.model.sfincs.boundaryconditions.zs;
%end

% Set new boundary conditions at 0.0
handles.model.sfincs.domain(ad).flowboundarypoints.time=[handles.model.sfincs.domain(ad).input.tref;handles.model.sfincs.domain(ad).input.tstop];
handles.model.sfincs.domain(ad).flowboundarypoints.zs=zeros(2,length(xp));
handles.model.sfincs.domain(ad).flowboundarypoints.astronomic_components=[];

setHandles(handles);

delete_flow_boundary_points;

plot_flow_boundary_points;

save_flow_boundary_points;
save_flow_boundary_conditions;


%%
function remove_flow_boundary_points

handles=getHandles;

handles.model.sfincs.domain(ad).input.bndfile='';
handles.model.sfincs.domain(ad).input.bzsfile='';
handles.model.sfincs.domain(ad).input.bcafile='';

handles.model.sfincs.domain(ad).flowboundarypoints.x=[];
handles.model.sfincs.domain(ad).flowboundarypoints.y=[];
handles.model.sfincs.domain(ad).flowboundarypoints.length=0;
handles.model.sfincs.domain(ad).flowboundarypoints.time=[];
handles.model.sfincs.domain(ad).flowboundarypoints.zs=[];
handles.model.sfincs.domain(ad).astronomic_components=[];

setHandles(handles);

delete_flow_boundary_points;

%%
function load_flow_boundary_points

handles=getHandles;
handles.model.sfincs.domain(ad).input.bzsfile='';
handles.model.sfincs.domain(ad).input.bcafile='';
setHandles(handles);

remove_flow_boundary_points;

ddb_sfincs_open_bnd_file;

plot_flow_boundary_points;

%%
function save_flow_boundary_points

ddb_sfincs_save_bnd_file;

%%
function save_flow_boundary_conditions

ddb_sfincs_save_bzs_file;

%%
function snap_boundary_points_to_depth_contour

handles=getHandles;

xz=handles.GUIData.x;
yz=handles.GUIData.y;
zz=handles.GUIData.z;

val=handles.model.sfincs.depthcontour.value;

[c,~]=contour(xz,yz,zz, [val val]);

%
if isempty(c)
    ddb_giveWarning('text',['No contour found for depth: ',num2str(val)]);    
end
    
%
xtmp = c(1,:);
ytmp = c(2,:);

id = find(xtmp == val);
xtmp(id) = NaN;
ytmp(id) = NaN;

xtmp = xtmp(~isnan(xtmp));
ytmp = ytmp(~isnan(ytmp));

x = handles.model.sfincs.domain(ad).flowboundarypoints.x;
y = handles.model.sfincs.domain(ad).flowboundarypoints.y;

xchanged = x;
ychanged = y;

% snap boundary points to nearest depth contour point
if strcmpi(handles.screenParameters.coordinateSystem.type,'cartesian')
    distmax = 100000; %100km
else %geographic
    distmax = 1.0;  %point needs to be found within 100km
end

for id = 1:handles.model.sfincs.domain(ad).flowboundarypoints.length

    [index, distance, twoout] = nearxy(xtmp',ytmp',x(id),y(id),distmax);

    if ~isempty(index)
        [mindistance,idmindistance] = min(distance);

        idwanted = index(idmindistance);

        xchanged(id) = xtmp(idwanted);
        ychanged(id) = ytmp(idwanted);        
    end
end

handles.model.sfincs.domain(ad).flowboundarypoints.x = xchanged;
handles.model.sfincs.domain(ad).flowboundarypoints.y = ychanged;
handles.model.sfincs.domain(ad).flowboundarypoints.length  = length(xchanged);

setHandles(handles);

delete_flow_boundary_points;

plot_flow_boundary_points;

%%
function generate_bca_file

handles=getHandles;

wb=waitbox('Fetching astronomical components ...');

try
    
    x=handles.model.sfincs.domain(ad).flowboundarypoints.x;
    y=handles.model.sfincs.domain(ad).flowboundarypoints.y;
    
    % Convert to lat-lon
    cs.name='WGS 84';
    cs.type='geographic';
    [x,y]=ddb_coordConvert(x,y,handles.screenParameters.coordinateSystem,cs);
    
    ii=handles.toolbox.tidedatabase.activeModel;
    name=handles.tideModels.model(ii).name;
    if strcmpi(handles.tideModels.model(ii).URL(1:4),'http')
        tidefile=[handles.tideModels.model(ii).URL '/' name '.nc'];
    else
        tidefile=[handles.tideModels.model(ii).URL filesep name '.nc'];
    end
    
    [gt,conList] =  read_tide_model(tidefile,'type','h','x',x','y',y','constituent','all');
    
    handles.model.sfincs.domain(ad).input.bcafile='sfincs.bca';
    
    % Now make a bca file
    refdate=floor(now);
    boundary(1).boundary=ddb_delft3dfm_initialize_boundary('sfincs','water_level','astronomic',refdate,refdate,x,y);
    boundary(1).boundary.water_level.astronomic_components.forcing_file='sfincs.bca';
    for ip=1:length(x)
        for ic=1:length(conList)
            boundary(1).boundary.water_level.astronomic_components.nodes(ip).name{ic}=conList{ic};
            boundary(1).boundary.water_level.astronomic_components.nodes(ip).amplitude(ic)=gt.amp(ic,ip);
            boundary(1).boundary.water_level.astronomic_components.nodes(ip).phase(ic)=gt.phi(ic,ip);
        end
    end
    
    delft3dfm_write_bc_file(boundary,refdate);
    
    handles.model.sfincs.domain(ad).astronomic_components=boundary(1).boundary.water_level.astronomic_components;
    
    setHandles(handles);
    
    close(wb);
    
    % Also generate tide time series
    generate_tides;
    
catch
    close(wb);
    ddb_giveWarning('error','Something went wrong while generating bca file ...');
end

%%
function generate_tides

handles=getHandles;

if isempty(handles.model.sfincs.domain(ad).astronomic_components)
    ddb_giveWarning('text','Please first generate astronomic components in BCA file!');
end

tim=handles.model.sfincs.domain(ad).input.tstart:10/1440:handles.model.sfincs.domain(ad).input.tstop;

x=handles.model.sfincs.domain(ad).flowboundarypoints.x;
y=handles.model.sfincs.domain(ad).flowboundarypoints.y;

% Convert to lat-lon
cs.name='WGS 84';
cs.type='geographic';
[x,y]=ddb_coordConvert(x,y,handles.screenParameters.coordinateSystem,cs);

wl=zeros(length(tim),length(x));

for ip=1:length(x)
    conList={};
    gt0=[];
    for ic=1:length(handles.model.sfincs.domain(ad).astronomic_components.nodes(ip).name)
        conList{ic}=handles.model.sfincs.domain(ad).astronomic_components.nodes(ip).name{ic};
        gt0.amp(ic)=handles.model.sfincs.domain(ad).astronomic_components.nodes(ip).amplitude(ic);
        gt0.phi(ic)=handles.model.sfincs.domain(ad).astronomic_components.nodes(ip).phase(ic);
    end
    wl0=makeTidePrediction(tim,conList,gt0.amp,gt0.phi,y(ip));
    wl(:,ip)=wl0';
end
handles.model.sfincs.domain(ad).flowboundarypoints.time=tim;
handles.model.sfincs.domain(ad).flowboundarypoints.zs=wl;

setHandles(handles);

save_flow_boundary_conditions;

%%
function delete_flow_boundary_points

handles=getHandles;

handles=ddb_sfincs_plot_flow_boundary_points(handles,'delete','domain',ad);

setHandles(handles);

%%
function plot_flow_boundary_points

handles=getHandles;

handles=ddb_sfincs_plot_flow_boundary_points(handles,'plot','domain',ad);

setHandles(handles);

%%
function input_changed
handles=getHandles;
if handles.auto_save
    ddb_sfincs_save_bnd_file;
    ddb_sfincs_save_bzs_file;
end
