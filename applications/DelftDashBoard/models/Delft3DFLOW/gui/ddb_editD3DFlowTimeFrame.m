function ddb_editD3DFlowTimeFrame
%DDB_EDITD3DFLOWTIMEFRAME  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowTimeFrame
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowTimeFrame
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
ddb_refreshScreen('Time Frame');
handles=getHandles;

hp                        = uipanel('Title','Time Frame','Units','pixels','Position',[50 30 220 140],'Tag','UIControl');
handles.GUIHandles.TextReferenceDate = uicontrol(gcf,'Style','text','String','Reference Date',     'Position',    [ 60 127  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStartTime     = uicontrol(gcf,'Style','text','String','Start Time',         'Position',    [ 60  97  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextStopTime      = uicontrol(gcf,'Style','text','String','Stop Time',          'Position',    [ 60  67  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTimeStep      = uicontrol(gcf,'Style','text','String','Time Step (min)',    'Position',    [ 60  37  80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditReferenceDate = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).ItDate,'itdate'), 'Position',    [150 130 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStartTime     = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).StartTime),'Position',  [150 100 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStopTime      = uicontrol(gcf,'Style','edit','String',D3DTimeString(handles.Model(md).Input(ad).StopTime),'Position',   [150  70 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditTimeStep      = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).TimeStep),'Position',[150  40 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditReferenceDate,'CallBack',{@EditReferenceDate_CallBack});
set(handles.GUIHandles.EditStartTime,    'CallBack',{@EditStartTime_CallBack});
set(handles.GUIHandles.EditStopTime,     'CallBack',{@EditStopTime_CallBack});
set(handles.GUIHandles.EditTimeStep,     'CallBack',{@EditTimeStep_CallBack});

SetUIBackgroundColors;

setHandles(handles);

%%
function EditReferenceDate_CallBack(hObject,eventdata)

handles=getHandles;
handles.Model(md).Input(ad).ItDate=D3DTimeString(get(hObject,'String'));
setHandles(handles);

function EditStartTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).StartTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

function EditStopTime_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).StopTime=D3DTimeString(get(hObject,'String'));
setHandles(handles);

function EditTimeStep_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).TimeStep=str2num(get(hObject,'String'));
setHandles(handles);

