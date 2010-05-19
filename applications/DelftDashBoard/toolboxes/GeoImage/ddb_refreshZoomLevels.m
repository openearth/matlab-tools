function ddb_refreshZoomLevels(handles)

if handles.Toolbox(tb).Input.XLim(2)-handles.Toolbox(tb).Input.XLim(1)>0
    npix=str2double(get(handles.GUIHandles.EditNPix,'String'));
    zoomLevel=ddb_getAutoZoomLevel(handles,handles.Toolbox(tb).Input.XLim,handles.Toolbox(tb).Input.YLim,npix);
    str=get(handles.GUIHandles.SelectZoomLevel,'String');
    str{1}=['auto (' num2str(zoomLevel) ')'];
    set(handles.GUIHandles.SelectZoomLevel,'String',str)
end
