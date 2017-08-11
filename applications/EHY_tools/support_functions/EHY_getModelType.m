function [modelType,mdFile]=EHY_getModelType(path)

mdFiles=[dir([path filesep '*.mdu']); dir([path filesep '*.mdf']); dir([path filesep '*siminp*'])];
if ~isempty(mdFiles)
    [~,order] = sort([mdFiles.datenum]);
    mdFile=[mdFiles(order(end)).folder filesep mdFiles(order(end)).name];
    modelType=nesthd_det_filetype(mdFile);
else % a file in the run directory was given
    [pathstr, name, ext] = fileparts(path);
    [modelType,mdFile]=EHY_getModelType([pathstr filesep]);
end





