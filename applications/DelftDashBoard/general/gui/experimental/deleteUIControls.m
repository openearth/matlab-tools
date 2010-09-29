function deleteUIControls

h=findobj(gcf,'Tag','UIControl');
if ~isempty(h)
    delete(h);
end

handles=getHandles;

if handles.debugMode
        
    panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
    
    oldelements=handles.Model(md).GUI.elements;
    htemp=ddb_readModelXML(handles,md);
    newelements=htemp.Model(md).GUI.elements;
    
    for j=1:length(oldelements)
        if strcmpi(oldelements(j).style,'tabpanel')
            %                jnew=strmatch(newelements(j).tag,);
            jnew=j;
            h=oldelements(j).handle;
            uh=get(h,'UserData');
            newelements(jnew).activeTabNr=uh.activeTab;
            for k=1:length(oldelements(j).tabs)
                for j2=1:length(oldelements(j).tabs(k).elements)
                    if strcmpi(oldelements(j).tabs(k).elements(j2).style,'tabpanel')
                        %                jnew=strmatch(newelements(j).tag,);
                        jnew2=j;
                        h=oldelements(j).tabs(k).elements(j2).handle;
                        uh=get(h,'UserData');
                        newelements(jnew).tabs(k).elements(jnew2).activeTabNr=uh.activeTab;
                    end
                end
            end
            
        end
    end
    % Temporarily set map panel as child of current figure
    set(handles.GUIHandles.mapPanel,'Parent',gcf);
    delete(handles.Model(md).GUI.elements(1).handle);
    handles.Model(md).GUI.elements=newelements;
    handles.Model(md).GUI.elements(1).position=panel.position;
    elements=handles.Model(md).GUI.elements;
    subFields{1}='Model';
    subFields{2}='Input';
    subIndices={md,1};
    if ~isempty(elements)
        elements=addUIElements(gcf,elements,'subFields',subFields,'subIndices',subIndices,'getFcn',@getHandles,'setFcn',@setHandles);
        set(elements(1).handle,'Visible','off');
        handles.Model(md).GUI.elements=elements;
    end
    
    setHandles(handles);
    iac=handles.Model(md).GUI.elements(1).activeTabNr;
    tbname=handles.Model(md).GUI.elements(1).tabs(iac).tabname;
    ddb_selectModel(handles.Model(md).Name,tbname,'runcallback',0);
    
end
