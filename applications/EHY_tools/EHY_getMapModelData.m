function varargout = EHY_getMapModelData(inputFile,varargin)
%% varargout = EHY_getMapModelData(inputFile,varargin)
% Extracts top view data (of water levels/velocities/salinity/temperature) from output of different model types
%
% Running 'EHY_getMapModelData' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getMapModelData-function with input arguments.
%
% Input Arguments:
% inputFile : file with simulation results
%
% Optional input arguments:
% varName   : Name of variable, choose from:
%             'wl'        water level
%             'wd'        water depth
%             'dps'       bed level
%             'uv'        velocities (in (u,v,)x,y-direction)
%             'sal'       salinity
%             'tem'       temperature
% t0        : Start time of dataset (e.g. '01-Jan-2018' or 737061 (Matlab date) )
% tend      : End time of dataset (e.g. '01-Feb-2018' or 737092 (Matlab date) )
% layer     : Model layer, e.g. '0' (all layers), [2] or [4:8]
% tint      : interval time (t0:tint:tend) in minutes
%
% Output:
% Data.times              : (matlab) times belonging with the series
% Data.val/vel_*          : requested data
% Data.dimensions         : Dimensions of requested data (time,spatial_dims,lyrs)
% Data.OPT                : Structure with optional user settings used
%
% Example1: EHY_getMapModelData % interactive
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
%% check user input
if ~exist('inputFile','var')
    EHY_getMapModelData_interactive
    return
end

%% Settings
OPT.varName         = 'wl';
OPT.t0              = '';
OPT.tend            = '';
OPT.tint            = ''; % in minutes
OPT.t               = []; % time index. If OPT.t is specified, OPT.t0, OPT.tend and OPT.tint are not used to find time index
OPT.layer           = 0;  % all
OPT.m               = 0;  % all (horizontal structured grid [m,n])
OPT.n               = 0;  % all (horizontal structured grid [m,n])
OPT.k               = 0;  % all (vertical   d3d grid [m,n,k])
OPT.mergePartitions = 1;  % merge output from several dfm '_map.nc'-files
OPT.disp            = 1;  % display status of getting map model data
OPT.gridFile        = ''; % grid (either lga or nc file) needed in combination with delwaq output file
OPT.sgft0           = 0;  % delwaq segment function (sgf) - datenum or datestr of t0
OPT.sgfkmax         = []; % delwaq segment function (sgf) - number of layers (k_max)

% return output at specified reference level
OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

% return output (cross section view) along a pli file
OPT.pliFile      = '';

OPT              = setproperty(OPT,varargin);

%% modify input
inputFile = strtrim(inputFile);
if ~isempty(OPT.t0)        OPT.t0      = datenum(OPT.t0);      end
if ~isempty(OPT.tend)      OPT.tend    = datenum(OPT.tend);    end
if ~isempty(OPT.tint )     OPT.tint    = OPT.tint/1440;        end % from minutes to days
if ~isnumeric(OPT.layer)   OPT.layer   = str2num(OPT.layer);   end
if ~isnumeric(OPT.t)       OPT.m       = str2num(OPT.t);       end
if ~isnumeric(OPT.m)       OPT.m       = str2num(OPT.m);       end
if ~isnumeric(OPT.n)       OPT.n       = str2num(OPT.n);       end
if ~isnumeric(OPT.k)       OPT.k       = str2num(OPT.k);       end
if ~isnumeric(OPT.z )      OPT.z       = str2num(OPT.z);       end
if ~isempty(OPT.sgft0)     OPT.sgft0   = datenum(OPT.sgft0);   end
if ~isnumeric(OPT.sgfkmax) OPT.sgfkmax = str2num(OPT.sgfkmax); end

if all(OPT.layer==0) && ~all(OPT.k==0) % OPT.k was provided, OPT.layer not
    OPT.layer = OPT.k; % OPT.layer is used in script
end

%% Get model type
modelType = EHY_getModelType(inputFile);

%% Get name of the parameter as known on output file
[OPT.varName,varNameInput] = EHY_nameOnFile(inputFile,OPT.varName);
if strcmp(OPT.varName,'noMatchFound')
    error(['Requested variable (' varNameInput ') not available in model output'])
