function ddb_editDelft3DWAVEDescription

ddb_refreshScreen('Description');
handles=getHandles;

uipanel('Title','Description','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.GUIHandles.TextProjectName = uicontrol(gcf,'Style','text','string','Project name','Position',[40 140 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditProjectName = uicontrol(gcf,'Style','edit','Position',[120 140 200 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextProjectNumber = uicontrol(gcf,'Style','text','string','Project number','Position',[40 110 100  20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditProjectNumber = uicontrol(gcf,'Style','edit','Position',[120 110 100 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.GUIHandles.TextDescription = uicontrol(gcf,'Style','text','string','Description (max. 3 lines)','Position',[40 80 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.GUIHandles.EditDescription = uicontrol(gcf,'Style','edit','Position',[40 30 500 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.GUIHandles.EditProjectName,'Max',1);
set(handles.GUIHandles.EditProjectName,'String',handles.Model(md).Input.ProjectName);
set(handles.GUIHandles.EditProjectName,'Callback',{@EditProjectName_Callback});

set(handles.GUIHandles.EditProjectNumber,'Max',1);
set(handles.GUIHandles.EditProjectNumber,'String',handles.Model(md).Input.ProjectNumber);
set(handles.GUIHandles.EditProjectNumber,'Callback',{@EditProjectNumber_Callback});

set(handles.GUIHandles.EditDescription,'Max',3);
set(handles.GUIHandles.EditDescription,'String',handles.Model(md).Input.Description);
set(handles.GUIHandles.EditDescription,'Callback',{@EditDescription_Callback});

SetUIBackgroundColors;

%%
function EditProjectName_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ProjectName=get(hObject,'String');
setHandles(handles);

%%
function EditProjectNumber_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.ProjectNumber=get(hObject,'String');
setHandles(handles);

%%
function EditDescription_Callback(hObject,eventdata)
handles=getHandles;
handles.Model(md).Input.Description=get(hObject,'String');
setHandles(handles);
