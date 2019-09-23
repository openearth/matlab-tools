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
OPT.lgaFile         = ''; %lga-file needed in combination with delwaq output file
OPT                 = setproperty(OPT,varargin);

%% modify input
inputFile = strtrim(inputFile);
if ~isempty(OPT.t0);      OPT.t0=datenum(OPT.t0);       end
if ~isempty(OPT.tend);    OPT.tend=datenum(OPT.tend);   end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end
if ~isnumeric(OPT.t);     OPT.m=str2num(OPT.t);         end
if ~isnumeric(OPT.m);     OPT.m=str2num(OPT.m);         end
if ~isnumeric(OPT.n);     OPT.n=str2num(OPT.n);         end
if ~isnumeric(OPT.k);     OPT.k=str2num(OPT.k);         end

if all(OPT.layer==0) && ~all(OPT.k==0) % OPT.k was provided, OPT.layer not
    OPT.layer = OPT.k; % OPT.layer is used in script
end

%% Get model type
modelType = EHY_getModelType(inputFile);

%% Get name of the parameter as known on output file
OPT.varName = EHY_nameOnFile(inputFile,OPT.varName);

%% Get information about required dimension information
dims = EHY_getDimsInfo(inputFile,OPT.varName);

%% Get time information from simulation and determine index of required times
timeInd = strmatch('time',{dims(:).name});
if ~isempty(timeInd)
    Data.times          = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
    if ~isempty(OPT.t)
        index_requested = OPT.t;
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
    gridInfo                = EHY_getGridInfo(inputFile,{'no_layers' 'layer_model'},'mergePartitions',0);
    no_layers               = gridInfo.no_layers;
    layer_model             = gridInfo.layer_model;
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
mInd = strmatch('m',{dims(:).name}); % structured grid
if ~isempty(mInd)
    OPT = EHY_getmodeldata_mn_index(OPT,inputFile);
    dims(mInd).index = OPT.m;
    nInd = strmatch('n',{dims(:).name});
    dims(nInd).index = OPT.n;
end

%% Get dimension size of requested indices
for iD=1:length(dims)
    dims(iD).sizeOut = length(dims(iD).index);
end

no_dims = length(dims);
order = no_dims:-1:1;

