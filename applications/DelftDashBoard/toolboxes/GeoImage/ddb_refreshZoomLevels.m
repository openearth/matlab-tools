function ddb_refreshZoomLevels(handles)

if handles.Toolbox(tb).Input.xLim(2)-handles.Toolbox(tb).Input.xLim(1)>0
    npix=str2double(get(handles.GUIHandles.EditNPix,'String'));
    zoomLevel=ddb_getAutoZoomLevel(handles,handles.Toolbox(tb).Input.xLim,handles.Toolbox(tb).Input.yLim,npix);
    str=get(handles.GUIHandles.SelectZoomLevel,'String');
    str{1}=['auto (' num2str(zoomLevel) ')'];
    set(handles.GUIHandles.SelectZoomLevel,'String',str)
end
