function ddb_menuBathymetry(hObject, eventdata, handles)

handles=getHandles;

lbl=get(hObject,'Label');

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

if ~strcmpi(handles.ScreenParameters.BackgroundBathymetry,lbl)
    handles.ScreenParameters.BackgroundBathymetry=lbl;
    setHandles(handles);
    ddb_updateDataInScreen;
end

