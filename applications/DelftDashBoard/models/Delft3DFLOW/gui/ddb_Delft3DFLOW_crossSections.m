function ddb_Delft3DFLOW_crossSections(varargin)

handles=getHandles;

ddb_zoomOff;

if isempty(varargin)
    ddb_refreshScreen;
    handles.Model(md).Input(ad).addCrossSection=0;
    handles.Model(md).Input(ad).selectCrossSection=0;
    handles.Model(md).Input(ad).changeCrossSection=0;
    handles.Model(md).Input(ad).deleteCrossSection=0;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
    setUIElements('delft3dflow.monitoring.monitoringpanel.crosssections');
    setHandles(handles);

else
    opt=varargin{1};
    switch(lower(opt))

        case{'add'}
            handles.Model(md).Input(ad).selectCrossSection=0;
            handles.Model(md).Input(ad).changeCrossSection=0;
            handles.Model(md).Input(ad).deleteCrossSection=0;
            if handles.Model(md).Input(ad).addCrossSection
                ddb_dragLine(@addCrossSection,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
                setInstructions({'','','Drag line on map for new cross section'});
            else
                set(gcf, 'windowbuttondownfcn',[]);
                clearInstructions;
            end
            setHandles(handles);

        case{'delete'}
            handles.Model(md).Input(ad).addCrossSection=0;
            handles.Model(md).Input(ad).selectCrossSection=0;
            handles.Model(md).Input(ad).changeCrossSection=0;
            ddb_clickObject('tag','crosssection','callback',@deleteCrossSectionFromMap);
            setInstructions({'','','Select cross section from map to delete'});
            if handles.Model(md).Input(ad).deleteCrossSection
                handles=deleteCrossSection(handles);
            end
            setHandles(handles);

        case{'select'}
            handles.Model(md).Input(ad).addCrossSection=0;
            handles.Model(md).Input(ad).deleteCrossSection=0;
            handles.Model(md).Input(ad).changeCrossSection=0;
            ddb_clickObject('tag','crosssection','callback',@selectCrossSectionFromMap);
            setInstructions({'','','Select cross section from map'});
            setHandles(handles);

        case{'change'}
            handles.Model(md).Input(ad).addCrossSection=0;
            handles.Model(md).Input(ad).selectCrossSection=0;
            handles.Model(md).Input(ad).deleteCrossSection=0;
            if handles.Model(md).Input(ad).changeCrossSection
                ddb_clickObject('tag','crosssection','callback',@changeCrossSectionFromMap);
                setInstructions({'','','Select cross section to change from map'});
            end
            setHandles(handles);

        case{'edit'}
            handles.Model(md).Input(ad).addCrossSection=0;
            handles.Model(md).Input(ad).selectCrossSection=0;
            handles.Model(md).Input(ad).changeCrossSection=0;
            handles.Model(md).Input(ad).deleteCrossSection=0;
            handles.editMode='edit';
            n=handles.Model(md).Input(ad).activeCrossSection;
            handles.Model(md).Input(ad).crossSectionNames{n}=handles.Model(md).Input(ad).crossSections(n).name;
            if strcmpi(handles.Model(md).Input(ad).crossSections(n).name(1),'(')
                m1str=num2str(handles.Model(md).Input(ad).crossSections(n).M1);
                m2str=num2str(handles.Model(md).Input(ad).crossSections(n).M2);
                n1str=num2str(handles.Model(md).Input(ad).crossSections(n).N1);
                n2str=num2str(handles.Model(md).Input(ad).crossSections(n).N2);
                handles.Model(md).Input(ad).crossSectionNames{n}=['('  m1str ',' n1str ')...(' m2str ',' n2str ')'];
            end
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            clearInstructions;
            setHandles(handles);

        case{'selectfromlist'}
            handles.Model(md).Input(ad).addCrossSection=0;
            handles.Model(md).Input(ad).selectCrossSection=0;
            handles.Model(md).Input(ad).changeCrossSection=0;
            % Delete selected cross section next time delete is clicked
            handles.Model(md).Input(ad).deleteCrossSection=1;
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
            clearInstructions;
            setHandles(handles);

        case{'openfile'}
            handles=ddb_readCrsFile(handles);
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            setHandles(handles);

        case{'savefile'}
            ddb_saveCrsFile(handles,ad);
            
        case{'plot'}
            handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
            setHandles(handles);

    end
end

refreshCrossSections;

%%
function addCrossSection(x,y)

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
    
    if handles.Model(md).Input(ad).changeCrossSection
        iac=handles.Model(md).Input(ad).activeCrossSection;
    else
        % Add mode
        handles.Model(md).Input(ad).nrCrossSections=handles.Model(md).Input(ad).nrCrossSections+1;
        iac=handles.Model(md).Input(ad).nrCrossSections;
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
    
    handles.Model(md).Input(ad).crossSections(iac).M1=m1;
    handles.Model(md).Input(ad).crossSections(iac).N1=n1;
    handles.Model(md).Input(ad).crossSections(iac).M2=m2;
    handles.Model(md).Input(ad).crossSections(iac).N2=n2;
    handles.Model(md).Input(ad).crossSections(iac).name=['(' num2str(m1) ',' num2str(n1) ')...(' num2str(m2) ',' num2str(n2) ')'];
    handles.Model(md).Input(ad).crossSectionNames{iac}=handles.Model(md).Input(ad).crossSections(iac).name;
    handles.Model(md).Input(ad).activeCrossSection=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
    
    if handles.Model(md).Input(ad).changeCrossSection
        ddb_clickObject('tag','crosssection','callback',@changeCrossSectionFromMap);
        setInstructions({'','','Select cross section'});
    else
        ddb_dragLine(@addCrossSection,'method','alonggridline','x',handles.Model(md).Input(ad).gridX,'y',handles.Model(md).Input(ad).gridY);
        setInstructions({'','','Drag new cross section'});
    end
end
setHandles(handles);
refreshCrossSections;

%%
function handles=deleteCrossSection(handles)

nrcrs=handles.Model(md).Input(ad).nrCrossSections;

if nrcrs>0
    iac=handles.Model(md).Input(ad).activeCrossSection;    
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'delete','crosssections');
    if nrcrs>1
        handles.Model(md).Input(ad).crossSections=removeFromStruc(handles.Model(md).Input(ad).crossSections,iac);
        handles.Model(md).Input(ad).crossSectionNames=removeFromCellArray(handles.Model(md).Input(ad).crossSectionNames,iac);
    else   
        handles.Model(md).Input(ad).crossSectionNames={''};
        handles.Model(md).Input(ad).activeCrossSection=1;
        handles.Model(md).Input(ad).crossSections(1).M1=[];
        handles.Model(md).Input(ad).crossSections(1).M2=[];
        handles.Model(md).Input(ad).crossSections(1).N1=[];
        handles.Model(md).Input(ad).crossSections(1).N2=[];
        handles.Model(md).Input(ad).crossSections(1).name='';
    end
    if iac==nrcrs
        iac=nrcrs-1;
    end
    handles.Model(md).Input(ad).nrCrossSections=nrcrs-1;
    handles.Model(md).Input(ad).activeCrossSection=iac;
    handles=ddb_Delft3DFLOW_plotAttributes(handles,'plot','crosssections');
    setHandles(handles);
    refreshCrossSections;
end

%%
function deleteCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeCrossSection=iac;
handles=deleteCrossSection(handles);
setHandles(handles);

%%
function selectCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeCrossSection=iac;
handles=ddb_Delft3DFLOW_plotAttributes(handles,'update','crosssections');
setHandles(handles);
refreshCrossSections;

%%
function changeCrossSectionFromMap(h)

handles=getHandles;
iac=get(h,'UserData');
handles.Model(md).Input(ad).activeCrossSection=iac;
ddb_Delft3DFLOW_plotCrossSections(handles,'update');
setHandles(handles);
refreshCrossSections;
ddb_dragLine(@addCrossSection,'free');
setInstructions({'','','Drag line for new position of cross section'});

%%
function refreshCrossSections
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.listcrosssections');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.editcrsm1');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.editcrsm2');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.editcrsn1');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.editcrsn2');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.editname');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.toggleaddcrosssection');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.toggleselectcrosssection');
setUIElement('delft3dflow.monitoring.monitoringpanel.crosssections.togglechangecrosssection');
