function [modelType,mdFile]=EHY_getModelType(path)

% [modelType,mdFile]=EHY_getModelType('p:\1230071.011-g6-dhydro\DHYDRO_2017_q1\Runs\F04_2_dtmax100\unstruc.dia')

mdFiles=[dir([path filesep '*.mdu']); dir([path filesep '*.mdf']); dir([path filesep '*siminp*'])];
if ~isempty(mdFiles)
    [~,order] = sort([mdFiles.datenum]);
    mdFile=[mdFiles(order(end)).folder filesep mdFiles(order(end)).name];
    modelType=nesthd_det_filetype(mdFile);
else % a file in the run directory was given
    [pathstr, name, ext] = fileparts(path);
    [modelType,mdFile]=EHY_getModelType([pathstr filesep]);
end





