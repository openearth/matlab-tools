function ddb_editD3DFlowProcesses
%DDB_EDITD3DFLOWPROCESSES  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowProcesses
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowProcesses
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
ddb_refreshScreen('Processes');
handles=getHandles;

uipanel('Title','Constituents','Units','pixels','Position',[50 20 210 150],'Tag','UIControl');
handles.GUIHandles.ToggleSalinity     = uicontrol(gcf,'Style','checkbox', 'String','Salinity','Position',[60 130 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleTemperature  = uicontrol(gcf,'Style','checkbox', 'String','Temperature','Position',[60 105 130 20],'Tag','UIControl');
handles.GUIHandles.TogglePollutants   = uicontrol(gcf,'Style','checkbox', 'String','Pollutants and Tracers','Position',[60 80 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleSediments    = uicontrol(gcf,'Style','checkbox', 'String','Sediments','Position',[60 55 130 20],'Tag','UIControl');
handles.GUIHandles.PushEditPollutants = uicontrol(gcf,'Style','pushbutton',  'String','Edit','Position',[200 80 50 20],'Tag','UIControl');
handles.GUIHandles.PushEditSediments  = uicontrol(gcf,'Style','pushbutton',  'String','Edit','Position',[200 55 50 20],'Tag','UIControl');

uipanel('Title','Physical','Units','pixels','Position',[280 20 300 150],'Tag','UIControl');
handles.GUIHandles.ToggleWind = uicontrol(gcf,'Style','checkbox', 'String','Wind','Position',[290 130 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleWaves = uicontrol(gcf,'Style','checkbox', 'String','Waves','Position',[290 105 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleOnlineWave = uicontrol(gcf,'Style','checkbox', 'String','Online Delft3D-Wave','Position',[290 80 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleRoller = uicontrol(gcf,'Style','checkbox', 'String','Roller Model','Position',[290 55 130 20],'Tag','UIControl');
handles.GUIHandles.ToggleSecondaryFlow = uicontrol(gcf,'Style','checkbox', 'String','Secondary Flow','Position',[430 130 140 20],'Tag','UIControl');
handles.GUIHandles.ToggleTidalForces = uicontrol(gcf,'Style','checkbox', 'String','Tide-generating Forces','Position',[430 105 140 20],'Tag','UIControl');
if strcmpi(handles.ScreenParameters.CoordinateSystem.Type,'Geographic')
    set(handles.GUIHandles.ToggleTidalForces,'Visible','on');
else
    set(handles.GUIHandles.ToggleTidalForces,'Visible','off');
end
uipanel('Title','Man-made','Units','pixels','Position',[600 20 210 150],'Tag','UIControl');
handles.GUIHandles.ToggleDredging = uicontrol(gcf,'Style','checkbox', 'String','Dredging and Dumping','Position',[610 130 160 20],'Tag','UIControl');

if handles.Model(md).Input(ad).Salinity.Include
    set(handles.GUIHandles.ToggleSalinity,'Value',1);
end
if handles.Model(md).Input(ad).Temperature.Include
    set(handles.GUIHandles.ToggleTemperature,'Value',1);
end
if handles.Model(md).Input(ad).Tracers
    set(handles.GUIHandles.TogglePollutants,'Value',1);
    set(handles.GUIHandles.PushEditPollutants,'Enable','on');
else
    set(handles.GUIHandles.PushEditPollutants,'Enable','off');
end
if handles.Model(md).Input(ad).sediments.include
    set(handles.GUIHandles.ToggleSediments,'Value',1);
    set(handles.GUIHandles.PushEditSediments,'Enable','on');
else
    set(handles.GUIHandles.PushEditSediments,'Enable','off');
end

if handles.Model(md).Input(ad).Wind
    set(handles.GUIHandles.ToggleWind,'Value',1);
end
if handles.Model(md).Input(ad).Waves
    set(handles.GUIHandles.ToggleWaves,'Value',1);
end
if handles.Model(md).Input(ad).OnlineWave
    set(handles.GUIHandles.ToggleOnlineWave,'Value',1);
end
if handles.Model(md).Input(ad).Roller.Include
    set(handles.GUIHandles.ToggleRoller,'Value',1);
end
if handles.Model(md).Input(ad).SecondaryFlow
    set(handles.GUIHandles.ToggleSecondaryFlow,'Value',1);
end
if handles.Model(md).Input(ad).TidalForces
    set(handles.GUIHandles.ToggleTidalForces,'Value',1);
end
if handles.Model(md).Input(ad).Dredging
    set(handles.GUIHandles.ToggleDredging,'Value',1);
end

set(handles.GUIHandles.ToggleSalinity,    'Callback',{@ToggleSalinity_Callback});
set(handles.GUIHandles.ToggleTemperature, 'Callback',{@ToggleTemperature_Callback});
set(handles.GUIHandles.TogglePollutants,  'Callback',{@TogglePollutants_Callback});
set(handles.GUIHandles.ToggleSediments,   'Callback',{@ToggleSediments_Callback});
set(handles.GUIHandles.ToggleWind,        'Callback',{@ToggleWind_Callback});
set(handles.GUIHandles.ToggleWaves,       'Callback',{@ToggleWaves_Callback});
set(handles.GUIHandles.ToggleOnlineWave,  'Callback',{@ToggleOnlineWave_Callback});
set(handles.GUIHandles.ToggleRoller,      'Callback',{@ToggleRoller_Callback});
set(handles.GUIHandles.ToggleSecondaryFlow,'Callback',{@ToggleSecondaryFlow_Callback});
set(handles.GUIHandles.ToggleTidalForces, 'Callback',{@ToggleTidalForces_Callback});
set(handles.GUIHandles.ToggleDredging,    'Callback',{@ToggleDredging_Callback});
set(handles.GUIHandles.PushEditPollutants,'Callback',{@PushEditPollutants_Callback});
set(handles.GUIHandles.PushEditSediments, 'Callback',{@PushEditSediments_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function ToggleSalinity_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Salinity.Include=get(hObject,'Value');
setHandles(handles);

%%
function ToggleTemperature_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Temperature.Include=get(hObject,'Value');
setHandles(handles);

%%
function TogglePollutants_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Tracers=get(hObject,'Value');
if handles.Model(md).Input(ad).Tracers
    set(handles.GUIHandles.PushEditPollutants,'Enable','on');
    if handles.Model(md).Input(ad).NrTracers==0
        handles=ddb_editD3DFlowPollutants(handles);
        if handles.Model(md).Input(ad).NrTracers==0
            set(handles.GUIHandles.PushEditPollutants,'Enable','off');
            handles.Model(md).Input(ad).Tracers=0;
            set(hObject,'Value',0);
        end
    end
else
    set(handles.GUIHandles.PushEditPollutants,'Enable','off');
end
setHandles(handles);

%%
function ToggleSediments_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).sediments.include=get(hObject,'Value');
if handles.Model(md).Input(ad).sediments.include
    set(handles.GUIHandles.PushEditSediments,'Enable','on');
    if handles.Model(md).Input(ad).NrSediments==0
        handles=ddb_editD3DFlowSediments(handles);
        if handles.Model(md).Input(ad).NrSediments==0
            set(handles.GUIHandles.PushEditSediments,'Enable','off');
            handles.Model(md).Input(ad).sediments.include=0;
            set(hObject,'Value',0);
        end
    end
else
    set(handles.GUIHandles.PushEditSediments,'Enable','off');
end
setHandles(handles);

%%
function ToggleWind_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Wind=get(hObject,'Value');
setHandles(handles);

%%
function ToggleWaves_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Waves=get(hObject,'Value');
setHandles(handles);

%%
function ToggleOnlineWave_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).OnlineWave=get(hObject,'Value');
setHandles(handles);

%%
function ToggleRoller_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Roller.Include=get(hObject,'Value');
setHandles(handles);

%%
function ToggleSecondaryFlow_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).SecondaryFlow=get(hObject,'Value');
setHandles(handles);

%%
function ToggleTidalForces_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).TidalForces=get(hObject,'Value');
setHandles(handles);

%%
function ToggleDredging_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Dredging=get(hObject,'Value');
setHandles(handles);

%%
function PushEditPollutants_Callback(hObject,eventdata)
handles=getHandles;
handles=ddb_editD3DFlowPollutants(handles);
if handles.Model(md).Input(ad).NrTracers==0
    set(hObject,'Enable','off');
    set(handles.GUIHandles.TogglePollutants,'Value',0);
    handles.Model(md).Input(ad).Tracers=0;
end
setHandles(handles);

%%
function PushEditSediments_Callback(hObject,eventdata)
handles=getHandles;
handles=ddb_editD3DFlowSediments(handles);
if handles.Model(md).Input(ad).NrSediments==0
    set(hObject,'Enable','off');
    set(handles.GUIHandles.ToggleSediments,'Value',0);
    handles.Model(md).Input(ad).sediments.include=0;
end
setHandles(handles);

