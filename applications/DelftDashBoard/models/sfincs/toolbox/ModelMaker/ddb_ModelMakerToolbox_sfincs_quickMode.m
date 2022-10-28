function ddb_ModelMakerToolbox_sfincs_quickMode(varargin)
%ddb_ModelMakerToolbox_sfincs_quickMode  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_ModelMakerToolbox_sfincs_quickMode(varargin)

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2015 Deltares
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
handles=getHandles;
ddb_zoomOff;

if isempty(varargin)
    % New tab selected
    ddb_refreshScreen;
    ddb_plotModelMaker('activate');
    ddb_plotsfincs('update','active',1,'visible',1);
    ddb_sfincs_plot_mask(handles, 'update','domain',ad,'visible',0);

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
            generateGrid('new');
        case{'generatebathymetry'}
            generateBathymetry;
        case{'prepare_for_fews'}    
            prepare_for_fews;
        case{'edittimes'}
            edit_times;
        case{'write_model_setup_yml'}
            write_model_setup_yml;
        case{'read_model_setup_yml'}
            read_model_setup_yml;
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

if ~isempty(handles.toolbox.modelmaker.gridOutlineHandle)
    try
        delete(handles.toolbox.modelmaker.gridOutlineHandle);
    end
end

h=UIRectangle(handles.GUIHandles.mapAxis,'plot','Tag','GridOutline','Marker','o','MarkerEdgeColor','k','MarkerSize',6,'rotate',1,'callback',@updateGridOutline, ...
    'x0',handles.toolbox.modelmaker.xOri,'y0',handles.toolbox.modelmaker.yOri,'dx',handles.toolbox.modelmaker.lengthX,'dy',handles.toolbox.modelmaker.lengthY, ...
    'rotation',handles.toolbox.modelmaker.rotation, ...
    'ddx',handles.toolbox.modelmaker.wavedX,'ddy',handles.toolbox.modelmaker.wavedY);
handles.toolbox.modelmaker.gridOutlineHandle=h;

setHandles(handles);

%%
function generateGrid(opt)

handles=getHandles;

% npmax=20000000;
% if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY>npmax
%     ddb_giveWarning('Warning',['Maximum number of grid points (' num2str(npmax) ') exceeded ! Please reduce grid resolution.']);
%     return
% end

% Temporarily set zMax to very high value
zmx=handles.toolbox.modelmaker.zMax;
handles.toolbox.modelmaker.zMax=20000;

%handles=ddb_initialize_sfincs_domain(handles,'dummy',ad,'dummy');

handles=ddb_ModelMakerToolbox_sfincs_generateGrid(handles,'option',opt);

handles.toolbox.modelmaker.zMax=zmx;

setHandles(handles);



%%
function generateBathymetry
handles=getHandles;
% Use background bathymetry data
datasets(1).name=handles.screenParameters.backgroundBathymetry;
handles=ddb_ModelMakerToolbox_sfincs_generateBathymetry(handles,ad,datasets);
setHandles(handles);

%%
function prepare_for_fews
handles=getHandles;

% These are the centre points !
id = 1; %needed to have more than 1?
xg=handles.model.sfincs.domain(id).gridx;
yg=handles.model.sfincs.domain(id).gridy;

% Write ascii inifile of shape of grid with all zeros
clear inifile

inifile = zeros(size(xg));
save('sfincs.ini','inifile','-ascii')

% Write csv-file of grid x&y in FEWS standard
wb = waitbox('Generating csv-file of grid ...');pause(0.1);

clear csv_out 

csv_out = num2cell([xg(:),yg(:)]);
csv_out = [['X'; csv_out(:,1)],[ 'Y'; csv_out(:,2)]];

T = cell2table(csv_out(2:end,:),'VariableNames',csv_out(1,:));
writetable(T,['sfincs_grid.csv']);

close(wb);

setHandles(handles);

