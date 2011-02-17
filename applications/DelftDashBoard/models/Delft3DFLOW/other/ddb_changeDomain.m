function ddb_changeDomain

handles=getHandles;

handles.GUIData.activeDryPoint=1;
handles.GUIData.activeThinDam=1;
handles.GUIData.activeObservationPoint=1;
handles.GUIData.activeOpenBoundary=1;
setHandles(handles);

for i=1:handles.GUIData.nrFlowDomains
    if i==ad
        ddb_plotDelft3DFLOW(handles,'activate',i);
    else
        ddb_plotDelft3DFLOW(handles,'deactivate',i);
    end        
end

if isempty(handles.screenParameters.activeSecondTab)
    tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','tabname',handles.screenParameters.activeTab);
else
    tabpanel(handles.GUIHandles.MainWindow,'tabpanel2','select','tabname',handles.screenParameters.activeSecondTab);
end
