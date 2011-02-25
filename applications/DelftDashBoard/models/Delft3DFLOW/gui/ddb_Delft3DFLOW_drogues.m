        function ddb_Delft3DFLOW_drogues(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addDrogue=0;
    handles.Model(md).Input(ad).selectDrogue=0;
    handles.Model(md).Input(ad).changeDrogue=0;
    handles.Model(md).Input(ad).deleteDrogue=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectDrogue=0;
            handles.Model(md).Input(ad).changeDrogue=0;
            handles.Model(md).Input(ad).deleteDrogue=0;
            if handles.Model(md).Input(ad).addDrogue
                handles.editMode='add';
                ddb_dragLine(@addDrogue,'free');
                setInstructions({'','','Click point on map for new drogue(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end

        case{'delete'}
            handles.Model(md).Input(ad).addDrogue=0;
            handles.Model(md).Input(ad).selectDrogue=0;
            handles.Model(md).Input(ad).changeDrogue=0;
            ddb_clickObject('tag','Drogue','callback',@deleteDrogueFromMap);
            setInstructions({'','','Select drogue from map to delete'});
            if handles.Model(md).Input(ad).deleteDrogue
                % Delete drogue selected from list
                handles=deleteDrogue(handles);
            end

        case{'select'}
            handles.Model(md).Input(ad).addDrogue=0;
            handles.Model(md).Input(ad).deleteDrogue=0;
            handles.Model(md).Input(ad).changeDrogue=0;
            if handles.Model(md).Input(ad).selectDrogue
                ddb_clickObject('tag','Drogue','callback',@selectDrogueFromMap);
                setInstructions({'','','Select drogue from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
                        
        case{'change'}
            handles.Model(md).Input(ad).addDrogue=0;
            handles.Model(md).Input(ad).selectDrogue=0;
            handles.Model(md).Input(ad).deleteDrogue=0;
            if handles.Model(md).Input(ad).changeDrogue
                ddb_clickObject('tag','Drogue','callback',@changeDrogueFromMap);
                setInstructions({'','','Select drogue to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end

        case{'edit'}
            handles.Model(md).Input(ad).addDrogue=0;
            handles.Model(md).Input(ad).selectDrogue=0;
            handles.Model(md).Input(ad).changeDrogue=0;
            handles.Model(md).Input(ad).deleteDrogue=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeDrogue;
            name=handles.Model(md).Input(ad).drogues(n).name;
            if strcmpi(handles.Model(md).Input(ad).drogues(n).name(1),'(')
                mstr=num2str(handles.Model(md).Input(ad).drogues(n).M);
                nstr=num2str(handles.Model(md).Input(ad).drogues(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.Model(md).Input(ad).drogueNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
            clearInstructions;

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addDrogue=0;
            handles.Model(md).Input(ad).selectDrogue=0;
            handles.Model(md).Input(ad).changeDrogue=0;
            % Delete selected drogue next time delete is clicked
            handles.Model(md).Input(ad).deleteDrogue=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
            clearInstructions;

        case{'openfile'}
            handles=ddb_readDroFile(handles);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');

        case{'savefile'}
            ddb_saveDroFile(handles,ad);

    end
end

setHandles(handles);

refreshDrogues;

%%
function addDrogue(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findGridCell(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.Model(md).Input(ad).changeDrogue
            iac=handles.Model(md).Input(ad).activeDrogue;
        else
            % Add mode
            handles.Model(md).Input(ad).nrDrogues=handles.Model(md).Input(ad).nrDrogues+1;
            iac=handles.Model(md).Input(ad).nrDrogues;
        end
        handles.Model(md).Input(ad).drogues(iac).M=m1;
        handles.Model(md).Input(ad).drogues(iac).N=n1;
        handles.Model(md).Input(ad).drogues(iac).releaseTime=handles.Model(md).Input(ad).startTime;
        handles.Model(md).Input(ad).drogues(iac).recoveryTime=handles.Model(md).Input(ad).stopTime;
        handles.Model(md).Input(ad).drogues(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        handles.Model(md).Input(ad).drogueNames{iac}=handles.Model(md).Input(ad).drogues(iac).name;
        handles.Model(md).Input(ad).activeDrogue=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
        setHandles(handles);
        
        if handles.Model(md).Input(ad).changeDrogue
            ddb_clickObject('tag','drogue','callback',@changeDrogueFromMap);
            setInstructions({'','','Select drogue'});
        else
            ddb_dragLine(@addDrogue,'free');
            setInstructions({'','','Click position of new drogue'});
        end
    end
end
refreshDrogues;

%%
function handles=deleteDrogue(handles)

nrobs=handles.Model(md).Input(ad).nrDrogues;

if nrobs>0
    iac=handles.Model(md).Input(ad).activeDrogue;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','drogues');
    if nrobs>1
        handles.Model(md).Input(ad).drogues=removeFromStruc(handles.Model(md).Input(ad).drogues,iac);
        handles.Model(md).Input(ad).drogueNames=removeFromCellArray(handles.Model(md).Input(ad).drogueNames,iac);
    else   
        handles.Model(md).Input(ad).drogueNames={''};
        handles.Model(md).Input(ad).activeDrogue=1;
        handles.Model(md).Input(ad).drogues(1).M=[];
        handles.Model(md).Input(ad).drogues(1).N=[];
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.Model(md).Input(ad).nrDrogues=nrobs-1;
    handles.Model(md).Input(ad).activeDrogue=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drogues');
    setHandles(handles);
    refreshDrogues;
end

%%
function deleteDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDrogue=iac;
handles=deleteDrogue(handles);
setHandles(handles);

%%
function selectDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDrogue=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
setHandles(handles);
refreshDrogues;

%%
function changeDrogueFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDrogue=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drogues');
setHandles(handles);
refreshDrogues;
ddb_dragLine(@addDrogue,'free');
setInstructions({'','','Click new position of drogue'});

%%
function refreshDrogues
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.listdrogues');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.editdrom');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.editdron');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.editdroreleasetime');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.editdrorecoverytime');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.editdroname');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.toggleadddrogue');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.toggleselectdrogue');
setUIElement('delft3dflow.monitoring.monitoringpanel.drogues.togglechangedrogue');

