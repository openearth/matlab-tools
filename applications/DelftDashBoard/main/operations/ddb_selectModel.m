function ddb_selectModel(mdl)

handles=getHandles;

% Making previous model invisible
set(handles.Model(md).GUI.elements(1).handle,'Visible','off');

% Setting new active model
ii=strmatch(mdl,{handles.Model.Name},'exact');
handles.ActiveModel.Name=mdl;
handles.ActiveModel.Nr=ii;

setHandles(handles);

% Make new active model visible
set(handles.Model(md).GUI.elements(1).handle,'Visible','on');

% Change menu items (file, domain and view)
ddb_changeFileMenuItems;

if handles.Model(md).supportsMultipleDomains
    set(handles.GUIHandles.Menu.Domain.Main,'Enable','on');
else
    set(handles.GUIHandles.Menu.Domain.Main,'Enable','off');
end

% Select toolbox
tabpanel('select','tag',handles.Model(md).Name,'tabname','toolbox');
