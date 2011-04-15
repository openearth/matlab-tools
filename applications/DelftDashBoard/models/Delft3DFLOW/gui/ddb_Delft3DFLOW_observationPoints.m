function ddb_Delft3DFLOW_observationPoints(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addObservationPoint=0;
    handles.Model(md).Input(ad).selectObservationPoint=0;
    handles.Model(md).Input(ad).changeObservationPoint=0;
    handles.Model(md).Input(ad).deleteObservationPoint=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
    setUIElements('delft3dflow.monitoring.monitoringpanel.observationpoints');
    setHandles(handles);

else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectObservationPoint=0;
            handles.Model(md).Input(ad).changeObservationPoint=0;
            handles.Model(md).Input(ad).deleteObservationPoint=0;
            if handles.Model(md).Input(ad).addObservationPoint
                handles.editMode='add';
                ddb_dragLine(@addObservationPoint,'free');
                setInstructions({'','','Click point on map for new observation point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'delete'}
            handles.Model(md).Input(ad).addObservationPoint=0;
            handles.Model(md).Input(ad).selectObservationPoint=0;
            handles.Model(md).Input(ad).changeObservationPoint=0;
            ddb_clickObject('tag','ObservationPoint','callback',@deleteObservationPointFromMap);
            setInstructions({'','','Select observation point from map to delete'});
            if handles.Model(md).Input(ad).deleteObservationPoint
                % Delete observation point selected from list
                handles=deleteObservationPoint(handles);
            end
            setHandles(handles);

        case{'select'}
            handles.Model(md).Input(ad).addObservationPoint=0;
            handles.Model(md).Input(ad).deleteObservationPoint=0;
            handles.Model(md).Input(ad).changeObservationPoint=0;
            if handles.Model(md).Input(ad).selectObservationPoint
                ddb_clickObject('tag','ObservationPoint','callback',@selectObservationPointFromMap);
                setInstructions({'','','Select observation point from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
                        
        case{'change'}
            handles.Model(md).Input(ad).addObservationPoint=0;
            handles.Model(md).Input(ad).selectObservationPoint=0;
            handles.Model(md).Input(ad).deleteObservationPoint=0;
            if handles.Model(md).Input(ad).changeObservationPoint
                ddb_clickObject('tag','ObservationPoint','callback',@changeObservationPointFromMap);
                setInstructions({'','','Select observation point to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'edit'}
            handles.Model(md).Input(ad).addObservationPoint=0;
            handles.Model(md).Input(ad).selectObservationPoint=0;
            handles.Model(md).Input(ad).changeObservationPoint=0;
            handles.Model(md).Input(ad).deleteObservationPoint=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeObservationPoint;
            name=handles.Model(md).Input(ad).observationPoints(n).name;
            if strcmpi(handles.Model(md).Input(ad).observationPoints(n).name(1),'(')
                mstr=num2str(handles.Model(md).Input(ad).observationPoints(n).M);
                nstr=num2str(handles.Model(md).Input(ad).observationPoints(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.Model(md).Input(ad).observationPointNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
            setHandles(handles);
            clearInstructions;

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addObservationPoint=0;
            handles.Model(md).Input(ad).selectObservationPoint=0;
            handles.Model(md).Input(ad).changeObservationPoint=0;
            % Delete selected observation point next time delete is clicked
            handles.Model(md).Input(ad).deleteObservationPoint=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
            setHandles(handles);
            clearInstructions;

        case{'openfile'}
            handles=ddb_readObsFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
            setHandles(handles);

        case{'savefile'}
            ddb_saveObsFile(handles,ad);

    end
end


refreshObservationPoints;

%%
function addObservationPoint(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findGridCell(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.Model(md).Input(ad).changeObservationPoint
            iac=handles.Model(md).Input(ad).activeObservationPoint;
        else
            % Add mode
            handles.Model(md).Input(ad).nrObservationPoints=handles.Model(md).Input(ad).nrObservationPoints+1;
            iac=handles.Model(md).Input(ad).nrObservationPoints;
        end
        handles.Model(md).Input(ad).observationPoints(iac).M=m1;
        handles.Model(md).Input(ad).observationPoints(iac).N=n1;
        handles.Model(md).Input(ad).observationPoints(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        handles.Model(md).Input(ad).observationPointNames{iac}=handles.Model(md).Input(ad).observationPoints(iac).name;
        handles.Model(md).Input(ad).activeObservationPoint=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
        setHandles(handles);
        
        if handles.Model(md).Input(ad).changeObservationPoint
            ddb_clickObject('tag','observationpoint','callback',@changeObservationPointFromMap);
            setInstructions({'','','Select observation point'});
        else
            ddb_dragLine(@addObservationPoint,'free');
            setInstructions({'','','Click position of new observation point'});
        end
    end
end
refreshObservationPoints;

%%
function handles=deleteObservationPoint(handles)

nrobs=handles.Model(md).Input(ad).nrObservationPoints;

if nrobs>0
    iac=handles.Model(md).Input(ad).activeObservationPoint;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','observationpoints');
    if nrobs>1
        handles.Model(md).Input(ad).observationPoints=removeFromStruc(handles.Model(md).Input(ad).observationPoints,iac);
        handles.Model(md).Input(ad).observationPointNames=removeFromCellArray(handles.Model(md).Input(ad).observationPointNames,iac);
    else   
        handles.Model(md).Input(ad).observationPointNames={''};
        handles.Model(md).Input(ad).activeObservationPoint=1;
        handles.Model(md).Input(ad).observationPoints(1).M=[];
        handles.Model(md).Input(ad).observationPoints(1).N=[];
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.Model(md).Input(ad).nrObservationPoints=nrobs-1;
    handles.Model(md).Input(ad).activeObservationPoint=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','observationpoints');
    setHandles(handles);
    refreshObservationPoints;
end

%%
function deleteObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeObservationPoint=iac;
handles=deleteObservationPoint(handles);
setHandles(handles);

%%
function selectObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeObservationPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','observationpoints');
setHandles(handles);
refreshObservationPoints;

%%
function changeObservationPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeObservationPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','observationPoints');
setHandles(handles);
refreshObservationPoints;
ddb_dragLine(@addObservationPoint,'free');
setInstructions({'','','Click new position of observation point'});

%%
function refreshObservationPoints
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.listobservationpoints');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.editobsm');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.editobsn');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.editobsname');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.toggleaddobservationpoint');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.toggleselectobservationpoint');
setUIElement('delft3dflow.monitoring.monitoringpanel.observationpoints.togglechangeobservationpoint');

