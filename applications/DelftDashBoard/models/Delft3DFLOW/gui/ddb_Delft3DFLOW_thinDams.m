function ddb_Delft3DFLOW_thinDams(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addThinDam=0;
    handles.Model(md).Input(ad).selectThinDam=0;
    handles.Model(md).Input(ad).changeThinDam=0;
    handles.Model(md).Input(ad).deleteThinDam=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','thindams');
    setHandles(handles);
    setUIElements('delft3dflow.domain.domainpanel.thindams');
else
    opt=varargin{1};
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            if handles.Model(md).Input(ad).addThinDam
                ddb_dragLine(@addThinDam,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
                setInstructions({'','','Drag line on map for new thin dam'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'delete'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            ddb_clickObject('tag','drypoint','callback',@deleteThinDamFromMap);
            setInstructions({'','','Select thin dam from map to delete'});
            if handles.Model(md).Input(ad).deleteThinDam
                handles=deleteThinDam(handles);
            end
            setHandles(handles);

        case{'select'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            ddb_clickObject('tag','drypoint','callback',@selectThinDamFromMap);
            setHandles(handles);
            setInstructions({'','','Select thin dam from map'});

        case{'change'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            if handles.Model(md).Input(ad).changeThinDam
                ddb_clickObject('tag','drypoint','callback',@changeThinDamFromMap);
                setInstructions({'','','Select thin dam to change from map'});
            end
            setHandles(handles);

        case{'edit'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            handles.Model(md).Input(ad).deleteThinDam=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeThinDam;
            m1str=num2str(handles.Model(md).Input(ad).thinDams(n).M1);
            m2str=num2str(handles.Model(md).Input(ad).thinDams(n).M2);
            n1str=num2str(handles.Model(md).Input(ad).thinDams(n).N1);
            n2str=num2str(handles.Model(md).Input(ad).thinDams(n).N2);
            handles.Model(md).Input(ad).thinDamNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','thindams');
            setHandles(handles);
            clearInstructions;

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addThinDam=0;
            handles.Model(md).Input(ad).selectThinDam=0;
            handles.Model(md).Input(ad).changeThinDam=0;
            % Delete selected dry point next time delete is clicked
            handles.Model(md).Input(ad).deleteThinDam=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','thindams');
            setHandles(handles);
            clearInstructions;

        case{'openfile'}
            handles=ddb_readThdFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','thindams');
            setHandles(handles);
            
        case{'savefile'}
            ddb_saveThdFile(handles,ad);
            
        case{'plot'}
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','thindams');
            setHandles(handles);
            
    end
end


refreshThinDams;

%%
function addThinDam(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;

if x1==x2 && y1==y2
    [m1,n1,uv]=FindGridLine(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
    m2=m1;
    n2=n1;
else
    [m1,n1]=FindCornerPoint(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
    [m2,n2]=FindCornerPoint(x2,y2,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
end
if m1>0 && (m1==m2 || n1==n2)
    
    if handles.Model(md).Input(ad).changeThinDam
        iac=handles.Model(md).Input(ad).activeThinDam;
    else
        % Add mode
        handles.Model(md).Input(ad).nrThinDams=handles.Model(md).Input(ad).nrThinDams+1;
        iac=handles.Model(md).Input(ad).nrThinDams;
    end

    if x1==x2 && y1==y2
        if uv==1
            handles.Model(md).Input(ad).thinDams(iac).UV='V';
        else
            handles.Model(md).Input(ad).thinDams(iac).UV='U';
        end            
    else
        if m2~=m1
            handles.Model(md).Input(ad).thinDams(iac).UV='V';
        else
            handles.Model(md).Input(ad).thinDams(iac).UV='U';
        end
    end
    if m2>m1
        m1=m1+1;
    end
    if m2<m1
        m2=m2+1;
    end
    if n2>n1
        n1=n1+1;
    end
    if n1>n2
        n2=n2+1;
    end
    
    handles.Model(md).Input(ad).thinDams(iac).M1=m1;
    handles.Model(md).Input(ad).thinDams(iac).N1=n1;
    handles.Model(md).Input(ad).thinDams(iac).M2=m2;
    handles.Model(md).Input(ad).thinDams(iac).N2=n2;
    handles.Model(md).Input(ad).thinDams(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).thinDamNames{iac}=handles.Model(md).Input(ad).thinDams(iac).name;
    handles.Model(md).Input(ad).activeThinDam=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','thindams');
    
    if handles.Model(md).Input(ad).changeThinDam
        ddb_clickObject('tag','thindam','callback',@changeThinDamFromMap);
        setInstructions({'','','Select thin dam'});
    else
        ddb_dragLine(@addThinDam,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
        setInstructions({'','','Drag new thin dam'});
    end
end
setHandles(handles);
refreshThinDams;

%%
function handles=deleteThinDam(handles)

nrdry=handles.Model(md).Input(ad).nrThinDams;

if nrdry>0
    iac=handles.Model(md).Input(ad).activeThinDam;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','thindams');
    if nrdry>1
        handles.Model(md).Input(ad).thinDams=removeFromStruc(handles.Model(md).Input(ad).thinDams,iac);
        handles.Model(md).Input(ad).thinDamNames=removeFromCellArray(handles.Model(md).Input(ad).thinDamNames,iac);
    else   
        handles.Model(md).Input(ad).thinDamNames={''};
        handles.Model(md).Input(ad).activeThinDam=1;
        handles.Model(md).Input(ad).thinDams(1).M1=[];
        handles.Model(md).Input(ad).thinDams(1).M2=[];
        handles.Model(md).Input(ad).thinDams(1).N1=[];
        handles.Model(md).Input(ad).thinDams(1).N2=[];
        handles.Model(md).Input(ad).thinDams(1).UV=[];
    end
    if iac==nrdry
        iac=nrdry-1;
    end
    handles.Model(md).Input(ad).nrThinDams=nrdry-1;
    handles.Model(md).Input(ad).activeThinDam=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','thindams');
    setHandles(handles);
    refreshThinDams;
end

%%
function deleteThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
handles=deleteThinDam(handles);
setHandles(handles);

%%
function selectThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','thindams');
setHandles(handles);
refreshThinDams;

%%
function changeThinDamFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeThinDam=iac;
ddb_Delft3DFLOW_plotThinDams(handles,'update');
setHandles(handles);
refreshThinDams;
ddb_dragLine(@addThinDam,'free');
setInstructions({'','','Drag line for new position of thin dam'});

%%
function refreshThinDams
setUIElement('delft3dflow.domain.domainpanel.thindams.listthindams');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinm1');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinm2');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinn1');
setUIElement('delft3dflow.domain.domainpanel.thindams.editthinn2');
setUIElement('delft3dflow.domain.domainpanel.thindams.radiou');
setUIElement('delft3dflow.domain.domainpanel.thindams.radiov');
setUIElement('delft3dflow.domain.domainpanel.thindams.toggleaddthindam');
setUIElement('delft3dflow.domain.domainpanel.thindams.toggleselectthindam');
setUIElement('delft3dflow.domain.domainpanel.thindams.togglechangethindam');
