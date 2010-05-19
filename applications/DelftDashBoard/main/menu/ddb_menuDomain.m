function ddb_menuDomain(hObject, eventdata, handles)

handles=getHandles;

tg=get(hObject,'Tag');

switch tg,
    case{'menuDomainAddDomain'}
        ddb_menuDomainAdd_Callback(hObject,eventdata,handles);
    case{'menuDomainFirstDomain'}
        ddb_menuDomainFirstDomain_Callback(hObject,eventdata,handles);
end

%%
function ddb_menuDomainFirstDomain_Callback(hObject, eventdata, handles)

%%
function MenuAddDomain_Callback(hObject, eventdata, handles)
