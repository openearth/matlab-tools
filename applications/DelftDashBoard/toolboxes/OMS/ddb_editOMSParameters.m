function ddb_editOMSParameters
%DDB_EDITOMSPARAMETERS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editOMSParameters
%
%   Input:

%
%
%
%
%   Example
%   ddb_editOMSParameters
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
ddb_refreshScreen('Toolbox','Parameters');

handles=getHandles;

ddb_plotOMS(handles,'activate');

% handles.Toolbox(tb).availableStations=LoadObservations(handles);
% handles.Toolbox(tb).nrAvailableStations=length(handles.Toolbox(tb).Stations);

handles.Toolbox(tb).ScenarioDir='E:\work\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts\';
handles.Toolbox(tb).ArchiveDir='E:\work\OperationalModelSystem\SoCalCoastalHazards\scenarios\forecasts\';

handles.Toolbox(tb).Type='Delft3DFLOWWAVE';

handles.GUIHandles.PushSaveModel = uicontrol(gcf,'Style','pushbutton','String','Save Model','Position',   [850 30 100  20],'Tag','UIControl');
handles.GUIHandles.PushLoadModel = uicontrol(gcf,'Style','pushbutton','String','Load Model','Position',   [850 55 100  20],'Tag','UIControl');

UIControlEdit(handles.Toolbox(tb).ShortName,  [120 130 100  20],'Toolbox',tb,'',1,'ShortName',    1,'string','Name');
UIControlEdit(handles.Toolbox(tb).LongName,   [120 105 100  20],'Toolbox',tb,'',1,'LongName',     1,'string','Long Name');
UIControlEdit(handles.Toolbox(tb).Directory,  [120  80 100  20],'Toolbox',tb,'',1,'Directory',    1,'string','Dir');
UIControlEdit(handles.Toolbox(tb).Runid,      [120  55 100  20],'Toolbox',tb,'',1,'Runid',        1,'string','Runid');

