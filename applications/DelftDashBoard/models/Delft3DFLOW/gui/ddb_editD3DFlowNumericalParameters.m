function ddb_editD3DFlowNumericalParameters
%DDB_EDITD3DFLOWNUMERICALPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editD3DFlowNumericalParameters
%
%   Input:

%
%
%
%
%   Example
%   ddb_editD3DFlowNumericalParameters
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
ddb_refreshScreen('Num. Parameters');

handles=getHandles;
id=ad;

uipanel('Title','Numerical Parameters','Units','pixels','Position',[50 20 900 150],'Tag','UIControl');

handles.GUIHandles.TextFlooding = uicontrol(gcf,'Style','text','String','Drying and flooding check at','Position',[60 126 140 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.TextD = uicontrol(gcf,'Style','text','String','Depth specified at','Position',[60 66 140 20],'HorizontalAlignment','left','Tag','UIControl');

str={'Max','Mean','Min','DP'};
handles.GUIHandles.SelectDpsOpt = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[210 130 60 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextDpsOpt = uicontrol(gcf,'Style','text','String','Depth at grid cell centres','Position',[60 126 140 20],'HorizontalAlignment','right','Tag','UIControl');

str={'Mean','Min','Upwind','Mor'};
handles.GUIHandles.SelectDpuOpt = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[210 100 60 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextDpuOpt = uicontrol(gcf,'Style','text','String','Depth at grid cell faces','Position',[60 96 140 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.ToggleCentresAndFaces = uicontrol(gcf,'Style','radiobutton','String','Cell Centres and Faces','Position',[210 70 140 20],'Tag','UIControl');
handles.GUIHandles.ToggleCentres         = uicontrol(gcf,'Style','radiobutton','String','Cell Faces only',       'Position',[210 50 140 20],'Tag','UIControl');
handles.GUIHandles.TextDryFlp            = uicontrol(gcf,'Style','text','String','Drying and flooding check at', 'Position',[ 60 66 140 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditThresh   = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(id).DryFlc), 'Position',[490 130 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextThresh   = uicontrol(gcf,'Style','text','String','Threshold Depth (m)', 'Position',[370 126 110 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditMarg     = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(id).Dco), 'Position',[490 100 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMarg     = uicontrol(gcf,'Style','text','String','Marginal Depth (m)',    'Position',[370  96 110 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditSmooth   = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(id).SmoothingTime), 'Position',[490 70 60 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextSmooth   = uicontrol(gcf,'Style','text','String','Smoothing Time (min)','Position',[370  66 110 20],'HorizontalAlignment','right','Tag','UIControl');

str={'Cyclic','Waqua','Flood'};
handles.GUIHandles.SelectMomsol = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[780 130 60 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextMomsol   = uicontrol(gcf,'Style','text','String','Advection Scheme for Momentum','Position',[570 126 200 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.EditThreshFlood = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(id).Dgcuni), 'Position',[780 100 60 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextThreshFlood = uicontrol(gcf,'Style','text','String','Threshold Depth Critical Flow Limiter (m)',    'Position',[570  96 200 20],'HorizontalAlignment','right','Tag','UIControl');

set(handles.GUIHandles.SelectDpsOpt,          'CallBack',{@SelectDpsOpt_Callback});
set(handles.GUIHandles.SelectDpuOpt,          'CallBack',{@SelectDpuOpt_Callback});
set(handles.GUIHandles.ToggleCentresAndFaces, 'CallBack',{@ToggleCentresAndFaces_Callback});
set(handles.GUIHandles.ToggleCentres,         'CallBack',{@ToggleCentres_Callback});
set(handles.GUIHandles.EditThresh,            'CallBack',{@EditThresh_Callback});
set(handles.GUIHandles.EditMarg,              'CallBack',{@EditMarg_Callback});
set(handles.GUIHandles.EditSmooth,            'CallBack',{@EditSmooth_Callback});
set(handles.GUIHandles.SelectMomsol,          'CallBack',{@SelectMomsol_Callback});
set(handles.GUIHandles.EditThreshFlood,       'CallBack',{@EditThreshFlood_Callback});

SetUIBackgroundColors;

RefreshNumericalParameters(handles);

setHandles(handles);


%%
function SelectDpsOpt_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.Model(md).Input(ad).DpsOpt=str{ii};
if strcmpi(str{ii},'DP')
    handles.Model(md).Input(ad).DpuOpt='MIN';
end
RefreshNumericalParameters(handles);
setHandles(handles);

%%
function SelectDpuOpt_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.Model(md).Input(ad).DpuOpt=str{ii};
RefreshNumericalParameters(handles);
setHandles(handles);

%%
function SelectMomsol_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.Model(md).Input(ad).MomSol=str{ii};
if strcmpi(str{ii},'flood')
    handles.Model(md).Input(ad).DpuOpt='MIN';
end
RefreshNumericalParameters(handles);
setHandles(handles);

%%
function ToggleCentresAndFaces_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
if handles.Model(md).Input(ad).DryFlp && ii==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleCentres,'Value',0);
    handles.Model(md).Input(ad).DryFlp=1;
end
RefreshNumericalParameters(handles);
setHandles(handles);

%%
function ToggleCentres_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
if ~handles.Model(md).Input(ad).DryFlp && ii==0
    set(hObject,'Value',1);
else
    set(handles.GUIHandles.ToggleCentresAndFaces,'Value',0);
    handles.Model(md).Input(ad).DryFlp=0;
end
RefreshNumericalParameters(handles);
setHandles(handles);

%%
function EditThresh_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).DryFlc=str2double(str);
setHandles(handles);

%%
function EditMarg_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).Dco=str2double(str);
setHandles(handles);

%%
function EditSmooth_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).SmoothingTime=str2double(str);
setHandles(handles);

%%
function EditThreshFlood_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).Dgcuni=str2double(str);
setHandles(handles);

%%
function RefreshNumericalParameters(handles)

id=ad;

str={'MAX','MEAN','MIN','DP'};
ii=strmatch(handles.Model(md).Input(id).DpsOpt,str,'exact');
set(handles.GUIHandles.SelectDpsOpt,'String',str);
set(handles.GUIHandles.SelectDpsOpt,'Value',ii);

switch lower(handles.Model(md).Input(id).MomSol)
    case {'cyclic','waqua'}
        if strcmpi(handles.Model(md).Input(id).DpsOpt,'DP')
            str={'MIN','UPW'};
        else
            str={'MEAN','MIN','UPW','MOR'};
        end
    case {'flood'}
        str={'MIN'};
end
set(handles.GUIHandles.SelectDpuOpt,'Value',1);
ii=strmatch(handles.Model(md).Input(id).DpuOpt,str,'exact');
set(handles.GUIHandles.SelectDpuOpt,'String',str);
set(handles.GUIHandles.SelectDpuOpt,'Value',ii);

if handles.Model(md).Input(id).DryFlp
    set(handles.GUIHandles.ToggleCentresAndFaces,'Value',1);
    set(handles.GUIHandles.ToggleCentres,'Value',0);
else
    set(handles.GUIHandles.ToggleCentresAndFaces,'Value',0);
    set(handles.GUIHandles.ToggleCentres,'Value',1);
end

str=get(handles.GUIHandles.SelectMomsol,'String');
ii=strmatch(handles.Model(md).Input(id).MomSol,str,'exact');
set(handles.GUIHandles.SelectMomsol,'Value',ii);

if strcmpi(handles.Model(md).Input(id).MomSol,'flood')
    set(handles.GUIHandles.EditThreshFlood,'String',num2str(handles.Model(md).Input(id).Dgcuni),'Enable','on');
else
    set(handles.GUIHandles.EditThreshFlood,'String','','Enable','off');
end

