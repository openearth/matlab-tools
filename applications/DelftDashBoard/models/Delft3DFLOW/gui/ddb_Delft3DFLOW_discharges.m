function ddb_Delft3DFLOW_discharges(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addDischarge=0;
    handles.Model(md).Input(ad).selectDischarge=0;
    handles.Model(md).Input(ad).changeDischarge=0;
    handles.Model(md).Input(ad).deleteDischarge=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectDischarge=0;
            handles.Model(md).Input(ad).changeDischarge=0;
            handles.Model(md).Input(ad).deleteDischarge=0;
            if handles.Model(md).Input(ad).addDischarge
                handles.editMode='add';
                ddb_dragLine(@addDischarge,'free');
                setInstructions({'','','Click point on map for new discharge(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end

        case{'delete'}
            handles.Model(md).Input(ad).addDischarge=0;
            handles.Model(md).Input(ad).selectDischarge=0;
            handles.Model(md).Input(ad).changeDischarge=0;
            ddb_clickObject('tag','Discharge','callback',@deleteDischargeFromMap);
            setInstructions({'','','Select discharge from map to delete'});
            if handles.Model(md).Input(ad).deleteDischarge
                % Delete discharge selected from list
                handles=deleteDischarge(handles);
            end

        case{'select'}
            handles.Model(md).Input(ad).addDischarge=0;
            handles.Model(md).Input(ad).deleteDischarge=0;
            handles.Model(md).Input(ad).changeDischarge=0;
            if handles.Model(md).Input(ad).selectDischarge
                ddb_clickObject('tag','Discharge','callback',@selectDischargeFromMap);
                setInstructions({'','','Select discharge from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
                        
        case{'change'}
            handles.Model(md).Input(ad).addDischarge=0;
            handles.Model(md).Input(ad).selectDischarge=0;
            handles.Model(md).Input(ad).deleteDischarge=0;
            if handles.Model(md).Input(ad).changeDischarge
                ddb_clickObject('tag','Discharge','callback',@changeDischargeFromMap);
                setInstructions({'','','Select discharge to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end

        case{'edit'}
            handles.Model(md).Input(ad).addDischarge=0;
            handles.Model(md).Input(ad).selectDischarge=0;
            handles.Model(md).Input(ad).changeDischarge=0;
            handles.Model(md).Input(ad).deleteDischarge=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeDischarge;
            name=handles.Model(md).Input(ad).discharges(n).name;
            if strcmpi(handles.Model(md).Input(ad).discharges(n).name(1),'(')
                mstr=num2str(handles.Model(md).Input(ad).discharges(n).M);
                nstr=num2str(handles.Model(md).Input(ad).discharges(n).N);
                name=['('  mstr ',' nstr ')'];
            end
            handles.Model(md).Input(ad).dischargeNames{n}=name;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
            clearInstructions;

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addDischarge=0;
            handles.Model(md).Input(ad).selectDischarge=0;
            handles.Model(md).Input(ad).changeDischarge=0;
            % Delete selected discharge next time delete is clicked
            handles.Model(md).Input(ad).deleteDischarge=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
            clearInstructions;

        case{'openfile'}
            handles=ddb_readObsFile(handles);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');

        case{'savefile'}
            ddb_saveObsFile(handles,ad);

    end
end

setHandles(handles);

refreshDischarges;

%%
function addDischarge(x,y)

x1=x(1);
y1=y(1);

handles=getHandles;
% Find grid indices
[m1,n1]=findGridCell(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
% Check if start and end are in one grid line
if ~isempty(m1)
    if m1>0
        if handles.Model(md).Input(ad).changeDischarge
            iac=handles.Model(md).Input(ad).activeDischarge;
        else
            % Add mode
            handles.Model(md).Input(ad).nrDischarges=handles.Model(md).Input(ad).nrDischarges+1;
            iac=handles.Model(md).Input(ad).nrDischarges;
        end
        handles.Model(md).Input(ad).discharges(iac).M=m1;
        handles.Model(md).Input(ad).discharges(iac).N=n1;
        handles.Model(md).Input(ad).discharges(iac).name=['(' num2str(m1) ',' num2str(n1) ')'];
        handles.Model(md).Input(ad).dischargeNames{iac}=handles.Model(md).Input(ad).discharges(iac).name;
        handles.Model(md).Input(ad).activeDischarge=iac;
        handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
        setHandles(handles);
        
        if handles.Model(md).Input(ad).changeDischarge
            ddb_clickObject('tag','discharge','callback',@changeDischargeFromMap);
            setInstructions({'','','Select discharge'});
        else
            ddb_dragLine(@addDischarge,'free');
            setInstructions({'','','Click position of new discharge'});
        end
    end
end
refreshDischarges;

%%
function handles=deleteDischarge(handles)

nrobs=handles.Model(md).Input(ad).nrDischarges;

if nrobs>0
    iac=handles.Model(md).Input(ad).activeDischarge;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','discharges');
    if nrobs>1
        handles.Model(md).Input(ad).discharges=removeFromStruc(handles.Model(md).Input(ad).discharges,iac);
        handles.Model(md).Input(ad).dischargeNames=removeFromCellArray(handles.Model(md).Input(ad).dischargeNames,iac);
    else   
        handles.Model(md).Input(ad).dischargeNames={''};
        handles.Model(md).Input(ad).activeDischarge=1;
        handles.Model(md).Input(ad).discharges(1).M=[];
        handles.Model(md).Input(ad).discharges(1).N=[];
    end
    if iac==nrobs
        iac=nrobs-1;
    end
    handles.Model(md).Input(ad).nrDischarges=nrobs-1;
    handles.Model(md).Input(ad).activeDischarge=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','discharges');
    setHandles(handles);
    refreshDischarges;
end

%%
function deleteDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDischarge=iac;
handles=deleteDischarge(handles);
setHandles(handles);

%%
function selectDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDischarge=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
setHandles(handles);
refreshDischarges;

%%
function changeDischargeFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDischarge=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','discharges');
setHandles(handles);
refreshDischarges;
ddb_dragLine(@addDischarge,'free');
setInstructions({'','','Click new position of discharge'});

%%
function refreshDischarges
setUIElement('delft3dflow.discharges.listdischarges');
setUIElement('delft3dflow.discharges.editobsm');
setUIElement('delft3dflow.discharges.editobsn');
setUIElement('delft3dflow.discharges.editobsname');
setUIElement('delft3dflow.discharges.toggleadddischarge');
setUIElement('delft3dflow.discharges.toggleselectdischarge');
setUIElement('delft3dflow.discharges.togglechangedischarge');

