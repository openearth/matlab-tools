function varargout = EHY_getMapModelData(fileInp,varargin)
%% varargout = EHY_getMapModelData(fileInp,varargin)
% Extracts top view data (of water levels/salinity/temperature) from output of different models
%
% Running 'EHY_getMapModelData_interactive' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getMapModelData-function with input arguments.
%
% Input Arguments:
% outputfile: Output file with simulation results
%
% Optional input arguments:
% varName   : Name of variable, choose from: 'wl','wd','uv','sal',tem'
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
%
% Output:
% Data.times              : (matlab) times belonging with the series
% Data.val                : requested data
% Data.dimensions         : Dimensions of requested data (time,spatial_dims,lyrs)
% Data.OPT                : Structure with optional user settings used
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018
%%
if ~exist('fileInp','var')
    EHY_getMapModelData_interactive
    return
end

OPT.varName = 'wl';
OPT.t0 = '';
OPT.tend = '';
OPT.layer = 0; % all

OPT         = setproperty(OPT,varargin);

%% modify input
if ~isempty(OPT.t0); OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend); OPT.tend=datenum(OPT.tend); end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end

%% Get the computational data
modelType=EHY_getModelType(fileInp);
switch modelType
    
    case 'dfm'
        %% Delft3D-Flexible Mesh
        % open data file
        gridInfo=EHY_getGridInfo(fileInp,{'no_layers','dimensions'});
        infonc=ncinfo(fileInp);
        OPT=EHY_getmodeldata_layer_index(OPT,gridInfo.no_layers);
        
        % time info
        Data.times=EHY_getmodeldata_getDatenumsFromOutputfile(fileInp);
        [Data,time_index,select]=EHY_getmodeldata_time_index(Data,OPT);
        if time_index==0; time_index=1; end % 0 = d3d style
        nr_times_clip = length(Data.times);
        
        % allocate variable 'value'
        if length(OPT.layer==1)
            Data.value = nan(nr_times_clip,gridInfo.no_NetElem);
            if strcmp(OPT.varName,'uv')
                Data.ucx=Data.value;
                Data.ucy=Data.value;
            end
        else
            Data.value = nan(nr_times_clip,gridInfo.no_NetElem,length(OPT.layer));
            if strcmp(OPT.varName,'uv')
                Data.ucx=Data.value;
                Data.ucy=Data.value;
            end
        end
        
        switch OPT.varName
            case 'wl'
                if ismember('mesh2d_s1',{infonc.Variables.Name})
                Data.value = ncread(fileInp,'mesh2d_s1',[1 time_index(1)],[Inf nr_times_clip])';
                else % old format
                    Data.value = ncread(fileInp,'s1',[1 time_index(1)],[Inf nr_times_clip])';
                end
            case {'wd','water depth'}
                if ismember('mesh2d_waterdepth',{infonc.Variables.Name})
                    Data.value = ncread(fileInp,'mesh2d_waterdepth',[1 time_index(1)],[Inf nr_times_clip])';
                else % old format
                    Data.value = ncread(fileInp,'waterdepth',[1 time_index(1)],[Inf nr_times_clip])';
                end
            case 'uv'
                if ismember('mesh2d_ucx',{infonc.Variables.Name})
                    if gridInfo.no_layers==1 % 2DH model
                        Data.ucx = ncread(fileInp,'mesh2d_ucx',[1 time_index(1)],[Inf nr_times_clip])';
                        Data.ucy = ncread(fileInp,'mesh2d_ucy',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.ucx = permute(ncread(fileInp,'mesh2d_ucx',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                        Data.ucy = permute(ncread(fileInp,'mesh2d_ucy',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                else % old format
                    if gridInfo.no_layers==1 % 2DH model
                        Data.ucx = ncread(fileInp,'ucx',[1 time_index(1)],[Inf nr_times_clip])';
                        Data.ucy = ncread(fileInp,'ucy',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.ucx = permute(ncread(fileInp,'ucx',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                        Data.ucy = permute(ncread(fileInp,'ucy',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                end
                 Data.value = sqrt( Data.ucx.^2 + Data.ucy.^2 ); % magnitude
            case 'sal'
                if ismember('mesh2d_sa1',{infonc.Variables.Name})
                    if gridInfo.no_layers==1 % 2DH model
                        Data.value = ncread(fileInp,'mesh2d_sa1',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.value = permute(ncread(fileInp,'mesh2d_sa1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                else % old format
                    if gridInfo.no_layers==1 % 2DH model
                        Data.value = ncread(fileInp,'sa1',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.value = permute(ncread(fileInp,'sa1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                end
            case 'tem'
                if ismember('mesh2d_tem1',{infonc.Variables.Name})
                    if gridInfo.no_layers==1 % 2DH model
                        Data.value = ncread(fileInp,'mesh2d_tem1',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.value = permute(ncread(fileInp,'mesh2d_tem1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                else % old format
                    if gridInfo.no_layers==1 % 2DH model
                        Data.value = ncread(fileInp,'tem1',[1 time_index(1)],[Inf nr_times_clip])';
                    else
                        Data.value = permute(ncread(fileInp,'tem1',[OPT.layer(1) 1 time_index(1)],[length(OPT.layer) Inf nr_times_clip]),[3 2 1]);
                    end
                end
        end
        % If partitioned run, delete ghost cells
        [~, name]=fileparts(fileInp);
        if length(name)>=13 && all(ismember(name(end-7:end-4),'0123456789')) && or(nc_isvar(fileInp,'FlowElemDomain'),nc_isvar(fileInp,'mesh2d_flowelem_domain'))
            domainNr=str2num(name(end-7:end-4));
            if nc_isvar(fileInp,'FlowElemDomain')
                FlowElemDomain=ncread(fileInp,'FlowElemDomain');
            elseif nc_isvar(fileInp,'mesh2d_flowelem_domain')
                FlowElemDomain=ncread(fileInp,'mesh2d_flowelem_domain');
            end
            Data.value(:,FlowElemDomain~=domainNr,:)=[];
            if strcmpi(OPT.varName,'uv')
                Data.ucx(:,FlowElemDomain~=domainNr,:)=[];
                Data.ucy(:,FlowElemDomain~=domainNr,:)=[];
            end
        end
        
    case 'd3d'
        %% Delft3D 4
        % to be implemented
        
    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % to be implemented
        
end

% dimension information
fn=fieldnames(Data);
if length(size(Data.(fn{end})))==2
    Data.dimensions='[times,netElem]';
elseif length(size(Data.(fn{end})))==3
    Data.dimensions='[times,netElem,layers]';
end

if strcmp(OPT.varName,'uv')
    OPT.comment='value is magnitude of velocity';
end

Data.OPT=OPT;
Data.OPT.outputfile=fileInp;

if nargout==1
    varargout{1}=Data;
end

end
