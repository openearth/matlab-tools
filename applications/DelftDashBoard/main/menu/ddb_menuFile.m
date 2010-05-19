function ddb_menuFile(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

ii=handles.ActiveModel.Nr;

kappen=0;

switch tg,
    case{'ddb_menuFileNew'}
        handles=ddb_resetAll(handles);
    case{'ddb_menuFileOpen'}
        handles=feval(handles.Model(ii).OpenFcn,handles,handles.ActiveDomain);
    case{'ddb_menuFileAddDomain'}
        handles=feval(handles.Model(ii).OpenFcn,handles,handles.ActiveDomain+1);
    case{'ddb_menuFileOpenDomains'}
        handles=feval(handles.Model(ii).OpenFcn,handles,0);
    case{'ddb_menuFileSave'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'Save');
    case{'ddb_menuFileSaveAs'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAs');
    case{'ddb_menuFileSaveAll'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAll');
    case{'ddb_menuFileSaveAllAs'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAllAs');
    case{'ddb_menuFileSaveAllDomains'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAllDomains');
    case{'ddb_menuFileOpenLandboundary'}
        handles=ddb_menuFileOpenLandboundary(handles);
    case{'ddb_menuFileSelectWorkingDirectory'}
        handles=SelectWorkingDirectory(handles);
    case{'ddb_menuFileExit'}
        ddb_menuExit;
        kappen=1;
end    

if ~kappen
    setHandles(handles);
end

