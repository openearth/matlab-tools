function ddb_resize(src,evt)

handles=getHandles;

sz=get(gcf,'Position');

screensize=get(0,'ScreenSize');

if sz(3)<1040 || sz(4)<600
    sz(3)=max(sz(3),1040);
    sz(4)=max(sz(4),600);
    if sz(2)+sz(4)>screensize(4)-60
        sz(2)=screensize(4)-sz(4)-60;
    end
    set(gcf,'Position',sz);
end

% First change size of model tab panels
for i=1:length(handles.Model)
    tabpanel('resize','tag',lower(handles.Model(i).name),'resize','position',[9 6 sz(3)-10 sz(4)-30]);
end

% Now change size of map panel
hp=get(handles.GUIHandles.mapPanel,'Parent');
posp=get(hp,'Position');
pos=[5 170 posp(3)-10 posp(4)-193];
set(handles.GUIHandles.mapPanel,'Position',pos);

% Now change size of map axis panel
posp=pos;
pos=[40 20 posp(3)-120 posp(4)-50];
set(handles.GUIHandles.mapAxisPanel,'Position',pos);

% Now change size of map axis
set(handles.GUIHandles.mapAxis,'Position',[1 1 pos(3)-5 pos(4)-5]);

% Now change size of colorbar
pos=[posp(3)-35 20 20 posp(4)-50];
set(handles.GUIHandles.colorBarPanel,'Position',pos);
pos=[2 2 15 posp(4)-55];
set(handles.GUIHandles.colorBar,'Position',pos);

% Now change size of coordinate system text
set(handles.GUIHandles.textXCoordinate,'Position',[350 posp(4)-25 80 15]);
set(handles.GUIHandles.textYCoordinate,'Position',[440 posp(4)-25 80 15]);
set(handles.GUIHandles.textCoordinateSystem,'Position',[90 posp(4)-25 200 15]);

xl=get(handles.GUIHandles.mapAxis,'XLim');
yl=get(handles.GUIHandles.mapAxis,'YLim');

[xl,yl]=CompXYLim(xl,yl,handles.screenParameters.xMaxRange,handles.screenParameters.yMaxRange);

set(handles.GUIHandles.mapAxis,'XLim',xl,'YLim',yl);
handles.screenParameters.xLim=xl;
handles.screenParameters.yLim=yl;

setHandles(handles);


