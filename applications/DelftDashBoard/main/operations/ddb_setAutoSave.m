function ddb_setAutoSave(src, eventdata)

handles=getHandles;
if strcmp(get(handles.GUIHandles.toolBar.autosave,'State'),'on')
    handles.auto_save=1;
else
    handles.auto_save=0;
end
setHandles(handles);
