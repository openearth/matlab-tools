function ddb_editSWANDescription

ddb_refreshScreen('Description');
handles=getHandles;

uipanel('Title','Description','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

handles.TextProjectName = uicontrol(gcf,'Style','text','string','Project name','Position',[40 140 100 20],'HorizontalAlignment','left','Tag','UIControl');
handles.EditProjectName = uicontrol(gcf,'Style','edit','Position',[120 140 200 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextProjectNumber = uicontrol(gcf,'Style','text','string','Project number','Position',[40 110 100  20],'HorizontalAlignment','left','Tag','UIControl');
handles.EditProjectNumber = uicontrol(gcf,'Style','edit','Position',[120 110 40 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

handles.TextDescription = uicontrol(gcf,'Style','text','string','Description (max. 3 lines)','Position',[40 80 150 20],'HorizontalAlignment','left','Tag','UIControl');
handles.EditDescription = uicontrol(gcf,'Style','edit','Position',[40 30 500 50],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');

set(handles.EditProjectName,'Max',1);
set(handles.EditProjectName,'String',handles.SWANInput.ProjectName);
set(handles.EditProjectName,'Callback',{@EditProjectName_Callback});

set(handles.EditProjectNumber,'Max',1);
set(handles.EditProjectNumber,'String',handles.SWANInput.ProjectNumber);
set(handles.EditProjectNumber,'Callback',{@EditProjectNumber_Callback});

set(handles.EditDescription,'Max',3);
set(handles.EditDescription,'String',handles.SWANInput.Description);
set(handles.EditDescription,'Callback',{@EditDescription_Callback});

SetUIBackgroundColors;

%%
function EditProjectName_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.ProjectName=get(hObject,'String');
setHandles(handles);

%%
function EditProjectNumber_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.ProjectNumber=get(hObject,'String');
setHandles(handles);

%%
function EditDescription_Callback(hObject,eventdata)
handles=getHandles;
handles.SWANInput.Description=get(hObject,'String');
setHandles(handles);
