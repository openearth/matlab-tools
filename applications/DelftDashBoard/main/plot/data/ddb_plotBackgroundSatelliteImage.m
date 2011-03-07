function handles=ddb_plotBackgroundSatelliteImage(handles,x,y,cdata)

h=handles.mapHandles.backgroundImage;
set(h,'XData',x,'YData',y,'CData',cdata);
set(handles.GUIHandles.mapAxis,'YDir','normal');
