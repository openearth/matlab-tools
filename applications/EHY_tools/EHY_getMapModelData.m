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
OPT.sedimentName    = ''; % name of sediment fraction
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
if ~isnumeric(OPT.t)       OPT.m       = str2num(OPT.t);       end
if ~isnumeric(OPT.m)       OPT.m       = str2num(OPT.m);       end
if ~isnumeric(OPT.n)       OPT.n       = str2num(OPT.n);       end
if ~isnumeric(OPT.k)       OPT.k       = str2num(OPT.k);       end
if ~isnumeric(OPT.z )      OPT.z       = str2num(OPT.z);       end
if ~isempty(OPT.sgft0)     OPT.sgft0   = datenum(OPT.sgft0);   end
if ~isnumeric(OPT.sgfkmax) OPT.sgfkmax = str2num(OPT.sgfkmax); end
if ~isnumeric(OPT.layer) && ~isempty(str2num(OPT.layer))
    OPT.layer   = str2num(OPT.layer);
end

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

%% Get the available and requested dimensions
[dims,~,Data,OPT] = EHY_getDimsInfo(inputFile,OPT,modelType);

%% find top or bottom layer in z-layer model
if ischar(OPT.layer)
    Data = EHY_getMapModelData_zLayerTopBottom(inputFile,modelType,OPT);
    if nargout==1
        varargout{1} = Data;
    end
    return
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
    [Data,gridInfo] = EHY_getMapModelData_xy(inputFile,OPT);
    if nargout > 0
        varargout{1} = Data;
    end
    if nargout > 1
        varargout{2} = gridInfo;
    end
    return
end

