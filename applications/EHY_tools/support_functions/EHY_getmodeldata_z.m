function Data = EHY_getmodeldata_z(inputFile,stat_name,modelType,OPT)

%% Info in EHY_getmodeldata:
% OPT.z            = ''; % z = positive up. Wanted vertical level = OPT.zRef + OPT.z
% OPT.zRef         = ''; % choose: '' = model reference level, 'wl' = water level or 'bed' = from bottom level
% OPT.zMethod      = ''; % interpolation method: '' = corresponding layer or 'linear' = 'interpolation between two layers'

%% OPT
OPT0 = OPT;
OPT = rmfield(OPT,{'z','zRef','zMethod','layer'});
varName0 = OPT.varName;

%% get "zcen_int"-data
% can be done faster for z-layers once tetris-issue for FM is solved
OPT.varName = 'Zcen_int'; % change wanted variabele to Zcen_int
OPT.layer = 0;
DataZ = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);

%% get wanted "varName"-data for all necessary layers
% get data
OPT.varName = varName0; % change wanted variabele back to original value
DataAll = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);

%% determine reference level
no_times = length(DataAll.times);
no_stat = length(DataAll.requestedStations);

if ismember(OPT0.zRef,{'wl','bed'})
    OPT.varName = OPT0.zRef;
    Data_zRef = EHY_getmodeldata(inputFile,stat_name,modelType,OPT);
    refLevel = Data_zRef.val;
    if ~isfield(Data_zRef,'times')
        refLevel = reshape(refLevel,1,no_stat);
    end
else % model reference level
    refLevel = 0;
end

% repmat refLevel to [time,stations]
if size(refLevel,1) == 1 && size(refLevel,1) < no_times
    refLevel = repmat(refLevel,no_times,1);
end
if size(refLevel,2) == 1 && size(refLevel,2) < no_stat
    refLevel = repmat(refLevel,1,no_stat);
end

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

% correct for order of layering > make layer 1 the bottom layer | This is only used within this function for the next loop
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
            
            if iZ == 1
                % cell interfaces to cell centers
                for iL = 1:size(DataZ.val,3)-1
                    DataZ.val_cen(:,:,iL) = mean(DataZ.val(:,:,iL:iL+1),3);
                end
                
                 % add surface and bed layer interfaces
                if strcmp(gridInfo.layer_model,'sigma-model')
                    DataZ.val_cen = cat(3,DataZ.val(:,:,1),DataZ.val_cen,DataZ.val(:,:,end));
                elseif strcmp(gridInfo.layer_model,'z-model')
                    bedlevel = squeeze(NaN*DataZ.val_cen(:,:,1)); % [times,stations]
                    for iL = 1:size(DataZ.Zcen_int,3)
                        valuesInThisLayer = squeeze(DataZ.Zcen_int(:,:,iL));
                        logi = ~isnan(valuesInThisLayer) & isnan(bedlevel);
                        bedlevel(logi) = valuesInThisLayer(logi);
                        if all(all(~isnan(bedlevel))); break; end
                    end
                    waterlevel = squeeze(NaN*DataZ.val_cen(:,:,1)); % [times,stations]
                    for iL = size(DataZ.Zcen_int,3):-1:1
                        valuesInThisLayer = squeeze(DataZ.Zcen_int(:,:,iL));
                        logi = ~isnan(valuesInThisLayer) & isnan(waterlevel);
                        waterlevel(logi) = valuesInThisLayer(logi);
                        if all(all(~isnan(waterlevel))); break; end
                    end
                    DataZ.val_cen = cat(3,bedlevel,DataZ.val_cen,waterlevel);
                end
            end
            
            for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
                if iZ == 1
                    % add surface and bed layer model values 
                    % (At the moment, this also works for Z-layer models as model values are copied into inactive cells)
                    DataAll.(v{iV})   = cat(3,DataAll.(v{iV})(:,:,1),DataAll.(v{iV}),DataAll.(v{iV})(:,:,end));
                end
                
                for iT = 1:no_times % loop over time
                    for iS = 1:no_stat % loop over stations
                        if ~isnan(wantedZ(iS))
                            logi = ~isnan(squeeze(DataZ.val_cen(iT,iS,:))); % active layers: prevent error for Z-layers
                            try
                                Data.(v{iV})(iT,iS,iZ) = interp1(squeeze(DataZ.val_cen(iT,iS,logi)),squeeze(DataAll.(v{iV})(iT,iS,logi)),wantedZ(iT,iS));
                            catch
                                Data.(v{iV})(iT,iS,iZ) = NaN;
                            end
                        end
                    end
                end
            end
            
        otherwise % corresponding layer
            
            for iV = 1:length(v) % loop over fieldname 'val','vel_x','vel_mag',etc.
                slicePerZ = NaN(size(Data.(v{1}),1),size(Data.(v{1}),2)); % size of first two dims of Data.val
                for iL = 1:no_layers % loop over layers
                    getFromThisModelLayer = DataZ.val(:,:,iL) <= wantedZ & DataZ.val(:,:,iL+1) >= wantedZ;
                    if any(any(getFromThisModelLayer))
                        valInThisModelLayer = DataAll.(v{iV})(:,:,iL);
                        slicePerZ(getFromThisModelLayer) = valInThisModelLayer(getFromThisModelLayer);
                    end
                    if all(all(~isnan(slicePerZ)))
                        break
                    end
                end
                Data.(v{iV})(:,:,iZ) = slicePerZ;
            end
    end
end
