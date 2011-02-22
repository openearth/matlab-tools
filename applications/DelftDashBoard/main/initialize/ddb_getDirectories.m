function [handles,ok]=ddb_getDirectories(handles)

ok=1;

handles.workingDirectory=pwd;

if isdeployed

    handles.settingsDir=[ctfroot filesep 'settings' filesep];

    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    ddbdir=[fileparts(exeDir) filesep 'data' filesep];
    additionalToolboxDir=[];

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
    
    handles.settingsDir=[inipath 'settings' filesep];
    ddbdir=getINIValue(inifile,'DataDir');
    if exist(ddbdir)==7 % absolute path
        ddbdir = [cd(cd(ddbdir)) filesep];
    elseif exist([fileparts(inifile) filesep ddbdir])==7 % relative path
        ddbdir = [cd(cd([fileparts(inifile) filesep ddbdir])) filesep];
    else
        error(['Local data directory ''' ddbdir ''' not found, check reference in ini-file!']);
    end
    
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
    catch
        additionalToolboxDir=[];
    end
    
end

handles.bathyDir=[ddbdir 'bathymetry' filesep];
handles.tideDir=[ddbdir 'tidemodels' filesep];
handles.toolBoxDir=[ddbdir 'toolbox' filesep];
handles.additionalToolboxDir=additionalToolboxDir;
handles.shorelineDir=[ddbdir 'shorelines' filesep];

if isdeployed
    handles.superTransDir=[ddbdir 'supertrans' filesep];
else
    dr=fileparts(which('EPSG.mat'));
    handles.superTransDir=[dr filesep];
end
