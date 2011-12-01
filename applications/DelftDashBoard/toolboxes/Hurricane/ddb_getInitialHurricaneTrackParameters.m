function h = ddb_getInitialHurricaneTrackParameters(h)
%DDB_GETINITIALHURRICANETRACKPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   h = ddb_getInitialHurricaneTrackParameters(h)
%
%   Input:
%   h =
%
%   Output:
%   h =
%
%   Example
%   ddb_getInitialHurricaneTrackParameters
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
% Created: 01 Dec 2011
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id: $
% $Date: $
% $Author: $
% $Revision: $
% $HeadURL: $
% $Keywords: $

%%
handles=getHandles;

h.ok=0;

fig=MakeNewWindow('Track Parameters',[260 210],'modal',[handles.settingsDir '\icons\deltares.gif']);

h.TextStartDate = uicontrol(gcf,'Style','text','String','Time First Point','Position',[10 166 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextTimeStep  = uicontrol(gcf,'Style','text','String','Time Increment (h)',      'Position',[10 136 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextVMax      = uicontrol(gcf,'Style','text','String','Vmax (m/s)',    'Position',[10 106 95 20],'HorizontalAlignment','right','Tag','UIControl');
h.TextPDrop     = uicontrol(gcf,'Style','text','String','Pdrop (Pa)',   'Position',[10  76 95 20],'HorizontalAlignment','right','Tag','UIControl');


h.EditStartDate = uicontrol(gcf,'Style','edit','String',D3DTimeString(h.t0),'Position',[110 170 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditTimeStep  = uicontrol(gcf,'Style','edit','String',num2str(h.dt),      'Position',[110 140 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditVMax      = uicontrol(gcf,'Style','edit','String',num2str(h.vmax),    'Position',[110 110 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
h.EditPDrop     = uicontrol(gcf,'Style','edit','String',num2str(h.pdrop),   'Position',[110  80 120 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

if ~h.hol==0
    set(h.EditVMax, 'String',num2str(h.para));
    set(h.EditPDrop,'String',num2str(h.parb));
    set(h.TextVMax,'String','Paramater A');
    set(h.TextPDrop,'String','Paramater B');
end

h.PushOK        = uicontrol(gcf,'Style','pushbutton','String','OK',    'Position',[160 30 70 20],'Tag','UIControl');
h.PushCancel    = uicontrol(gcf,'Style','pushbutton','String','Cancel','Position',[80 30 70 20],'Tag','UIControl');

set(h.PushOK,    'CallBack',{@PushOK_CallBack});
set(h.PushCancel,'CallBack',{@PushCancel_CallBack});

guidata(gcf,h);
uiwait;
h=guidata(gcf);
close(fig);

function PushOK_CallBack(hObject,eventdata)
h=guidata(gcf);
h.t0=D3DTimeString(get(h.EditStartDate,'String'));
h.dt=str2double(get(h.EditTimeStep,'String'));
if h.hol
    h.vmax=str2double(get(h.EditVMax,'String'));
    h.pdrop=str2double(get(h.EditPDrop,'String'));
else
    h.para=str2double(get(h.EditVMax,'String'));
    h.parb=str2double(get(h.EditPDrop,'String'));
end

h.ok=1;
guidata(gcf,h);
uiresume;

function PushCancel_CallBack(hObject,eventdata)
uiresume;

