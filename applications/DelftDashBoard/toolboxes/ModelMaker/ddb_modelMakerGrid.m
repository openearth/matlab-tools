function ddb_modelMakerGrid
%DDB_MODELMAKERGRID  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_modelMakerGrid
%
%   Input:

%
%
%
%
%   Example
%   ddb_modelMakerGrid
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
ddb_refreshScreen('Toolbox','Grid');
handles=getHandles;

ddb_plotModelMaker(handles,'activate');

% Coastal Grid
uipanel('Title','Coast Model','Units','pixels','Position',[540 30 460 120],'Tag','UIControl');
handles.GUIHandles.EditYOffshore     = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.YOffshore,    'Position',[730 115  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDXCoast       = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.DXCoast,      'Position',[730  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDYMinCoast    = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.DYMinCoast,   'Position',[730  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDYMaxCoast    = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.DYMaxCoast,   'Position',[730  40  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditCourantCoast  = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.CourantCoast, 'Position',[940 115  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditNSmoothCoast  = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.NSmoothCoast, 'Position',[940  90  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');
handles.GUIHandles.EditDepthRelCoast = uicontrol(gcf,'Style','edit','String',handles.Toolbox(tb).Input.DepthRelCoast,'Position',[940  65  50 20],'HorizontalAlignment','right','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextYOffshore     = uicontrol(gcf,'Style','text','String','Offshore Distance (m)',           'Position',[550 111 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDXCoast       = uicontrol(gcf,'Style','text','String','Alongshore Grid Spacing (m)',     'Position',[550  86 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDYMinCoast    = uicontrol(gcf,'Style','text','String','Min Cross-shore Grid Spacing (m)','Position',[550  61 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDYMaxCoast    = uicontrol(gcf,'Style','text','String','Max Cross-shore Grid Spacing (m)','Position',[550  36 170 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextCourantCoast  = uicontrol(gcf,'Style','text','String','Courant Number (-)',              'Position',[790 111 140 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextNSmoothCoast  = uicontrol(gcf,'Style','text','String','Cross-shore Smoothness (-)',      'Position',[790  86 140 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.TextDepthRelCoast = uicontrol(gcf,'Style','text','String','Spacing/Depth Relation (-)',      'Position',[790  61 140 20],'HorizontalAlignment','left','Tag','UIControl');

handles.GUIHandles.PushDrawCoastLine     = uicontrol(gcf,'Style','pushbutton','String','Draw Coastline',        'Position',[790 40 95 20],'Tag','UIControl');
handles.GUIHandles.PushGenerateCoastGrid = uicontrol(gcf,'Style','pushbutton','String','Generate Grid',         'Position',[895 40 95 20],'Tag','UIControl');

set(handles.GUIHandles.EditYOffshore,        'Callback',{@EditYOffshore_Callback});
set(handles.GUIHandles.EditDXCoast,          'Callback',{@EditDXCoast_Callback});
set(handles.GUIHandles.EditDYMinCoast,       'Callback',{@EditDYMinCoast_Callback});
set(handles.GUIHandles.EditDYMaxCoast,       'Callback',{@EditDYMaxCoast_Callback});
set(handles.GUIHandles.EditCourantCoast,     'Callback',{@EditCourantCoast_Callback});
set(handles.GUIHandles.EditNSmoothCoast,     'Callback',{@EditNSmoothCoast_Callback});
set(handles.GUIHandles.EditDepthRelCoast,    'Callback',{@EditDepthRelCoast_Callback});
set(handles.GUIHandles.PushDrawCoastLine,    'Callback',{@PushDrawCoastLine_Callback});
set(handles.GUIHandles.PushGenerateCoastGrid,'Callback',{@PushGenerateCoastGrid_Callback});

SetUIBackgroundColors;

setHandles(handles);

%%
function EditYOffshore_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.YOffshore=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDXCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.DXCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDYMinCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.DYMinCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDYMaxCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.DYMaxCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditCourantCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.CourantCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditNSmoothCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.NSmoothCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function EditDepthRelCoast_Callback(hObject,eventdata)
handles=getHandles;

handles.Toolbox(tb).Input.DepthRelCoast=str2double(get(hObject,'String'));
setHandles(handles);

%%
function PushDrawCoastLine_Callback(hObject,eventdata)

handles=getHandles;

ddb_zoomOff;
h=findall(gcf,'Tag','CoastSpline');
set(h,'HitTest','off');
[x,y]=DrawPolyline('g',1.5,'o','r');
if ~isempty(h)
    delete(h);
end
if ~isempty(x)
    handles.Toolbox(tb).Input.CoastSplineX=x;
    handles.Toolbox(tb).Input.CoastSplineY=y;
end
DrawCoastSpline(handles);
setHandles(handles);

%%
function PushGenerateCoastGrid_Callback(hObject,eventdata)

handles=getHandles;

f=str2func(['GenerateGrid' handles.Model(md).Name]);
try
    handles=feval(f,handles,ad,0,0,'ddb_test');
catch
    ddb_giveWarning('text',['Grid generation not supported for ' handles.Model(md).LongName]);
    return
end

xb=handles.GUIData.x;
yb=handles.GUIData.y;
zb=handles.GUIData.z;

xs=handles.Toolbox(tb).Input.CoastSplineX;
ys=handles.Toolbox(tb).Input.CoastSplineY;
yoff=handles.Toolbox(tb).Input.YOffshore;
dx=handles.Toolbox(tb).Input.DXCoast;
dymin=handles.Toolbox(tb).Input.DYMinCoast;
dymax=handles.Toolbox(tb).Input.DYMaxCoast;
dt=handles.Model(md).Input(ad).TimeStep*60;
c=handles.Toolbox(tb).Input.CourantCoast;
nsmooth=handles.Toolbox(tb).Input.NSmoothCoast;
drel=handles.Toolbox(tb).Input.DepthRelCoast;

[x,y,z]=MakeCoastalGrid(xs,ys,xb,yb,zb,yoff,dx,dymin,dymax,dt,c,nsmooth,drel);

handles=feval(f,handles,ad,x,y);

setHandles(handles);

%%
function DrawCoastSpline(handles)


h=findall(gcf,'Tag','CoastSpline');
if ~isempty(h)
    delete(h);
end
if ~isempty(handles.Toolbox(tb).Input.CoastSplineX)
    xs=handles.Toolbox(tb).Input.CoastSplineX;
    ys=handles.Toolbox(tb).Input.CoastSplineY;
    dx=handles.Toolbox(tb).Input.DXCoast;
    pd=pathdistance(xs,ys);
    nx=round(pd(end)/dx);
    nx=max(nx,1);
    ddx=pd(end)/nx;
    xp=pd(1):ddx:pd(end);
    if length(xp)<1000
        xc = spline(pd,xs,xp);
        yc = spline(pd,ys,xp);
        z  = zeros(size(xc))+6000;
        h  = plot3(xc,yc,z,'g');
        set(h,'LineWidth',1.5);
        set(h,'Tag','CoastSpline');
        set(h,'HitTest','off');
        for i=1:length(handles.Toolbox(tb).Input.CoastSplineX)
            h=plot3(handles.Toolbox(tb).Input.CoastSplineX(i),handles.Toolbox(tb).Input.CoastSplineY(i),7000,'ro');
            set(h,'MarkerEdgeColor','r','MarkerFaceColor','r','MarkerSize',4);
            set(h,'ButtonDownFcn',{@MoveVertex});
            set(h,'Tag','CoastSpline');
            set(h,'UserData',i);
        end
    end
end

%%
function MoveVertex(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
h=get(gcf,'CurrentObject');
ii=get(h,'UserData');
set(0,'UserData',ii);

%%
function FollowTrack(imagefig, varargins)
handles=getHandles;

pos = get(gca, 'CurrentPoint');
xi=pos(1,1);
yi=pos(1,2);
ii=get(0,'UserData');
handles.Toolbox(tb).Input.CoastSplineX(ii)=xi;
handles.Toolbox(tb).Input.CoastSplineY(ii)=yi;
DrawCoastSpline(handles);
setHandles(handles);

%%
function StopTrack(imagefig, varargins)
set(gcf, 'windowbuttonmotionfcn', []);
set(gcf, 'windowbuttonupfcn',     []);
set(0,'UserData',[]);


