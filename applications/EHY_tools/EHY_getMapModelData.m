function varargout = EHY_getMapModelData(inputFile,varargin)
%% varargout = EHY_getMapModelData(inputFile,varargin)
% Extracts top view data (of water levels/salinity/temperature) from output of different models
%
% Running 'EHY_getMapModelData_interactive' without any arguments opens a interactive version, that also gives
% feedback on how to use the EHY_getMapModelData-function with input arguments.
%
% Input Arguments:
% inputFile: model file with simulation results
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
OPT.t               = []; % time index. If OPT.t is specified, OPT.t0 and OPT.tend are not used to find time index
OPT.layer           = 0;  % all
OPT.m               = 0;  % all (horizontal structured grid [m,n])
OPT.n               = 0;  % all (horizontal structured grid [m,n])
OPT.k               = 0;  % all (vertical   d3d grid [m,n,k])
OPT.mergePartitions = 1;  % merge output from several dfm '_map.nc'-files
OPT.disp            = 1;  % display status of getting map model data
OPT.gridFile        = ''; % grid (either lga or nc file) needed in combination with delwaq output file
OPT.sgft0           = ''; % delwaq segment function (sgf) - datenum or datestr of t0
OPT.sgfkmax         = []; % delwaq segment function (sgf) - number of layers (k_max)
OPT                 = setproperty(OPT,varargin);

%% modify input
inputFile = strtrim(inputFile);
if ~isempty(OPT.t0);        OPT.t0=datenum(OPT.t0);           end
if ~isempty(OPT.tend);      OPT.tend=datenum(OPT.tend);       end
if ~isnumeric(OPT.layer);   OPT.layer=str2num(OPT.layer);     end
if ~isnumeric(OPT.t);       OPT.m=str2num(OPT.t);             end
if ~isnumeric(OPT.m);       OPT.m=str2num(OPT.m);             end
if ~isnumeric(OPT.n);       OPT.n=str2num(OPT.n);             end
if ~isnumeric(OPT.k);       OPT.k=str2num(OPT.k);             end
if ~isempty(OPT.sgft0);     OPT.sgft0=datenum(OPT.sgft0);     end
if ~isnumeric(OPT.sgfkmax); OPT.sgfkmax=str2num(OPT.sgfkmax); end

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
%% Get information about required dimension information
dims = EHY_getDimsInfo(inputFile,OPT.varName,OPT.gridFile);

%% Get time information from simulation and determine index of required times
timeInd = strmatch('time',{dims(:).name});
if ~isempty(timeInd)
    Data.times          = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
    if ~isempty(OPT.t)
        if all(OPT.t==0)
            index_requested = 1:length(Data.times);
        else
        index_requested = OPT.t;
        end
        time_index      = 1:length(Data.times);
    else
        [Data,time_index,~,index_requested]  = EHY_getmodeldata_time_index(Data,OPT);
    end
    Data.times                               = Data.times(index_requested); % if time-interval was used, this step is needed
    dims(timeInd).index                      = time_index(index_requested);
    dims(timeInd).indexOut                   = 1:length(dims(timeInd).index);
end

%% Get layer information and type of vertical schematisation
layersInd = strmatch('layers',{dims(:).name});
if ~isempty(layersInd)
    gridInfo                 = EHY_getGridInfo(inputFile,{'no_layers'},'mergePartitions',0,'gridFile',OPT.gridFile);
    no_layers               = gridInfo.no_layers;
    OPT                     = EHY_getmodeldata_layer_index(OPT,no_layers);
    dims(layersInd).index    = OPT.layer';
    dims(layersInd).indexOut = 1:length(OPT.layer);
end

%% Get horizontal grid information (cells / faces)
facesInd = strmatch('faces',{dims(:).name}); % unstructured network
if ~isempty(facesInd)
        dims(facesInd).index    = 1:dims(facesInd).size;
        dims(facesInd).indexOut = 1:dims(facesInd).size;
end
mInd = strmatch('m',{dims(:).name},'exact'); % structured grid
if ~isempty(mInd)
    OPT = EHY_getmodeldata_mn_index(OPT,inputFile);
    dims(mInd).index = OPT.m;
    nInd = strmatch('n',{dims(:).name},'exact');
    dims(nInd).index = OPT.n;
end

