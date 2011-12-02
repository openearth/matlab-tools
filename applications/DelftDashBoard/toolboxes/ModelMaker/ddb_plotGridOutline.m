function ddb_plotGridOutline(c)
%DDB_PLOTGRIDOUTLINE  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   ddb_plotGridOutline(c)
%
%   Input:
%   c =
%
%
%
%
%   Example
%   ddb_plotGridOutline
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
handles=getHandles;

xori=handles.Toolbox(tb).Input.XOri;
yori=handles.Toolbox(tb).Input.YOri;
rot=handles.Toolbox(tb).Input.Rotation;
dx=handles.Toolbox(tb).Input.dX;
dy=handles.Toolbox(tb).Input.dY;
nx=handles.Toolbox(tb).Input.nX;
ny=handles.Toolbox(tb).Input.nY;

x(1)=xori;
x(2)=x(1)+nx*dx*cos(pi*rot/180);
x(3)=x(2)-ny*dy*sin(pi*rot/180);
x(4)=x(3)-nx*dx*cos(pi*rot/180);
x(5)=x(1);

y(1)=yori;
y(2)=y(1)+nx*dx*sin(pi*rot/180);
y(3)=y(2)+ny*dy*cos(pi*rot/180);
y(4)=y(3)-nx*dx*sin(pi*rot/180);
y(5)=y(1);

z=zeros(size(x))+100;
plt=plot3(x,y,z);
set(plt,'LineWidth',1.5,'Color',c);
set(plt,'Tag','GridOutline');
hold on;

for i=1:4
    %    sh(i)=plot3(x(i),y(i),5000,'ko');
    sh(i)=plot3(x(i),y(i),200,'ko');hold on;
    set(sh(i),'Tag','SelectionHighlight','MarkerSize',4);
    set(sh(i),'MarkerEdgeColor','k');
    set(sh(i),'MarkerFaceColor','r');
    usdsh.Parent=plt(1);
    usdsh.nr=i;
    set(sh(i),'UserData',usdsh);
    set(sh(i),'ButtonDownFcn',{@SelectObject});
end
set(sh(1),'MarkerFaceColor','y','MarkerSize',5);


usd.SelectionHighlights=sh;
usd.x=x;
usd.y=y;
usd.rot=rot;
set(plt,'userdata',usd);


%%
function SelectObject(imagefig, varargins)

if strcmp(get(gcf,'SelectionType'),'open')
    %    GiveWarning('txt','Isn''t this fun?!');
else
    if strcmp(get(gco,'Tag'),'SelectionHighlight')
        ud=get(gco,'userdata');
        usd=get(ud.Parent,'userdata');
        usd.nr=ud.nr;
        if strcmp(get(gcf,'SelectionType'),'normal')
            pos = get(gca, 'CurrentPoint');
            usd.x0=pos(1,1);
            usd.y0=pos(1,2);
            set(gcf, 'windowbuttonmotionfcn', {@MoveCornerPoint});
        else
            % Rotate
            if usd.nr==1
                set(gcf, 'windowbuttonmotionfcn', {@MoveGrid});
            else
                pos = get(gca, 'CurrentPoint');
                h=findobj('Tag','MainWindow');
                handles=guidata(h);
                usd.rot0=handles.Toolbox(tb).Input.Rotation;
                usd.rot00=180*atan2(pos(1,2)-usd.y(1),pos(1,1)-usd.x(1))/pi;
                set(gcf, 'windowbuttonmotionfcn', {@RotateGrid});
            end
        end
    end
    set(0,'userdata',usd);
    set(gcf, 'windowbuttonupfcn', {@StopTrack});
end

%%
function MoveCornerPoint(imagefig, varargins)

usd=get(0,'userdata');

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

handles=getHandles;


