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
        
        % Create new folder
        disp('Copying data file from repository ...');
        mkdir(ddbdir);
        mkdir([ddbdir 'bathymetry']);
        copyfiles([inipath 'data' filesep 'bathymetry'],[ddbdir 'bathymetry']);
        mkdir([ddbdir 'imagery']);
        mkdir([ddbdir 'shorelines']);
        copyfiles([inipath 'data' filesep 'shorelines'],[ddbdir 'shorelines']);
        mkdir([ddbdir 'tidemodels']);
        copyfiles([inipath 'data' filesep 'tidemodels'],[ddbdir 'tidemodels']);
        mkdir([ddbdir 'toolboxes']);
        
        % Find toolboxes and copy all files in data folders
        flist=dir([inipath 'toolboxes']);
        for i=1:length(flist)
            if isdir([inipath 'toolboxes' filesep flist(i).name])
                switch lower(flist(i).name)
                    case{'.','..','.svn'}
                    otherwise
                        if isdir([inipath 'toolboxes' filesep flist(i).name filesep 'data'])
                            mkdir([ddbdir 'toolboxes' filesep flist(i).name]);
                            copyfiles([inipath 'toolboxes' filesep flist(i).name filesep 'data'],[ddbdir 'toolboxes' filesep flist(i).name]);
                        end
                end
            end
        end
        
        % Find ADDITIONAL toolboxes and copy all files in data folders
        if ~isempty(additionalToolboxDir)
            flist=dir(additionalToolboxDir);
            for i=1:length(flist)
                if isdir([additionalToolboxDir filesep flist(i).name])
                    switch lower(flist(i).name)
                        case{'.','..','.svn'}
                        otherwise
                            if isdir([additionalToolboxDir filesep flist(i).name filesep 'data'])
                                mkdir([ddbdir 'toolboxes' filesep flist(i).name]);
                                copyfiles([additionalToolboxDir filesep flist(i).name filesep 'data'],[ddbdir 'toolboxes' filesep flist(i).name]);
                            end
                    end
                end
            end
        end
        
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

function copyfiles(inpdir,outdir)
% Copies all files (and not the directories!) to new folder
flist=dir([inpdir filesep '*']);
for i=1:length(flist)
    if ~isdir([inpdir filesep flist(i).name])
        copyfile([inpdir filesep flist(i).name],outdir);
    end
end