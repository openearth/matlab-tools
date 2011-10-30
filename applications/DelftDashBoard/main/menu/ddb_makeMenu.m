function handles=ddb_makeMenu(handles)

%% File
handles.GUIHandles.Menu.File.Main=uimenu('Label','File','Tag','menuFile');
% Items are added in ddb_changeFileMenuItems

%% Toolbox
uimenu('Label','Toolbox','Tag','menuToolbox');
for k=1:length(handles.Toolbox)
    enab=handles.Toolbox(k).enable;
    if enab==1
        enab='on';
    else
        enab='off';
    end
    if strcmpi(enab,'on')
        if k==2
            handles=ddb_addMenuItem(handles,'Toolbox',handles.Toolbox(k).name,'Callback',{@ddb_menuToolbox},'longname',handles.Toolbox(k).longName,'Separator','on','enable',enab);
        else
            handles=ddb_addMenuItem(handles,'Toolbox',handles.Toolbox(k).name,'Callback',{@ddb_menuToolbox,},'longname',handles.Toolbox(k).longName,'enable',enab);
        end
    end
end

%% Models
uimenu('Label','Model','Tag','menuModel');
for k=1:length(handles.Model)
    enab=handles.Model(k).enable;
    if enab
        enab='on';
    else
        enab='off';
    end
    if strcmpi(enab,'on')
        handles=ddb_addMenuItem(handles,'Model',handles.Model(k).name,     'Callback',{@ddb_menuModel},'longname',handles.Model(k).longName,'Checked','off','enable',enab);
    end
end

%% Domain
uimenu('Label','Domain','Tag','menuDomain');
handles=ddb_addMenuItem(handles,'Domain','Add Domain ...',      'Callback',{@ddb_menuDomain});
handles=ddb_addMenuItem(handles,'Domain','tst',                 'Callback',{@ddb_menuDomain},'Separator','on','HandleName','FirstDomain');

%% Bathymetry
uimenu('Label','Bathymetry','Tag','menuBathymetry');
for i=1:handles.bathymetry.nrDatasets
    if strcmpi(handles.bathymetry.datasets{i},handles.screenParameters.backgroundBathymetry)
        if handles.bathymetry.dataset(i).isAvailable
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.datasets{i},'Callback',{@ddb_menuBathymetry},'Checked','on','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.datasets{i},'Callback',{@ddb_menuBathymetry},'Checked','on','Enable','off');
        end
    else
        if handles.bathymetry.dataset(i).isAvailable
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.datasets{i},'Callback',{@ddb_menuBathymetry},'Checked','off','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Bathymetry',handles.bathymetry.datasets{i},'Callback',{@ddb_menuBathymetry},'Checked','off','Enable','off');
        end
    end
end

%% Shoreline
uimenu('Label','Shoreline','Tag','menuShoreline');
for i=1:handles.shorelines.nrShorelines
    if strcmpi(handles.shorelines.longName{i},handles.screenParameters.shoreline)
        if handles.shorelines.shoreline(i).isAvailable
            handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','on','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','on','Enable','off');
        end
    else
        if handles.shorelines.shoreline(i).isAvailable
            handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','off','Enable','on');
        else
            handles=ddb_addMenuItem(handles,'Shoreline',handles.shorelines.longName{i},'Callback',{@ddb_menuShoreline},'Checked','off','Enable','off');
        end
    end
end

%% View -> from now model specific items to be filled in by a model select function (for example: ddb_selectDelft3DFLOW.m)
uimenu('Label','View','Tag','menuView');
handles=ddb_addMenuItem(handles,'View','Background Bathymetry','Callback',{@ddb_menuView},'Checked','on','longname','Bathymetry');
handles=ddb_addMenuItem(handles,'View','Aerial',               'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Aerial','Separator','on');
handles=ddb_addMenuItem(handles,'View','Hybrid',               'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Hybrid');
handles=ddb_addMenuItem(handles,'View','Roads',                'Callback',{@ddb_menuView},'Checked','off','Enable','on','longname','Map');
handles=ddb_addMenuItem(handles,'View','Shoreline',            'Callback',{@ddb_menuView},'Checked','on','longname','Shoreline','Separator','on');
handles=ddb_addMenuItem(handles,'View','Cities',               'Callback',{@ddb_menuView});
handles=ddb_addMenuItem(handles,'View','Model',                'longname','Model specific items','Separator','on');
handles=ddb_addMenuItem(handles,'View','Settings',             'Callback',{@ddb_menuView},'Separator','on');

%% Coordinate System
uimenu('Label','Coordinate System','Tag','menuCoordinateSystem');
handles=ddb_addMenuItem(handles,'CoordinateSystem','WGS 84',               'Callback',{@ddb_menuCoordinateSystem},'Checked','on','HandleName','Geographic');
handles=ddb_addMenuItem(handles,'CoordinateSystem','Other Geographic ...',     'Callback',{@ddb_menuCoordinateSystem});
handles=ddb_addMenuItem(handles,'CoordinateSystem','Amersfoort / RD New',  'Callback',{@ddb_menuCoordinateSystem},'Separator','on','HandleName','Cartesian');
handles=ddb_addMenuItem(handles,'CoordinateSystem','Other Cartesian ...',      'Callback',{@ddb_menuCoordinateSystem});
handles=ddb_addMenuItem(handles,'CoordinateSystem','WGS 84 / UTM zone 31N','Callback',{@ddb_menuCoordinateSystem},'Separator','on','HandleName','UTM');
handles=ddb_addMenuItem(handles,'CoordinateSystem','Select UTM Zone ...',  'Callback',{@ddb_menuCoordinateSystem});

%% Options
uimenu('Label','Options','Tag','menuOptions');
handles=ddb_addMenuItem(handles,'Options',               'Coordinate Conversion','Callback',{@ddb_menuOptions});
handles=ddb_addMenuItem(handles,'Options',               'Quickplot',            'Callback',{@ddb_menuOptions});
handles=ddb_addMenuItem(handles,'Options',               'Muppet',               'Callback',{@ddb_menuOptions}, 'Enable','off');
handles=ddb_addMenuItem(handles,'Options',               'Ldb Tool',             'Callback',{@ddb_menuOptions},'Separator','on', 'Enable','off');
handles=ddb_addMenuItem(handles,'Options',               'Data management', 'Enable','off');
handles=ddb_addMenuItem(handles,'OptionsDatamanagement', 'bathymetry',           'Callback',{@ddb_menuOptions}, 'Enable','off');
handles=ddb_addMenuItem(handles,'OptionsDatamanagement', 'shorelines',           'Callback',{@ddb_menuOptions}, 'Enable','off');
handles=ddb_addMenuItem(handles,'OptionsDatamanagement', 'tidemodels',           'Callback',{@ddb_menuOptions}, 'Enable','off');

%% Help
uimenu('Label','Help','Tag','menuHelp');
handles=ddb_addMenuItem(handles,'Help','Deltares Online',        'Callback',{@ddb_menuHelp});
handles=ddb_addMenuItem(handles,'Help','Delft Dashboard Online', 'Callback',{@ddb_menuHelp});
handles=ddb_addMenuItem(handles,'Help','About Delft Dashboard',  'Callback',{@ddb_menuHelp});

%% Debug
if ~isdeployed
    uimenu('Label','Debug','Tag','menuDebug');
    handles=ddb_addMenuItem(handles,'Debug','Debug Mode','Callback',{@ddb_menuDebug},'Checked','off');
end

