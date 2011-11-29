function ddb_selectDelft3DFLOW
%DDB_SELECTDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_selectDelft3DFLOW
%
%   Input:

%
%
%
%
%   Example
%   ddb_selectDelft3DFLOW
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
% Created: 29 Nov 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

sz=get(gcf,'Position');

strings={'Toolbox','Description','Domain','Time Frame','Processes','Init. Conditions','Boundaries','Phys. Parameters','Num. Parameters', ...
    'Discharges','Monitoring','Additional','Output'};
callbacks={@ddb_selectToolbox,@ddb_editD3DFlowDescription,@ddb_editD3DFlowDomain,@ddb_editD3DFlowTimeFrame,@ddb_editD3DFlowProcesses,@ddb_editD3DFlowInitialConditions, ...
    @ddb_editD3DFlowOpenBoundaries,@ddb_editD3DFlowPhysicalParameters,@ddb_editD3DFlowNumericalParameters,@ddb_editD3DFlowDischarges,@ddb_editD3DFlowMonitoring, ...
    @ddb_editD3DFlowAdditional,@ddb_editD3DFlowOutput};
% width=[60 70 60 70 70 90 70 100 100 70 70 70 60];
% tabpanel(gcf,'tabpanel','create','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks,'width',width);
tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks);

handles.ActiveModel.Name='Delft3DFLOW';
ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');
handles.ActiveModel.Nr=ii;

handles.ActiveDomain=1;
set(handles.GUIHandles.Menu.Domain.Main,'Enable','on');

set(handles.GUIHandles.Menu.File.Open,     'Label','Open MDF');
set(handles.GUIHandles.Menu.File.Save,     'Label','Save MDF');
set(handles.GUIHandles.Menu.File.SaveAs,   'Label','Save MDF As ...');

set(handles.GUIHandles.Menu.File.SaveAll,          'Enable','on');
set(handles.GUIHandles.Menu.File.SaveAllAs,        'Enable','on');

set(handles.GUIHandles.Menu.File.OpenDomains,      'Enable','on');
set(handles.GUIHandles.Menu.File.SaveAllDomains,   'Enable','on');

% fill in the model specific items of the view-menu
% first delete previous menu items
delete(get(findobj(gcf,'Type','uimenu','Tag','menuViewModel'),'Children'));
% change name of model menu (to Delft3D-FLOW)
set(findobj(gcf,'Type','uimenu','Tag','menuViewModel'),'Label','Delft3D-FLOW');
% add model specific items to menu
handles=ddb_addMenuItem(handles,'ViewModel','Grid',                'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Model Bathymetry',    'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Open Boundaries',     'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Observation Points',  'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Cross Sections',      'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Thin Dams',           'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Dry Points',          'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');

handles=ddb_refreshFlowDomains(handles);

setHandles(handles);

