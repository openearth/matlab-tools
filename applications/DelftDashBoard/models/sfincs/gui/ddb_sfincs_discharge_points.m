function ddb_sfincs_discharge_points(varargin)

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
% programming tools in an open discharge, version controlled environment.
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
    refresh_discharge_points;
    handles=getHandles;
    handles=ddb_sfincs_plot_discharge_points(handles,'plot','domain',ad,'visible',1);
    setHandles(handles);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectdischargepointfromlist'}
            select_discharge_point_from_list;
        case{'adddischargepoint'}
            gui_clickpoint('xy','callback',@add_discharge_point);
            setInstructions({'','','Click point on map for new discharge point'});
        case{'deletedischargepoint'}
            delete_discharge_point;
        case{'editdischargepoint'}
            edit_discharge_point;
        case{'editdischarge'}
            edit_discharge;
        case{'loaddischargepoints'}
            load_discharge_points;
        case{'savedischargepoints'}
            save_discharge_points;
        case{'loaddischarges'}
            load_discharges;
        case{'savedischarges'}
            save_discharges;
            
    end
    
end

%%
function add_discharge_point(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;

handles.model.sfincs.domain(ad).discharges.number=handles.model.sfincs.domain(ad).discharges.number+1;

if handles.model.sfincs.domain(ad).discharges.number==1
    % First discharge
    handles.model.sfincs.domain(ad).discharges.time=[handles.model.sfincs.domain(ad).input.tstart handles.model.sfincs.domain(ad).input.tstop];
    handles.model.sfincs.domain(ad).discharges.q=[];    
end

iac=handles.model.sfincs.domain(ad).discharges.number;
handles.model.sfincs.domain(ad).discharges.point(iac).x=x1;
handles.model.sfincs.domain(ad).discharges.point(iac).y=y1;
handles.model.sfincs.domain(ad).discharges.point(iac).q=0.0;
handles.model.sfincs.domain(ad).discharges.point(iac).editable=1;
handles.model.sfincs.domain(ad).discharges.activepoint=iac;

qq=zeros(length(handles.model.sfincs.domain(ad).discharges.time), 1);
handles.model.sfincs.domain(ad).discharges.q=[handles.model.sfincs.domain(ad).discharges.q qq];    

setHandles(handles);

clearInstructions;

refresh_discharge_points;

handles=getHandles;
handles=ddb_sfincs_plot_discharge_points(handles,'plot','active',1);
setHandles(handles);

input_changed;

%%
function delete_discharge_point

handles=getHandles;

nrsrc=handles.model.sfincs.domain(ad).discharges.number;

if nrsrc>0
    iac=handles.model.sfincs.domain(ad).discharges.activepoint;
    handles=ddb_sfincs_plot_discharge_points(handles,'delete','discharges');
    if nrsrc>1

        if iac==1
            handles.model.sfincs.domain(ad).discharges.q=handles.model.sfincs.domain(ad).discharges.q(:,2:end);
        elseif iac==handles.model.sfincs.domain(ad).discharges.number
            handles.model.sfincs.domain(ad).discharges.q=handles.model.sfincs.domain(ad).discharges.q(:,1:end-1);
        else
            handles.model.sfincs.domain(ad).discharges.q=[handles.model.sfincs.domain(ad).discharges.q(:,1:iac-1) handles.model.sfincs.domain(ad).discharges.q(:,iac+1:end)];
        end
            
        handles.model.sfincs.domain(ad).discharges.point=removeFromStruc(handles.model.sfincs.domain(ad).discharges.point,iac);
    else
        handles.model.sfincs.domain(ad).discharges.activepoint=1;
        handles.model.sfincs.domain(ad).discharges.point(1).name='';
        handles.model.sfincs.domain(ad).discharges.point(1).x=NaN;
        handles.model.sfincs.domain(ad).discharges.point(1).y=NaN;
        handles.model.sfincs.domain(ad).discharges.point(1).q=NaN;
        handles.model.sfincs.domain(ad).discharges.point(1).editable=0;
        handles.model.sfincs.domain(ad).discharges.q=[];
    end
    if iac==nrsrc
        iac=nrsrc-1;
    end
    handles.model.sfincs.domain(ad).discharges.number=nrsrc-1;
    handles.model.sfincs.domain(ad).discharges.activepoint=max(iac,1);
    
    setHandles(handles);
    
    update_discharge_point_names;
    refresh_discharge_points;

    handles=getHandles;
    handles=ddb_sfincs_plot_discharge_points(handles,'plot','active',1);
    setHandles(handles);

    input_changed;

end

%%
function edit_discharge_point
refresh_discharge_points;
handles=getHandles;
handles=ddb_sfincs_plot_discharge_points(handles,'plot','active',1);
setHandles(handles);
input_changed;

%%
function edit_discharge
handles=getHandles;
iac=handles.model.sfincs.domain(ad).discharges.activepoint;
handles.model.sfincs.domain(ad).discharges.q(:,iac)=handles.model.sfincs.domain(ad).discharges.point(iac).q;
setHandles(handles);
input_changed;

%%
function select_discharge_point_from_list

handles=getHandles;
handles=ddb_sfincs_plot_discharge_points(handles,'plot','active',1);
setHandles(handles);

%%
function load_discharge_points

ddb_sfincs_open_src_file;

refresh_discharge_points;

handles=getHandles;
handles=ddb_sfincs_plot_discharge_points(handles,'plot','active',1);
setHandles(handles);

%%
function save_discharge_points

ddb_sfincs_save_src_file;

%%
function load_discharges

ddb_sfincs_open_dis_file;

%%
function save_discharges

ddb_sfincs_save_dis_file;

%%
function refresh_discharge_points
update_discharge_point_names;
% Check if discharge is editable
handles=getHandles;
q=handles.model.sfincs.domain(ad).discharges.q;
for ip=1:handles.model.sfincs.domain(ad).discharges.number
    qq=q(:,ip);
    if length(unique(qq))==1
        handles.model.sfincs.domain(ad).discharges.point(ip).editable=1;
        handles.model.sfincs.domain(ad).discharges.point(ip).q=qq(1);
    else    
        handles.model.sfincs.domain(ad).discharges.point(ip).editable=0;
        handles.model.sfincs.domain(ad).discharges.point(ip).q=NaN;
    end
end
setHandles(handles);
gui_updateActiveTab;

%%
function update_discharge_point_names
handles=getHandles;
handles.model.sfincs.domain(ad).discharges.names={''};
for ip=1:handles.model.sfincs.domain(ad).discharges.number
    handles.model.sfincs.domain(ad).discharges.point(ip).name=['src' num2str(ip,'%0.3i')];
    handles.model.sfincs.domain(ad).discharges.names{ip}=handles.model.sfincs.domain(ad).discharges.point(ip).name;
end
setHandles(handles);

%%
function input_changed
handles=getHandles;
if handles.auto_save
    ddb_sfincs_save_src_file;
    ddb_sfincs_save_dis_file;
end
