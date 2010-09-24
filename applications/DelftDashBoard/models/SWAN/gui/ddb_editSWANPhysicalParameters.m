function EditSwanPhysicalParameters

ddb_refreshScreen('Physical Parameters');
handles=getHandles;

hp = uipanel('Title','Physical Parameters','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

strings={'Constants','Wind','Processes','Various'};
callbacks={@EditSwanConstants,@EditSwanWind,@EditSwanProcesses,@EditSwanVarious};
%tabpanel(gcf,'tabpanel2','create','position',[30 30 970 110],'strings',strings,'callbacks',callbacks,'width',width);

handles=getHandles;
panel=get(handles.Model(md).GUI.elements(1).handle,'UserData');
iac=panel.activeTab;
parent=panel.largeTabHandles(iac);
tabpanel('create','tag','tabpanel2','position',[20 20 970 110],'strings',strings,'callbacks',callbacks,'tabnames',strings,'Parent',parent,'activetabnr',1);

EditSwanConstants;
