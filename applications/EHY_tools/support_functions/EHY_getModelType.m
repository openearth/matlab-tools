function [modelType,mdFile]=EHY_getModelType(path)

mdFiles=[dir([path filesep '*.mdu']); dir([path filesep '*.mdf']); dir([path filesep '*siminp*'])];
if ~isempty(mdFiles)
    [~,order] = sort([mdFiles.datenum]);
    mdFile=[path filesep mdFiles(order(1)).name];
    modelType=nesthd_det_filetype(mdFile);
else % a file in the run directory was given
    [pathstr, name, ext] = fileparts(path);
    [modelType,mdFile]=EHY_getModelType([pathstr filesep]);
end





