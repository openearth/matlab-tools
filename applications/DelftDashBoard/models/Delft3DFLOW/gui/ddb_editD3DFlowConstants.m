function ddb_editD3DFlowConstants
%DDB_EDITD3DFLOWCONSTANTS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowConstants
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowConstants
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
ddb_refreshScreen('Phys. Parameters','Constants');
handles=getHandles;

id=ad;

posy=125;

handles.GUIHandles.EditGravity = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).G),'Position',[180 posy 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextGravity = uicontrol(gcf,'Style','text', 'String','Gravity (m/s2)','Position',[60 posy-4 110 20],'HorizontalAlignment','left','Tag','UIControl');
posy=posy-25;
handles.GUIHandles.EditDensity = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).RhoW),'Position',[180 posy 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextDensity = uicontrol(gcf,'Style','text', 'String','Water Density (kg/m3)','Position',[60 posy-4 110 20],'HorizontalAlignment','left','Tag','UIControl');

set(handles.GUIHandles.EditGravity,'CallBack',{@EditGravity_CallBack});
set(handles.GUIHandles.EditDensity,'CallBack',{@EditDensity_CallBack});

if handles.Model(md).Input(id).Wind
    posy=posy-25;
    handles.GUIHandles.EditAirDensity = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).RhoAir),'Position',[180 posy 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextAirDensity = uicontrol(gcf,'Style','text', 'String','Air Density (kg/m3)','Position',[60 posy-4 110 20],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditAirDensity,'CallBack',{@EditAirDensity_CallBack});
    % Wind drag coefficients
    hp = uipanel('Title','Wind Drag Coefficients','Units','pixels','Position',[270 60 310 90],'Tag','UIControl');
    handles.GUIHandles.TextFirstBreakpoint  = uicontrol(gcf,'Style','text', 'String','First Breakpoint', 'Position',[280 91 90 20],'HorizontalAlignment','right','Tag','UIControl');
    handles.GUIHandles.TextSecondBreakpoint = uicontrol(gcf,'Style','text', 'String','Second Breakpoint','Position',[280 66 90 20],'HorizontalAlignment','right','Tag','UIControl');
    handles.GUIHandles.TextCoefficient      = uicontrol(gcf,'Style','text', 'String','Coefficient (-)', 'Position',[380 115 90 20],'HorizontalAlignment','center','Tag','UIControl');
    handles.GUIHandles.TextWindSpeed        = uicontrol(gcf,'Style','text', 'String','Wind Speed (m/s)','Position',[480 115 90 20],'HorizontalAlignment','center','Tag','UIControl');
    handles.GUIHandles.EditCoefficient1     = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).WindStress(1)),'Position',[380 95 90 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.EditCoefficient2     = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).WindStress(3)),'Position',[380 70 90 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.EditWindSpeed1       = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).WindStress(2)),'Position',[480 95 90 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.EditWindSpeed2       = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).WindStress(4)),'Position',[480 70 90 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    set(handles.GUIHandles.EditCoefficient1,'CallBack',{@EditCoefficient1_CallBack});
    set(handles.GUIHandles.EditCoefficient2,'CallBack',{@EditCoefficient2_CallBack});
    set(handles.GUIHandles.EditWindSpeed1,'CallBack',{@EditWindSpeed1_CallBack});
    set(handles.GUIHandles.EditWindSpeed2,'CallBack',{@EditWindSpeed2_CallBack});
end

if handles.Model(md).Input(id).SecondaryFlow
    posy=posy-25;
    handles.GUIHandles.EditBetaC = uicontrol(gcf,'Style','edit', 'String',num2str(handles.Model(md).Input(id).BetaC),'Position',[180 posy 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
    handles.GUIHandles.TextBetaC = uicontrol(gcf,'Style','text', 'String','Beta_c','Position',[60 posy-4 110 20],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.EditBetaC,'CallBack',{@EditBetaC_CallBack});
    posy=posy-25;
    handles.GUIHandles.ToggleEquiliState = uicontrol(gcf,'Style','checkbox', 'String','','Position',[180 posy 50 20],'HorizontalAlignment','right','Tag','UIControl');
    handles.GUIHandles.TextEquiliState   = uicontrol(gcf,'Style','text', 'String','Equilibrium State','Position',[60 posy-4 110 20],'HorizontalAlignment','left','Tag','UIControl');
    set(handles.GUIHandles.ToggleEquiliState,'Value',handles.Model(md).Input(id).Equili);
    set(handles.GUIHandles.ToggleEquiliState,'CallBack',{@ToggleEquiliState_CallBack});
end

SetUIBackgroundColors;

guidata(gcf,handles);

%%
function EditGravity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).G=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditDensity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).RhoW=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditAirDensity_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).RhoAir=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditBetaC_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).BetaC=str2num(get(hObject,'String'));
setHandles(handles);

%%
function ToggleEquiliState_CallBack(hObject,eventdata)
handles=getHandles;
handles.GUIhandles.Model(md).Input(ad).Equili=get(hObject,'Value');
setHandles(handles);


%%
function EditCoefficient1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).WindStress(1)=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditCoefficient2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).WindStress(3)=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditWindSpeed1_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).WindStress(2)=str2num(get(hObject,'String'));
setHandles(handles);

%%
function EditWindSpeed2_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).WindStress(4)=str2num(get(hObject,'String'));
setHandles(handles);

