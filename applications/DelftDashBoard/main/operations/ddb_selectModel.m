function ddb_selectModel(mdl,tabname,varargin)

icb=1;

for i=1:length(varargin)
    if ischar(varargin{i})
        switch lower(varargin{i})
            case{'runcallback'}
                icb=varargin{i+1};
        end
    end
end

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
tabpanel('select','tag',lower(handles.Model(md).Name),'tabname',tabname,'runcallback',icb);

set(handles.GUIHandles.mapPanel,'Parent',handles.Model(md).GUI.elements(1).handle);
