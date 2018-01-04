function [modelType,mdFile]=EHY_getModelType(path)

%% determine mdFile
% the mdFile itself was given
[~, name, ext] = fileparts(path);
if ismember(ext,{'.mdu','.mdf'}) || ~isempty(strfind(lower(name),'siminp'))
    mdFile=path;
end

% the run directory was given
if ~exist('mdFile','var')
    mdFiles=[dir([path filesep '*.mdu']); dir([path filesep '*.mdf']); dir([path filesep '*siminp*'])];
    if ~isempty(mdFiles)
        [~,order] = sort([mdFiles.datenum]);
        mdFile=fullfile([path filesep mdFiles(order(1)).name]);
        if length(order)>1
            disp(['More than 1 mdf/mdu/siminp-file was found, now using ''' mdFiles(order(1)).name ''''])
        end
    end
end

% output file was given, try to get runid
if ~exist('mdFile','var') % dflowfm
    expression = '(\w+)_his.nc';
    [runid,~] = regexp(path,expression,'tokens','match');
    if ~isempty(runid)
        runid=char(runid{1});
        mdFiles=dir([fileparts(fileparts(path)) filesep '*' runid '.mdu']);
        if length(mdFiles)==1
            mdFile=[fileparts(fileparts(path)) filesep runid '.mdu'];
        end
    end
end
if ~exist('mdFile','var') % delft3d4
    expression = 'trih-(\w+).dat';
    [runid,~] = regexp(path,expression,'tokens','match');
    if ~isempty(runid)
        runid=char(runid{1});
        mdFiles=dir([fileparts(path) filesep '*' runid '.mdf']);
        if length(mdFiles)==1
            mdFile=[fileparts(path) filesep runid '.mdf'];
        end
    end
end

% file in the run directory was given
if ~exist('mdFile','var')
    pathstr=fileparts(path);
    [modelType,mdFile]=EHY_getModelType(pathstr);
end

%% determine modelType
if ~isempty(strfind(lower(mdFile),'.mdu'))
    modelType='mdu';
elseif ~isempty(strfind(lower(mdFile),'.mdf'))
    modelType='mdf';
elseif ~isempty(strfind(lower(mdFile),'siminp'))
    modelType='siminp';
end

