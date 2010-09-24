function ddb_editDelft3DWAVEPhysicalParameters

ddb_refreshScreen('Physical Parameters');

hp = uipanel('Title','Physical Parameters','Units','pixels','Position',[20 20 990 160],'Tag','UIControl');

strings={'Constants','Wind','Processes','Various'};
callbacks={@ddb_editDelft3DWAVEConstants,@ddb_editDelft3DWAVEWind,@ddb_editDelft3DWAVEProcesses,@ddb_editDelft3DWAVEVarious};
tabpanel(gcf,'tabpanel2','create','position',[30 30 970 110],'strings',strings,'callbacks',callbacks);

ddb_editDelft3DWAVEConstants;
