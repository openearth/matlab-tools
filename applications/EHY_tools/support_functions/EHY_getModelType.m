function [modelType,mdFile]=EHY_getModelType(path)
[pathstr, name, ext] = fileparts(path);
if isempty(ext) % a file was given, but not a mdf,mdu or siminp. Let's search in the folder
    path=pathstr;
end

path=[path filesep];
mdFiles=[dir([path '*.mdu']); dir([path '*.mdf']); dir([path '*siminp*'])];
[~,order] = sort([mdFiles.datenum]);
mdFile=[mdFiles(order(end)).folder filesep mdFiles(order(end)).name];
modelType=nesthd_det_filetype(mdFile);

