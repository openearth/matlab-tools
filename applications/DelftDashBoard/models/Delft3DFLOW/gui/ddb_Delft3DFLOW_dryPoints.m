function ddb_Delft3DFLOW_dryPoints(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addDryPoint=0;
    handles.Model(md).Input(ad).selectDryPoint=0;
    handles.Model(md).Input(ad).changeDryPoint=0;
    handles.Model(md).Input(ad).deleteDryPoint=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drypoints');
    setHandles(handles);
    setUIElements('delft3dflow.domain.domainpanel.drypoints');

else
    
    opt=varargin{1};
    
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            if handles.Model(md).Input(ad).addDryPoint
                handles.editMode='add';
                ddb_dragLine(@addDryPoint,'free');
                setInstructions({'','','Click point or drag line on map for new dry point(s)'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'delete'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            ddb_clickObject('tag','drypoint','callback',@deleteDryPointFromMap);
            setInstructions({'','','Select dry point from map to delete'});
            if handles.Model(md).Input(ad).deleteDryPoint
                % Delete dry point selected from list
                handles=deleteDryPoint(handles);
            end
            setHandles(handles);

        case{'select'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            if handles.Model(md).Input(ad).selectDryPoint
                ddb_clickObject('tag','drypoint','callback',@selectDryPointFromMap);
                setInstructions({'','','Select dry point from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);
                        
        case{'change'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            if handles.Model(md).Input(ad).changeDryPoint
                ddb_clickObject('tag','drypoint','callback',@changeDryPointFromMap);
                setInstructions({'','','Select dry point to change from map'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'edit'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            handles.Model(md).Input(ad).deleteDryPoint=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeDryPoint;
            m1str=num2str(handles.Model(md).Input(ad).dryPoints(n).M1);
            m2str=num2str(handles.Model(md).Input(ad).dryPoints(n).M2);
            n1str=num2str(handles.Model(md).Input(ad).dryPoints(n).N1);
            n2str=num2str(handles.Model(md).Input(ad).dryPoints(n).N2);
            handles.Model(md).Input(ad).dryPointNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drypoints');
            setHandles(handles);
            clearInstructions;

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addDryPoint=0;
            handles.Model(md).Input(ad).selectDryPoint=0;
            handles.Model(md).Input(ad).changeDryPoint=0;
            % Delete selected dry point next time delete is clicked
            handles.Model(md).Input(ad).deleteDryPoint=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','drypoints');
            setHandles(handles);
            clearInstructions;

        case{'openfile'}
            handles=ddb_readDryFile(handles,ad);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drypoints');
            setHandles(handles);

        case{'savefile'}
            ddb_saveDryFile(handles,ad);

    end
end

refreshDryPoints;

%%
function addDryPoint(x,y)

x1=x(1);x2=x(2);
y1=y(1);y2=y(2);

handles=getHandles;
% Find grid indices of start and end point of line
[m1,n1]=findGridCell(x1,y1,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
[m2,n2]=findGridCell(x2,y2,handles.Model(md).Input(ad).gridX,handles.Model(md).Input(ad).gridY);
% Check if start and end are in one grid line
if m1>0 && (m1==m2 || n1==n2)
    if handles.Model(md).Input(ad).changeDryPoint
        iac=handles.Model(md).Input(ad).activeDryPoint;
    else
        % Add mode
        handles.Model(md).Input(ad).nrDryPoints=handles.Model(md).Input(ad).nrDryPoints+1;
        iac=handles.Model(md).Input(ad).nrDryPoints;
    end
    handles.Model(md).Input(ad).dryPoints(iac).M1=m1;
    handles.Model(md).Input(ad).dryPoints(iac).N1=n1;
    handles.Model(md).Input(ad).dryPoints(iac).M2=m2;
    handles.Model(md).Input(ad).dryPoints(iac).N2=n2;
    handles.Model(md).Input(ad).dryPoints(iac).Name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).dryPointNames{iac}=handles.Model(md).Input(ad).dryPoints(iac).Name;
    handles.Model(md).Input(ad).activeDryPoint=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drypoints');
    setHandles(handles);
    
    if handles.Model(md).Input(ad).changeDryPoint
        ddb_clickObject('tag','drypoint','callback',@changeDryPointFromMap);
        setInstructions({'','','Select dry point'});
    else
        ddb_dragLine(@addDryPoint,'free');
        setInstructions({'','','Click position of new dry point'});
    end
end
refreshDryPoints;

%%
function handles=deleteDryPoint(handles)

nrdry=handles.Model(md).Input(ad).nrDryPoints;

if nrdry>0
    iac=handles.Model(md).Input(ad).activeDryPoint;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','drypoints');
    if nrdry>1
        handles.Model(md).Input(ad).dryPoints=removeFromStruc(handles.Model(md).Input(ad).dryPoints,iac);
        handles.Model(md).Input(ad).dryPointNames=removeFromCellArray(handles.Model(md).Input(ad).dryPointNames,iac);
    else   
        handles.Model(md).Input(ad).dryPointNames={''};
        handles.Model(md).Input(ad).activeDryPoint=1;
        handles.Model(md).Input(ad).dryPoints(1).M1=[];
        handles.Model(md).Input(ad).dryPoints(1).M2=[];
        handles.Model(md).Input(ad).dryPoints(1).N1=[];
        handles.Model(md).Input(ad).dryPoints(1).N2=[];
    end
    if iac==nrdry
        iac=nrdry-1;
    end
    handles.Model(md).Input(ad).nrDryPoints=nrdry-1;
    handles.Model(md).Input(ad).activeDryPoint=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','drypoints');
    setHandles(handles);
    refreshDryPoints;
end

%%
function deleteDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
handles=deleteDryPoint(handles);
setHandles(handles);

%%
function selectDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drypoints');
setHandles(handles);
refreshDryPoints;

%%
function changeDryPointFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeDryPoint=iac;
ddb_Delft3DFLOW_plotAttributes(handles,'update','drypoints');
setHandles(handles);
refreshDryPoints;
ddb_dragLine(@addDryPoint,'free');
setInstructions({'','','Click new position of dry point'});

%%
function refreshDryPoints
setUIElement('delft3dflow.domain.domainpanel.drypoints.listdrypoints');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdrym1');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdrym2');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdryn1');
setUIElement('delft3dflow.domain.domainpanel.drypoints.editdryn2');
setUIElement('delft3dflow.domain.domainpanel.drypoints.toggleadddrypoint');
setUIElement('delft3dflow.domain.domainpanel.drypoints.toggleselectdrypoint');
setUIElement('delft3dflow.domain.domainpanel.drypoints.togglechangedrypoint');

