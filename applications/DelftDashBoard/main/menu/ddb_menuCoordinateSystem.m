function ddb_menuCoordinateSystem(hObject, eventdata, handles)

handles=getHandles;
handles.ConvertModelData=0;
setHandles(handles);

tg=get(hObject,'Tag');

ddb_zoomOff;

switch tg,
    case{'menuCoordinateSystemGeographic'}
        menuCoordinateSystemGeo_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemUTM'}
        menuCoordinateSystemUTM_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemSelectUTMZone'}
        menuCoordinateSystemSelectUTMZone_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemCartesian'}
        menuCoordinateSystemCartesian_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemOtherCartesian'}
        menuCoordinateSystemOtherCartesian_Callback(hObject,eventdata,handles);
    case{'menuCoordinateSystemOtherGeographic'}
        menuCoordinateSystemOtherGeographic_Callback(hObject,eventdata,handles);
end

%%
function menuCoordinateSystemGeo_Callback(hObject,eventdata,handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');
    handles.OldCoordinateSystem=handles.ScreenParameters.CoordinateSystem;
    lab=get(hObject,'Label');
    if ~strcmp(handles.ScreenParameters.CoordinateSystem.Name,lab)
        handles.ConvertModelData=iconv;
        handles.OldCoordinateSystem=handles.ScreenParameters.CoordinateSystem;
        handles.ScreenParameters.CoordinateSystem.Name=lab;
        handles.ScreenParameters.CoordinateSystem.Type='Geographic';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemUTM_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(hObject,'Checked','on');
    lab=get(hObject,'Label');
    if ~strcmp(handles.ScreenParameters.CoordinateSystem.Name,lab)
        handles.ConvertModelData=iconv;
        handles.OldCoordinateSystem=handles.ScreenParameters.CoordinateSystem;
        handles.ScreenParameters.CoordinateSystem.Name=lab;
        handles.ScreenParameters.CoordinateSystem.Type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemSelectUTMZone_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    
    
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');
    set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Checked','on');

    ddb_zoomOff;

    UTMZone=ddb_selectUTMZone;

    if ~isempty(UTMZone)

        handles.ScreenParameters.UTMZone=UTMZone;

        zn={'C','D','E','F','G','H','J','K','L','M'};
        ii=strmatch(handles.ScreenParameters.UTMZone{2},zn,'exact');
        if ~isempty(ii)
            str='S';
        else
            str='N';
        end

        lab=['WGS 84 / UTM zone ' num2str(handles.ScreenParameters.UTMZone{1}) str];
        set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',lab);
        if ~strcmp(handles.ScreenParameters.CoordinateSystem.Name,lab)
            handles.ConvertModelData=iconv;
            handles.OldCoordinateSystem=handles.ScreenParameters.CoordinateSystem;
            handles.ScreenParameters.CoordinateSystem.Name=lab;
            handles.ScreenParameters.CoordinateSystem.Type='Cartesian';
            setHandles(handles);
            ddb_changeCoordinateSystem;
        end
    end
end

%%
function menuCoordinateSystemCartesian_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    ch=get(get(hObject,'Parent'),'Children');
    set(ch,'Checked','off');

    set(hObject,'Checked','on');
    lab=get(hObject,'Label');
    if ~strcmp(handles.ScreenParameters.CoordinateSystem.Name,lab)
        handles.ConvertModelData=iconv;
        handles.OldCoordinateSystem=handles.ScreenParameters.CoordinateSystem;
        handles.ScreenParameters.CoordinateSystem.Name=lab;
        handles.ScreenParameters.CoordinateSystem.Type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemOtherGeographic_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.CoordinateSystem.Geographic,'Label');
    [cs,ok]=ddb_selectCoordinateSystem(handles.CoordinateData.CoordSysGeo,cs0);
    if ok
        handles.ConvertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Geographic,'Label',cs,'Checked','on');
        handles.ScreenParameters.CoordinateSystem.Name=cs;
        handles.ScreenParameters.CoordinateSystem.Type='Geographic';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemOtherCartesian_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label');
    [cs,ok]=ddb_selectCoordinateSystem(handles.CoordinateData.CoordSysCart,cs0);
    if ok
        handles.ConvertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label',cs,'Checked','on');
        handles.ScreenParameters.CoordinateSystem.Name=cs;
        handles.ScreenParameters.CoordinateSystem.Type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function [ok,iconv]=checkOK

ButtonName = questdlg('Also convert existing model input? Otherwise model input will be discarded!', ...
    'Convert existing model input', ...
    'Cancel','No', 'Yes', 'Yes');

switch ButtonName,
    case 'Cancel',
        ok=0;
        iconv=0;
    case 'No',
        ok=1;
        iconv=0;
    case 'Yes',
        ok=1;
        iconv=1;
end
