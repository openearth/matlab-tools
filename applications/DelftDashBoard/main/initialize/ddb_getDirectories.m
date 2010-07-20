function [handles,ok]=ddb_getDirectories(handles)

ok=1;

handles.WorkingDirectory=pwd;

if isdeployed

    handles.SettingsDir=[ctfroot filesep 'settings' filesep];

    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    ddbdir=[fileparts(exeDir) filesep 'data' filesep];
   
else
    
    inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

    % check existence of ini file DelftDashBoard.ini
    if exist([inipath filesep 'DelftDashBoard.ini'],'file')
        inifile=[inipath 'DelftDashBoard.ini'];
    else
        GiveWarning('text',[inipath 'DelftDashBoard.ini not found !']);
        ok=0;
        return;
    end
    
    handles.SettingsDir=[inipath 'settings' filesep];
    ddbdir=getINIValue(inifile,'DataDir');
    
end

handles.BathyDir=[ddbdir 'bathymetry' filesep];
handles.SuperTransDir=[ddbdir 'supertrans' filesep];
handles.TideDir=[ddbdir 'tidemodels' filesep];
handles.ToolBoxDir=[ddbdir 'toolbox' filesep];
handles.LandboundaryDir=[ddbdir 'landboundaries' filesep];
