function ddb_selectXBeach

handles=getHandles;
sz=get(gcf,'Position');

strings={'Toolbox','Description','Domain','Time Frame','Phys. Params','Waves','Flow','Sediment'};

callbacks={@ddb_selectToolbox,@ddb_editXBeachDescription,@ddb_editXBeachDomain,@ddb_editXBeachTimeFrame,@ddb_editXBeachPhysParams, ...
    @ddb_editXBeachWaves,@ddb_editXBeachFlow,@ddb_editXBeachSediment};

% Take out XBeachDescription (AvR)
% callbacks={@ddb_selectToolbox,@ddb_editXBeachDomain,@ddb_editXBeachTimeFrame,@ddb_editXBeachPhysParams, ...
%     @ddb_editXBeachWaves,@ddb_editXBeachFlow,@ddb_editXBeachSediment};
width=[60 70 60 70 80 60 60 60];
tabpanel(gcf,'tabpanel','change','position',[10 10 sz(3)-20 sz(4)-40],'strings',strings,'callbacks',callbacks);

handles.ActiveModel.Name='XBeach';
ii=strmatch(handles.ActiveModel.Name,{handles.Model.Name},'exact');
handles.ActiveModel.Nr=ii;

handles.ActiveDomain=1;

set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');

set(handles.GUIHandles.Menu.File.Open,     'Label','Open params');
set(handles.GUIHandles.Menu.File.Save,     'Label','Save params');
set(handles.GUIHandles.Menu.File.SaveAs,   'Label','Save params As ...');

set(handles.GUIHandles.Menu.File.SaveAll,          'Enable','on');
set(handles.GUIHandles.Menu.File.SaveAllAs,        'Enable','on');

set(handles.GUIHandles.Menu.File.OpenDomains,      'Enable','off');
set(handles.GUIHandles.Menu.File.SaveAllDomains,   'Enable','off');

% first delete previous menu items
delete(get(findobj(gcf,'Type','uimenu','Tag',['ddb_menuViewModel']),'Children'));
% change name of model menu (to XBeach)
set(findobj(gcf,'Type','uimenu','Tag',['ddb_menuViewModel']),'Label','XBeach');
% add model specific items to menu
handles=ddb_addMenuItem(handles,'ViewModel','Grid',                'Callback',{@ddb_menuViewXBeach},'Checked','on');
handles=ddb_addMenuItem(handles,'ViewModel','Model Bathymetry',    'Callback',{@ddb_menuViewXBeach},'Checked','on');
% handles=ddb_addMenuItem(handles,'ViewModel','Observation Points',  'Callback',{@ddb_menuViewXBeach},'Checked','on');
% handles=ddb_addMenuItem(handles,'ViewModel','Cross Sections',
% 'Callback',{@ddb_menuViewXBeachW},'Checked','on');

setHandles(handles);
