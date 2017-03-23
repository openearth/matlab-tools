function modelType=EHY_getModelType(file)
% modelType=EHY_getModelType(file)
% This function returns the modelType of the given file
%
% Example: EHY_getModelType('D:\Noordzee.mdu')
% 
% created by Julien Groenenboom, March 2017

[pathstr, name, ext] = fileparts(file);

modelTypes={'d3d','dfm'};

ext_d3d={'.mdf'};
ext_dfm={'.mdu'};

for iM=1:length(modelTypes)
    if ~isempty(strmatch(eval(['ext_' modelTypes{iM}]),ext))
        modelType=modelTypes{iM};
    end
end
