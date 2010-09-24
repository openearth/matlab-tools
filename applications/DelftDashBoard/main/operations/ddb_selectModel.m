function ddb_selectModel(mdl)

handles=getHandles;

% Making previous model invisible
elements=handles.Model(handles.ActiveModel.Nr).GUI.elements;
set(elements(1).handle,'Visible','off');

% Setting new active model
ii=strmatch(mdl,{handles.Model.Name},'exact');
handles.ActiveModel.Name=mdl;
handles.ActiveModel.Nr=ii;

setHandles(handles);

% Make new active model visible
elements=handles.Model(md).GUI.elements;
set(elements(1).handle,'Visible','on');

% Change menu items (file, domain and view)
ddb_changeModelMenuItems(handles);

% Select toolbox
tabpanel('select','tag',handles.Model(md).Name,'tabname','toolbox');
