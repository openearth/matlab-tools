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
    if exist(ddbdir)==7 % absolute path
        ddbdir = [cd(cd(ddbdir)) filesep];
    elseif exist([fileparts(inifile) filesep ddbdir])==7 % relative path
        ddbdir = [cd(cd([fileparts(inifile) filesep ddbdir])) filesep];
    else
        error(['Local data directory ''' ddbdir ''' not found, check reference in ini-file!']);
    end
end

handles.BathyDir=[ddbdir 'bathymetry' filesep];
handles.TideDir=[ddbdir 'tidemodels' filesep];
handles.ToolBoxDir=[ddbdir 'toolbox' filesep];
handles.ShorelineDir=[ddbdir 'shorelines' filesep];

if isdeployed
    handles.SuperTransDir=[ddbdir 'supertrans' filesep];
else
    dr=fileparts(which('EPSG.mat'));
    handles.SuperTransDir=[dr filesep];
end