%% check if output data is in several partitions and merge if necessary
if OPT.mergePartitions == 1 && EHY_isPartitioned(inputFile)
    ncFiles = dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    ncFilesName = regexpi({ncFiles.name},['\S{' num2str(length(ncFiles(1).name)-11) '}+\d{4}_+\S{3}.nc'],'match');
    ncFilesName = ncFilesName(~cellfun('isempty',ncFilesName));
    ncFiles = strcat(fileparts(inputFile),filesep,vertcat(ncFilesName{:}));

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
                Data.val = cat(facesInd,Data.val,DataPart.val);
            elseif isfield(Data,'vel_x')
                Data.vel_x = cat(facesInd,Data.vel_x,DataPart.vel_x);
                Data.vel_y = cat(facesInd,Data.vel_y,DataPart.vel_y);
                Data.vel_mag = cat(facesInd,Data.vel_mag,DataPart.vel_mag);
                Data.vel_dir = cat(facesInd,Data.vel_dir,DataPart.vel_dir);
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

        if ~isempty(strfind(OPT.varName,'ucx')) || ~isempty(strfind(OPT.varName,'ucy')) || ismember(OPT.varName,{'u','v'})
            value_x   =  nc_varget(inputFile,strrep(OPT.varName,'ucy','ucx'),start-1,count);
            value_y   =  nc_varget(inputFile,strrep(OPT.varName,'ucx','ucy'),start-1,count);
        else
            value     =  nc_varget(inputFile,OPT.varName,start-1,count);
        end

        % initiate correct order if no_dims == 1
        if numel(dims) == 1
            if exist('value','var')
                Data.val = NaN(dims.sizeOut,1);
            elseif exist('value_x','var')
                Data.vel_x = NaN(dims.sizeOut,1);
                Data.vel_y = NaN(dims.sizeOut,1);
            end
        end

        % deal with deleted leading singleton dimensions
        valueIndex = {dims.index};
        while all(valueIndex{1}==1)
            valueIndex(1) = [];
        end

        % put value(_x/_y) in output structure 'Data'
        if exist('value','var')
            Data.val(dims.indexOut) = value(valueIndex{:});
        elseif exist('value_x','var')
            Data.vel_x(dims.indexOut) = value_x(valueIndex{:});
            Data.vel_y(dims.indexOut) = value_y(valueIndex{:});
        end

        % If partitioned run, delete ghost cells
        [~, name] = fileparts(inputFile);
        varName = EHY_nameOnFile(inputFile,'FlowElemDomain');
        if EHY_isPartitioned(inputFile,modelType) && nc_isvar(inputFile,varName)
            domainNr = str2num(name(end-7:end-4));
            FlowElemDomain = ncread(inputFile,varName);

            if isfield(Data,'val')
                if facesInd == 1
                    Data.val(FlowElemDomain ~= domainNr,:,:) = [];
                elseif facesInd == 2
                    Data.val(:,FlowElemDomain ~= domainNr,:) = [];
                end
            elseif isfield(Data,'vel_x')
                if facesInd == 1
                    Data.vel_x(FlowElemDomain ~= domainNr,:,:) = [];
                    Data.vel_y(FlowElemDomain ~= domainNr,:,:) = [];
                elseif facesInd == 2
                    Data.vel_x(:,FlowElemDomain ~= domainNr,:) = [];
                    Data.vel_y(:,FlowElemDomain ~= domainNr,:) = [];
                end
            end
        end

        if isfield(Data,'vel_x')
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
            Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
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
            layer_ind = dims(layersInd).index;
            layer_ind = reshape(layer_ind,1,numel(layer_ind));
        else
            no_layers = 1;
            layer_ind = 1;
        end

        time_ind  = dims(timeInd).index;
        m_ind = dims(mInd).index;
        n_ind = dims(nInd).index;
        if exist('sedfracInd','var')
            sed_ind = dims(sedfracInd).index;
        end

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
            if no_layers ~= 1 % 3D
                data = qpread(trim,1,'horizontal velocity','griddata',time_ind,m_ind,n_ind,dims(layersInd).index);
            else % 2Dh
                data = qpread(trim,1,'depth averaged velocity','griddata',time_ind,m_ind,n_ind);
            end
            Data.vel_x(dims.indexOut) = data.XComp;
            Data.vel_y(dims.indexOut) = data.YComp;
            %swap m/n because it is swapped back later on
            Data.vel_x = permute(Data.vel_x,[1 3 2 4]);
            Data.vel_y = permute(Data.vel_y,[1 3 2 4]);
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            Data.vel_dir = mod(atan2(Data.vel_x,Data.vel_y)*180/pi,360);
            Data.vel_dir_comment = 'Considered clockwise from geographic North to where vector points';
        elseif ismember(OPT.varName,{'salinity' 'temperature'}) || ~isempty( strmatch(lower(OPT.varName),lower(constituents),'exact'))
            cons_ind = strmatch(lower(OPT.varName),lower(constituents),'exact');
            if no_layers == 1
                Data.val = vs_let(trim,'map-series',{time_ind},'R1',{n_ind,m_ind,cons_ind},'quiet');
            else
                Data.val = vs_let(trim,'map-series',{time_ind},'R1',{n_ind,m_ind,layer_ind,cons_ind},'quiet');
            end

        elseif strcmp(OPT.varName,'SBUU') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SBVV'     ,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);

        elseif strcmp(OPT.varName,'SSUU') % suspended load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SSVV'     ,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);

        elseif strcmp(OPT.varName,'SBUUA') % average bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SBVVA'    ,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);

        elseif strcmp(OPT.varName,'SSUUA') % average suspended load
            Data.val_x   = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{time_ind},'SSVVA'    ,{n_ind,m_ind,sed_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);

        elseif strcmp(OPT.varName,'DP_BEDLYR') % sediment thickness
            Data.val = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,2},'quiet');

        elseif strcmp(OPT.varName,'TAUKSI') % bed shear
            Data.val_x   = vs_let(trim,'map-series',{time_ind},OPT.varName,{n_ind,m_ind},'quiet');
            Data.val_y   = vs_let(trim,'map-series',{time_ind},'TAUETA'   ,{n_ind,m_ind},'quiet');
            Data.val_max = vs_let(trim,'map-series',{time_ind},'TAUMAX'   ,{n_ind,m_ind},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);

        elseif strcmp(OPT.varName,'RSEDEQ')
            Data.val = vs_let(trim,'map-sed-series',{time_ind},OPT.varName,{n_ind,m_ind,dims(layersInd).index,sed_ind},'quiet');

        elseif strcmp(OPT.varName,'Zcen_int')
            error('to do')
        end

        % get active/inactive mask
        mask = vs_let(trim,'map-const',{1},'KCS',{n_ind,m_ind},'quiet');
        mask(mask==0) = NaN;
        mask = mask*0+1;

        % mask data and swap m,n-indices (from vs_let) from [n,m] to [time,m,n(,layers)]
        fns = intersect(fieldnames(Data),{'val','vel_x','vel_y','vel_mag','vel_dir','val_x','val_y','val_max','val_mag'});
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
dimensionsComment = {dims.name};

fn = char(intersect(fieldnames(Data),{'val','vel_x','val_x'}));
while ~isempty(fn) && ndims(Data.(fn)) < numel(dimensionsComment)
    dimensionsComment(end) = [];
end
while ~isempty(fn) && ndims(Data.(fn)) > numel(dimensionsComment)
    dimensionsComment{end+1,1} = '-';
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