%% Get sediment fractions information
sedfracInd = strmatch('sedimentFraction',{dims(:).name});
if ~isempty(sedfracInd)
    sedfracName = vs_let(vs_use(inputFile,'quiet'),'map-const','NAMSED','quiet');
    if size(sedfracName,2) > 1
        warning('Using multiple (all) sediment fractions.');
    end
    dims(sedfracInd).index    = 1:size(sedfracName,2);
    dims(sedfracInd).indexOut = 1:size(sedfracName,2);
end

%% EHY_getmodeldata_optimiseDims
[dims,start,count,order] = EHY_getmodeldata_optimiseDims(dims,modelType);

%% check if output data is in several partitions and merge if necessary
if OPT.mergePartitions==1 && EHY_isPartitioned(inputFile)
    mapFiles=dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    mapFilesName = regexpi({mapFiles.name},['\S{' num2str(length(mapFiles(1).name)-11) '}+\d{4}_map.nc'],'match');
    mapFilesName = mapFilesName(~cellfun('isempty',mapFilesName));
    try % temp fix for e.g. RMM_dflowfm_0007_0007_numlimdt.xyz
        if ~isempty(str2num(inputFile(end-15:end-12)))
            mapFiles=dir([inputFile(1:end-16) '*' inputFile(end-6:end)]);
        end
    end
    
    order = numel(dims):-1:1;
    for iM=1:length(mapFilesName)
        if OPT.disp
            disp(['Reading and merging map model data from partitions: ' num2str(iM) '/' num2str(length(mapFilesName))])
        end
        mapFile=cell2mat([fileparts(inputFile) filesep mapFilesName{iM}]);
        DataPart=EHY_getMapModelData(mapFile,varargin{:},'mergePartitions',0);
        if iM==1
            Data=DataPart;
        else
            if isfield(Data,'val')
                Data.val=cat(order(facesInd),Data.val,DataPart.val);
            elseif isfield(Data,'vel_x')
                Data.vel_x=cat(order(facesInd),Data.vel_x,DataPart.vel_x);
                Data.vel_y=cat(order(facesInd),Data.vel_y,DataPart.vel_y);
                Data.vel_mag=cat(order(facesInd),Data.vel_mag,DataPart.vel_mag);
            end
        end
    end
    Data.OPT.mergePartitions=1;
    modelType = 'dummy : Do not load new data, this was a partitioned run';
end

%% Get the computational data
switch modelType
    % Delft3D-Flexible Mesh
    case 'dfm'
        
        % read data from netcdf file
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
                if order(facesInd)==1
                    Data.val(FlowElemDomain~=domainNr,:,:)=[];
                elseif order(facesInd)==2
                    Data.val(:,FlowElemDomain~=domainNr,:)=[];
                end
            elseif isfield(Data,'vel_x')
                if order(facesInd)==1
                    Data.vel_x(FlowElemDomain~=domainNr,:,:)=[];
                    Data.vel_y(FlowElemDomain~=domainNr,:,:)=[];
                elseif order(facesInd)==2
                    Data.vel_x(:,FlowElemDomain~=domainNr,:)=[];
                    Data.vel_y(:,FlowElemDomain~=domainNr,:)=[];
                end
            end
        end
        
        if isfield(Data,'vel_x')
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
        end
        
    case 'd3d'
        %% Delft3D 4
        trim = vs_use(inputFile,'quiet');
        if strcmp(OPT.varName,'S1') % velocity
                Data.val = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');          
                
        elseif strcmp(OPT.varName,'U1') % velocity
            error('This should be tested for velocities in x,y- or m,n-direction and apply to velocity grid')