%%
function edit_times
handles=getHandles;
tref=handles.model.sfincs.domain(ad).tref;
tstart=handles.model.sfincs.domain(ad).tstart;
tstop=handles.model.sfincs.domain(ad).tstop;
handles.model.sfincs.domain(ad).input.tref=datestr(tref,'yyyymmdd HHMMSS');
handles.model.sfincs.domain(ad).input.tstart=datestr(tstart,'yyyymmdd HHMMSS');
handles.model.sfincs.domain(ad).input.tstop=datestr(tstop,'yyyymmdd HHMMSS');
setHandles(handles);

%%
function write_model_setup_yml

handles=getHandles;

fid=fopen(handles.toolbox.modelmaker.sfincs.setup_config_file,'wt');

% Coordinates

fprintf(fid,'%s\n','coordinates:');
fprintf(fid,'%s\n',['  x0: ' num2fstr(handles.model.sfincs.domain.input.x0)]);
fprintf(fid,'%s\n',['  y0: ' num2fstr(handles.model.sfincs.domain.input.y0)]);
fprintf(fid,'%s\n',['  dx: ' num2fstr(handles.model.sfincs.domain.input.dx)]);
fprintf(fid,'%s\n',['  dy: ' num2fstr(handles.model.sfincs.domain.input.dy)]);
fprintf(fid,'%s\n',['  nmax: ' num2str(handles.model.sfincs.domain.input.nmax)]);
fprintf(fid,'%s\n',['  mmax: ' num2str(handles.model.sfincs.domain.input.mmax)]);
fprintf(fid,'%s\n',['  rotation: ' num2fstr(handles.model.sfincs.domain.input.rotation)]);
fprintf(fid,'%s\n',['  crs: "' handles.screenParameters.coordinateSystem.name '"']);

% Mask
fprintf(fid,'%s\n','mask:');
fprintf(fid,'%s\n',['  zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.zmin)]);
fprintf(fid,'%s\n',['  zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.zmax)]);
if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons>0
    fprintf(fid,'%s\n',['  include_polygon:']);
    fprintf(fid,'%s\n',['  - file_name: "' handles.toolbox.modelmaker.sfincs.mask.includepolygonfile '"']);
    fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.includepolygon_zmin)]);
    fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.includepolygon_zmax)]);
else
    fprintf(fid,'%s\n',['  include_polygon: []']);
end
if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons>0
    fprintf(fid,'%s\n',['  exclude_polygon:']);
    fprintf(fid,'%s\n',['  - file_name: "' handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile '"']);
    fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.excludepolygon_zmin)]);
    fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.excludepolygon_zmax)]);
else
    fprintf(fid,'%s\n',['  exclude_polygon: []']);
end
if handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons>0
    fprintf(fid,'%s\n',['  open_boundary_polygon:']);
    fprintf(fid,'%s\n',['  - file_name: "' handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile '"']);
    fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon_zmin)]);
    fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon_zmax)]);
else
    fprintf(fid,'%s\n',['  open_boundary_polygon: []']);
end
if handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons>0
    fprintf(fid,'%s\n',['  outflow_boundary_polygon:']);
    fprintf(fid,'%s\n',['  - file_name: "' handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile '"']);
    fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon_zmin)]);
    fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon_zmax)]);
else
    fprintf(fid,'%s\n',['  outflow_boundary_polygon: []']);
end
fprintf(fid,'%s\n','bathymetry:');
for j=1:length(handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets)
    fprintf(fid,'%s\n',['  dataset:']);
    fprintf(fid,'%s\n',['  - name: "' handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).name '"']);
    fprintf(fid,'%s\n',['    source: "delftdashboard"']);
    fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).zMin)]);
    fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).zMax)]);
