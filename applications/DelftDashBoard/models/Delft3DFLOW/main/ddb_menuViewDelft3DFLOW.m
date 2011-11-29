function ddb_menuViewDelft3DFLOW(hObject, eventdata, handles)
%DDB_MENUVIEWDELFT3DFLOW  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuViewDelft3DFLOW(hObject, eventdata, handles)
%
%   Input:
%   hObject   =
%   eventdata =
%   handles   =
%
%
%
%
%   Example
%   ddb_menuViewDelft3DFLOW
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

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewModelGrid'}
        menuViewGrid_Callback(hObject,eventdata,handles);
    case{'menuViewModelModelBathymetry'}
        menuViewModelBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewModelObservationPoints'}
        menuViewObservationPoints_Callback(hObject,eventdata,handles);
    case{'menuViewModelOpenBoundaries'}
        menuViewOpenBoundaries_Callback(hObject,eventdata,handles);
    case{'menuViewModelThinDams'}
        menuViewThinDams_Callback(hObject,eventdata,handles);
    case{'menuViewModelDryPoints'}
        menuViewDryPoints_Callback(hObject,eventdata,handles);
    case{'menuViewModelCrossSections'}
        menuViewCrossSections_Callback(hObject,eventdata,handles);
end

%%
function menuViewGrid_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','FlowGrid');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','FlowGrid');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewModelBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','FlowBathymetry');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','FlowBathymetry');
    if ~isempty(h)
        set(h,'Visible','on');
    end
    %     if strcmp(get(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked'),'on')
    %         set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    %         h=findall(gcf,'Tag','BackgroundBathymetry');
    %         if length(h)>0
    %             set(h,'Visible','off');
    %         end
    %     end
end

%%
function menuViewOpenBoundaries_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','OpenBoundary');
    if ~isempty(h)
        set(h,'Visible','off');
    end
    h=findall(gcf,'Tag','OpenBoundaryText');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','OpenBoundary');
    if ~isempty(h)
        set(h,'Visible','on');
    end
    h=findall(gcf,'Tag','OpenBoundaryText');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewObservationPoints_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','ObservationPoint');
    if ~isempty(h)
        set(h,'Visible','off');
    end
    h=findall(gcf,'Tag','ObservationPointText');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','ObservationPoint');
    if ~isempty(h)
        set(h,'Visible','on');
    end
    h=findall(gcf,'Tag','ObservationPointText');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewThinDams_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','ThinDam');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','ThinDam');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewDryPoints_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','DryPoint');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','DryPoint');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%
function menuViewCrossSections_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    h=findall(gcf,'Tag','CrossSection');
    if ~isempty(h)
        set(h,'Visible','off');
    end
    h=findall(gcf,'Tag','CrossSectionText');
    if ~isempty(h)
        set(h,'Visible','off');
    end
else
    set(hObject,'Checked','on');
    h=findall(gcf,'Tag','CrossSection');
    if ~isempty(h)
        set(h,'Visible','on');
    end
    h=findall(gcf,'Tag','CrossSectionText');
    if ~isempty(h)
        set(h,'Visible','on');
    end
end

%%

