function [modelType,varargout] = EHY_getModelType(fileInp)
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
% Added 13-02-2019: varargout{1} in which fileType (mdf, mdu, bct, ext etc.) is stored
%
% support function of the EHY_tools
% Julien Groenenboom - E: Julien.Groenenboom@deltares.nl

%%
if nargin==0 % no input was given
    disp('Open a file')
    [fileInp, pathname]=uigetfile('*.*','Open a file');
    if isnumeric(fileInp); disp('EHY_getModelType stopped by user.'); return; end
    fileInp=[pathname fileInp];
end

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
            if ~isempty(strfind(fileInp,'_his.nc')) || ~isempty(strfind(fileInp,'_map.nc')) || ~isempty(strfind(fileInp,'_net.nc'))
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
    
elseif isstruct(fileInp)
    
    % Delft3D 4
    if isfield(fileInp,'FileType')
        if strcmpi(fileInp.FileType,'NEFIS')
            modelType = 'd3d';
        end
    end
    
end
%% fileType
if nargout>1
    varargout{1}                    = '';
    [~,~,ext]                       = fileparts(fileInp);
    if length(ext) > 1 varargout{1} = ext(2:end); end
    if ~isempty(strfind(lower(fileInp),'siminp' ))   varargout{1} = 'siminp'; end
    if ~isempty(strfind(lower(fileInp),'sds'    ))   varargout{1} = 'sds'   ; end
    if ~isempty(strfind(lower(fileInp),'_his.nc'))   varargout{1} = 'his_nc'; end
    if ~isempty(strfind(lower(fileInp),'_map.nc'))   varargout{1} = 'map_nc'; end
    if ~isempty(strfind(lower(fileInp),'_net.nc'))   varargout{1} = 'net_nc'; end
    if ~isempty(strfind(lower(fileInp),'trih'   ))   varargout{1} = 'trih'  ; end
    if ~isempty(strfind(lower(fileInp),'trim'   ))   varargout{1} = 'trim'  ; end
    if ~isempty(strfind(lower(fileInp),'rgf'))       varargout{1} = 'grd'   ; end
end