%             if ~isempty(layersInd) % 3D
%                 Data.vel_x = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(layersInd).index},'quiet');
%                 Data.vel_y = vs_let(trim,'map-series',{dims(timeInd).index},'V1'       ,{dims(nInd).index,dims(mInd).index,dims(layersInd).index},'quiet');
%             else % 2Dh
%                 Data.vel_x = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');
%                 Data.vel_y = vs_let(trim,'map-series',{dims(timeInd).index},'V1'       ,{dims(nInd).index,dims(mInd).index},'quiet');
%             end
%             Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            
        elseif strcmp(OPT.varName,'SBUU') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{dims(timeInd).index},'SBVV'     ,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SSUU') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{dims(timeInd).index},'SSVV'     ,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SBUUA') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{dims(timeInd).index},'SBVVA'    ,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'SSUUA') % bed load
            Data.val_x   = vs_let(trim,'map-sed-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-sed-series',{dims(timeInd).index},'SSVVA'    ,{dims(nInd).index,dims(mInd).index,dims(sedfracInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'TAUKSI') % bed load
            Data.val_x   = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');
            Data.val_y   = vs_let(trim,'map-series',{dims(timeInd).index},'TAUETA'   ,{dims(nInd).index,dims(mInd).index},'quiet');
            Data.val_max = vs_let(trim,'map-series',{dims(timeInd).index},'TAUMAX'   ,{dims(nInd).index,dims(mInd).index},'quiet');
            Data.val_mag = sqrt(Data.val_x.^2 + Data.val_y.^2);
            
        elseif strcmp(OPT.varName,'RSEDEQ') % velocity
            Data.val = vs_let(trim,'map-sed-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(layersInd).index,dims(sedfracInd).index},'quiet');
            
        elseif strcmp(OPT.varName,'DPS0') % bottom level, bed to ref
            Data.val = vs_let(trim,'map-const',{1},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');
            
        elseif strcmp(OPT.varName,'wd') % water depth, bed to wl
            wl  = vs_let(trim,'map-series',{dims(timeInd).index},'S1'  ,{dims(nInd).index,dims(mInd).index},'quiet');          
            dps = vs_let(trim,'map-const' ,{1}                  ,'DPS0',{dims(nInd).index,dims(mInd).index},'quiet');
            Data.val = wl+dps; 
        end
        % swap m,n-indices (from vs_let) from [n,m] to [time,m,n(,layers)]
        fns = intersect(fieldnames(Data),{'val','vel_x','vel_y','vel_mag','val_x','val_max','val_mag'});
        for iFns = 1:length(fns)
            if isfield(Data,fns{iFns})
                Data.(fns{iFns}) = permute(Data.(fns{iFns}),[1 3 2 4]);
            end
        end
        
        % delete ghost cells
        for iFns = 1:length(fns)
            if dims(mInd).index(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,2:end,:,:); end
            if dims(nInd).index(1)==1; Data.(fns{iFns}) = Data.(fns{iFns})(:,:,2:end,:); end
        end
        
    case 'delwaq'
        [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
        if ~strcmpi(typeOfModelFileDetail,'sgf')
            dw       = delwaq('open',inputFile);
            subInd   = strmatch(OPT.varName,dw.SubsName);
            [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(OPT.gridFile);
            if ismember(typeOfModelFileDetail,{'lga','cco'})
                dwGrid      = delwaq('open',OPT.gridFile);
                Data.val = NaN([dims.sizeOut]); % allocate
                
                for iT = 1:length(dims(timeInd).index)
                    time_ind  = dims(timeInd).index(iT);
                    [~,data]  = delwaq('read',dw,subInd,0,time_ind);
                    data      = waq2flow3d(data,dwGrid.Index);
                    layer_ind = dims(layersInd).index;
                    Data.val(dims(timeInd).indexOut(iT),:,:,:) = data(dims(mInd).index,dims(nInd).index,dims(layersInd).index);
                end
                
                % delete ghost cells
                if dims(nInd).index(1)==1; Data.val = Data.val(:,2:end,:,:); end
                if dims(mInd).index(1)==1; Data.val = Data.val(:,:,2:end,:); end
                
            elseif strcmp(typeOfModelFileDetail, 'nc')
                no_segm_perlayer = dims(facesInd).size;
                
                if ~isempty(layersInd)
                    layer = dims(layersInd).index;
                else
                    layer = 1;
                end
                
                segm = ((layer - 1) * no_segm_perlayer + 1):(layer * no_segm_perlayer);
                [~, data] = delwaq('read', dw, subInd, segm, dims(timeInd).index);
                Data.val = permute(data,[3 2 1]);
            end
            
        else % SGF
            
            gridInfo = EHY_getGridInfo(OPT.gridFile,'dimensions');
            no_seg = OPT.sgfkmax * gridInfo.no_NetElem;
            data = delwaq_sgf('read',file_sgf, no_seg, OPT.sgft0);
            Data.times = data.Date';
            
        end
        Data.val(Data.val==-999) = NaN;

    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % to be implemented
        
end

%% add dimension information to Data
% dimension information
if strcmp(modelType,'dfm')
    dimensionsComment = fliplr({dims.nameOnFile});
else
    dimensionsComment = {dims.name};
end

fn = char(intersect(fieldnames(Data),{'val','vel_x','val_x'}));
while ndims(Data.(fn))<numel(dimensionsComment)
    dimensionsComment(end) = [];
end

% add to Data-struct
dimensionsComment = sprintf('%s,',dimensionsComment{:});
Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1}=Data;
end

end
