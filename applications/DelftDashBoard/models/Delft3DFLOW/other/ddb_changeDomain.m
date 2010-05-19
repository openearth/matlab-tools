function ddb_changeDomain

handles=getHandles;

handles.GUIData.ActiveDryPoint=1;
handles.GUIData.ActiveThinDam=1;
handles.GUIData.ActiveObservationPoint=1;
handles.GUIData.ActiveOpenBoundary=1;
setHandles(handles);

for i=1:handles.GUIData.NrFlowDomains
    if i==ad
        ddb_plotDelft3DFLOW(handles,'activate',i);
    else
        ddb_plotDelft3DFLOW(handles,'deactivate',i);
    end        
end

if isempty(handles.ScreenParameters.ActiveSecondTab)
    tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select',handles.ScreenParameters.ActiveTab);
else
    tabpanel(handles.GUIHandles.MainWindow,'tabpanel2','select',handles.ScreenParameters.ActiveSecondTab);
end