switch usd.nr,
    case 1
        
        x0=[posx posy];
        
        x1=[usd.x(3) usd.y(3)];
        x2=[usd.x(2) usd.y(2)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;
        
        x1=[usd.x(4) usd.y(4)];
        x2=[usd.x(3) usd.y(3)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;
        
        if distx>0 && disty>0
            handles.Toolbox(tb).Input.nX=round(abs(distx)/handles.Toolbox(tb).Input.dX);
            handles.Toolbox(tb).Input.nY=round(abs(disty)/handles.Toolbox(tb).Input.dY);
            handles.Toolbox(tb).Input.XOri=posx;
            handles.Toolbox(tb).Input.YOri=posy;
            set(handles.GUIHandles.EditXOri,'String',num2str(handles.Toolbox(tb).Input.XOri));
            set(handles.GUIHandles.EditYOri,'String',num2str(handles.Toolbox(tb).Input.YOri));
            set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
            set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
        end
        
    case 2
        
        x0=[posx posy];
        
        x1=[usd.x(1) usd.y(1)];
        x2=[usd.x(4) usd.y(4)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;
        
        x1=[usd.x(4) usd.y(4)];
        x2=[usd.x(3) usd.y(3)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;
        
        if distx>0 && disty>0
            
            handles.Toolbox(tb).Input.nX=round(abs(distx)/handles.Toolbox(tb).Input.dX);
            handles.Toolbox(tb).Input.nY=round(abs(disty)/handles.Toolbox(tb).Input.dY);
            
            handles.Toolbox(tb).Input.XOri=posx-handles.Toolbox(tb).Input.nX*handles.Toolbox(tb).Input.dX*cos(pi*handles.Toolbox(tb).Input.Rotation/180);
            handles.Toolbox(tb).Input.YOri=posy-handles.Toolbox(tb).Input.nX*handles.Toolbox(tb).Input.dX*sin(pi*handles.Toolbox(tb).Input.Rotation/180);
            
            set(handles.GUIHandles.EditXOri,'String',num2str(handles.Toolbox(tb).Input.XOri));
            set(handles.GUIHandles.EditYOri,'String',num2str(handles.Toolbox(tb).Input.YOri));
            set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
            set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
            
        end
        
    case 3
        x0=[posx posy];
        
        x1=[usd.x(1) usd.y(1)];
        x2=[usd.x(4) usd.y(4)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;
        
        x1=[usd.x(2) usd.y(2)];
        x2=[usd.x(1) usd.y(1)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;
        
        if distx>0 && disty>0
            handles.Toolbox(tb).Input.nX=round(abs(distx)/handles.Toolbox(tb).Input.dX);
            handles.Toolbox(tb).Input.nY=round(abs(disty)/handles.Toolbox(tb).Input.dY);
            
            set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
            set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
        end
        
    case 4
        x0=[posx posy];
        
        x1=[usd.x(3) usd.y(3)];
        x2=[usd.x(2) usd.y(2)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        distx=det([x2-x1 ; x1-x0])/pt;
        
        x1=[usd.x(2) usd.y(2)];
        x2=[usd.x(1) usd.y(1)];
        pt=sqrt((x2(1)-x1(1))^2  + (x2(2)-x1(2))^2);
        disty=det([x2-x1 ; x1-x0])/pt;
        
        if distx>0 && disty>0
            
            handles.Toolbox(tb).Input.nX=round(abs(distx)/handles.Toolbox(tb).Input.dX);
            handles.Toolbox(tb).Input.nY=round(abs(disty)/handles.Toolbox(tb).Input.dY);
            
            handles.Toolbox(tb).Input.XOri=posx+handles.Toolbox(tb).Input.nY*handles.Toolbox(tb).Input.dY*sin(pi*handles.Toolbox(tb).Input.Rotation/180);
            handles.Toolbox(tb).Input.YOri=posy-handles.Toolbox(tb).Input.nY*handles.Toolbox(tb).Input.dY*cos(pi*handles.Toolbox(tb).Input.Rotation/180);
            
            set(handles.GUIHandles.EditXOri,'String',num2str(handles.Toolbox(tb).Input.XOri));
            set(handles.GUIHandles.EditYOri,'String',num2str(handles.Toolbox(tb).Input.YOri));
            set(handles.GUIHandles.EditNX,'String',num2str(handles.Toolbox(tb).Input.nX));
            set(handles.GUIHandles.EditNY,'String',num2str(handles.Toolbox(tb).Input.nY));
            
        end
end

setHandles(handles);
ddb_deleteGridOutline;
ddb_plotGridOutline('g');
ddb_updateCoordinateText('arrow');

%%
function RotateGrid(imagefig, varargins)

usd=get(0,'userdata');

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
handles=getHandles;


rot=180*atan2(pos(1,2)-usd.y(1),pos(1,1)-usd.x(1))/pi;
drot=rot-usd.rot00;

handles.Toolbox(tb).Input.Rotation=usd.rot0+drot;
set(handles.GUIHandles.EditRotation,'String',num2str(handles.Toolbox(tb).Input.Rotation));

setHandles(handles);
ddb_deleteGridOutline;
ddb_plotGridOutline('g');
ddb_updateCoordinateText('arrow');

%%
function MoveGrid(imagefig, varargins)

pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);

handles=getHandles;


handles.Toolbox(tb).Input.XOri=posx;
handles.Toolbox(tb).Input.YOri=posy;
set(handles.GUIHandles.EditXOri,'String',num2str(posx));
set(handles.GUIHandles.EditYOri,'String',num2str(posy));

setHandles(handles);
ddb_deleteGridOutline;
ddb_plotGridOutline('g');
ddb_updateCoordinateText('arrow');

%%
function StopTrack(imagefig, varargins)
ddb_setWindowButtonUpDownFcn;
ddb_setWindowButtonMotionFcn;
set(0,'userdata',[]);

