function ddb_menuBathymetry(hObject, eventdata, handles)

handles=getHandles;

lbl=get(hObject,'Label');

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

if ~strcmpi(handles.screenParameters.backgroundBathymetry,lbl)
    handles.screenParameters.backgroundBathymetry=lbl;
    setHandles(handles);
    ddb_updateDataInScreen;
end
