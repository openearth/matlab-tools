function [handles,ok]=ddb_getDirectories(handles)
% Find DDB directories

ok=1;

handles.workingDirectory=pwd;

if isdeployed

    handles.settingsDir=[ctfroot filesep 'ddbsettings' filesep];

    [status, result] = system('path');
    exeDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'));
    ddbdir=[fileparts(exeDir) filesep 'data' filesep];
    additionalToolboxDir=[];

else
    
    inipath=[fileparts(fileparts(fileparts(which('DelftDashBoard')))) filesep];

    % check existence of ini file DelftDashBoard.ini
    inifile=[inipath 'DelftDashBoard.ini'];

    if ~exist(inifile,'file')
        
        txt='Select folder (preferably named "delftdashboard") for data storage (e.g. d:\delftdashboard). You may need to create a new folder. Folder must be outside OET repository!';
        dirname = uigetdir(inipath,txt);
        
        if isnumeric(dirname)
            dirname='';
        end
        
        if isempty(dirname)
            error('Local data directory not found, check reference in ini-file!');
        end
        
        datadir=[dirname filesep 'data'];

        disp('Making delftdashboard.ini file ...');
        
        fid=fopen([inipath 'delftdashboard.ini'],'wt');        
        fprintf(fid,'%s\n','% Data directories');
        fprintf(fid,'%s\n',['DataDir=' datadir filesep]);
        fclose(fid);

    end
    
    handles.settingsDir=[inipath 'settings' filesep];
    ddbdir=getINIValue(inifile,'DataDir');
    if exist(ddbdir)==7 % absolute path
        ddbdir = [cd(cd(ddbdir)) filesep];
    elseif exist([fileparts(inifile) filesep ddbdir])==7 % relative path
        ddbdir = [cd(cd([fileparts(inifile) filesep ddbdir])) filesep];
    else
%         error(['Local data directory ''' ddbdir ''' not found, check reference in ini-file!']);
    end
    
    try
        additionalToolboxDir=getINIValue(inifile,'AdditionalToolboxDir');
    catch
        additionalToolboxDir=[];
    end

    if ~isdir(ddbdir)
        
        % Usually done the first time ddb is run. Files are copied from
        % repository to DDB data folder
        
        ddb_copyAllFilesToDataFolder(inipath,ddbdir,additionalToolboxDir);
                        
    end
    
end

handles.bathyDir=[ddbdir 'bathymetry' filesep];
handles.tideDir=[ddbdir 'tidemodels' filesep];
handles.toolBoxDir=[ddbdir 'toolboxes' filesep];
handles.additionalToolboxDir=additionalToolboxDir;
handles.shorelineDir=[ddbdir 'shorelines' filesep];
handles.satelliteDir=[ddbdir 'imagery' filesep];

if isdeployed
    handles.superTransDir=[ddbdir 'supertrans' filesep];
else
    dr=fileparts(which('EPSG.mat'));
    handles.superTransDir=[dr filesep];
end

