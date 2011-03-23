function ddb_menuToolbox(hObject, eventdata)

%profile on

handles=getHandles;

tg=get(hObject,'Tag');
tbname=tg(12:end);

% Check the selected toolbox in the menu
h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

if ~strcmpi(handles.activeToolbox.name,tbname)
    handles.activeToolbox.name=tbname;
    handles.activeToolbox.nr=strmatch(tbname,{handles.Toolbox(:).name},'exact');
    % Now add the new GUI elements to toolbox tab
    setHandles(handles);
end

% Select toolbox
selectToolbox;