end

%% return output at specified reference level
if ~isempty(OPT.z)
    Data = EHY_getMapModelData_z(inputFile,modelType,OPT);
    if nargout==1
        varargout{1} = Data;
    end
    return
end

%% return sideview output along a pli file
if ~isempty(OPT.pliFile)
    Data = EHY_getMapModelData_xy(inputFile,OPT);
    if nargout==1
        varargout{1} = Data;
    end
    return
end

%% Get the available and requested dimensions
[dims,~,Data] = EHY_getDimsInfo(inputFile,OPT,modelType);

%% check if output data is in several partitions and merge if necessary
if OPT.mergePartitions == 1 && EHY_isPartitioned(inputFile)
    ncFiles = dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    ncFilesName = regexpi({ncFiles.name},['\S{' num2str(length(ncFiles(1).name)-11) '}+\d{4}_+\S{3}.nc'],'match');
    ncFilesName = ncFilesName(~cellfun('isempty',ncFilesName));
    ncFiles = strcat(fileparts(inputFile),filesep,vertcat(ncFilesName{:}));
       
    order = max([numel(dims) 2]):-1:1;
    
    for iF = 1:length(ncFiles)
        if OPT.disp
            disp(['Reading and merging map model data from partitions: ' num2str(iF) '/' num2str(length(ncFiles))])
        end
        ncFile = ncFiles{iF};
        DataPart = EHY_getMapModelData(ncFile,OPT,'mergePartitions',0);
        if iF==1
            Data = DataPart;
        else
            if isfield(Data,'val')
                Data.val = cat(order(facesInd),Data.val,DataPart.val);
            elseif isfield(Data,'vel_x')
                Data.vel_x = cat(order(facesInd),Data.vel_x,DataPart.vel_x);
                Data.vel_y = cat(order(facesInd),Data.vel_y,DataPart.vel_y);
                Data.vel_mag = cat(order(facesInd),Data.vel_mag,DataPart.vel_mag);
            end
        end
    end
    Data.OPT.mergePartitions = 1;
    modelType = 'partitionedFmRun';
    dims = EHY_getmodeldata_optimiseDims(dims);
end