%% check if output data is in several partitions and merge if necessary
if OPT.mergePartitions==1 && EHY_isPartitioned(inputFile)
    mapFiles=dir([inputFile(1:end-11) '*' inputFile(end-6:end)]);
    try % temp fix for e.g. RMM_dflowfm_0007_0007_numlimdt.xyz
        if ~isempty(str2num(inputFile(end-15:end-12)))
            mapFiles=dir([inputFile(1:end-16) '*' inputFile(end-6:end)]);
        end
    end
    
    for iM=1:length(mapFiles)
        if OPT.disp
            disp(['Reading and merging map model data from partitions: ' num2str(iM) '/' num2str(length(mapFiles))])
        end
        mapFile=[fileparts(inputFile) filesep mapFiles(iM).name];
        DataPart=EHY_getMapModelData(mapFile,varargin{:},'mergePartitions',0);
        if iM==1
            Data=DataPart;
        else
            if isfield(Data,'val')
                Data.val=cat(order(facesInd),Data.val,DataPart.val);
            elseif isfield(Data,'vel_x')
                Data.vel_x=cat(order(facesInd),Data.vel_x,DataPart.vel_x);
                Data.vel_y=cat(order(facesInd),Data.vel_y,DataPart.vel_x);
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
        
        %% Read data
        start = ones(1,no_dims);
        count = [dims.size];
        
        % change 'time'-values to wanted indices
        if ~isempty(timeInd)
            start(timeInd) = dims(timeInd).index(1);
            count(timeInd) = dims(timeInd).index(end)-dims(timeInd).index(1)+1;
            dims(timeInd).index = dims(timeInd).index-dims(timeInd).index(1)+1;% needed to 'only keep requested indices'
        end
        
        % change 'layer'-values to wanted indices
        if ~isempty(layersInd)
            diffLayers=diff(dims(layersInd).index);
            if isempty(diffLayers) || all(diffLayers==1)
                % take OPT.tint into account
                start(layersInd) = dims(layersInd).index(1);
                count(layersInd) = dims(layersInd).index(end)-dims(layersInd).index(1)+1;
                dims(layersInd).index = dims(layersInd).index-dims(layersInd).index(1)+1;% needed to 'only keep requested indices'
            end
        end
        
        % read data from netcdf file
        if ~isempty(strfind(OPT.varName,'ucx'))
            value_x   =  ncread(inputFile,OPT.varName,start,count);
            value_y   =  ncread(inputFile,strrep(OPT.varName,'ucx','ucy'),start,count);
        else
            value     =  ncread(inputFile,OPT.varName,start,count);
        end
        
        % put value(_x/_y) in output structure 'Data'
        if exist('value','var')
            if no_dims==1
                Data.val(dims(1).indexOut,1) = value(dims(1).index);
            elseif no_dims==2
                Data.val(dims(2).indexOut,dims(1).indexOut) = permute( value(dims(1).index,dims(2).index) ,order);
            elseif no_dims==3
                Data.val(dims(3).indexOut,dims(2).indexOut,dims(1).indexOut) = permute( value(dims(1).index,dims(2).index,dims(3).index) ,order);
            end
        elseif exist('value_x','var')
            if no_dims==1
                Data.vel_x(dims(1).indexOut,1) = value_x(dims(1).index);
                Data.vel_y(dims(1).indexOut,1) = value_y(dims(1).index);
            elseif no_dims==2
                Data.vel_x(dims(2).indexOut,dims(1).indexOut) = permute( value_x(dims(1).index,dims(2).index) ,order);
                Data.vel_y(dims(2).indexOut,dims(1).indexOut) = permute( value_y(dims(1).index,dims(2).index) ,order);
            elseif no_dims==3
                Data.vel_x(dims(3).indexOut,dims(2).indexOut,dims(1).indexOut) = permute( value_x(dims(1).index,dims(2).index,dims(3).index) ,order);
                Data.vel_y(dims(3).indexOut,dims(2).indexOut,dims(1).indexOut) = permute( value_y(dims(1).index,dims(2).index,dims(3).index) ,order);
            end
        end
        
        % If partitioned run, delete ghost cells
        [~, name] = fileparts(inputFile);
        varName = EHY_nameOnFile(inputFile,'FlowElemDomain');
        if length(name)>=13 && all(ismember(name(end-7:end-4),'0123456789')) && nc_isvar(inputFile,varName)
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
                Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            end
            
        end
        
    case 'd3d'
        %% Delft3D 4
        trim = vs_use(inputFile,'quiet');
        if strcmp(OPT.varName,'S1') % velocity
                Data.val = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');          
                
        elseif strcmp(OPT.varName,'U1') % velocity
            if ~isempty(layersInd) % 3D
                Data.vel_x = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index,dims(layersInd).index},'quiet');
                Data.vel_y = vs_let(trim,'map-series',{dims(timeInd).index},'V1'       ,{dims(nInd).index,dims(mInd).index,dims(layersInd).index},'quiet');
            else % 2Dh
                Data.vel_x = vs_let(trim,'map-series',{dims(timeInd).index},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');
                Data.vel_y = vs_let(trim,'map-series',{dims(timeInd).index},'V1'       ,{dims(nInd).index,dims(mInd).index},'quiet');
            end
            Data.vel_mag = sqrt(Data.vel_x.^2 + Data.vel_y.^2);
            
        elseif strcmp(OPT.varName,'DPS0') % bottom level, bed to ref
            Data.val = vs_let(trim,'map-const',{1},OPT.varName,{dims(nInd).index,dims(mInd).index},'quiet');
            
        elseif strcmp(OPT.varName,'wd') % water depth, bed to wl
            wl  = vs_let(trim,'map-series',{dims(timeInd).index},'S1'  ,{dims(nInd).index,dims(mInd).index},'quiet');          
            dps = vs_let(trim,'map-const' ,{1}                  ,'DPS0',{dims(nInd).index,dims(mInd).index},'quiet');
            Data.val = wl+dps; 
        end
        % delete ghost cells
        if dims(nInd).index(1)==1; Data.val = Data.val(:,2:end,:,:); end
        if dims(mInd).index(1)==1; Data.val = Data.val(:,:,2:end,:); end      
        
    case 'delwaq'
        dw       = delwaq('open',inputFile);
        lga      = delwaq('open',OPT.lgaFile);
        subInd   = strmatch(OPT.varName,dw.SubsName);
        Data.val = NaN([1 size(lga.Index)]); % allocate 
        
        for iT = 1:length(dims(timeInd).index)
            time_ind = dims(timeInd).index(iT);
            [~,data] = delwaq('read',dw,subInd,0,time_ind);
            data     = waq2flow3d(data,lga.Index);
            Data.val(dims(timeInd).indexOut(iT),:,:,:) = data;
        end
        
        % delete ghost cells
        if dims(nInd).index(1)==1; Data.val = Data.val(:,2:end,:,:); end
        if dims(mInd).index(1)==1; Data.val = Data.val(:,:,2:end,:); end
        
        Data.val(Data.val<0) = NaN;
        
    case 'simona'
        %% SIMONA (WAQUA/TRIWAQ)
        % to be implemented
        
end

% dimension information
if isfield(Data,'val')
    fn = 'val';
elseif isfield(Data,'vel_x')
    fn = 'vel_x';
end
if strcmp(modelType,'dfm')
    if exist('dims','var')
        dimensionsComment = fliplr({dims.nameOnFile});
        while length(size(Data.(fn))) < no_dims % size of output < no_dims
            % if e.g. only 1 layer selected, output is 2D instead of 3D.
            dimensionsComment(end) = [];
            dims(end) = [];
            no_dims = length(dims);
        end
    else
        if length(size(Data.(fn)))==2
            dimensionsComment={'time','faces'};
        elseif length(size(Data.(fn)))==3
            dimensionsComment={'time','faces','layers'};
        end
    end
elseif any(ismember(modelType,{'d3d','delwaq'}))
    if length(size(Data.(fn)))==3
        dimensionsComment={'time','n_index','m_index'};
    elseif length(size(Data.(fn)))==4
        dimensionsComment={'time','n_index','m_index','k_index'};
    end
end

if exist('dimensionsComment','var') % does not exist for partitioned dfm simulation
    dimensionsComment = sprintf('%s,',dimensionsComment{:});
    Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];
end

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1}=Data;
end

end
