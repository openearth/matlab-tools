function [modelType,mdFile]=EHY_getModelType(path)
    path=[path filesep];
    mdFiles=[dir([path '*.mdu']); dir([path '*.mdf']); dir([path '*siminp*']); dir([path '*waqpro*'])];
    mdFile=[mdFiles(1).folder filesep mdFiles(1).name];
    modelType=nesthd_det_filetype(mdFile);

