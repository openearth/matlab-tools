function ddb_selectModel(mdl)

handles=getHandles;

% Making previous model invisible
set(handles.Model(md).GUI.elements(1).handle,'Visible','off');

% Setting new active model
ii=strmatch(mdl,{handles.Model.name},'exact');
handles.activeModel.name=mdl;
handles.activeModel.nr=ii;

setHandles(handles);

% Make new active model visible
set(handles.Model(md).GUI.elements(1).handle,'Visible','on');

% Change menu items (file, domain and view)
ddb_changeFileMenuItems;

% Set the domain menu
if handles.Model(md).supportsMultipleDomains
    set(handles.GUIHandles.Menu.Domain.Main,'Enable','on');
else
    set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');
end

% Make the map panel a child of the present model tab panel
set(handles.GUIHandles.mapPanel,'Parent',handles.Model(md).GUI.elements(1).handle);

% Select toolbox
ddb_selectToolbox;
