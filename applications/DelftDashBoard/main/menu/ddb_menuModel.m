function ddb_menuModel(hObject, eventdata)

handles=getHandles;

mdl=get(hObject,'Tag');

mdl=mdl(10:end);

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

ii=strmatch(mdl,{handles.Model.Name},'exact');

handles.ActiveModel.Name=mdl;
handles.ActiveModel.Nr=ii;

setHandles(handles);

ddb_selectModel;
tabpanel(handles.GUIHandles.MainWindow,'tabpanel','select','Toolbox');