end
fprintf(fid,'%s\n','roughness:');
fprintf(fid,'%s\n',['  dataset:']);
fprintf(fid,'%s\n',['  - zlevel: ' num2fstr(handles.toolbox.modelmaker.sfincs.roughness.rgh_lev_land)]);
fprintf(fid,'%s\n',['    roughness_type: manning']);
fprintf(fid,'%s\n',['    roughness_deep: ' num2fstr(handles.toolbox.modelmaker.sfincs.roughness.manning_sea)]);
fprintf(fid,'%s\n',['    roughness_shallow: ' num2fstr(handles.toolbox.modelmaker.sfincs.roughness.manning_land)]);
for j=1:handles.toolbox.modelmaker.sfincs.roughness.nrSelectedDatasets
    fprintf(fid,'%s\n',['  dataset:']);
    fprintf(fid,'%s\n',['  - name: "' handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(j).name '"']);
    fprintf(fid,'%s\n',['    source: "delftdashboard"']);
%     fprintf(fid,'%s\n',['    zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(j).zMin)]);
%     fprintf(fid,'%s\n',['    zmax: ' num2fstr(handles.toolbox.modelmaker.sfincs.roughness.selectedDatasets(j).zMax)]);
end
fprintf(fid,'%s\n','subgrid:');
fprintf(fid,'%s\n',['  nr_bins: ' num2str(handles.toolbox.modelmaker.sfincs.subgrid.nbin)]);
fprintf(fid,'%s\n',['  nr_subgrid_pixels: ' num2str(handles.toolbox.modelmaker.sfincs.subgrid.refi)]);
fprintf(fid,'%s\n',['  zmin: ' num2fstr(handles.toolbox.modelmaker.sfincs.subgrid.zmin)]);
fprintf(fid,'%s\n',['  max_gradient: ' num2fstr(handles.toolbox.modelmaker.sfincs.subgrid.maxdzdv)]);
fprintf(fid,'%s\n',['  manning_max: ' num2fstr(handles.toolbox.modelmaker.sfincs.subgrid.manning_deep_value)]);
fprintf(fid,'%s\n',['  manning_max_level: ' num2fstr(handles.toolbox.modelmaker.sfincs.subgrid.manning_deep_level)]);

fclose(fid);

% Now save polygon files
if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons>0
    save_polygon(handles.toolbox.modelmaker.sfincs.mask.includepolygon,handles.toolbox.modelmaker.sfincs.mask.includepolygonfile);
end
if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons>0
    save_polygon(handles.toolbox.modelmaker.sfincs.mask.excludepolygon,handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile);
end
if handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons>0
    save_polygon(handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon,handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile);
end
if handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons>0
    save_polygon(handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon,handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile);
end

% coordinates: 
%   x0: 34467.30970073266
%   y0: 3618195.3228380345
%   dx: 500.0
%   dy: 500.0
%   mmax: 78.0
%   nmax: 58.0
%   rotation: 39.686567752782075
%   crs: "WGS 84 / UTM zone 18N"
% 

% config.coordinates.x0=handles.model.sfincs.domain.input.x0;
% config.coordinates.y0=handles.model.sfincs.domain.input.y0;
% config.coordinates.dx=handles.model.sfincs.domain.input.dx;
% config.coordinates.dy=handles.model.sfincs.domain.input.dy;
% config.coordinates.mmax=handles.model.sfincs.domain.input.mmax;
% config.coordinates.nmax=handles.model.sfincs.domain.input.nmax;
% config.coordinates.rotation=handles.model.sfincs.domain.input.rotation;
% config.coordinates.crs=handles.screenParameters.coordinateSystem.name;
% 
% config.mask=[];
% config.mask.zmin=handles.toolbox.modelmaker.sfincs.zmin;
% config.mask.zmax=handles.toolbox.modelmaker.sfincs.zmax;
% 
% if handles.toolbox.modelmaker.sfincs.mask.nrincludepolygons>0
%     config.mask.include_polygon{1}.file_name=handles.toolbox.modelmaker.sfincs.mask.includepolygonfile;
%     config.mask.include_polygon{1}.zmin=handles.toolbox.modelmaker.sfincs.mask.includepolygon_zmin;
%     config.mask.include_polygon{1}.zmax=handles.toolbox.modelmaker.sfincs.mask.includepolygon_zmax;
%     % And save the polygon file
% end
% 
% if handles.toolbox.modelmaker.sfincs.mask.nrexcludepolygons>0
%     config.mask.exclude_polygon{1}.file_name=handles.toolbox.modelmaker.sfincs.mask.excludepolygonfile;
%     config.mask.exclude_polygon{1}.zmin=handles.toolbox.modelmaker.sfincs.mask.excludepolygon_zmin;
%     config.mask.exclude_polygon{1}.zmax=handles.toolbox.modelmaker.sfincs.mask.excludepolygon_zmax;
%     % And save the polygon file
% end
% 
% if handles.toolbox.modelmaker.sfincs.mask.nrwaterlevelboundarypolygons>0
%     config.mask.wl_boundary_polygon{1}.file_name=handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygonfile;
%     config.mask.wl_boundary_polygon{1}.zmin=handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon_zmin;
%     config.mask.wl_boundary_polygon{1}.zmax=handles.toolbox.modelmaker.sfincs.mask.waterlevelboundarypolygon_zmax;
%     % And save the polygon file
% end
% 
% if handles.toolbox.modelmaker.sfincs.mask.nroutflowboundarypolygons>0
%     config.mask.outflow_boundary_polygon{1}.file_name=handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygonfile;
%     config.mask.outflow_boundary_polygon{1}.zmin=handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon_zmin;
%     config.mask.outflow_boundary_polygon{1}.zmax=handles.toolbox.modelmaker.sfincs.mask.outflowboundarypolygon_zmax;
%     % And save the polygon file
% end
% 
% for j=1:length(handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets)
%     config.bathymetry.dataset{j}.name=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).name;
%     config.bathymetry.dataset{j}.source='delftdashboard';
%     config.bathymetry.dataset{j}.zmin=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).zMin;
%     config.bathymetry.dataset{j}.zmax=handles.toolbox.modelmaker.sfincs.bathymetry.selectedDatasets(j).zMax;
% end
% 
% % yml.write(config, 'model_setup.yml',0);

