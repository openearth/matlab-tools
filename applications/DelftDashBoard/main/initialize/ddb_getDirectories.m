function handles=ddb_getDirectories(handles)

handles.SettingsDir=getINIValue(handles.IniFile,'SettingsDir');
handles.BathyDir=getINIValue(handles.IniFile,'BathyDir');
handles.SuperTransDir=getINIValue(handles.IniFile,'SuperTransDir');
handles.TideDir=getINIValue(handles.IniFile,'TideDir');
handles.GeoDir=getINIValue(handles.IniFile,'GeoDir');
handles.ToolBoxDir=getINIValue(handles.IniFile,'ToolboxDir');

