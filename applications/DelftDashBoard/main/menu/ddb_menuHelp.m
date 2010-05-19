function ddb_menuHelp(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuHelpDeltaresOnline'}
        ddb_menuHelpDeltaresOnline_Callback(hObject,eventdata,handles);
    case{'menuHelpDelftDashboardOnline'}
        ddb_menuHelpDelftDashBoardOnline_Callback(hObject,eventdata,handles);
    case{'menuHelpAboutDelftDashboard'}
        ddb_menuHelpddb_aboutDelftDashBoard_Callback(hObject,eventdata,handles);
end

%%
function ddb_menuHelpDeltaresOnline_Callback(hObject, eventdata, handles)

web http://www.deltares.nl -browser

%%
function ddb_menuHelpDelftDashBoardOnline_Callback(hObject, eventdata, handles)

web http://public.deltares.nl/display/MCTDOC/DelftAlmighty -browser

%%
function ddb_menuHelpddb_aboutDelftDashBoard_Callback(hObject, eventdata, handles)

ddb_aboutDelftDashBoard(handles);
