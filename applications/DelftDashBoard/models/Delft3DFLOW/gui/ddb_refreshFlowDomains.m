function ddb_refreshFlowDomains

handles=getHandles;

h=findobj(gcf,'Tag','menuDomain');

hc=get(h,'Children');
delete(hc);

for i=1:handles.Model(md).nrDomains
    str{i}=handles.Model(md).Input(i).runid;
    ui=uimenu(h,'Label',str{i},'Callback',{@SelectDomain,i},'Checked','off','UserData',i);
    if i==ad
        set(ui,'Checked','on');
    end
end
%uimenu(h,'Label','Add Domain ...','Callback',{@SelectDomain,0},'Checked','off','UserData',0);

%%
function SelectDomain(hObject, eventdata, nr)

handles=getHandles;
if nr>0
    handles.activeDomain=nr;
    setHandles(handles);
    h=findall(gcf,'Tag','menuDomain');
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
        id=handles.GUIData.nrFlowDomains+1;
        handles.GUIData.nrFlowDomains=id;
        handles.activeDomain=id;
        handles.Model(md).Input(id).runid=str;
        handles=ddb_initializeFlowDomain(handles,'all',id,handles.Model(md).Input(id).runid);
        setHandles(handles);
        ddb_refreshFlowDomains;
        ddb_changeDomain;
    end
end
