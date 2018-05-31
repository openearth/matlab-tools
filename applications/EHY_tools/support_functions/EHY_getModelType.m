function modelType=EHY_getModelType(filename)
%% modelType=EHY_getModelType(filename)
%
% This function returns the modelType based on a filename
% modelType can be:
% dfm       Delft3D-Flexible Mesh
% d3d       Delft3D 4
% simona    SIMONA (WAQUA/TRIWAQ)
%
% Example1: 	modelType=EHY_getModelType('D:\model.mdu')
% Example2: 	modelType=EHY_getModelType('D:\model.obs')
% Example3: 	modelType=EHY_getModelType('D:\trih-r01.dat')
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if nargin==0 % no input was given
    disp('Open a file')
    [filename, pathname]=uigetfile('*.*','Open a file');
    if isnumeric(filename); disp('EHY_getModelType stopped by user.'); return; end
    filename=[pathname filename];
end

%%
[pathstr, name, ext] = fileparts(lower(filename));
modelType='';

% Delft3D-FM
if isempty(modelType)
    if ismember(ext,{'.mdu','.ext','.nc','.bc','.xyn','.tim'})
        modelType = 'dfm';
    end
end

% Delft3D 4
if isempty(modelType)
    if ~isempty(strfind(name,'trih-')) || ~isempty(strfind(name,'trim-'))
            ismember(ext,{'.mdf','.bcc','.bct','.bca','.bnd','.crs','.dat','.def','.enc','.eva','.grd','.obs','.src'})
        modelType = 'd3d';
    end
end

% SIMONA (WAQUA/TRIWAQ)
if isempty(modelType)
    if ~isempty(strfind(name,'sds')) || ~isempty(strfind(name,'siminp'))
        modelType = 'simona';
    end
end
