function ddb_menuModel(hObject, eventdata)

mdl=get(hObject,'Tag');

mdl=mdl(10:end);

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

ddb_selectModel(mdl,'toolbox');

