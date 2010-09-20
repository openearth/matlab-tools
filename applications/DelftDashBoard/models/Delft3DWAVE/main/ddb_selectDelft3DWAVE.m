function ddb_selectDelft3DWAVE

handles=getHandles;

sz=get(gcf,'Position');

strings={'Toolbox','Description','Hydrodynamics','Grids','Time Frame','Boundaries','Obstacles','Phys. Parameters', ...
    'Num. Parameters','Output Curves','Output Parameters'};
callbacks={@ddb_selectToolbox,@ddb_editDelft3DWAVEDescription,@ddb_editDelft3DWAVEHydrodynamics,@ddb_editDelft3DWAVEGrids,@ddb_editDelft3DWAVETimeFrame, ...
    @ddb_editDelft3DWAVEBoundaries,@ddb_editDelft3DWAVEObstacles,@ddb_editDelft3DWAVEPhysicalParameters,@ddb_editDelft3DWAVENumericalParameters, ...
    @ddb_editDelft3DWAVEOutputCurves,@ddb_editDelft3DWAVEOutputParameters};
width=[60 70 100 60 70 70 70 100 100 100 100];
tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks,'width',width);

handles.ActiveModel.Name='Delft3DWAVE';
ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');
handles.ActiveModel.Nr=ii;

handles.ActiveDomain=1;

set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');

set(handles.GUIHandles.Menu.File.Open,     'Label','Open Delft3DWAVE');
set(handles.GUIHandles.Menu.File.Save,     'Label','Save Delft3DWAVE');
set(handles.GUIHandles.Menu.File.SaveAs,   'Label','Save Delft3DWAVE As ...');

set(handles.GUIHandles.Menu.File.SaveAll,          'Enable','off');
set(handles.GUIHandles.Menu.File.SaveAllAs,        'Enable','off');

set(handles.GUIHandles.Menu.File.OpenDomains,      'Enable','off');
set(handles.GUIHandles.Menu.File.SaveAllDomains,   'Enable','off');

setHandles(handles);
