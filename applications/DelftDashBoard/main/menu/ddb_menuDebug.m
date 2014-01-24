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

% % Delete existing model tab panel
% for ii=2:length(handles.Model(md).GUI.element.element.tab)
%     parent=handles.Model(md).GUI.element(1).element.tab(ii).tab.handle;
%     ch=get(parent,'Children');
%     if ~isempty(ch)
%         delete(ch);
%     end
% end

% originalElements=handles.Model(md).GUI.element;

% % First try to delete existing panels
% for im=1:length(handles.Model)
%     if isfield(handles.Model(im).GUI.element(1).element,'handle')
%         try
%             delete(handles.Model(im).GUI.element(1).element.handle);
%         end
%     end
% end

% Re-read xml files
handles=ddb_readModelXML(handles,md);
handles=ddb_readToolboxXML(handles,tb);
% 
% handles.Model(md).GUI.element.element.handle=originalElements.element.handle;    
% el=getappdata(originalElements.element.handle,'element');
% 
% % And add tab elements
% for ii=2:length(handles.Model(md).GUI.element.element.tab)
%     elements=handles.Model(md).GUI.element.element.tab(ii).tab.element;
%     parent=originalElements.element.tab(ii).tab.handle;
%     elements=gui_addElements(gcf,elements,'getFcn',@getHandles,'setFcn',@setHandles,'Parent',parent);    
%     handles.Model(md).GUI.element.element.tab(ii).tab.element=elements;
%     handles.Model(md).GUI.element.element.tab(ii).tab.handle=originalElements.element.tab(ii).tab.handle;
%     setappdata(handles.Model(md).GUI.element.element.tab(ii).tab.handle,'elements',elements);
%     el.tab(ii).tab.element=elements;
% end
% handles.Model(md).GUI.element.element.tab(1).tab.handle=originalElements.element.tab(1).tab.handle;    
% setappdata(originalElements.element.handle,'element',el);

setHandles(handles);

% disp('Adding model tabpanels ...');
% ddb_addModelTabPanels;

% disp('Loading additional map data ...');
% ddb_loadMapData;

% disp('Initializing screen ...');
% ddb_makeMapPanel;

%ddb_addModelTabPanels;

% ddb_selectToolbox;

drawnow;

set(gcf,'Pointer','arrow');

