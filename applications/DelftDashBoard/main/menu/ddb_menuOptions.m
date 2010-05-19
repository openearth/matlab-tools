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
