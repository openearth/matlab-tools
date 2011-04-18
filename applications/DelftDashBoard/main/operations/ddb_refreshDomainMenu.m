function ddb_refreshDomainMenu

handles=getHandles;

h=findobj(gcf,'Tag','menuDomain');

hc=get(h,'Children');
delete(hc);

for i=1:handles.Model(md).nrDomains
    str{i}=handles.Model(md).Input(i).runid;
    ui=uimenu(h,'Label',str{i},'Callback',{@selectDomain,i},'Checked','off','UserData',i);
    if i==ad
        set(ui,'Checked','on');
    end
end
uimenu(h,'Label','Add Domain','Callback',{@selectDomain,0},'Checked','off','UserData',0,'separator','on');
uimenu(h,'Label','Delete Domain','Callback',@deleteDomain,'Checked','off','UserData',0);

%%
function selectDomain(hObject, eventdata, nr)
ddb_zoomOff;
handles=getHandles;
if nr>0
    changeDomain(nr);
else
    str=GetUIString('Enter Runid New Domain');
    if ~isempty(str)
        id=handles.Model(md).nrDomains+1;
        handles.Model(md).nrDomains=id;
        handles.activeDomain=id;
        handles.Model(md).Input(id).runid=str;
        handles=ddb_initializeFlowDomain(handles,'all',id,handles.Model(md).Input(id).runid);
        setHandles(handles);
        ddb_refreshDomainMenu;
        changeDomain(id);
    end
end

%%
function changeDomain(nr)
ddb_zoomOff;
handles=getHandles;
% Check and uncheck the proper domains in the menu
handles.activeDomain=nr;
setHandles(handles);
h=findobj(gcf,'Tag','menuDomain');
hc=get(h,'Children');
for i=1:length(hc)
    set(hc(i),'Checked','off');
end
h=findobj(hc,'UserData',nr);
set(h,'Checked','on');
% Update the figure
for i=1:handles.Model(md).nrDomains
    feval(handles.Model(md).plotFcn,'update','active',0,'visible',1,'domain',i);
end

%% And now set all elements and execute active tab!


%%
function deleteDomain(hObject, eventdata)
handles=getHandles;
if handles.Model(md).nrDomains>1   
    feval(handles.Model(md).plotFcn,'delete');
    handles.Model(md).Input=removeFromStruc(handles.Model(md).Input,ad);
    handles.Model(md).nrDomains=handles.Model(md).nrDomains-1;
    handles.activeDomain=1;
    handles.Model(md).DDBoundaries=[];
    setHandles(handles);
    feval(handles.Model(md).plotFcn,'plot','active',0,'visible',1,'domain',0);
    ddb_refreshDomainMenu;
    
    %% And now set all elements and execute active tab!

end