% %%
% function read_model_setup_yml
% 
% handles=getHandles;
% 
% inp=yml.read(handles.toolbox.modelmaker.sfincs.setup_config_file);
% 
% % Coordinates
% handles.model.sfincs.domain.input.x0=inp.coordinates.x0;
% handles.model.sfincs.domain.input.y0=inp.coordinates.y0;
% handles.model.sfincs.domain.input.dx=inp.coordinates.dx;
% handles.model.sfincs.domain.input.dy=inp.coordinates.dy;
% handles.model.sfincs.domain.input.nmax=inp.coordinates.nmax;
% handles.model.sfincs.domain.input.mmax=inp.coordinates.mmax;
% handles.model.sfincs.domain.input.rotation=inp.coordinates.rotation;
% % TODO: crs
% 
% % Mask
% handles.toolbox.modelmaker.sfincs.zmin=inp.mask.zmin;
% handles.toolbox.modelmaker.sfincs.zmax=inp.mask.zmax;
% if isfield(inp.mask,'include_polygon')
%     
% end
% 
% setHandles(handles);

%%
%%
function save_polygon(p,file_name)

handles=getHandles;

cs=handles.screenParameters.coordinateSystem.type;
if strcmpi(cs,'geographic')
    fmt='%12.7f %12.7f\n';
else
    fmt='%11.1f %11.1f\n';
end

fid=fopen(file_name,'wt');
for ip=1:length(p)
    fprintf(fid,'%s\n',['BL' num2str(ip,'%0.4i')]);
    fprintf(fid,'%i %i\n',[p(ip).length 2]);
    for ix=1:p(ip).length
        fprintf(fid,fmt,[p(ip).x(ix) p(ip).y(ix)]);
    end
end
fclose(fid);

%%
function str=num2fstr(val)
if round(val)==val
    % Float
    str=[num2str(val) '.0'];
else
    str=num2str(val);
end
