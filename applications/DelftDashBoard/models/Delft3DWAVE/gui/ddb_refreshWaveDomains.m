function handles=ddb_refreshWaveDomains(handles)

ii=strmatch('Delft3DWAVE',{handles.Model.Name},'exact');

h=findall(gcf,'Tag','ddb_menuDomain');

hc=get(h,'Children');
delete(hc);

for i=1:handles.GUIData.NrWaveDomains
    str{i}=handles.Model(md).Input(i).Runid;
    ui=uimenu(h,'Label',str{i},'Callback',{@SelectDomain,i},'Checked','off','UserData',i);
    if i==handles.ActiveDomain
        set(ui,'Checked','on');
    end
end
uimenu(h,'Label','Add Domain ...','Callback',{@SelectDomain,0},'Checked','off','UserData',0);

%%
function SelectDomain(hObject, eventdata, nr)

handles=getHandles;
if nr>0
    handles.ActiveDomain=nr;
    setHandles(handles);
    h=findall(gcf,'Tag','ddb_menuDomain');
    hc=get(h,'Children');
    for i=1:length(hc)
        set(hc(i),'Checked','off');
    end
    h=findall(hc,'UserData',nr);
    set(h,'Checked','on');
    ddb_changeDomain;
else
    str=GetUIString('Enter Runid New Domain');
    if ~isempty(str)
        id=handles.GUIData.NrWaveDomains+1;
        handles.GUIData.NrWaveDomains=id;
        handles.ActiveDomain=id;
        handles.Model(md).Input(id).Runid=str;
        handles=ddb_initializeWaveDomain(handles,'all',id,handles.Model(md).Input(id).Runid);
        setHandles(handles);
        handles=ddb_refreshWaveDomains(handles);
        setHandles(handles);
        ddb_changeDomain;
    end
end

