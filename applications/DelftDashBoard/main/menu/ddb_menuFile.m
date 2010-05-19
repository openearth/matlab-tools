function ddb_menuFile(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

ii=handles.ActiveModel.Nr;

kappen=0;

switch tg,
    case{'menuFileNew'}
        handles=ddb_resetAll(handles);
    case{'menuFileOpen'}
        handles=feval(handles.Model(ii).OpenFcn,handles,handles.ActiveDomain);
    case{'menuFileAddDomain'}
        handles=feval(handles.Model(ii).OpenFcn,handles,handles.ActiveDomain+1);
    case{'menuFileOpenDomains'}
        handles=feval(handles.Model(ii).OpenFcn,handles,0);
    case{'menuFileSave'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'Save');
    case{'menuFileSaveAs'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAs');
    case{'menuFileSaveAll'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAll');
    case{'menuFileSaveAllAs'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAllAs');
    case{'menuFileSaveAllDomains'}
        handles=feval(handles.Model(ii).SaveFcn,handles,'SaveAllDomains');
    case{'menuFileOpenLandboundary'}
        handles=ddb_menuFileOpenLandboundary(handles);
    case{'menuFileSelectWorkingDirectory'}
        handles=SelectWorkingDirectory(handles);
    case{'menuFileExit'}
        ddb_menuExit;
        kappen=1;
end    

if ~kappen
    setHandles(handles);
end

