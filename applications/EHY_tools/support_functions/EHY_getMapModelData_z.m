function Data = EHY_getMapModelData_z(inputFile,OPT)

error('working on it - function is not working correctly yet')

%% Info in EHY_getMapModelData:
% OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
% OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
% OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

%% OPT
OPT0 = OPT;
OPT = rmfield(OPT,{'z','zRef','zMethod','layer'});
varName0 = OPT.varName;

%% determine wanted Z-coordinate
if ismember(OPT0.zRef,{'wl','bed'})
    OPT.varName = OPT0.zRef;
    Data_zRef = EHY_getMapModelData(inputFile,OPT);
    refLevel = Data_zRef.val;
else % model reference level
    refLevel = 0;
end

% wanted Z-coordinate
wantedZ = OPT0.z + refLevel;

%% get "zcen_int"-data
% can be done faster for z-layers once tetris-issue for FM is solved
OPT.varName = 'Zcen_int'; % change wanted variabele to Zcen_int
OPT.layer = 0;
% DataZ = EHY_getMapModelData(inputFile,OPT);

%% get wanted "varName"-data for all necessary layers
% get data
OPT.varName = varName0; % change wanted variabele back to original value
DataAll = EHY_getMapModelData(inputFile,OPT);

%% check
dimTextInd = strfind(DataAll.dimensions,',');
if isempty(strfind(DataAll.dimensions(dimTextInd(end)+1:end-1),'lay'))
    error('Last dimension is not the layer-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
elseif isempty(strfind(DataAll.dimensions(2:dimTextInd(1)-1),'time'))
    error('First dimension is not the time-dimension and that is what this script uses. Please contact Julien.Groenenboom@deltares.nl')
end

%% Calculate values at specified reference level
% initiate Data-struct
Data      = DataAll;
Data.OPT  = setproperty(Data.OPT,OPT0); % set original OPT back
% delete 'layer'-dimension
no_dims   = size(Data.val);
no_layers = no_dims(end);
Data.OPT  = rmfield(Data.OPT,'layer');
Data.val  = NaN(no_dims(1:end-1));
Data.dimensions = [Data.dimensions(1:dimTextInd(end)-1) ']'];

% correct for order of layering > layer 1 is at the bottom
gridInfo = EHY_getGridInfo(inputFile,'layer_model');
if strcmp(modelType,'d3d') && strcmp(gridInfo.layer_model,'sigma-model')
    DataZ.val = flip(DataZ.val,3);
    DataAll.val = flip(DataAll.val,3); 
end

% get corresponding layer/apply interpolation
switch OPT0.zMethod
    case 'linear'
        error('to do')
        
    otherwise % corresponding layer
        for iL = 1:no_layers % loop over layers
            getFromThisLayer = DataZ.val(:,:,iL) <= wantedZ & DataZ.val(:,:,iL+1)>wantedZ;
            if any(any(getFromThisLayer))
                valInThisLayer = DataAll.val(:,:,iL);
                Data.val(getFromThisLayer) = valInThisLayer(getFromThisLayer);
            end
        end
end
