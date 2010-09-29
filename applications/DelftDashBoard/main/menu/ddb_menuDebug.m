function ddb_menuDebug(hObject, eventdata, handles)

tg=get(hObject,'Tag');

switch tg,
    case{'menuDebugDebugMode'}
        menuDebugMode_Callback(hObject,eventdata);
end

%%
function menuDebugMode_Callback(hObject, eventdata)

handles=getHandles;

checked=get(hObject,'Checked');

if strcmp(checked,'off')
    handles.debugMode=1;
    set(hObject,'Checked','on');
else
    handles.debugMode=0;
    set(hObject,'Checked','off');
end    

setHandles(handles);
