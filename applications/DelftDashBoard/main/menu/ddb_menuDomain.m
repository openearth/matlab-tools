function ddb_menuDomain(hObject, eventdata, handles)

tg=get(hObject,'Tag');

switch tg
    case{'menuDomainAddDomain'}
        ddb_menuDomainAdd_Callback(hObject,eventdata);
    case{'menuDomainFirstDomain'}
        ddb_menuDomainFirstDomain_Callback(hObject,eventdata);
end

%%
function ddb_menuDomainFirstDomain_Callback(hObject, eventdata)

%%
function ddb_menuDomainAdd_Callback(hObject, eventdata)

% handles=getHandles;
% handles.GUIData.NrFlowDomains=handles.GUIData.NrFlowDomains+1;
% handles.ActiveDomain=handles.GUIData.NrFlowDomains;
% handles.Model(md).Input(handles.ActiveDomain)=handles.Model(md).Input(handles.ActiveDomain-1);
% handles=ddb_initializeFlowDomain(handles,'griddependentinput',handles.ActiveDomain,'new');
% setHandles(handles);
% ddb_changeDomain;
