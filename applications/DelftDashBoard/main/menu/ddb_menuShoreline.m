function ddb_menuShoreline(hObject, eventdata, handles)

handles=getHandles;

lbl=get(hObject,'Label');

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

if ~strcmpi(handles.ScreenParameters.Shoreline,lbl)
    handles.ScreenParameters.Shoreline=lbl;
    setHandles(handles);
    ddb_updateDataInScreen;
end
