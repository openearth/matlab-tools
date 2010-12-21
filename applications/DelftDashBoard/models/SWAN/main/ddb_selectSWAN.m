function ddb_selectSWAN

handles=getHandles;

sz=get(gcf,'Position');

strings={'Toolbox','Description','Hydrodynamics','Grids','Time Frame','Boundaries','Obstacles','Phys. Parameters', ...
    'Num. Parameters','Output Curves','Output Parameters'};
callbacks={@ddb_selectToolbox,...
           @ddb_editSWANDescription,...
           @ddb_editSWANHydrodynamics,...
           @ddb_editSWANGrids,...
           @ddb_editSWANTimeFrame, ...
           @ddb_editSWANBoundaries,...
           @ddb_editSWANObstacles,...
           @ddb_editSWANPhysicalParameters,...
           @ddb_editSWANNumericalParameters, ...
           @ddb_editSWANOutputCurves,...
           @ddb_editSWANOutputParameters};
width=[60 70 100 60 70 70 70 100 100 100 100];
tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],...
              'strings',strings,'callbacks',callbacks,'width',width);

handles.ActiveModel.Name='SWAN';
ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');
handles.ActiveModel.Nr=ii;

handles.ActiveDomain=1;

set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');

set(handles.GUIHandles.Menu.File.Open,     'Label','Open SWAN');
set(handles.GUIHandles.Menu.File.Save,     'Label','Save SWAN');
set(handles.GUIHandles.Menu.File.SaveAs,   'Label','Save SWAN As ...');

set(handles.GUIHandles.Menu.File.SaveAll,          'Enable','off');
set(handles.GUIHandles.Menu.File.SaveAllAs,        'Enable','off');

set(handles.GUIHandles.Menu.File.OpenDomains,      'Enable','off');
set(handles.GUIHandles.Menu.File.SaveAllDomains,   'Enable','off');

setHandles(handles);
