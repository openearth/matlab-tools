function varargout = EHY_getMapModelData(inputFile,varargin)
%% varargout = EHY_getMapModelData(inputFile,varargin)
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
% Data.val/vel_*          : requested data
% Data.dimensions         : Dimensions of requested data (time,spatial_dims,lyrs)
% Data.OPT                : Structure with optional user settings used
%
% For questions/suggestions, please contact Julien.Groenenboom@deltares.nl
% created by Julien Groenenboom, October 2018
%% check user input
if ~exist('inputFile','var')
    EHY_getMapModelData_interactive
    return
end

%% Settings
OPT.varName         = 'wl';
OPT.t0              = '';
OPT.tend            = '';
OPT.layer           = 0; % all
OPT.mergePartitions = 1; % merge output from several dfm '_map.nc'-files
OPT.disp            = 1; % display status of getting map model data
OPT                 = setproperty(OPT,varargin);

%% modify input
inputFile=strtrim(inputFile);
if ~isempty(OPT.t0); OPT.t0=datenum(OPT.t0); end
if ~isempty(OPT.tend); OPT.tend=datenum(OPT.tend); end
if ~isnumeric(OPT.layer); OPT.layer=str2num(OPT.layer); end

%% Get model type
modelType = EHY_getModelType(inputFile);
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);

%% Get name of the parameter as known on output file
OPT.varName = EHY_nameOnFile(inputFile,OPT.varName);
if strcmp(modelType,'dfm') && ~nc_isvar(inputFile,OPT.varName)
    error(['Could not find variable ''' OPT.varName ''' on provided file'])
end

%% Get information about required dimension information
dims = EHY_getDimsInfo(inputFile,OPT.varName);

%% Get time information from simulation and determine index of required times
timeInd = strmatch('time',{dims(:).name});
if ~isempty(timeInd)
    Data.times                               = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
    [Data,time_index,select,index_requested] = EHY_getmodeldata_time_index(Data,OPT);
    Data.times                               = Data.times(index_requested); % if time-interval was used, this step is needed
    dims(timeInd).index                      = time_index(index_requested);
    dims(timeInd).indexOut                   = 1:length(dims(timeInd).index);
end

%% Get layer information and type of vertical schematisation
laydimInd = find(~cellfun(@isempty,strfind(lower({dims(:).name}),'layer'))); % any dimensionName with 'layer' in it
if ~isempty(laydimInd)
    gridInfo                 = EHY_getGridInfo(inputFile,{'no_layers' 'layer_model'},'mergePartitions',0);
    no_layers                = gridInfo.no_layers;
    layer_model              = gridInfo.layer_model;
    OPT                      = EHY_getmodeldata_layer_index(OPT,no_layers);
    dims(laydimInd).index    = OPT.layer';
    dims(laydimInd).indexOut = 1:length(OPT.layer);
end

%% Get horizontal grid information
mesh2dInd = find(~cellfun(@isempty,strfind(lower({dims(:).name}),'face'))); % any dimensionName with 'face' in it
if ~isempty(mesh2dInd)
    dims(mesh2dInd).index    = 1:dims(mesh2dInd).size;
    dims(mesh2dInd).indexOut = 1:dims(mesh2dInd).size;
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
                Data.val=cat(order(mesh2dInd),Data.val,DataPart.val);
            elseif isfield(Data,'vel_x')
                Data.vel_x=cat(order(mesh2dInd),Data.vel_x,DataPart.vel_x);
                Data.vel_y=cat(order(mesh2dInd),Data.vel_y,DataPart.vel_x);
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
        start = repmat(1,1,no_dims);
        count = [dims.size];
        
        % change 'time'-values to wanted indices
        if ~isempty(timeInd)
            start(timeInd) = dims(timeInd).index(1);
            count(timeInd) = dims(timeInd).index(end)-dims(timeInd).index(1)+1;
            dims(timeInd).index = dims(timeInd).index-dims(timeInd).index(1)+1;% needed to 'only keep requested indices'
        end
        
        % change 'layer'-values to wanted indices
        if ~isempty(laydimInd)
            diffLayers=diff(dims(laydimInd).index);
            if isempty(diffLayers) || all(diffLayers==1)
                % take OPT.tint into account
                start(laydimInd) = dims(laydimInd).index(1);
                count(laydimInd) = dims(laydimInd).index(end)-dims(laydimInd).index(1)+1;
                dims(laydimInd).index = dims(laydimInd).index-dims(laydimInd).index(1)+1;% needed to 'only keep requested indices'
            end
        end
        
        % read data from netcdf file
        if ~isempty(strfind(OPT.varName,'ucx'))
            value_x   =  ncread(inputFile,OPT.varName,start,count);
            value_y   =  ncread(inputFile,OPT.varName,start,count);
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
        [~, name]=fileparts(inputFile);
        if length(name)>=13 && all(ismember(name(end-7:end-4),'0123456789')) && or(nc_isvar(inputFile,'FlowElemDomain'),nc_isvar(inputFile,'mesh2d_flowelem_domain'))
            domainNr=str2num(name(end-7:end-4));
            if nc_isvar(inputFile,'FlowElemDomain')
                FlowElemDomain=ncread(inputFile,'FlowElemDomain');
            elseif nc_isvar(inputFile,'mesh2d_flowelem_domain')
                FlowElemDomain=ncread(inputFile,'mesh2d_flowelem_domain');
            end
            
            if isfield(Data,'val')
                if order(mesh2dInd)==1
                    Data.val(FlowElemDomain~=domainNr,:,:)=[];
                elseif order(mesh2dInd)==2
                    Data.val(:,FlowElemDomain~=domainNr,:)=[];
                end
            elseif isfield(Data,'vel_x')
                if order(mesh2dInd)==1
                    Data.vel_x(FlowElemDomain~=domainNr,:,:)=[];
                    Data.vel_y(FlowElemDomain~=domainNr,:,:)=[];
                elseif order(mesh2dInd)==2
                    Data.vel_x(:,FlowElemDomain~=domainNr,:)=[];
                    Data.vel_y(:,FlowElemDomain~=domainNr,:)=[];
                end
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
if isfield(Data,'val')
    fn='val';
elseif isfield(Data,'vel_x')
    fn='vel_x';
end
if exist('dims','var')
    dimensionsComment = fliplr({dims.name});
    while length(size(Data.(fn)))<no_dims % size of output < no_dims
        dimensionsComment(end)=[];
        dims(end)=[];
        no_dims=length(dims);
    end
    dimensionsComment = sprintf('%s,',dimensionsComment{:});
    Data.dimensions = ['[' dimensionsComment(1:end-1) ']'];
else
    if length(size(Data.(fn)))==2
        Data.dimensions='[times,netElem]';
    elseif length(size(Data.(fn)))==3
        Data.dimensions='[times,netElem,layers]';
    end
end

%% Fill output struct
Data.OPT               = OPT;
Data.OPT.inputFile     = inputFile;

if nargout==1
    varargout{1}=Data;
end

end
