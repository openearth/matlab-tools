function ddb_menuToolbox(hObject, eventdata)

handles=getHandles;

tg=get(hObject,'Tag');

tbname=tg(12:end);

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

handles.activeToolbox.Name=tbname;
handles.activeToolbox.Nr=strmatch(tbname,{handles.Toolbox(:).Name},'exact');

setHandles(handles);

% Select toolbox
tabpanel('select','tag',handles.Model(md).Name,'tabname','toolbox');
