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

% output file was given, try to get runid and mdFile
if ~exist('mdFile','var') % dflowfm
    [~,name,ext]=fileparts(path);
    filename=[name ext];
    id=strfind(filename,'_his.nc');
    runid=filename(1:id-1);
    if length(runid)>5 && ~isempty(str2num(runid(end-3:end))) && strcmp(runid(end-4),'_')
        runid=runid(1:end-5); % skip partitioning part
    end
    if ~isempty(runid)
        mdFiles=dir([fileparts(fileparts(path)) filesep '*' runid '.mdu']);
        if length(mdFiles)==1
            mdFile=[fileparts(fileparts(path)) filesep runid '.mdu'];
        end
    end
end
if ~exist('mdFile','var') % delft3d4
    id1=strfind(path,'trih-');
    id2=strfind(path,'.dat');
    runid=path(id1+5:id2-1);
    if ~isempty(runid)
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

