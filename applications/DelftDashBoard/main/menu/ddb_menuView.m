function ddb_menuView(hObject, eventdata)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuViewShoreline'}
        menuViewShorelines_Callback(hObject,eventdata,handles);
    case{'menuViewBackgroundBathymetry'}
        menuViewBackgroundBathymetry_Callback(hObject,eventdata,handles);
    case{'menuViewAerial'}
        menuViewAerial_Callback(hObject,eventdata,handles);
    case{'menuViewHybrid'}
        menuViewHybrid_Callback(hObject,eventdata,handles);
    case{'menuViewRoads'}
        menuViewRoads_Callback(hObject,eventdata,handles);
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
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='bathymetry';
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewAerial_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='aerial';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewHybrid_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='hybrid';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Roads,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
end

%%
function menuViewRoads_Callback(hObject, eventdata, handles)

checked=get(hObject,'Checked');

if strcmp(checked,'on')
    set(hObject,'Checked','off');
    set(handles.mapHandles.backgroundImage,'Visible','off');
else
    set(hObject,'Checked','on');
    set(handles.mapHandles.backgroundImage,'Visible','on');
    handles.GUIData.backgroundImageType='satellite';
    handles.screenParameters.satelliteImageType='road';
    set(handles.GUIHandles.Menu.View.BackgroundBathymetry,'Checked','off');
    set(handles.GUIHandles.Menu.View.Aerial,'Checked','off');
    set(handles.GUIHandles.Menu.View.Hybrid,'Checked','off');
    setHandles(handles);
    ddb_updateDataInScreen;
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

