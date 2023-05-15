function FMversion = EHY_getFMversion(inputFile,modelType)

%% EHY_getFMversion
%
% Example 1: EHY_getFMversion('model_map.nc')
% Example 2: EHY_getFMversion('model_map.nc','dfm')
% returns  : FMversion = '1.2.100' (string)
% Note: The Delft3D code moved from SVN to GIT, so there is no revision number anymore (?)
%

if ~exist('modelType','var') % modelType was not provided
    modelType = EHY_getModelType(inputFile);
end

if strcmp(modelType,'dfm')
    source = ncreadatt(inputFile,'/','source');
    % Examples:
    % source = 'D-Flow FM 1.2.41.63609'
    % source = 'Deltares, D-Flow FM Version 1.2.100.66357, Apr 10 2020, 02:20:29, model'
    % source = 'D-Flow FM 1.2.184.000000. Model:'
    FMversion = char(regexp(source, '\d+\.\d+\.\d+', 'match'));
else
    error('Determining version number of non-FM files not yet implemented')
end
