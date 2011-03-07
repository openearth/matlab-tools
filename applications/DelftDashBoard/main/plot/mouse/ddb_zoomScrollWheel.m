function ddb_zoomScrollWheel(src,evnt)

handles=getHandles;

xl=get(handles.GUIHandles.mapAxis,'xlim');
yl=get(handles.GUIHandles.mapAxis,'ylim');

posax=get(handles.GUIHandles.mapAxis,'Position');

zm=0.8;

pgcf=get(gcf,'CurrentPoint');

dx0=(xl(2)-xl(1))*(pgcf(1)-posax(1))/posax(3);
dy0=(yl(2)-yl(1))*(pgcf(2)-posax(2))/posax(4);
x0=xl(1)+dx0;
y0=yl(1)+dy0;

if evnt.VerticalScrollCount<0
    p1(1)=x0-zm*dx0;
    p1(2)=y0-zm*dy0;
    offset(1)=((xl(2)-xl(1))*zm);
    offset(2)=((yl(2)-yl(1))*zm);
else
    p1(1)=x0-dx0/zm;
    p1(2)=y0-dy0/zm;
    offset(1)=((xl(2)-xl(1))/zm);
    offset(2)=((yl(2)-yl(1))/zm);
end

[xl,yl]=CompXYLim([p1(1) p1(1)+offset(1) ],[p1(2) p1(2)+offset(2)],handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);

set(handles.GUIHandles.mapAxis,'xlim',xl,'ylim',yl);
handles.screenParameters.xLim=xl;
handles.screenParameters.yLim=yl;
setHandles(handles);
