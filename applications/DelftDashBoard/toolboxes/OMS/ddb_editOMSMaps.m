function ddb_editOMSMaps
%DDB_EDITOMSMAPS  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_editOMSMaps
%
%   Input:

%
%
%
%
%   Example
%   ddb_editOMSMaps
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
ddb_refreshScreen('Toolbox','Maps');

handles=getHandles;

ddb_plotOMS(handles,'deactivate');

mappar=handles.Toolbox(tb).MapParameter;

handles.GUIHandles.ListParameters = uicontrol(gcf,'Style','popupmenu','String',mappar,'Value',handles.Toolbox(tb).ActiveMap, 'Position',   [ 60  120 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.PlotMap      = uicontrol(gcf,'Style','checkbox','String','Plot',   'Position',   [265 130 80 20],'Tag','UIControl');

handles.GUIHandles.TextType = uicontrol(gcf,'Style','text','String','Type',   'Position',   [180 101 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.SelectType = uicontrol(gcf,'Style','popupmenu','String',{'2dscalar','2dvector'},'Position',   [265 105 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextColorMap = uicontrol(gcf,'Style','text','String','Color Map',   'Position',   [180 76 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditColorMap = uicontrol(gcf,'Style','edit','String','',   'Position',   [265 80 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextLongName = uicontrol(gcf,'Style','text','String','Long Name',   'Position',   [180 51 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditLongName = uicontrol(gcf,'Style','edit','String','',   'Position',   [265 55 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextShortName = uicontrol(gcf,'Style','text','String','Short Name',   'Position',   [180 26 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditShortName = uicontrol(gcf,'Style','edit','String','',   'Position',   [265 30 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextUnit = uicontrol(gcf,'Style','text','String','Unit',   'Position',   [370 126 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditUnit = uicontrol(gcf,'Style','edit','String','',   'Position',   [455 130 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextBarLabel = uicontrol(gcf,'Style','text','String','Bar Label',   'Position',   [370 101 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditBarLabel = uicontrol(gcf,'Style','edit','String','',   'Position',   [455 105 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextPlotRoutine = uicontrol(gcf,'Style','text','String','Plot Routine',   'Position',   [370 76 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.SelectPlotRoutine = uicontrol(gcf,'Style','popupmenu','String',{'PlotPatches','PlotColoredCurvedArrows'},   'Position',   [455 80 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDtAnim = uicontrol(gcf,'Style','text','String','Dt Anim',   'Position',   [565 126 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditDtAnim = uicontrol(gcf,'Style','edit','String','',   'Position',   [650 130 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDtCurVec = uicontrol(gcf,'Style','text','String','Dt Curvec',   'Position',   [565 101 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditDtCurVec = uicontrol(gcf,'Style','edit','String','',   'Position',   [650 105 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDxCurVec = uicontrol(gcf,'Style','text','String','Dx Curvec',   'Position',   [565 76 80 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.EditDxCurVec = uicontrol(gcf,'Style','edit','String','',   'Position',   [650 80 100 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.ListParameters,'Callback',{@ListParameters_Callback});
set(handles.GUIHandles.PlotMap,'Callback',{@PlotMap_Callback});
set(handles.GUIHandles.SelectType,'Callback',{@SelectType_Callback});
set(handles.GUIHandles.EditColorMap,'Callback',{@EditColorMap_Callback});
set(handles.GUIHandles.EditLongName,'Callback',{@EditLongName_Callback});
set(handles.GUIHandles.EditShortName,'Callback',{@EditShortName_Callback});
set(handles.GUIHandles.EditUnit,'Callback',{@EditUnit_Callback});
set(handles.GUIHandles.EditBarLabel,'Callback',{@EditBarLabel_Callback});
set(handles.GUIHandles.SelectPlotRoutine,'Callback',{@SelectPlotRoutine_Callback});
set(handles.GUIHandles.EditDtAnim,'Callback',{@EditDtAnim_Callback});
set(handles.GUIHandles.EditDtCurVec,'Callback',{@EditDtCurVec_Callback});
set(handles.GUIHandles.EditDxCurVec,'Callback',{@EditDxCurVec_Callback});

SetUIBackgroundColors;

Refresh(handles);

setHandles(handles);

%%
function ListParameters_Callback(hObject,eventdata)
handles=getHandles;
handles.Toolbox(tb).ActiveMap=get(hObject,'Value');
Refresh(handles);
setHandles(handles);

%%
function PlotMap_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapPlot(iac)=get(hObject,'Value');
setHandles(handles);

%%
function SelectType_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
str=get(hObject,'String');
i=get(hObject,'Value');
handles.Toolbox(tb).MapType{iac}=str{i};
setHandles(handles);

%%
function EditColorMap_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapColorMap{iac}=get(hObject,'String');
setHandles(handles);

%%
function EditLongName_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapLongName{iac}=get(hObject,'String');
setHandles(handles);

%%
function EditShortName_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapShortName{iac}=get(hObject,'String');
setHandles(handles);

%%
function EditUnit_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapUnit{iac}=get(hObject,'String');
setHandles(handles);

%%
function EditBarLabel_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapBarLabel{iac}=get(hObject,'String');
setHandles(handles);

%%
function SelectPlotRoutine_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
str=get(hObject,'String');
i=get(hObject,'Value');
handles.Toolbox(tb).MapPlotRoutine{iac}=str{i};
Refresh(handles);
setHandles(handles);

%%
function EditDtAnim_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapDtAnim(iac)=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDxCurVec_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapDxCurVec(iac)=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDtCurVec_Callback(hObject,eventdata)
handles=getHandles;
iac=handles.Toolbox(tb).ActiveMap;
handles.Toolbox(tb).MapDtCurVec(iac)=str2double(get(hObject,'String'));
setHandles(handles);

%%
function Refresh(handles)

iac=handles.Toolbox(tb).ActiveMap;

str=get(handles.GUIHandles.SelectType,'String');
tp=handles.Toolbox(tb).MapType{iac};
ii=strmatch(tp,str,'exact');
set(handles.GUIHandles.SelectType,'Value',ii);

str=get(handles.GUIHandles.SelectPlotRoutine,'String');
tp=handles.Toolbox(tb).MapPlotRoutine{iac};
ii=strmatch(tp,str,'exact');
set(handles.GUIHandles.SelectPlotRoutine,'Value',ii);

set(handles.GUIHandles.PlotMap,'Value',handles.Toolbox(tb).MapPlot(iac));
set(handles.GUIHandles.EditColorMap,'String',handles.Toolbox(tb).MapColorMap{iac});
set(handles.GUIHandles.EditLongName,'String',handles.Toolbox(tb).MapLongName{iac});
set(handles.GUIHandles.EditShortName,'String',handles.Toolbox(tb).MapShortName{iac});
set(handles.GUIHandles.EditUnit,'String',handles.Toolbox(tb).MapUnit{iac});
set(handles.GUIHandles.EditBarLabel,'String',handles.Toolbox(tb).MapBarLabel{iac});
set(handles.GUIHandles.EditDtAnim,'String',num2str(handles.Toolbox(tb).MapDtAnim(iac)));
set(handles.GUIHandles.EditDtCurVec,'String',num2str(handles.Toolbox(tb).MapDtCurVec(iac)));
set(handles.GUIHandles.EditDxCurVec,'String',num2str(handles.Toolbox(tb).MapDxCurVec(iac)));

if strcmpi(handles.Toolbox(tb).MapPlotRoutine{iac},'plotcoloredcurvedarrows')
    set(handles.GUIHandles.TextDtAnim,'Visible','on');
    set(handles.GUIHandles.TextDtCurVec,'Visible','on');
    set(handles.GUIHandles.TextDxCurVec,'Visible','on');
    set(handles.GUIHandles.EditDtAnim,'Visible','on');
    set(handles.GUIHandles.EditDtCurVec,'Visible','on');
    set(handles.GUIHandles.EditDxCurVec,'Visible','on');
else
    set(handles.GUIHandles.TextDtAnim,'Visible','off');
    set(handles.GUIHandles.TextDtCurVec,'Visible','off');
    set(handles.GUIHandles.TextDxCurVec,'Visible','off');
    set(handles.GUIHandles.EditDtAnim,'Visible','off');
    set(handles.GUIHandles.EditDtCurVec,'Visible','off');
    set(handles.GUIHandles.EditDxCurVec,'Visible','off');
end