ii=strmatch(handles.Toolbox(tb).Continent,handles.Toolbox(tb).Continents,'exact');
handles.GUIHandles.SelectContinent = uicontrol(gcf,'Style','popupmenu','String',handles.Toolbox(tb).Continents, 'Position',  [120  35 100  20],'BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.GUIHandles.SelectContinent,'Value',ii);

UIControlEdit(handles.Toolbox(tb).Location(1),[260 130 50  20],'Toolbox',tb,'',1,'Location',      1,'real','Pos');
UIControlEdit(handles.Toolbox(tb).Location(2),[320 130 50  20],'Toolbox',tb,'',1,'Location',      2,'real','');
handles.GUIHandles.setLocation = uicontrol(gcf,'Style','pushbutton','String','Edit', 'Position',  [375  130 30  20],'Tag','UIControl');

handles.GUIHandles.TextXLim=uicontrol(gcf,'Style','text','String','X Lim', 'Position',  [220 101 35  20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextYLim=uicontrol(gcf,'Style','text','String','Y Lim', 'Position',  [220  76 35  20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditXLim1=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).XLim(1)), 'Position',  [260 105 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditXLim2=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).XLim(2)), 'Position',  [320 105 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditYLim1=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).YLim(1)), 'Position',  [260  80 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditYLim2=uicontrol(gcf,'Style','edit','String',num2str(handles.Toolbox(tb).YLim(2)), 'Position',  [320  80 50  20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.setXYLim = uicontrol(gcf,'Style','pushbutton','String','Edit', 'Position',  [375  105 30  20],'Tag','UIControl');

UIControlEdit(handles.Toolbox(tb).Size,       [260  55 50  20],'Toolbox',tb,'',1,'Size',          1,'integer','Size');
UIControlEdit(handles.Toolbox(tb).Priority,   [260  30 50  20],'Toolbox',tb,'',1,'Priority',      1,'integer','Priority');

UIControlEdit(handles.Toolbox(tb).FlowNested, [500 130 75  20],'Toolbox',tb,'',1,'FlowNested',      1,'string','Flow Nested');
UIControlEdit(handles.Toolbox(tb).WaveNested, [500 105 75  20],'Toolbox',tb,'',1,'WaveNested',      1,'string','Wave Nested');
UIControlEdit(handles.Toolbox(tb).FlowSpinUp, [500  80 30  20],'Toolbox',tb,'',1,'FlowSpinUp',   1,'integer','Flow Spin-up');
UIControlEdit(handles.Toolbox(tb).WaveSpinUp, [500  55 30  20],'Toolbox',tb,'',1,'WaveSpinUp',   1,'integer','Wave Spin-up');

UIControlEdit(handles.Toolbox(tb).TimeStep,   [640 130 30  20],'Toolbox',tb,'',1,'TimeStep',     1,'integer','Time Step');
UIControlEdit(handles.Toolbox(tb).MapTimeStep,[640 105 30  20],'Toolbox',tb,'',1,'MapTimeStep',   1,'integer','Map Step');
UIControlEdit(handles.Toolbox(tb).HisTimeStep,[640  80 30  20],'Toolbox',tb,'',1,'HisTimeStep',   1,'integer','His Step');
UIControlEdit(handles.Toolbox(tb).ComTimeStep,[640  55 30  20],'Toolbox',tb,'',1,'ComTimeStep',   1,'integer','Com Step');
UIControlEdit(handles.Toolbox(tb).RunTime    ,[640  30 30  20],'Toolbox',tb,'',1,'RunTime',       1,'integer','Run Time');

UIControlEdit(handles.Toolbox(tb).UseMeteo,   [730 130 90  20],'Toolbox',tb,'',1,'UseMeteo',    1,'string','Meteo');
UIControlEdit(handles.Toolbox(tb).DxMeteo,    [730 105 90  20],'Toolbox',tb,'',1,'DxMeteo',      1,'real','Dx Meteo');
UIControlEdit(handles.Toolbox(tb).WebSite,    [730  80 90  20],'Toolbox',tb,'',1,'WebSite',     1,'string','Web Site');

if strcmpi(handles.Toolbox(tb).Type,'xbeachcluster')
    UIControlEdit(handles.Toolbox(tb).MorFac,   [880 130 60  20],'Toolbox',tb,'',1,'MorFac',    1,'real','MorFac');
end

set(handles.GUIHandles.EditXLim1,'Callback',{@EditXLim1_Callback});
set(handles.GUIHandles.EditXLim2,'Callback',{@EditXLim2_Callback});
set(handles.GUIHandles.EditYLim1,'Callback',{@EditYLim1_Callback});
set(handles.GUIHandles.EditYLim2,'Callback',{@EditYLim2_Callback});

set(handles.GUIHandles.SelectContinent,'Callback',{@SelectContinent_Callback});
set(handles.GUIHandles.PushLoadModel,  'Callback',{@PushLoadModel_Callback});
set(handles.GUIHandles.PushSaveModel,  'Callback',{@PushSaveModel_Callback});
set(handles.GUIHandles.setXYLim,  'Callback',{@setXYLim_Callback});

SetUIBackgroundColors;

PlotModelLimits(handles)

setHandles(handles);

%%
function PushSaveModel_Callback(hObject,eventdata)
handles=getHandles;
ddb_saveOMSModel(handles);

%%
function PushLoadModel_Callback(hObject,eventdata)
handles=getHandles;
[filename, pathname, filterindex] = uigetfile('*.xml', 'Select model XML file');
if ~pathname==0
    fname=[pathname filename];
    handles=ddb_readOMSModelData(handles,fname);
    ddb_plotOMSStations(handles);
    PlotModelLimits(handles);
    Refresh(handles);
end
setHandles(handles);

%%
function SelectContinent_Callback(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
ii=get(hObject,'Value');
handles.Toolbox(tb).Continent=str{ii};
setHandles(handles);

%%
function EditXLim1_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).XLim(1)=str2double(get(hObject,'String'));
PlotModelLimits(handles);
setHandles(handles);

%%
function EditXLim2_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).XLim(2)=str2double(get(hObject,'String'));
PlotModelLimits(handles);
setHandles(handles);

%%
function EditYLim1_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).YLim(1)=str2double(get(hObject,'String'));
PlotModelLimits(handles);
setHandles(handles);

%%
function EditYLim2_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).YLim(2)=str2double(get(hObject,'String'));
PlotModelLimits(handles);
setHandles(handles);

%%
function setXYLim_Callback(hObject,eventdata)

ddb_zoomOff;

f1=@DeleteModelLimits;
f2=@UpdateModelLimits;
f3=@UpdateModelLimits;
DrawRectangle('OMSModelLimits',f1,f2,f3,'dx',0.1,'dy',0.1,'Color','g','Marker','o','MarkerColor','r','LineWidth',1.5,'Rotation',0);

%%
function UpdateModelLimits(x0,y0,lenx,leny,rotation)

handles=getHandles;

handles.Toolbox(tb).XLim(1)=x0;
handles.Toolbox(tb).XLim(2)=x0+lenx;
handles.Toolbox(tb).YLim(1)=y0;
handles.Toolbox(tb).YLim(2)=y0+leny;

try
    set(handles.GUIHandles.EditXLim1,'String',num2str(handles.Toolbox(tb).XLim(1)));
    set(handles.GUIHandles.EditXLim2,'String',num2str(handles.Toolbox(tb).XLim(2)));
    set(handles.GUIHandles.EditYLim1,'String',num2str(handles.Toolbox(tb).YLim(1)));
    set(handles.GUIHandles.EditYLim2,'String',num2str(handles.Toolbox(tb).YLim(2)));
end

setHandles(handles);

%%
function DeleteModelLimits

h=findall(gca,'Tag','OMSModelLimits');

if ~isempty(h)
    usd=get(h,'userdata');
    try
        sh=usd.ch;
        delete(sh);
        delete(h);
    end
end

%%
function Refresh(handles)

%%
function PlotModelLimits(handles)

h=findall(gca,'Tag','OMSModelLimits');
lenx=handles.Toolbox(tb).XLim(2)-handles.Toolbox(tb).XLim(1);
leny=handles.Toolbox(tb).YLim(2)-handles.Toolbox(tb).YLim(1);
if ~isempty(h)
    PlotRectangle('OMSModelLimits',handles.Toolbox(tb).XLim(1),handles.Toolbox(tb).YLim(1),lenx,leny,0);
else
    dx=0.1;
    dy=0.1;
    fmove=[];
    fstop=@UpdateModelLimits;
    col='g';
    lw=1.5;
    marker='o';
    markercol='r';
    rot=0;
    PlotRectangle('OMSModelLimits',handles.Toolbox(tb).XLim(1),handles.Toolbox(tb).YLim(1),lenx,leny,0,dx,dy,fmove,fstop,col,lw,marker,markercol,rot);
end

