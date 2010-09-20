function ddb_refreshDelft3DWAVEHydrodynamics

handles=getHandles;

enab=0;
if handles.Model(md).Input.FlowBedLevel
    setprop('checkuseflowbedlevel','Value',1);
    enab=1;
end
if handles.Model(md).Input.FlowWaterLevel
    setprop('checkuseflowwaterlevel','Value',1);
    enab=1;
end
if handles.Model(md).Input.FlowVelocity
    setprop('checkuseflowcurrent','Value',1);
    enab=1;
end
if handles.Model(md).Input.FlowWind
    setprop('checkuseflowwind','Value',1);
    enab=1;
end

if enab
    setprop('pushselectmdffile','Enable','on');
    setprop('pushselectmdffile_filetext','Enable','on');
else
    setprop('pushselectmdffile','Enable','off');
    setprop('pushselectmdffile_filetext','Enable','off');    
end

% if size(get(handles.GUIHandles.PushSelectMDFfile,'Enable'),2)==3
%     handles.Model(md).Input.MDFFile='';
%     handles.Model(md).Input.ItDate='';
%     handles.Model(md).Input.AvailableFlowTimes='';
%     handles.Model(md).Input.Timepoints='';
%     set(handles.GUIHandles.TextSelectMDFfile,'String',['File : ' handles.Model(md).Input.MDFFile]);
% end


