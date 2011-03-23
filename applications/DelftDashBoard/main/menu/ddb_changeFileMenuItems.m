function ddb_changeFileMenuItems

handles=getHandles;

hmain=handles.GUIHandles.Menu.File.Main;
ch=get(hmain,'Children');
if ~isempty(ch)
    delete(ch);
end

% New
argin=[];
argin{1}='Callback';
argin{2}=@ddb_resetAll;
handles=ddb_addMenuItem(handles,'File','New','Callback',@ddb_menuSelect,'argin',argin);

% File open
for i=1:length(handles.Model(md).GUI.menu.openFile)
    str=handles.Model(md).GUI.menu.openFile(i).string;
    cb=handles.Model(md).GUI.menu.openFile(i).callback;
    opt=handles.Model(md).GUI.menu.openFile(i).option;
%    tag=handles.Model(md).GUI.menu.openFile(i).tag;
    argin=[];
    argin{1}='Callback';
    argin{2}=cb;
    argin{3}='Options';
    argin{4}=opt;
    if i==1
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin);
    end
end

% File save
for i=1:length(handles.Model(md).GUI.menu.saveFile)
    str=handles.Model(md).GUI.menu.saveFile(i).string;
    cb=handles.Model(md).GUI.menu.saveFile(i).callback;
    opt=handles.Model(md).GUI.menu.saveFile(i).option;
%    tag=handles.Model(md).GUI.menu.openFile(i).tag;
    argin=[];
    argin{1}='Callback';
    argin{2}=cb;
    argin{3}='Options';
    argin{4}=opt;
    if i==1
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');
    else
        handles=ddb_addMenuItem(handles,'File',str,'Callback',@ddb_menuSelect,'argin',argin);
    end
end

% Shoreline
argin=[];
argin{1}='Callback';
argin{2}=@ddb_menuFileOpenShoreline;
% handles=ddb_addMenuItem(handles,'File','Open Shoreline',          'Callback',{@ddb_menuSelect},'argin',argin,'Separator','on');

% Working directory
argin=[];
argin{1}='Callback';
argin{2}=@ddb_selectWorkingDirectory;
handles=ddb_addMenuItem(handles,'File','Select Working Directory','Callback',@ddb_menuSelect,'argin',argin,'Separator','on');

argin=[];
argin{1}='Callback';
argin{2}=@ddb_menuExit;
handles=ddb_addMenuItem(handles,'File','Exit',                    'Callback',@ddb_menuSelect,'argin',argin,'Separator','on');

setHandles(handles);
