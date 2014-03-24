function ddb_modelMakerQuickMode
%DDB_MODELMAKERQUICKMODE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_modelMakerQuickMode
%
%   Input:

%
%
%
%
%   Example
%   ddb_modelMakerQuickMode
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
ddb_refreshScreen('Toolbox','Quick Mode');

handles=getHandles;

ddb_plotModelMaker(handles,'activate');

if strcmp(handles.ScreenParameters.CoordinateSystem.Type,'Geographic')
    handles.toolbox.modelmaker.dX=min(max(handles.toolbox.modelmaker.dX,0.001),1);
    handles.toolbox.modelmaker.dY=min(max(handles.toolbox.modelmaker.dY,0.001),1);
else
    handles.toolbox.modelmaker.dX=min(max(handles.toolbox.modelmaker.dX,100),100000);
    handles.toolbox.modelmaker.dY=min(max(handles.toolbox.modelmaker.dY,100),100000);
end

handles.GUIHandles.EditXOri     = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.XOri),    'Position',[ 80 105 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNX       = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.nX),      'Position',[ 80  80 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDX       = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.dX),      'Position',[ 80  55 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditRotation = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.Rotation),'Position',[ 80  30 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditYOri     = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.YOri),    'Position',[190 105 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNY       = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.nY),      'Position',[190  80 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDY       = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.dY),      'Position',[190  55 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextXOri     = uicontrol(gcf,'Style','text','String','X Origin','Position',[ 35 102 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextNX       = uicontrol(gcf,'Style','text','String','MMax',    'Position',[ 35  77 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextDX       = uicontrol(gcf,'Style','text','String','Delta X', 'Position',[ 35  52 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextRotation = uicontrol(gcf,'Style','text','String','Rotation','Position',[ 35  27 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextYOri     = uicontrol(gcf,'Style','text','String','Y Origin','Position',[145 102 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextNY       = uicontrol(gcf,'Style','text','String','NMax',    'Position',[145  77 40 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextDY       = uicontrol(gcf,'Style','text','String','Delta Y', 'Position',[145  52 40 20],'HorizontalAlignment','right','Tag','UIControl');

handles.GUIHandles.Pushddb_drawGridOutline            = uicontrol(gcf,'Style','pushbutton','String','Draw Grid Outline',           'Position',[260 105 100 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateGrid               = uicontrol(gcf,'Style','pushbutton','String','Generate Grid',               'Position',[380 130 170 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateBathymetry         = uicontrol(gcf,'Style','pushbutton','String','Generate Bathymetry',         'Position',[380 105 170 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateBoundaryLocations  = uicontrol(gcf,'Style','pushbutton','String','Generate Open Boundaries',    'Position',[380  80 170 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateBoundaryConditions = uicontrol(gcf,'Style','pushbutton','String','Generate Boundary Conditions','Position',[380  55 170 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateInitialConditions  = uicontrol(gcf,'Style','pushbutton','String','Generate Initial Conditions', 'Position',[380  30 170 20],'Tag','UIControl');

set(handles.GUIHandles.EditXOri,'CallBack',    {@EditXOri_CallBack});
set(handles.GUIHandles.EditNX,  'CallBack',    {@EditNX_CallBack});
set(handles.GUIHandles.EditDX,  'CallBack',    {@EditDX_CallBack});
set(handles.GUIHandles.EditYOri,'CallBack',    {@EditYOri_CallBack});
set(handles.GUIHandles.EditNY,  'CallBack',    {@EditNY_CallBack});
set(handles.GUIHandles.EditDY,  'CallBack',    {@EditDY_CallBack});
set(handles.GUIHandles.EditRotation,'CallBack',{@EditRotation_CallBack});

str=handles.Bathymetry.Datasets;
ii=handles.Bathymetry.ActiveDataset;
handles.GUIHandles.SelectBackgroundBathymetry = uicontrol(gcf,'Style','popupmenu','String',str,'Value',ii,'Position',[560 105 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.SelectBackgroundBathymetry,'Visible','off');

str=handles.TideModels.longName;
ii=strmatch(handles.TideModels.ActiveTideModelBC,handles.TideModels.Name,'exact');
handles.GUIHandles.SelectTideModelBC = uicontrol(gcf,'Style','popupmenu','String',str,'Value',ii,'Position',[560 55 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');
ii=strmatch(handles.TideModels.ActiveTideModelIC,handles.TideModels.Name,'exact');
handles.GUIHandles.SelectTideModelIC = uicontrol(gcf,'Style','popupmenu','String',str,'Value',ii,'Position',[560 30 100 20],'BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.Pushddb_drawGridOutline,           'CallBack',{@Pushddb_drawGridOutline_Callback});
set(handles.GUIHandles.PushGenerateGrid,              'CallBack',{@PushGenerateGrid_Callback});
set(handles.GUIHandles.PushGenerateBathymetry,        'CallBack',{@PushGenerateBathymetry_Callback});
set(handles.GUIHandles.PushGenerateBoundaryLocations, 'CallBack',{@PushGenerateBoundaryLocations_Callback});
set(handles.GUIHandles.PushGenerateBoundaryConditions,'CallBack',{@PushGenerateBoundaryConditions_Callback});
set(handles.GUIHandles.PushGenerateInitialConditions, 'CallBack',{@PushGenerateInitialConditions_Callback});

handles.GUIHandles.EditZMax          = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.ZMax),          'Position',[560 130 50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditSectionLength = uicontrol(gcf,'Style','edit','String',num2str(handles.toolbox.modelmaker.SectionLength), 'Position',[560  80 30 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.TextZMax          = uicontrol(gcf,'Style','text','String','ZMax (m)',                     'Position',[615 126 50 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextSectionLength = uicontrol(gcf,'Style','text','String','Cells per Section',            'Position',[595  76 85 20],'HorizontalAlignment','left','Tag','UIControl');
set(handles.GUIHandles.EditZMax,     'CallBack',{@EditZMax_CallBack});
set(handles.GUIHandles.EditSectionLength,     'CallBack',{@EditSectionLength_CallBack});

uipanel('Title','','Units','pixels','Position',[690 30 310 120],'Tag','UIControl');
handles.GUIHandles.EditRunid         = uicontrol(gcf,'Style','edit','String',handles.Model(md).Input(ad).Runid,        'Position',[765 115  50 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditAttributeName = uicontrol(gcf,'Style','edit','String',handles.Model(md).Input(ad).AttName,      'Position',[765  90  50 20],'HorizontalAlignment','left', 'BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditReferenceDate = uicontrol(gcf,'Style','edit','String',datestr(handles.Model(md).Input(ad).ItDate,'yyyy mm dd'), 'Position',[880 115 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStartTime     = uicontrol(gcf,'Style','edit','String',datestr(handles.Model(md).Input(ad).StartTime,'yyyy mm dd HH MM SS'),'Position',[880  90 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditStopTime      = uicontrol(gcf,'Style','edit','String',datestr(handles.Model(md).Input(ad).StopTime, 'yyyy mm dd HH MM SS'),'Position',[880  65 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditTimeStep      = uicontrol(gcf,'Style','edit','String',num2str(handles.Model(md).Input(ad).TimeStep),'Position',[880  40 110 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.RunSimulation     = uicontrol(gcf,'Style','pushbutton','String','Run', 'Position',[765 65 50 20],'Tag','UIControl');
handles.GUIHandles.TextRunid         = uicontrol(gcf,'Style','text','String','Run ID',    'Position',[695 112 65 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextAttribute     = uicontrol(gcf,'Style','text','String','Attribute Files', 'Position',[693 87 70 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextRefTime       = uicontrol(gcf,'Style','text','String','Ref Time', 'Position',[825 112 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTStart        = uicontrol(gcf,'Style','text','String','Start Time', 'Position',[825  87 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextTStop         = uicontrol(gcf,'Style','text','String','Stop Time', 'Position', [825  62 50 20],'HorizontalAlignment','right','Tag','UIControl');
handles.GUIHandles.TextDT            = uicontrol(gcf,'Style','text','String','Time Step (min)', 'Position', [800  36 75 20],'HorizontalAlignment','right','Tag','UIControl');

set(handles.GUIHandles.EditRunid,        'CallBack',{@EditRunid_CallBack});
set(handles.GUIHandles.EditAttributeName,'CallBack',{@EditAttributeName_CallBack});
set(handles.GUIHandles.EditReferenceDate,'CallBack',{@EditReferenceDate_CallBack});
set(handles.GUIHandles.EditStartTime,    'CallBack',{@EditStartTime_CallBack});
set(handles.GUIHandles.EditStopTime,     'CallBack',{@EditStopTime_CallBack});
set(handles.GUIHandles.EditTimeStep,     'CallBack',{@EditTimeStep_CallBack});
set(handles.GUIHandles.RunSimulation,    'CallBack',{@RunSimulation_Callback});

set(handles.GUIHandles.SelectBackgroundBathymetry,        'CallBack',{@SelectBackgroundBathymetry_Callback});
set(handles.GUIHandles.SelectTideModelBC,        'CallBack',{@SelectTideModelBC_Callback});
set(handles.GUIHandles.SelectTideModelIC,        'CallBack',{@SelectTideModelIC_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function EditXOri_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.XOri=str2double(get(hObject,'String'));
setHandles(handles);

h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditDX_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.nX=round(handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.dX/str2double(get(hObject,'String')));
handles.toolbox.modelmaker.dX=str2double(get(hObject,'String'));
set(handles.GUIHandles.EditNX,'String',num2str(handles.toolbox.modelmaker.nX));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditNX_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.nX=str2double(get(hObject,'String'));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditYOri_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.YOri=str2double(get(hObject,'String'));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditDY_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.nY=round(handles.toolbox.modelmaker.nY*handles.toolbox.modelmaker.dY/str2double(get(hObject,'String')));
handles.toolbox.modelmaker.dY=str2double(get(hObject,'String'));
set(handles.GUIHandles.EditNY,'String',num2str(handles.toolbox.modelmaker.nY));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditNY_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.nY=str2double(get(hObject,'String'));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditRotation_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.Rotation=str2double(get(hObject,'String'));
setHandles(handles);
h=findobj(gca,'Tag','GridOutline');
if ~isempty(h)
    lenx=handles.toolbox.modelmaker.dX*handles.toolbox.modelmaker.nX;
    leny=handles.toolbox.modelmaker.dY*handles.toolbox.modelmaker.nY;
    PlotRectangle('GridOutline',handles.toolbox.modelmaker.XOri,handles.toolbox.modelmaker.YOri,lenx,leny,handles.toolbox.modelmaker.Rotation);
end

%%
function EditZMax_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.ZMax=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditSectionLength_CallBack(hObject,eventdata)
handles=getHandles;
handles.toolbox.modelmaker.SectionLength=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditRunid_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).Runid=get(hObject,'String');
setHandles(handles);

%%
function EditAttributeName_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).AttName=get(hObject,'String');
setHandles(handles);

%%
function EditReferenceDate_CallBack(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).ItDate=datenum(str,'yyyy mm dd');
setHandles(handles);

%%
function EditStartTime_CallBack(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).StartTime=datenum(str,'yyyy mm dd HH MM SS');
setHandles(handles);

%%
function EditStopTime_CallBack(hObject,eventdata)
handles=getHandles;
str=get(hObject,'String');
handles.Model(md).Input(ad).StopTime=datenum(str,'yyyy mm dd HH MM SS');
setHandles(handles);

%%
function EditTimeStep_CallBack(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input(ad).TimeStep=str2num(get(hObject,'String'));
setHandles(handles);

%%
function SelectBackgroundBathymetry_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
str=get(hObject,'String');
% handles.ScreenParameters.BackgroundBathymetry=str{ii};
handles.Bathymetry.ActiveDataset=ii;
setHandles(handles);

%%
function SelectTideModelBC_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.TideModels.ActiveTideModelBC=handles.TideModels.Name{ii};
setHandles(handles);

%%
function SelectTideModelIC_Callback(hObject,eventdata)
handles=getHandles;
ii=get(hObject,'Value');
handles.TideModels.ActiveTideModelIC=handles.TideModels.Name{ii};
setHandles(handles);

%%
function PushGenerateGrid_Callback(hObject,eventdata)
handles=getHandles;

if handles.toolbox.modelmaker.nX*handles.toolbox.modelmaker.nY<=2000000
    f=str2func(['ddb_generateGrid' handles.Model(md).Name]);
    try
        handles=feval(f,handles,ad,0,0,'ddb_test');
    catch
        ddb_giveWarning('text',['Grid generation not supported for ' handles.Model(md).LongName]);
        return
    end
    
    wb = waitbox('Generating grid ...');pause(0.1);
    
    xori=handles.toolbox.modelmaker.XOri;
    nx=handles.toolbox.modelmaker.nX;
    dx=handles.toolbox.modelmaker.dX;
    yori=handles.toolbox.modelmaker.YOri;
    ny=handles.toolbox.modelmaker.nY;
    dy=handles.toolbox.modelmaker.dY;
    rot=pi*handles.toolbox.modelmaker.Rotation/180;
    zmax=handles.toolbox.modelmaker.ZMax;
    [x,y]=MakeRectangularGrid(xori,yori,nx,ny,dx,dy,rot,zmax,handles.GUIData.x,handles.GUIData.y,handles.GUIData.z);
    
    close(wb);
    
    handles=feval(f,handles,ad,x,y);
    
    setHandles(handles);
    
else
    ddb_giveWarning('Warning','Maximum number of grid points (2,000,000) exceeded ! Please reduce grid resolution.');
end

%%
function PushGenerateBathymetry_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['ddb_generateBathymetry' handles.Model(md).Name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    ddb_giveWarning('text',['Bathymetry generation not supported for ' handles.Model(md).LongName]);
    return
end

handles=feval(f,handles,ad);

setHandles(handles);


%%
function Pushddb_drawGridOutline_Callback(hObject,eventdata)
ddb_zoomOff;
handles=getHandles;

f1=@ddb_deleteGridOutline;
f2=@UpdateGridOutline;
f3=@UpdateGridOutline;
DrawRectangle('GridOutline',f1,f2,f3,'dx',handles.toolbox.modelmaker.dX,'dy',handles.toolbox.modelmaker.dY,'Color','g','Marker','o','MarkerColor','r','LineWidth',1.5,'Rotation','off');

%%
function UpdateGridOutline(x0,y0,lenx,leny,rotation)

handles=getHandles;

handles.toolbox.modelmaker.XOri=x0;
handles.toolbox.modelmaker.YOri=y0;
handles.toolbox.modelmaker.Rotation=rotation;
handles.toolbox.modelmaker.nX=round(lenx/handles.toolbox.modelmaker.dX);
handles.toolbox.modelmaker.nY=round(leny/handles.toolbox.modelmaker.dY);

set(handles.GUIHandles.EditXOri,'String',num2str(handles.toolbox.modelmaker.XOri));
set(handles.GUIHandles.EditYOri,'String',num2str(handles.toolbox.modelmaker.YOri));
set(handles.GUIHandles.EditNX,'String',num2str(handles.toolbox.modelmaker.nX));
set(handles.GUIHandles.EditNY,'String',num2str(handles.toolbox.modelmaker.nY));
set(handles.GUIHandles.EditRotation,'String',num2str(handles.toolbox.modelmaker.Rotation));

setHandles(handles);

%%
function PushGenerateBoundaryLocations_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['ddb_generateBoundaryLocations' handles.Model(md).Name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    ddb_giveWarning('text',['Boundary generation not supported for ' handles.Model(md).LongName]);
    return
end

x=handles.Model(md).Input(ad).GridX;
y=handles.Model(md).Input(ad).GridX;

handles=feval(f,handles,ad,x,y);

setHandles(handles);

%%
function PushGenerateInitialConditions_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['ddb_generateInitialConditions' handles.Model(md).Name]);

try
    handles=feval(f,handles,ad,'ddb_test','ddb_test');
catch
    ddb_giveWarning('text',['Initial conditions generation not supported for ' handles.Model(md).LongName]);
    return
end

if ~isempty(handles.Model(md).Input(ad).GrdFile)
    AttName=get(handles.GUIHandles.EditAttributeName,'String');
    handles.Model(md).Input(ad).IniFile=[AttName '.ini'];
    handles.Model(md).Input(ad).InitialConditions='ini';
    handles.Model(md).Input(ad).SmoothingTime=0.0;
    handles=feval(f,handles,ad,handles.Model(md).Input(ad).IniFile);
else
    ddb_giveWarning('Warning','First generate or load a grid');
end
setHandles(handles);

%%
function PushGenerateBoundaryConditions_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['ddb_generateBoundaryConditions' handles.Model(md).Name]);
try
    handles=feval(f,handles,ad,'ddb_test');
catch
    ddb_giveWarning('text',['Boundary condition generation not supported for ' handles.Model(md).LongName]);
    return
end

handles=feval(f,handles,ad);

setHandles(handles);%%

%%
function RunSimulation_Callback(hObject,eventdata)
system('batch_flw.bat');

