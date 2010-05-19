function [x,y]=DrawLine(LineColor,LineWidth,LineStyle)

x=[];
y=[];

set(gcf, 'windowbuttondownfcn',   {@StartTrack});
set(gcf, 'windowbuttonmotionfcn', {@MoveMouse});
set(gcf, 'windowbuttonupfcn',     {@StopTrack});
usd.x=[];
usd.y=[];
usd.Line=[];

usd.LineColor=LineColor;
usd.LineWidth=LineWidth;
usd.LineStyle=LineStyle;

set(0,'UserData',usd);

waitfor(0,'userdata',[]);

h=findall(gcf,'Tag','DraggedLine');
if ~isempty(h)
    usd=get(h,'UserData');
    x=usd.x;
    y=usd.y;
    delete(h);
end

%%
function StartTrack(imagefig, varargins) 
set(gcf, 'windowbuttonmotionfcn', {@FollowTrack});
usd=get(0,'UserData');
pos = get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x=posx;
usd.y=posy;
usd.z=9000;
usd.Line=plot3(usd.x,usd.y,usd.z);
set(usd.Line,'LineWidth',usd.LineWidth);
set(usd.Line,'LineStyle',usd.LineStyle);
set(usd.Line,'Color',usd.LineColor);
set(0,'UserData',usd);

%%
function FollowTrack(imagefig, varargins) 
usd =get(gca,'UserData');
pos =get(gca, 'CurrentPoint');
posx=pos(1,1);
posy=pos(1,2);
usd.x(2)=posx;
usd.y(2)=posy;
usd.z(2)=9000;
set(usd.Line,'XData',usd.x);
set(usd.Line,'YData',usd.y);
set(usd.Line,'ZData',usd.z);
set(gca,'UserData',usd);
ddb_updateCoordinateText('arrow',[]);

%%
function StopTrack(imagefig, varargins)
handles=getHandles;
set(gcf, 'windowbuttonupfcn', []);
set(gcf, 'windowbuttonmotionfcn', handles.WindowButtonMotionFcn);
usd=get(0,'UserData');
set(usd.Line,'UserData',usd);
set(usd.Line,'Tag','DraggedLine');
set(0,'UserData',[]);

%%
function MoveMouse(imagefig, varargins)
ddb_updateCoordinateText('arrow',@StartTrack);
