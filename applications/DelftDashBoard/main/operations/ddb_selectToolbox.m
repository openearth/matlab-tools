function ddb_selectToolbox

ddb_refreshScreen('Toolbox');

handles=getHandles;

ii=strmatch(handles.activeToolbox.Name,{handles.Toolbox(:).Name},'exact');
handles.activeToolbox.Nr=ii;

setHandles(handles);

feval(handles.Toolbox(ii).CallFcn);
