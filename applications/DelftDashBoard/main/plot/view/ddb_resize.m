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

set(handles.GUIHandles.Axis,'Position',[60 200 sz(3)-155 sz(4)-265]);

% set(handles.GUIHandles.TextXCoordinate,'Position',[60+sz(3)-155-160 200+sz(4)-265 80 20]);
% set(handles.GUIHandles.TextYCoordinate,'Position',[60+sz(3)-155-80 200+sz(4)-265 80 20]);
set(handles.GUIHandles.TextXCoordinate,'Position',[300 200+sz(4)-260 80 15]);
set(handles.GUIHandles.TextYCoordinate,'Position',[380 200+sz(4)-260 80 15]);
set(handles.GUIHandles.TextCoordinateSystem,'Position',[100 200+sz(4)-260 200 15]);

xl=get(handles.GUIHandles.Axis,'XLim');
yl=get(handles.GUIHandles.Axis,'YLim');

[xl,yl]=CompXYLim(xl,yl,handles.ScreenParameters.XMaxRange,handles.ScreenParameters.YMaxRange);

set(handles.GUIHandles.Axis,'XLim',xl,'YLim',yl);
handles.ScreenParameters.XLim=xl;
handles.ScreenParameters.YLim=yl;

setHandles(handles);

h=findobj(gcf,'Tag','colorbar');
if ~isempty(h)
    set(h,'Position',[sz(3)-80 200 30 sz(4)-265]);
end

for i=1:length(handles.Model)
    tabpanel('resize','tag',handles.Model(i).Name,'resize','position',[10 10 sz(3)-20 sz(4)-40]);
end
