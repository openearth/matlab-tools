function ddb_menuView(hObject, eventdata)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewShoreline'}
        menuViewShorelines_Callback(hObject,eventdata,handles);
    case{'menuViewBackgroundBathymetry'}
        menuViewBackgroundBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewCities'}
        menuViewCities_Callback(hObject,eventdata,handles);
    case{'menuViewSettings'}
        menuViewSettings_Callback(hObject,eventdata);
end    

%%
function menuViewShorelines_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.shoreline,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.shoreline,'Visible','on');
end

%%
function menuViewBackgroundBathymetry_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.bathymetry,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.bathymetry,'Visible','on');
end

%%
function menuViewCities_Callback(hObject, eventdata, handles)
checked=get(hObject,'Checked');
if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.textCities,'Visible','off');
    set(handles.mapHandles.cities,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.textCities,'Visible','on');
    set(handles.mapHandles.cities,'Visible','on');
end    

%%
function menuViewSettings_Callback(hObject, eventdata)

ddb_editViewSettings;

