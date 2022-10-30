function ddb_sfincs_obstacles(varargin)

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

    ddb_refreshScreen;
    
    % New tab selected
    handles=getHandles;
    handles=update_names(handles);
    handles=ddb_sfincs_plot_thin_dams(handles,'plot','active',1);
    setHandles(handles);

%    ddb_plotsfincs('update','active',1,'visible',1);
else
    
    %Options selected
    
    opt=lower(varargin{1});
    
    switch lower(opt)
        case{'selectthindamfromlist'}
            select_thin_dam_from_list;
        case{'addthindam'}
            draw_thin_dam;
        case{'deletethindam'}
            delete_thin_dam;
        case{'changethindam'}
            h=varargin{2};
            x=varargin{3};
            y=varargin{4};
            change_thin_dam(h,x,y);
        case{'loadthindams'}
            load_thin_dams;
        case{'savethindams'}
            save_thin_dams;
            
    end
    
end

%%
function draw_thin_dam

handles=getHandles;
% Click Add in GUI
%handles.model.sfincs.domain(ad).deletethindam=0;
ddb_zoomOff;
setInstructions({'','','Draw thin dam'});
gui_polyline('draw','tag','sfincsthindam','Marker','o','createcallback',@add_thin_dam,'closed',0, ...
    'color','g','markeredgecolor','r','markerfacecolor','r');
setHandles(handles);

%%
function add_thin_dam(h,x,y)

clearInstructions;

handles=getHandles;

% Add mode
handles.model.sfincs.domain(ad).nrthindams=handles.model.sfincs.domain(ad).nrthindams+1;
iac=handles.model.sfincs.domain(ad).nrthindams;

handles.model.sfincs.domain(ad).thindams(iac).x=x;
handles.model.sfincs.domain(ad).thindams(iac).y=y;
handles.model.sfincs.domain(ad).thindams(iac).handle=h;
handles.model.sfincs.domain(ad).activethindam=iac;

handles=ddb_sfincs_plot_thin_dams(handles,'plot','active',1);

handles=update_names(handles);

setHandles(handles);

refresh_thin_dams;

%%
function change_thin_dam(h,x,y)

% Cross section changed on map

handles=getHandles;

for ii=1:handles.model.sfincs.domain(ad).nrthindams
    if handles.model.sfincs.domain(ad).thindams(ii).handle==h
        iac=ii;
        break;
    end
end

handles.model.sfincs.domain(ad).thindams(iac).x=x;
handles.model.sfincs.domain(ad).thindams(iac).y=y;
handles.model.sfincs.domain(ad).activethindam=iac;

handles=ddb_sfincs_plot_thin_dams(handles,'plot','active',1);

setHandles(handles);

refresh_thin_dams;

%%
function delete_thin_dam

clearInstructions;

handles=getHandles;

nrobs=handles.model.sfincs.domain(ad).nrthindams;

if nrobs>0
    iac=handles.model.sfincs.domain(ad).activethindam;
    handles=ddb_sfincs_plot_thin_dams(handles,'delete','thindams');
    if nrobs>1
        handles.model.sfincs.domain(ad).thindams=removeFromStruc(handles.model.sfincs.domain(ad).thindams,iac);
    else
        handles.model.sfincs.domain(ad).activethindam=1;
        handles.model.sfincs.domain(ad).thindams(1).x=0;
        handles.model.sfincs.domain(ad).thindams(1).y=0;
    end
    if iac==nrobs
        iac=max(nrobs-1,1);
    end
    handles.model.sfincs.domain(ad).nrthindams=nrobs-1;
    handles.model.sfincs.domain(ad).activethindam=iac;
    handles=ddb_sfincs_plot_thin_dams(handles,'plot','active',1);
    
    handles=update_names(handles);
    
    setHandles(handles);
    refresh_thin_dams;
end

%%
function select_thin_dam_from_list
clearInstructions;
handles=getHandles;
handles=ddb_sfincs_plot_thin_dams(handles,'update');
setHandles(handles);

%%
function handles=update_names(handles)
handles.model.sfincs.domain(ad).thindamnames={''};
for ib=1:handles.model.sfincs.domain.nrthindams
    handles.model.sfincs.domain(ad).thindamnames{ib}=num2str(ib);
end

%%
function refresh_thin_dams
gui_updateActiveTab;

%%
function load_thin_dams
handles=getHandles;
handles.model.sfincs.domain(ad).thindams = sfincs_read_thin_dams(handles.model.sfincs.domain(ad).input.thdfile);
handles.model.sfincs.domain(ad).nrthindams=length(handles.model.sfincs.domain(ad).thindams);
handles.model.sfincs.domain(ad).activethindam=1;
handles=update_names(handles);
handles=ddb_sfincs_plot_thin_dams(handles,'plot','active',1);
setHandles(handles);

%%
function save_thin_dams
handles=getHandles;
sfincs_write_thin_dams(handles.model.sfincs.domain(ad).input.thdfile, handles.model.sfincs.domain(ad).thindams);

