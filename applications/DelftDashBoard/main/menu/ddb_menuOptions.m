function ddb_menuOptions(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuOptionsCoordinateConversion'}
        ddb_menuOptionsCoordinateConversion_Callback(hObject,eventdata,handles);
    case{'menuOptionsMuppet'}
        ddb_menuOptionsMuppet_Callback(hObject,eventdata,handles);
    case{'menuOptionsQuickplot'}
        ddb_menuOptionsQuickplot_Callback(hObject,eventdata,handles);
    case{'menuOptionsLdbTool'}
        ddb_menuOptionsLdbTool_Callback(hObject,eventdata,handles);
    case{'menuOptionsDatamanagementbathymetry','menuOptionsDatamanagementshorelines','menuOptionsDatamanagementtidemodels'}
        ddb_menuOptionsDM_Callback(hObject,eventdata,handles);    
end

%%
function ddb_menuOptionsCoordinateConversion_Callback(hObject, eventdata, handles)
SuperTrans(handles.EPSG);
guidata(hObject, handles);

%%
function ddb_menuOptionsMuppet_Callback(hObject, eventdata, handles)
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\muppet\bin\muppet.exe']);

%%
function ddb_menuOptionsLdbTool_Callback(hObject, eventdata, handles)

%LdbTool;
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\ldbtool\bin\ldbtool.exe']);

%%
function ddb_menuOptionsQuickplot_Callback(hObject, eventdata, handles)
d3dpath=[getenv('D3D_HOME')];
system([d3dpath, '\w32\quickplot\bin\win32\d3d_qp.exe']);

%%
function ddb_menuOptionsDM_Callback(hObject,eventdata,handles)

switch get(hObject,'Tag');
    case 'menuOptionsDatamanagementbathymetry'
        urls = {handles.Bathymetry.Dataset(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Bathymetry',{handles.Bathymetry.Dataset(:).longName},{handles.Bathymetry.Dataset(:).Name},fileLoc);
        
    case 'menuOptionsDatamanagementshorelines'
        urls = {handles.Shorelines.Shoreline(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Shorelines',{handles.Shorelines.Shoreline(:).longName},{handles.Shorelines.Shoreline(:).Name},fileLoc);

    case 'menuOptionsDatamanagementtidemodels'
        urls = {handles.TideModels.Model(:).URL};
        fileLoc = repmat({'local'},1,length(urls));
        fileLoc(strncmp('http',urls,4))= {'opendap'};
        handles = ddb_dmSelector(handles,'Tidemodels',{handles.TideModels.Model(:).longName},{handles.TideModels.Model(:).Name},fileLoc);

end