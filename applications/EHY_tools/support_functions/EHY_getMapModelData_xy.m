function [Data_xy,gridInfo] = EHY_getMapModelData_xy(inputFile,varargin)
%  Function: Create data needed for plotting of cross section information
%
%% Initialise:
OPT       = varargin{1};
Data.modelType = EHY_getModelType(inputFile);

%% Read the pli file
thalweg = readldb(OPT.pliFile);
OPT = rmfield(OPT,'pliFile');

%% Horizontal (x,y) coordinates
tmp   = EHY_getGridInfo(inputFile,{'XYcor', 'XYcen','edge_nodes','face_nodes','layer_model'},'mergePartitions',OPT.mergePartitions);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% get "z-data"
[dims,dimsInd,tmp] = EHY_getDimsInfo(inputFile,OPT,Data.modelType);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end
if ~isempty(dimsInd.layers) && dims(dimsInd.layers).sizeOut > 1
    [Data.Zint,Data.Zcen,Data.wl,Data.bed] = EHY_getMapModelData_construct_zcoordinates(inputFile,Data.modelType,OPT);
    dmy = size(Data.Zcen);
    no_layers = dmy(end);
else
    no_layers = 1;
end

%% get wanted "varName"-data for all points
tmp   = EHY_getMapModelData(inputFile,OPT);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% Calculate values at pli locations
disp('Start determining properties along trajectory')

warning off
if strcmp(Data.modelType,'dfm') && isfield(Data,'face_nodes')
    arb = arbcross(Data.face_nodes',Data.Xcor,Data.Ycor,thalweg.x,thalweg.y);
elseif strcmp(Data.modelType,'d3d') || isfield(Data,'Xcor')
    arb = arbcross(Data.Xcor,Data.Ycor,thalweg.x,thalweg.y);
end
warning on

Data_xy.Xcor = arb.x;
Data_xy.Ycor = arb.y;

%%
Data_xy.Scor = distance(Data_xy.Xcor,Data_xy.Ycor)';
Data_xy.Xcen = (Data_xy.Xcor(1:end-1) + Data_xy.Xcor(2:end)) ./ 2;
Data_xy.Ycen = (Data_xy.Ycor(1:end-1) + Data_xy.Ycor(2:end)) ./ 2;
Data_xy.Scen = (Data_xy.Scor(1:end-1) + Data_xy.Scor(2:end)) ./ 2;

%%  Determine vertical levels at Scen locations and corresponding values
no_times      = length(Data.times);

if strcmp(Data.modelType,'dfm') && isfield(Data,'face_nodes')
    val = arbcross(arb,{'FACE' permute(Data.val,[2 3 1])});
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 1])});
    end
elseif strcmp(Data.modelType,'d3d') || isfield(Data,'Xcor')
    val = arbcross(arb,{'FACE' permute(Data.val,[2 3 4 1])});
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 4 1])});
    end
end

no_XYcorTrajectory = size(val,1);
Data_xy.val  = zeros(no_times, no_XYcorTrajectory, no_layers);
if no_layers > 1
    Data_xy.Zint = zeros(no_times, no_XYcorTrajectory, no_layers+1);
end
for iT = 1:no_times
    for iC = 1:no_XYcorTrajectory
        startBlock = (iT-1)*no_layers+1;
        endBlock = startBlock + no_layers - 1;
        Data_xy.val(iT,iC,:) = val(iC,startBlock:endBlock);
        
        if strcmp(Data.modelType,'d3d') && strcmp(Data.layer_model,'sigma-model')
            startBlock = (iT-1)*(no_layers+1)+1;
        else
            startBlock = (no_times-iT)*(no_layers+1)+1;
        end
        endBlock = startBlock + (no_layers+1) - 1;
        if no_layers > 1
            Data_xy.Zint(iT,iC,:) = Zint(iC,startBlock:endBlock);
        end
    end
end
if no_layers > 1
    Data_xy.Zcen = (Data_xy.Zint(:,:,1:end-1) + Data_xy.Zint(:,:,2:end)) ./ 2;
    Data_xy.wl = Data_xy.Zint(:,:,end);
    Data_xy.bed = squeeze(Data_xy.Zint(1,:,1));
end

Data_xy.times = Data.times;

disp('Finished determining properties along trajectory')

%% make gridInfo for plotting using EHY_plotMapModelData
if nargout > 1
    if no_layers > 1
        gridInfo.Xcor = Data_xy.Scor;
        gridInfo.Ycor = Data_xy.Zint; % [times,cells,layers]
    else
        gridInfo = [];
        for i = 1:length(val)
            Data_xy.val_staircase(2*i-1,1)  = Data_xy.val(i);
            Data_xy.val_staircase(2*i,1)    = Data_xy.val(i);
            Data_xy.Scor_staircase(2*i-1,1) = Data_xy.Scor(i);
            Data_xy.Scor_staircase(2*i,1)   = Data_xy.Scor(i+1);
        end
    end
end