%% Get the computational data
switch modelType
    case 'dfm'
        %%  Delft3D-Flexible Mesh
        % initialise start+count and optimise if possible
        [dims,start,count] = EHY_getmodeldata_optimiseDims(dims);
        order = numel(dims):-1:1;
        
        if ~isempty(strfind(OPT.varName,'ucx')) || ~isempty(strfind(OPT.varName,'ucy')) 
            value_x   =  ncread(inputFile,strrep(OPT.varName,'ucy','ucx'),start,count);
            value_y   =  ncread(inputFile,strrep(OPT.varName,'ucx','ucy'),start,count);
        else
            value     =  ncread(inputFile,OPT.varName,start,count);
        end
        
        % put value(_x/_y) in output structure 'Data'
        if exist('value','var')
            Data.val(dims(order).indexOut) = permute(value(dims.index),order);
        elseif exist('value_x','var')
            Data.vel_x(dims(order).indexOut) = permute(value_x(dims.index),order);
            Data.vel_y(dims(order).indexOut) = permute(value_y(dims.index),order);
        end
        
        % If partitioned run, delete ghost cells
        [~, name] = fileparts(inputFile);
        varName = EHY_nameOnFile(inputFile,'FlowElemDomain');
        if length(name)>=10 && all(ismember(name(end-7:end-4),'0123456789')) && nc_isvar(inputFile,varName)
            domainNr = str2num(name(end-7:end-4));
            FlowElemDomain = ncread(inputFile,varName);
            
            if isfield(Data,'val')
                if order(facesInd) == 1
                    Data.val(FlowElemDomain ~= domainNr,:,:) = [];
                elseif order(facesInd) == 2
                    Data.val(:,FlowElemDomain ~= domainNr,:) = [];
                end
            elseif isfield(Data,'vel_x')
                if order(facesInd) == 1
                    Data.vel_x(FlowElemDomain ~= domainNr,:,:) = [];
                    Data.vel_y(FlowElemDomain ~= domainNr,:,:) = [];
                elseif order(facesInd) == 2
                    Data.vel_x(:,FlowElemDomain ~= domainNr,:) = [];
                    Data.vel_y(:,FlowElemDomain ~= domainNr,:) = [];
                end
            end
        end
        
        if isfield(Data,'vel_x')
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
        end
        
    case 'd3d'
        %% Delft3D 4
        trim = vs_use(inputFile,'quiet');
        
        % constituents
        constituents = squeeze(vs_let(trim,'map-const','NAMCON','quiet'));
        if size(constituents,1)>size(constituents,2); constituents = constituents'; end
        constituents = cellstr(constituents);
        
        % vertical grid info
        if exist('layersInd','var')
            no_layers = dims(layersInd).size;
            layerInd  = dims(layersInd).index;
        else
            no_layers = 1;
        end
        
        time_ind  = dims(timeInd).index;
        m_ind = dims(mInd).index;
        n_ind = dims(nInd).index;

        if strcmp(OPT.varName,'S1') % water level
            Data.val = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind},'quiet');
            
        elseif strcmp(OPT.varName,'DPS0') % bottom level, bed to ref
            Data.val = vs_let(trim,'map-const',{1},OPT.varName,{n_ind,m_ind},'quiet');
            
        elseif strcmp(OPT.varName,'bedlevel') % bedlevel (z-coordinate, negative)
            Data.val = -1*vs_let(trim,'map-const',{1},'DPS0',{n_ind,m_ind},'quiet');
            
        elseif strcmp(OPT.varName,'wd') % water depth, bed to wl
            wl  = vs_let(trim,'map-series',{time_ind},'S1'  ,{n_ind,m_ind},'quiet');
            dps = vs_let(trim,'map-const' ,{1}                  ,'DPS0',{n_ind,m_ind},'quiet');
            Data.val = wl+dps;
            
        elseif strcmp(OPT.varName,'U1') % velocity
            error('This should be tested for velocities in x,y- or m,n-direction and apply to velocity grid')
            %             if no_layers ~= 1 % 3D
