function ddb_selectCyclonePoint(h)
% DDB - Call GUI to change values in cyclone track file for individual
% points. Called when double-clicking on cyclone track.
i=getappdata(h,'number');
handles=getHandles;
handles.Toolbox(tb).Input.activeCyclonePoint=i;
handles.Toolbox(tb).Input.activeQuadrant=1;
setHandles(handles);

[handles,ok]=ddb_changeCycloneValue(handles);

if ok
    handles=ddb_setTrackTableValues(handles);
    setHandles(handles);
    ddb_updateTrackTables;
end
