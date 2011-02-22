function ddb_changeDomain

handles=getHandles;

handles.GUIData.activeDryPoint=1;
handles.GUIData.activeThinDam=1;
handles.GUIData.activeObservationPoint=1;
handles.GUIData.activeOpenBoundary=1;
setHandles(handles);

for i=1:handles.GUIData.nrFlowDomains
    if i==ad
        ddb_plotDelft3DFLOW('plot','activate',1);
    else
        ddb_plotDelft3DFLOW('plot','activate',0);
    end        
end

% if isempty(handles.screenParameters.activeSecondTab)
%     tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','tabname',handles.screenParameters.activeTab);
% else
%     tabpanel(handles.GUIHandles.MainWindow,'tabpanel2','select','tabname',handles.screenParameters.activeSecondTab);
% end