%                 Data.vel_x = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(layersInd).index},'quiet');
%                 Data.vel_y = vs_let(trim,'map-series',{time_ind},'V1'       ,{n_ind,m_ind,dims(layersInd).index},'quiet');
%             else % 2Dh
%                 Data.vel_x = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind},'quiet');
%                 Data.vel_y = vs_let(trim,'map-series',{time_ind},'V1'       ,{n_ind,m_ind},'quiet');
%             end
%             Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            
        elseif ismember(OPT.varName,{'salinity' 'temperature'})
            consInd                 = strmatch(lower(OPT.varName),lower(constituents),'exact');
            if no_layers == 1
                Data.val = vs_let(trim,'map-series',{time_ind},'R1',{n_ind,m_ind,consInd},'quiet');
            else
                Data.val = vs_let(trim,'map-series',{time_ind},'R1',{n_ind,m_ind,layerInd,consInd},'quiet');
            end
            
        elseif strcmp(OPT.varName,'SBUU') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SBVV'     ,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SSUU') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SSVV'     ,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SBUUA') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SBVVA'    ,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SSUUA') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SSVVA'    ,{n_ind,m_ind,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'TAUKSI') % bed load
            Data.val_x   = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-series',{time_ind},'TAUETA'   ,{n_ind,m_ind},'quiet');
            Data.val_max = vs_let(trim,'map-series',{time_ind},'TAUMAX'   ,{n_ind,m_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'RSEDEQ')
            Data.val = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(layersInd).index,dims(sedfracInd).index},'quiet');
        
        elseif strcmp(OPT.varName,'Zcen_int')
            error('to do')
        end
        
        % get active/inactive mask
        mask = vs_let(trim,'map-const',{1},'KCS',{n_ind,m_ind},'quiet');
        mask(mask==0) = NaN;
        mask = mask*0+1;

        % mask data and swap m,n-indices (from vs_let) from [n,m] to [time,m,n(,layers)]
        fns = intersect(fieldnames(Data),{'val','vel_x','vel_y','vel_mag','val_x','val_max','val_mag'});
        for iFns = 1:length(fns)
            if isfield(Data,fns{iFns})
                Data.(fns{iFns})(Data.(fns{iFns}) == -999) = NaN;
                Data.(fns{iFns}) = Data.(fns{iFns}).*mask;
                Data.(fns{iFns}) = permute(Data.(fns{iFns}),[1 3 2 4]);
            end
        end
        
        % delete ghost cells // aim: get same result as 'loaddata' from d3d_qp
        for iFns = 1:length(fns)
            % delete
            if m_ind(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,2:end,:,:); end
            if n_ind(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,:,2:end,:); end
            % set to NaN
            if m_ind(end)==dims(mInd).size; Data.(fns{iFns})(:,end,:,:) = NaN; end
            if n_ind(end)==dims(nInd).size; Data.(fns{iFns})(:,:,end,:) = NaN; end
        end
        
    case 'delwaq'
        [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
        if strcmpi(typeOfModelFileDetail,'map')
            dw       = delwaq('open',inputFile);
            subs_ind   = strmatch(OPT.varName,dw.SubsName);
            [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(OPT.gridFile);
            if ismember(typeOfModelFileDetail,{'lga','cco'})
                dwGrid      = delwaq('open',OPT.gridFile);
                Data.val = NaN([dims.sizeOut]); % allocate
                
                m_ind = dims(mInd).index;
                n_ind = dims(nInd).index;
        
                for iT = 1:length(dims(timeInd).index)
                    time_ind  = dims(timeInd).index(iT);
                    [~,data]  = delwaq('read',dw,subs_ind,0,time_ind);
                    data      = waq2flow3d(data,dwGrid.Index);
                    Data.val(dims(timeInd).indexOut(iT),:,:,:) = data(m_ind,n_ind,dims(layersInd).index);
                end
                
                % delete ghost cells
                if n_ind(1)==1; Data.val = Data.val(:,2:end,:,:); end
                if m_ind(1)==1; Data.val = Data.val(:,:,2:end,:); end
                
            elseif strcmp(typeOfModelFileDetail, 'nc')
                no_segm_perlayer = dims(facesInd).size;
                
                if exist('layersInd','var') && ~isempty(layersInd)
                    layer_ind = dims(layersInd).index;
                else
                    layer_ind = 1;
                end
                
                segm_ind = ((layer_ind - 1) * no_segm_perlayer + 1):(layer_ind * no_segm_perlayer);
                [~, data] = delwaq('read', dw, subs_ind, segm_ind, dims(timeInd).index);
                Data.val = permute(data,[3 2 1]);
            end
            
        elseif strcmpi(typeOfModelFileDetail,'sgf')
            
            gridInfo = EHY_getGridInfo(OPT.gridFile,'dimensions');
            no_segm_perlayer = gridInfo.no_NetElem;
            
            layer_ind = OPT.layer;
            segm_ind = ((layer_ind - 1) * no_segm_perlayer + 1):(layer_ind * no_segm_perlayer);
            total_no_seg = OPT.sgfkmax * gridInfo.no_NetElem;
            
            data = delwaq_sgf('read',inputFile, total_no_seg, OPT.sgft0);
            
            Data.times = data.Date';
            [Data,time_ind] = EHY_getmodeldata_time_index(Data,OPT);
            
            Data.val = data.data(time_ind,segm_ind);
            
            dims(1).name = 'time';
            dims(2).name = 'segments';
            
        end
        Data.val(Data.val == -999) = NaN;

    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % to be implemented
        
end

%% add dimension information to Data
% dimension information
if strcmp(modelType,'dfm') || strcmp(modelType,'partitionedFmRun')
    dimensionsComment = fliplr({dims.name});
else
    dimensionsComment = {dims.name};
end

fn = char(intersect(fieldnames(Data),{'val','vel_x','val_x'}));
while ~isempty(fn) && ndims(Data.(fn))<numel(dimensionsComment)
    dimensionsComment(end) = [];
end

% add to Data-struct
dimensionsComment = sprintf('%s,',dimensionsComment{:});
Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1} = Data;
end

end
