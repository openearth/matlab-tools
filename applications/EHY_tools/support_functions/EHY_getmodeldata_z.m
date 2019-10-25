function Data = EHY_getmodeldata_z(inputFile,stat_name,modelType,OPT)

%% Info in EHY_getmodeldata:
% OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
% OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
% OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

%% OPT
OPT0 = OPT;
OPT = rmfield(OPT,{'z','zRef','zMethod','layer'});
varName0 = OPT.varName;

%% determine reference level
if ismember(OPT0.zRef,{'wl','bed'})
    OPT.varName = OPT0.zRef;
    Data_zRef = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);
    refLevel = Data_zRef.val;
else % model reference level
    refLevel = 0;
end

%% get "zcen_int"-data
% can be done faster for z-layers once tetris-issue for FM is solved
OPT.varName = 'Zcen_int'; % change wanted variabele to Zcen_int
OPT.layer = 0;
DataZ = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);

%% get wanted "varName"-data for all necessary layers
% get data
OPT.varName = varName0; % change wanted variabele back to original value
DataAll = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);

%% check
dimTextInd = strfind(DataAll.dimensions,',');
if isempty(strfind(lower(DataAll.dimensions(dimTextInd(end)+1:end-1)),'lay'))
    error('Last dimension is not the layer-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
elseif isempty(strfind(DataAll.dimensions(2:dimTextInd(1)-1),'time'))
    error('First dimension is not the time-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
end

%% Calculate values at specified reference level

% we are going to loop over fieldnames 'val','vel_x','vel_mag',etc.
v = intersect(fieldnames(DataAll),{'val','vel_x','vel_y','vel_mag','val_x','val_y'});

% initiate Data-struct
Data      = DataAll;
Data.OPT  = setproperty(Data.OPT,OPT0); % set original OPT back
% delete 'layer'-dimension
no_dims   = size(Data.(v{1}));
no_layers = no_dims(end);
Data.OPT  = rmfield(Data.OPT,'layer');
for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
    Data.(v{iV})  = NaN([no_dims(1:end-1) length(OPT0.z)]);
end

if length(OPT0.z) > 1
    Data.dimensions = [Data.dimensions(1:dimTextInd(end)-1) ',z]'];
else
    Data.dimensions = [Data.dimensions(1:dimTextInd(end)-1) ']'];
end

% correct for order of layering > layer 1 is at the bottom
gridInfo = EHY_getGridInfo(inputFile,'layer_model');
if strcmp(modelType,'d3d') && strcmp(gridInfo.layer_model,'sigma-model')
    DataZ.val = flip(DataZ.val,3);
    for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
        DataAll.(v{iV}) = flip(DataAll.(v{iV}),3);
    end
end

% wanted Z-coordinate
for iZ = 1:length(OPT0.z)
    wantedZ = refLevel + OPT0.z(iZ); % 1st dim = time, 2nd dim = stations
    
    % get corresponding layer/apply interpolation
    switch OPT0.zMethod
        case 'linear'
            error('to do')
            
        otherwise % corresponding layer
            
            for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
                slicePerZ = NaN(size(Data.(v{1}),1),size(Data.(v{1}),2)); % size of first two dims of Data.val
                for iL = 1:no_layers % loop over layers
                    getFromThisModelLayer = DataZ.val(:,:,iL) <= wantedZ & DataZ.val(:,:,iL+1)>wantedZ;
                    if any(any(getFromThisModelLayer))
                        valInThisModelLayer = DataAll.(v{iV})(:,:,iL);
                        slicePerZ(getFromThisModelLayer) = valInThisModelLayer(getFromThisModelLayer);
                    end
                end
                Data.(v{iV})(:,:,iZ) = slicePerZ;
            end
    end
end
