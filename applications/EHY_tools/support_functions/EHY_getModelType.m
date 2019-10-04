function modelType = EHY_getModelType(fileInp)
%% modelType = EHY_getModelType(fileInp)
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
% Hint: to get the type of model file, use EHY_getTypeOfModelFile
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if ischar(fileInp)
    
    [pathstr, name, ext] = fileparts(lower(fileInp));
    modelType='';
    
    % Delft3D-FM
    if isempty(modelType)
        if ismember(ext,{'.mdu','.ext','.bc','.pli','.xyn','.tim'})
            modelType = 'dfm';
        end
    end
    
    % Delft3D 4
    if isempty(modelType)
        if ~isempty(strfind(name,'trih-')) || ~isempty(strfind(name,'trim-')) || ...
                ismember(ext,{'.mdf','.bcc','.bct','.bca','.bnd','.crs','.dat','.def','.enc','.eva','.grd','.obs','.src'})
            modelType = 'd3d';
        end
    end
    
    % SIMONA (WAQUA/TRIWAQ)
    if isempty(modelType)
        if ~isempty(strfind(name,'sds'   )) || ~isempty(strfind(name,'siminp'))  || ~isempty(strfind(name,'rgf')) || ...
                ~isempty(strfind(name,'points')) || ~isempty(strfind(name,'timeser'))
            modelType = 'simona';
        end
    end
    
    % Delft3D-FM or Sobek3 netcdf outputfile
    if isempty(modelType)
        if ismember(ext,{'.nc'})
            if ~isempty(strfind(fileInp,'_his.nc')) || ~isempty(strfind(fileInp,'_map.nc')) || ~isempty(strfind(fileInp,'_net.nc')) || ...
                    ~isempty(strfind(fileInp,'_fou.nc')) || ~isempty(strfind(fileInp,'_waqgeom.nc')) 
                modelType = 'dfm';
            elseif ~isempty(strfind(name,'observations'))
                modelType = 'sobek3_new';
            elseif ~isempty(strfind(name,'water level (op)-'))
                modelType = 'sobek3';
            end
        end
    end
    
    % Implic
    if isempty(modelType)
        if isdir(fileInp)
            modelType = 'implic';
        end
    end
    
    % delwaq
    if ismember(ext,{'.map','.his','.lga','.cco'})
        modelType = 'delwaq';
    end
    
elseif isstruct(fileInp)
    
    % Delft3D 4
    if isfield(fileInp,'FileType')
        if strcmpi(fileInp.FileType,'NEFIS')
            modelType = 'd3d';
        end
    end
    
end
