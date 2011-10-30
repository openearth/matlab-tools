function ddb_copyAllFilesToDataFolder(inipath,ddbdir,additionalToolboxDir)

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
mkdir([ddbdir 'supertrans']);
epf=which('EPSG.mat');
if ~isempty(epf)
    copyfile(epf,[ddbdir 'supertrans']);
end
epf=which('EPSG_ud.mat');
if ~isempty(epf)
    copyfile(epf,[ddbdir 'supertrans']);
end

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
