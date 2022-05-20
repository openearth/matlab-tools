function ddb_menuDebug(hObject, eventdata, handles)
%DDB_MENUDEBUG  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_menuDebug(hObject, eventdata, handles)
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
%   ddb_menuDebug
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
tg=get(hObject,'Tag');

switch tg,
    case{'menuDebugReloadXML'}
        menuDebugMode_Callback(hObject,eventdata);
end

%%
function menuDebugMode_Callback(hObject, eventdata)

handles=getHandles;

ddb_zoomOff;

set(gcf,'Pointer','watch');
pause(0.01);

% Delete model tab panels
models=fieldnames(handles.model);
for ii=1:length(models)
    delete(handles.model.(models{ii}).GUI.element(1).element.handle);
end

% Re-read xml files
handles=ddb_readModelXML(handles,lower(handles.activeModel.name));
handles=ddb_readToolboxXML(handles,lower(handles.activeToolbox.name));
setHandles(handles);

ddb_addModelTabPanels;

handles=getHandles;
set(handles.model.(handles.activeModel.name).GUI.element(1).element.handle,'visible','on');

ddb_makeMapPanel;

ddb_updateDataInScreen;

% Toolbox is selected in ddb_selectModel
ddb_selectModel(handles.activeModel.name);
ddb_resize;
drawnow;

set(gcf,'Pointer','arrow');

