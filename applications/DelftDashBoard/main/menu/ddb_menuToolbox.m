function ddb_menuToolbox(hObject, eventdata)

%profile on

handles=getHandles;

tg=get(hObject,'Tag');

tbname=tg(12:end);

h=get(hObject,'Parent');
ch=get(h,'Children');
set(ch,'Checked','off');
set(hObject,'Checked','on');

% Check if toolbox is already selected
if ~strcmpi(handles.activeToolbox.name,tbname)
    handles.activeToolbox.name=tbname;
    handles.activeToolbox.nr=strmatch(tbname,{handles.Toolbox(:).name},'exact');
    % Now add the new GUI elements to toolbox tab
    setHandles(handles);
    handles=ddb_addToolboxElements(handles);
    setHandles(handles);
    % Select toolbox by 'clicking' the toolbox tab. This will call
    % selectToolbox.
    tabpanel('select','tag',handles.Model(md).name,'tabname','toolbox','runcallback',0);
    ddb_selectToolbox;
    
end
%drawnow
%profile viewer
