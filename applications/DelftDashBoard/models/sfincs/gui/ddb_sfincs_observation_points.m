function ddb_sfincs_observation_points(varargin)

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
%    ddb_plotsfincs('update','active',1,'visible',1);
    handles=getHandles;
    handles=ddb_sfincs_plot_observation_points(handles,'plot','domain',ad,'visible',1);
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectobservationpointfromlist'}
            select_observation_point_from_list;
        case{'addobservationpoint'}
            gui_clickpoint('xy','callback',@add_observation_point);
            setInstructions({'','','Click point on map for new observation point'});
        case{'deleteobservationpoint'}
            delete_observation_point;
        case{'editobservationpoint'}
            edit_observation_point;
        case{'loadobservationpoints'}
            load_observation_points;
        case{'saveobservationpoints'}
            save_observation_points;
            
    end
    
end

%%
function add_observation_point(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;

handles.model.sfincs.domain(ad).nrobservationpoints=handles.model.sfincs.domain(ad).nrobservationpoints+1;
iac=handles.model.sfincs.domain(ad).nrobservationpoints;
handles.model.sfincs.domain(ad).observationpoints(iac).name=['obspoint ' num2str(iac)];

handles.model.sfincs.domain(ad).observationpoints(iac).x=x1;
handles.model.sfincs.domain(ad).observationpoints(iac).y=y1;
handles.model.sfincs.domain(ad).activeobservationpoint=iac;

handles=ddb_sfincs_plot_observation_points(handles,'plot','active',1);
setHandles(handles);

clearInstructions;

update_observation_point_names;

refresh_observation_points;

input_changed;

%%
function delete_observation_point

handles=getHandles;

nrobs=handles.model.sfincs.domain(ad).nrobservationpoints;

if nrobs>0
    iac=handles.model.sfincs.domain(ad).activeobservationpoint;
    handles=ddb_sfincs_plot_observation_points(handles,'delete','observationpoints');
    if nrobs>1
        handles.model.sfincs.domain(ad).observationpoints=removeFromStruc(handles.model.sfincs.domain(ad).observationpoints,iac);
    else
        handles.model.sfincs.domain(ad).activeobservationpoint=1;
        handles.model.sfincs.domain(ad).observationpoints(1).name='';
        handles.model.sfincs.domain(ad).observationpoints(1).x=NaN;
        handles.model.sfincs.domain(ad).observationpoints(1).y=NaN;
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.model.sfincs.domain(ad).nrobservationpoints=nrobs-1;
    handles.model.sfincs.domain(ad).activeobservationpoint=max(iac,1);
    handles=ddb_sfincs_plot_observation_points(handles,'plot','active',1);
    setHandles(handles);
    update_observation_point_names;
    refresh_observation_points;
    input_changed;       
end

%%
function edit_observation_point

handles=getHandles;
handles=ddb_sfincs_plot_observation_points(handles,'plot','active',1);
setHandles(handles);
refresh_observation_points;
input_changed;

%%
function select_observation_point_from_list

handles=getHandles;
handles=ddb_sfincs_plot_observation_points(handles,'plot','active',1);
setHandles(handles);
refresh_observation_points;

%%
function load_observation_points

ddb_sfincs_open_obs_file;
update_observation_point_names;

handles=getHandles;
handles=ddb_sfincs_plot_observation_points(handles,'plot','active',1);
setHandles(handles);

refresh_observation_points;

%%
function save_observation_points

ddb_sfincs_save_obs_file;

%%
function refresh_observation_points
gui_updateActiveTab;

%%
function update_observation_point_names
handles=getHandles;
handles.model.sfincs.domain(ad).observationpointnames={''};
for ip=1:handles.model.sfincs.domain(ad).nrobservationpoints
    handles.model.sfincs.domain(ad).observationpointnames{ip}=handles.model.sfincs.domain(ad).observationpoints(ip).name;
end
setHandles(handles);

%%
function input_changed
handles=getHandles;
if handles.auto_save
    ddb_sfincs_save_obs_file;
end
