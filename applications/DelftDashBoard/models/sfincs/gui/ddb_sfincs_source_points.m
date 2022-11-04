function ddb_sfincs_source_points(varargin)

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
    handles=getHandles;
    handles=ddb_sfincs_plot_source_points(handles,'plot','domain',ad,'visible',1);
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectsourcepointfromlist'}
            select_source_point_from_list;
        case{'addsourcepoint'}
            gui_clickpoint('xy','callback',@add_source_point);
            setInstructions({'','','Click point on map for new source point'});
        case{'deletesourcepoint'}
            delete_source_point;
        case{'editsourcepoint'}
            edit_source_point;
        case{'loadsourcepoints'}
            load_source_points;
        case{'savesourcepoints'}
            save_source_points;
            
    end
    
end

%%
function add_source_point(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;

handles.model.sfincs.domain(ad).sourcepoints.length=handles.model.sfincs.domain(ad).sourcepoints.length+1;
iac=handles.model.sfincs.domain(ad).sourcepoints.length;
handles.model.sfincs.domain(ad).sourcepoints.names{iac}=['srcpoint ' num2str(iac)];

handles.model.sfincs.domain(ad).sourcepoints.x(iac)=x1;
handles.model.sfincs.domain(ad).sourcepoints.y(iac)=y1;
handles.model.sfincs.domain(ad).sourcepoints.activepoint=iac;

handles=ddb_sfincs_plot_source_points(handles,'plot','active',1);
setHandles(handles);

clearInstructions;

%update_source_point_names;

refresh_source_points;

%%
function delete_source_point

handles=getHandles;

nrsrc=handles.model.sfincs.domain(ad).sourcepoints.length;

if nrsrc>0
    iac=handles.model.sfincs.domain(ad).activesourcepoint;
    handles=ddb_sfincs_plot_source_points(handles,'delete','sourcepoints');
    if nrsrc>1
        handles.model.sfincs.domain(ad).sourcepoints=removeFromStruc(handles.model.sfincs.domain(ad).sourcepoints,iac);
    else
        handles.model.sfincs.domain(ad).activesourcepoint=1;
        handles.model.sfincs.domain(ad).sourcepoints(1).name='';
        handles.model.sfincs.domain(ad).sourcepoints(1).x=NaN;
        handles.model.sfincs.domain(ad).sourcepoints(1).y=NaN;
    end
    if iac==nrsrc
        iac=nrsrc-1;
    end
    handles.model.sfincs.domain(ad).nrsourcepoints=nrsrc-1;
    handles.model.sfincs.domain(ad).activesourcepoint=max(iac,1);
    handles=ddb_sfincs_plot_source_points(handles,'plot','active',1);
    setHandles(handles);
    update_source_point_names;
    refresh_source_points;
end

%%
function edit_source_point

handles=getHandles;
handles=ddb_sfincs_plot_source_points(handles,'plot','active',1);
setHandles(handles);
refresh_source_points;

%%
function select_source_point_from_list

handles=getHandles;
handles=ddb_sfincs_plot_source_points(handles,'plot','active',1);
setHandles(handles);
refresh_source_points;

%%
function load_source_points

handles=getHandles;
filename=handles.model.sfincs.domain(ad).input.obsfile;
points=sfincs_read_source_points(filename);
for ip=1:length(points.x)
    handles.model.sfincs.domain(ad).sourcepoints(ip).x=points.x(ip);
    handles.model.sfincs.domain(ad).sourcepoints(ip).y=points.y(ip);
    handles.model.sfincs.domain(ad).sourcepoints(ip).name=points.names{ip};
end
handles.model.sfincs.domain(ad).nrsourcepoints=length(points.x);
handles.model.sfincs.domain(ad).activesourcepoint=1;
handles=ddb_sfincs_plot_source_points(handles,'plot','active',1);
setHandles(handles);
update_source_point_names;
refresh_source_points;

%%
function save_source_points
handles=getHandles;
filename=handles.model.sfincs.domain(ad).input.obsfile;
sfincs_write_source_points(filename,handles.model.sfincs.domain(ad).sourcepoints,'cstype',handles.screenParameters.coordinateSystem.type);

%%
function refresh_source_points
gui_updateActiveTab;

%%
function update_source_point_names
handles=getHandles;
handles.model.sfincs.domain(ad).sourcepointnames={''};
for ip=1:handles.model.sfincs.domain(ad).nrsourcepoints
    handles.model.sfincs.domain(ad).sourcepointnames{ip}=handles.model.sfincs.domain(ad).sourcepoints(ip).name;
end
setHandles(handles);

