function ddb_drawGridOutline(src, eventdata)
%DDB_DRAWGRIDOUTLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_drawGridOutline(src, eventdata)
%
%   Input:
%   src       =
%   eventdata =
%
%
%
%
%   Example
%   ddb_drawGridOutline
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
% Created: 02 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
pan off;
h=findall(gcf,'ToolTipString','Pan');
set(h,'State','off');
h=findall(gcf,'ToolTipString','Zoom In');
set(h,'State','off');
h=findall(gcf,'ToolTipString','Zoom Out');
set(h,'State','off');
zoom off;
plotedit off;

set(gcf, 'windowbuttondownfcn',  {@StartTrack});
set(gcf, 'windowbuttonmotionfcn',{@MoveMouse});
set(gcf,'KeyPressFcn',[]);

%%
function StartTrack(imagefig, varargins)

set(gcf, 'windowbuttondownfcn', []);
set(gcf, 'windowbuttonmotionfcn', {@MoveTrack});
set(gcf, 'windowbuttonupfcn', {@StopTrack});

h=findobj('Tag','MainWindow');
handles=guidata(h);

hold on;

ddb_deleteGridOutline;

pos = get(gca, 'CurrentPoint');

usd.x0=pos(1,1);
usd.y0=pos(1,2);
handles.toolbox.modelmaker.XOri=usd.x0;
handles.toolbox.modelmaker.YOri=usd.y0;
handles.toolbox.modelmaker.nX=0;
handles.toolbox.modelmaker.nY=0;
handles.toolbox.modelmaker.dX=str2double(get(handles.EditDX,'String'));
handles.toolbox.modelmaker.dY=str2double(get(handles.EditDY,'String'));
handles.GUIHandles.GridRotation=0;

set(handles.GUIHandles.EditXOri,'String',num2str(usd.x0));
set(handles.GUIHandles.EditYOri,'String',num2str(usd.y0));
set(handles.GUIHandles.EditNX,'String',num2str(handles.toolbox.modelmaker.nX));
set(handles.GUIHandles.EditNY,'String',num2str(handles.toolbox.modelmaker.nY));
set(handles.GUIHandles.EditRotation,'String',num2str(handles.toolbox.modelmaker.Rotation));

guidata(h,handles);

ddb_plotGridOutline('g');

set(0,'UserData',usd);

%%
function MoveTrack(imagefig, varargins)

set(gcf, 'windowbuttonupfcn', {@StopTrack});

h=findobj('Tag','MainWindow');
handles=guidata(h);

usd=get(0,'userdata');
pos = get(gca, 'CurrentPoint');

posx=pos(1,1);
posy=pos(1,2);

ddb_deleteGridOutline;

handles.toolbox.modelmaker.XOri=min(posx,usd.x0);
handles.toolbox.modelmaker.YOri=min(posy,usd.y0);
handles.toolbox.modelmaker.nX=round(abs(posx-usd.x0)/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(abs(posy-usd.y0)/handles.toolbox.modelmaker.dY);
handles.toolbox.modelmaker.Rotation=0;

set(handles.GUIHandles.EditXOri,'String',num2str(handles.toolbox.modelmaker.XOri));
set(handles.GUIHandles.EditYOri,'String',num2str(handles.toolbox.modelmaker.YOri));
set(handles.GUIHandles.EditNX,'String',num2str(handles.toolbox.modelmaker.nX));
set(handles.GUIHandles.EditNY,'String',num2str(handles.toolbox.modelmaker.nY));
set(handles.GUIHandles.EditRotation,'String',num2str(handles.toolbox.modelmaker.Rotation));

guidata(h,handles);
ddb_plotGridOutline('g');

set(0,'userdata',usd);

ddb_updateCoordinateText('crosshair');

%%
function StopTrack(imagefig, varargins)

ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;

set(0,'userdata',[]);

%%
function MoveMouse(imagefig, varargins)

ddb_updateCoordinateText('crosshair');

