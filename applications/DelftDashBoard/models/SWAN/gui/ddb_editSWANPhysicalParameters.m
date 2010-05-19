function EditSwanPhysicalParameters

ddb_refreshScreen('Physical Parameters');
handles=getHandles;

hp = uipanel('Title','Physical Parameters','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

strings={'Constants','Wind','Processes','Various'};
callbacks={@EditSwanConstants,@EditSwanWind,@EditSwanProcesses,@EditSwanVarious};
tabpanel(gcf,'tabpanel2','create',[30 30 970 110],strings,callbacks);

EditSwanConstants;
