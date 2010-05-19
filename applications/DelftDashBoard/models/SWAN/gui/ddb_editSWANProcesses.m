function EditSwanProcesses

ddb_refreshScreen('Physical Parameters','Processes');
handles=getHandles;

handles.TextGeneration     = uicontrol(gcf,'Style','text','String','Speed : ','Generation mode for physics :',[50 110 150 15],'HorizontalAlignment','left','Tag','UIControl');
% handles.EditGeneration     = uicontrol(gcf,'Style','popupmenu','String',str,'Position',[50 85 50 20],'HorizontalAlignment','left','BackgroundColor',[1 1 1],'Tag','UIControl');
set(handles.EditGeneration,'Max',1);
set(handles.EditGeneration,'String',handles.SwanInput(handles.ActiveDomain).Generation);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function EditGeneration_CallBack(hObject,eventdata)
handles=getHandles;
handles.SwanInput(handles.ActiveDomain).Generation=get(hObject,'String');
% set(handles.SelectType,'Value',ii);
setHandles(handles);
