function [Data_xy,gridInfo] = EHY_getMapModelData_xy(inputFile,varargin)
%  Function: Create data needed for plotting of cross section information

%% Initialise:
OPT       = varargin{1};
Data.modelType = EHY_getModelType(inputFile);

%% Read the pli file
if ~isempty(OPT.pliFile)
    pli = readldb(OPT.pliFile);
    pli = [pli.x pli.y];
    OPT = rmfield(OPT,'pliFile');
elseif ~isempty(OPT.pli)
    pli = OPT.pli;
    OPT = rmfield(OPT,'pli');
else
    error('You need to specify either "pliFile" or "pli"')
end

if size(pli,1) == 2 && size(pli,2) > 2
    pli = pli';
end
    
%% Determine which partitions to load data from
if OPT.mergePartitions == 1
    partitionNrs = EHY_findPartitionNumbers(inputFile,'pli',pli);
else
    partitionNrs = str2num(inputFile(end-10:end-7));
end
% continue with relevant partition numbers
OPT.mergePartitionNrs = partitionNrs;

%% Horizontal (x,y) coordinates
tmp   = EHY_getGridInfo(inputFile,{'XYcor', 'XYcen','edge_nodes','face_nodes','layer_model'},'mergePartitionNrs',OPT.mergePartitionNrs);
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

%% get wanted "varName"-data for all relevant partitions
tmp   = EHY_getMapModelData(inputFile,OPT);
names = fieldnames(tmp); for i_name = 1: length(names) Data.(names{i_name}) = tmp.(names{i_name}); end

%% Calculate values at pli locations
disp('Start determining properties along trajectory')

warning off
if strcmp(Data.modelType,'dfm') && isfield(Data,'face_nodes')
    arb = arbcross(Data.face_nodes',Data.Xcor,Data.Ycor,pli(:,1),pli(:,2));
elseif strcmp(Data.modelType,'d3d') || isfield(Data,'Xcor')
    arb = arbcross(Data.Xcor,Data.Ycor,pli(:,1),pli(:,2));
end
warning on

Data_xy.Xcor = arb.x;
Data_xy.Ycor = arb.y;

%% Determine X,Y and distance (S) at crossings (*cor) and middle of crossings (*cen)
% *cor
nonan = ~isnan(Data_xy.Xcor);
Data_xy.Scor(nonan,:) = [0; cumsum(sqrt(diff(Data_xy.Xcor(nonan)).^2+diff(Data_xy.Ycor(nonan)).^2))];
% *cen
Data_xy.Xcen = (Data_xy.Xcor(1:end-1) + Data_xy.Xcor(2:end)) ./ 2;
Data_xy.Ycen = (Data_xy.Ycor(1:end-1) + Data_xy.Ycor(2:end)) ./ 2;
Data_xy.Scen = (Data_xy.Scor(1:end-1) + Data_xy.Scor(2:end)) ./ 2;

%%  Determine vertical levels at Scen locations and corresponding values
no_times      = length(Data.times);

if strcmp(Data.modelType,'dfm') && isfield(Data,'face_nodes')
    if isfield(Data,'val')
        val = arbcross(arb,{'FACE' permute(Data.val,[2 3 1])});
    elseif isfield(Data,'vel_x')
        vel_x = arbcross(arb,{'FACE' permute(Data.vel_x,[2 3 1])});
        vel_y = arbcross(arb,{'FACE' permute(Data.vel_y,[2 3 1])});
        vel_dir = arbcross(arb,{'FACE' permute(Data.vel_dir,[2 3 1])});
        vel_mag = arbcross(arb,{'FACE' permute(Data.vel_mag,[2 3 1])});
    end
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 1])});
    end
elseif strcmp(Data.modelType,'d3d') || isfield(Data,'Xcor')
    val = arbcross(arb,{'FACE' permute(Data.val,[2 3 4 1])});
    if no_layers > 1
        Zint = arbcross(arb,{'FACE' permute(Data.Zint,[2 3 4 1])});
    end
end

no_XYcenTrajectory = length(arb.dxt);
Data_xy.val  = zeros(no_times, no_XYcenTrajectory, no_layers);
if no_layers > 1
    Data_xy.Zint = zeros(no_times, no_XYcenTrajectory, no_layers+1);
end
for iT = 1:no_times
    for iC = 1:no_XYcenTrajectory
        startBlock = (iT-1)*no_layers+1;
        endBlock = startBlock + no_layers - 1;
        
        if isfield(Data,'val')
            Data_xy.val(iT,iC,:) = val(iC,startBlock:endBlock);
        elseif isfield(Data,'vel_x')
            Data_xy.vel_x(iT,iC,:) = vel_x(iC,startBlock:endBlock);
            Data_xy.vel_y(iT,iC,:) = vel_y(iC,startBlock:endBlock);
            Data_xy.vel_mag(iT,iC,:) = vel_mag(iC,startBlock:endBlock);
            Data_xy.vel_dir(iT,iC,:) = vel_dir(iC,startBlock:endBlock);
        end
        
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
