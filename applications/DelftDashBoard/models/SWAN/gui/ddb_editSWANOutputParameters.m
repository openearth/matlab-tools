function EditSwanOutputParameters

ddb_refreshScreen('Output Parameters');

hp = uipanel('Title','Output Parameters','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');
handles.Text = uicontrol(gcf,'Style','text','String','Sorry, this feature is not implemented yet','Position',[60 70  400 20],'HorizontalAlignment','left','Tag','UIControl');
