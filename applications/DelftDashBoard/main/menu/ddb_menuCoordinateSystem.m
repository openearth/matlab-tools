function ddb_menuCoordinateSystem(hObject, eventdata, handles)

handles=getHandles;
handles.convertModelData=0;
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
    handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
    lab=get(hObject,'Label');
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Geographic';
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
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Cartesian';
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

        handles.screenParameters.UTMZone=UTMZone;

        zn={'C','D','E','F','G','H','J','K','L','M'};
        ii=strmatch(handles.screenParameters.UTMZone{2},zn,'exact');
        if ~isempty(ii)
            str='S';
        else
            str='N';
        end

        lab=['WGS 84 / UTM zone ' num2str(handles.screenParameters.UTMZone{1}) str];
        set(handles.GUIHandles.Menu.CoordinateSystem.UTM,'Label',lab);
        if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
            handles.convertModelData=iconv;
            handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
            handles.screenParameters.coordinateSystem.name=lab;
            handles.screenParameters.coordinateSystem.type='Cartesian';
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
    if ~strcmp(handles.screenParameters.coordinateSystem.name,lab)
        handles.convertModelData=iconv;
        handles.oldCoordinateSystem=handles.screenParameters.coordinateSystem;
        handles.screenParameters.coordinateSystem.name=lab;
        handles.screenParameters.coordinateSystem.type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemOtherGeographic_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.coordinateSystem.Geographic,'Label');
%    [cs,ok]=ddb_selectCoordinateSystem(handles.coordinateData.coordSysGeo,cs0);
    [cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',cs0,'type','geographic');
    if ok
        handles.convertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Geographic,'Label',cs,'Checked','on');
        handles.screenParameters.coordinateSystem.name=cs;
        handles.screenParameters.coordinateSystem.type='Geographic';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function menuCoordinateSystemOtherCartesian_Callback(hObject, eventdata, handles)

[ok,iconv]=checkOK;
if ok
    cs0=get(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label');
%    [cs,ok]=ddb_selectCoordinateSystem(handles.coordinateData.coordSysCart,cs0);
    [cs,type,nr,ok]=ddb_selectCoordinateSystem(handles.coordinateData,handles.EPSG,'default',cs0,'type','projected');
    if ok
        handles.convertModelData=iconv;
        ch=get(get(hObject,'Parent'),'Children');
        set(ch,'Checked','off');
        set(handles.GUIHandles.Menu.CoordinateSystem.Cartesian,'Label',cs,'Checked','on');
        handles.screenParameters.coordinateSystem.name=cs;
        handles.screenParameters.coordinateSystem.type='Cartesian';
        setHandles(handles);
        ddb_changeCoordinateSystem;
    end
end

%%
function [ok,iconv]=checkOK

% ButtonName = questdlg('Also convert existing model input? Otherwise model input will be discarded!', ...
%     'Convert existing model input', ...
%     'Cancel','No', 'Yes', 'Yes');
% 
% switch ButtonName,
%     case 'Cancel',
%         ok=0;
%         iconv=0;
%     case 'No',
%         ok=1;
%         iconv=0;
%     case 'Yes',
%         ok=1;
%         iconv=1;
% end

ButtonName = questdlg('All model and toolbox input will be discarded! Continue?', ...
    'Warning', ...
    'No', 'Yes', 'Yes');

switch ButtonName,
    case 'No',
        ok=0;
        iconv=0;
    case 'Yes',
        ok=1;
        iconv=1;
end
