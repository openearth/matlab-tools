function ddb_selectDelft3DFLOW

handles=getHandles;

sz=get(gcf,'Position');

strings={'Toolbox','Description','Domain','Time Frame','Processes','Init. Conditions','Boundaries','Phys. Parameters','Num. Parameters', ...
    'Discharges','Monitoring','Additional','Output'};
callbacks={@ddb_selectToolbox,@ddb_editD3DFlowDescription,@ddb_editD3DFlowDomain,@ddb_editD3DFlowTimeFrame,@ddb_editD3DFlowProcesses,@ddb_editD3DFlowInitialConditions, ...
    @ddb_editD3DFlowOpenBoundaries,@ddb_editD3DFlowPhysicalParameters,@ddb_editD3DFlowNumericalParameters,@ddb_editD3DFlowDischarges,@ddb_editD3DFlowMonitoring, ...
    @ddb_editD3DFlowAdditional,@ddb_editD3DFlowOutput};
% width=[60 70 60 70 70 90 70 100 100 70 70 70 60];
% tabpanel(gcf,'tabpanel','create','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks,'width',width);
tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks);

handles.ActiveModel.Name='Delft3DFLOW';
ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');
handles.ActiveModel.Nr=ii;

handles.ActiveDomain=1;
set(handles.GUIHandles.Menu.Domain.Main,'Enable','on');

set(handles.GUIHandles.Menu.File.Open,     'Label','Open MDF');
set(handles.GUIHandles.Menu.File.Save,     'Label','Save MDF');
set(handles.GUIHandles.Menu.File.SaveAs,   'Label','Save MDF As ...');

set(handles.GUIHandles.Menu.File.SaveAll,          'Enable','on');
set(handles.GUIHandles.Menu.File.SaveAllAs,        'Enable','on');

set(handles.GUIHandles.Menu.File.OpenDomains,      'Enable','on');
set(handles.GUIHandles.Menu.File.SaveAllDomains,   'Enable','on');

% fill in the model specific items of the view-menu
% first delete previous menu items
delete(get(findobj(gcf,'Type','uimenu','Tag','menuViewModel'),'Children'));
% change name of model menu (to Delft3D-FLOW)
set(findobj(gcf,'Type','uimenu','Tag','menuViewModel'),'Label','Delft3D-FLOW');
% add model specific items to menu
handles=ddb_addMenuItem(handles,'ViewModel','Grid',                'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Model Bathymetry',    'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Open Boundaries',     'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Observation Points',  'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Cross Sections',      'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Thin Dams',           'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Dry Points',          'Callback',{@ddb_menuViewDelft3DFLOW},'Checked','on');

handles=ddb_refreshFlowDomains(handles);

setHandles(handles);
