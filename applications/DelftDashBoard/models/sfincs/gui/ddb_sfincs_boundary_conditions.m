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

        case{'createflowboundarypoints'}
            create_flow_boundary_points;
        case{'removeflowboundarypoints'}
            remove_flow_boundary_points;
        case{'loadflowboundarypoints'}
            load_flow_boundary_points;
        case{'saveflowboundarypoints'}
            save_flow_boundary_points;

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
            
    end
    
end

%%
function draw_boundary_spline

setInstructions({'','Click on map to draw boundary spline','Use right-click to end coast line'});

ddb_zoomOff;

gui_polyline('draw','Tag','sfincsboundaryspline','Marker','o','createcallback',@create_boundary_spline,'changecallback',@change_boundary_spline, ...
    'type','spline','closed',0);

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
function create_flow_boundary_points

handles=getHandles;

xs=handles.model.sfincs.boundaryspline.x;
ys=handles.model.sfincs.boundaryspline.y;

[xp,yp]=spline2d(xs,ys,handles.model.sfincs.boundaryspline.flowdx);

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

handles.model.sfincs.domain(ad).flowboundarypoints.length=length(xp);

setHandles(handles);

delete_flow_boundary_points;

plot_flow_boundary_points;

%%
function remove_flow_boundary_points

handles=getHandles;

handles.model.sfincs.domain(ad).flowboundarypoints.x=[];
handles.model.sfincs.domain(ad).flowboundarypoints.y=[];
handles.model.sfincs.domain(ad).flowboundarypoints.length=0;

setHandles(handles);

delete_flow_boundary_points;

%%
function load_flow_boundary_points

remove_flow_boundary_points;

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.bndfile;
xy=load(filename);
xy=xy';
xp=xy(1,:);
yp=xy(2,:);

handles.model.sfincs.domain(ad).flowboundarypoints.x=xp;
handles.model.sfincs.domain(ad).flowboundarypoints.y=yp;
handles.model.sfincs.domain(ad).flowboundarypoints.length=length(xp);

setHandles(handles);

plot_flow_boundary_points;

%%
function save_flow_boundary_points

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.bndfile;

fid=fopen(filename,'wt');
for ip=1:handles.model.sfincs.domain(ad).flowboundarypoints.length
    fprintf(fid,'%10.1f %10.1f\n',handles.model.sfincs.domain(ad).flowboundarypoints.x(ip),handles.model.sfincs.domain(ad).flowboundarypoints.y(ip));
end
fclose(fid);

setHandles(handles);


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
function create_wave_boundary_points

handles=getHandles;

xs=handles.model.sfincs.boundaryspline.x;
ys=handles.model.sfincs.boundaryspline.y;

[xp,yp]=spline2d(xs,ys,handles.model.sfincs.boundaryspline.wavedx);

merge=0;
if ~isempty(handles.model.sfincs.domain(ad).waveboundarypoints.x)
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
    handles.model.sfincs.domain(ad).waveboundarypoints.x=[handles.model.sfincs.domain(ad).waveboundarypoints.x xp];
    handles.model.sfincs.domain(ad).waveboundarypoints.y=[handles.model.sfincs.domain(ad).waveboundarypoints.y yp];
else
    handles.model.sfincs.domain(ad).waveboundarypoints.x=xp;
    handles.model.sfincs.domain(ad).waveboundarypoints.y=yp;
end

handles.model.sfincs.domain(ad).waveboundarypoints.length=length(xp);

setHandles(handles);

delete_wave_boundary_points;

plot_wave_boundary_points;

%%
function remove_wave_boundary_points

handles=getHandles;

handles.model.sfincs.domain(ad).waveboundarypoints.x=[];
handles.model.sfincs.domain(ad).waveboundarypoints.y=[];
handles.model.sfincs.domain(ad).waveboundarypoints.length=0;

setHandles(handles);

delete_wave_boundary_points;

%%
function load_wave_boundary_points

remove_wave_boundary_points;

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.bwvfile;
xy=load(filename);
xy=xy';
xp=xy(1,:);
yp=xy(2,:);

handles.model.sfincs.domain(ad).waveboundarypoints.x=xp;
handles.model.sfincs.domain(ad).waveboundarypoints.y=yp;
handles.model.sfincs.domain(ad).waveboundarypoints.length=length(xp);

setHandles(handles);

plot_wave_boundary_points;

%%
function save_wave_boundary_points

handles=getHandles;

filename=handles.model.sfincs.domain(ad).input.bwvfile;

fid=fopen(filename,'wt');
for ip=1:handles.model.sfincs.domain(ad).waveboundarypoints.length
    fprintf(fid,'%10.1f %10.1f\n',handles.model.sfincs.domain(ad).waveboundarypoints.x(ip),handles.model.sfincs.domain(ad).waveboundarypoints.y(ip));
end
fclose(fid);

setHandles(handles);


%%
function delete_wave_boundary_points

handles=getHandles;

handles=ddb_sfincs_plot_wave_boundary_points(handles,'delete','domain',ad);

setHandles(handles);

%%
function plot_wave_boundary_points

handles=getHandles;

handles=ddb_sfincs_plot_wave_boundary_points(handles,'plot','domain',ad);

setHandles(handles);

%%
function save_boundary_conditions

handles=getHandles;

inp=handles.model.sfincs.domain(ad).input;

nt=2;

np=handles.model.sfincs.domain(ad).flowboundarypoints.length;
bnd0=zeros(nt,np);

simtime=86400*(handles.model.sfincs.domain(ad).tstop-handles.model.sfincs.domain(ad).tref);
% BZS
t=[0;simtime];
v=bnd0+handles.model.sfincs.boundaryconditions.zs;
handles.model.sfincs.domain(ad).flowboundaryconditions.time=t;
handles.model.sfincs.domain(ad).flowboundaryconditions.zs=v;
sfincs_write_boundary_conditions(inp.bzsfile,t,v);

% np=handles.model.sfincs.domain(ad).waveboundarypoints.length;
bnd0=zeros(nt,np);

% BHS
t=[0;simtime];
v=bnd0+handles.model.sfincs.boundaryconditions.hs;
handles.model.sfincs.domain(ad).waveboundaryconditions.time=t;
handles.model.sfincs.domain(ad).waveboundaryconditions.hs=v;
sfincs_write_boundary_conditions(inp.bhsfile,t,v);

% BTP
t=[0;simtime];
v=bnd0+handles.model.sfincs.boundaryconditions.tp;
handles.model.sfincs.domain(ad).waveboundaryconditions.time=t;
handles.model.sfincs.domain(ad).waveboundaryconditions.tp=v;
sfincs_write_boundary_conditions(inp.btpfile,t,v);

% BWD
t=[0;simtime];
v=bnd0+handles.model.sfincs.boundaryconditions.wd;
handles.model.sfincs.domain(ad).waveboundaryconditions.time=t;
handles.model.sfincs.domain(ad).waveboundaryconditions.wd=v;
sfincs_write_boundary_conditions(inp.bwdfile,t,v);

