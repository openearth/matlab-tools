function ddb_changeModelMenuItems(handles)

hmain=handles.GUIHandles.Menu.File.Main;
ch=get(hmain,'Children');
if ~isempty(ch)
    delete(ch);
end
handles=ddb_addMenuItem(handles,'File','New',                     'Callback',{@ddb_menuFile});
for i=1:length(handles.Model(md).GUI.menu.openFile)
    if i==1
        handles=ddb_addMenuItem(handles,'File',handles.Model(md).GUI.menu.openFile(i).string,                    'Callback',{@ddb_menuFile},'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',handles.Model(md).GUI.menu.openFile(i).string,                    'Callback',{@ddb_menuFile});
    end
end
for i=1:length(handles.Model(md).GUI.menu.saveFile)
    if i==1
        handles=ddb_addMenuItem(handles,'File',handles.Model(md).GUI.menu.saveFile(i).string,                    'Callback',{@ddb_menuFile},'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',handles.Model(md).GUI.menu.saveFile(i).string,                    'Callback',{@ddb_menuFile});
    end
end
handles=ddb_addMenuItem(handles,'File','Open Shoreline',          'Callback',{@ddb_menuFile},'Separator','on');
handles=ddb_addMenuItem(handles,'File','Select Working Directory','Callback',{@ddb_menuFile},'Separator','on');
handles=ddb_addMenuItem(handles,'File','Exit',                    'Callback',{@ddb_menuFile},'Separator','on');
