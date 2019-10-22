function [dims,dimsInd,Data] = EHY_getDimsInfo(inputFile,OPT,modelType,stat_name)

%% Info
% dims.size         size  as on modelfile
% dims.index        index as on modelfile
% dims.indexOut     index in 'Data'-struct
% dims.sizeOut      size  in 'Data'-struct

if isfield(OPT,'gridFile')
    gridFile = OPT.gridFile;
end

%% dims
if nargout > 1
    %% Get info about available dimensions on file (and their sizes)
    [~, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
    switch modelType
        case 'dfm'
            infonc    = ncinfo(inputFile,OPT.varName);
            dimsNames = {infonc.Dimensions.Name};
            dimsSizes = infonc.Size;
            for iD=1:length(dimsNames)
                dims(iD).name       = dimsNames{iD};
                dims(iD).size       = dimsSizes(iD);
                dims(iD).index      = 1:dims(iD).size;
                dims(iD).indexOut   = 1:dims(iD).size;
            end
            
        case 'd3d'
            % time // always ask for time
            dims(1).name = 'time';
            
            if strcmp(typeOfModelFileDetail,'trih')
                % stations
                stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
                if ~isempty(stationNames)
                    dims(end+1).name = 'stations';
                end
            elseif strcmp(typeOfModelFileDetail,'trim')
                % faces/grid cells
                dims(end+1).name = 'm';
                dims(end+1).name = 'n';
            end
            
            % sediment fractions
            d3d = vs_use(inputFile,'quiet');
            NAMSEDind = strmatch('NAMSED',{d3d.ElmDef.Name});
            if ~isempty(NAMSEDind) && d3d.ElmDef(NAMSEDind).Size>1
                dims(end+1).name = 'sedimentFraction';
            end
            
            % layers
            gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
            if gridInfo.no_layers > 1 && ~ismember(EHY_nameOnFile(inputFile,OPT.varName),{'wl','wd','dps','S1'})
                dims(end+1).name = 'layers';
            end
            
        case 'delwaq'
            % time
            dims(1).name = 'time';
            
            if strcmp(typeOfModelFileDetail,'his')
                % stations
                stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
                if ~isempty(stationNames)
                    dims(end+1).name = 'stations';
                end
            elseif strcmp(typeOfModelFileDetail,'map')
                [~, typeOfModelFileDetailGrid] = EHY_getTypeOfModelFile(gridFile);
                if ismember(typeOfModelFileDetailGrid, {'lga', 'cco'})     % faces/grid cells
                    dims(end+1).name = 'm';
                    dims(end+1).name = 'n';
                elseif strcmp(typeOfModelFileDetailGrid, 'nc')
                    dims(end+1).name = 'faces';
                    gridInfo = EHY_getGridInfo(gridFile, {'dimensions'});
                    dims(end).size = gridInfo.no_NetElem;
                end
                
                % layers
                gridInfo = EHY_getGridInfo(inputFile,{'no_layers'}, 'gridFile', gridFile);
                if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1
                    dims(end+1).name = 'layers';
                end
                
            end
            
            if strcmpi(typeOfModelFileDetail,'sgf')
                dims = [];
                dims.name = '';
            end
            
        otherwise % SOBEK / SIMONA
            % time // always ask for time
            dims(1).name = 'time';
            
            % layers
            gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
            if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1 && ~ismember(OPT.varName,{'wl','wd','dps'})
                dims(end+1).name = 'layers';
            end
            
            % stations
            stationNames = EHY_getStationNames(inputFile,modelType,'varName',OPT.varName);
            if ~isempty(stationNames)
                dims(end+1).name = 'stations';
            end
            
    end
end

%% dimsInd
if nargout > 1
    dimsInd.stations = find(ismember({dims(:).name},{'stations','cross_section','general_structures'}));
    dimsInd.time = find(ismember({dims(:).name},'time'));
    dimsInd.layers = find(ismember({dims(:).name},{'layers','laydim','nmesh2d_layer','mesh2d_nLayers'}));
    dimsInd.faces = find(ismember({dims(:).name},{'faces','nmesh2d_face','mesh2d_nFaces','nFlowElem','nNetElem'}));
    dimsInd.m = find(ismember({dims(:).name},'m')); % structured grid
    dimsInd.n = find(ismember({dims(:).name},'n'));
    dimsInd.sedfrac = find(ismember({dims(:).name},'sedimentFraction'));
end

%% Data
if nargout > 2
    Data = struct;
    
    %% Get list with the numbers of the requested stations
    if ~isempty(dimsInd.stations)
        [Data,stationNrNoNan]           = EHY_getRequestedStations(inputFile,stat_name,modelType,'varName',OPT.varName);
        dims(dimsInd.stations).index    = reshape(stationNrNoNan,1,length(stationNrNoNan));
        dims(dimsInd.stations).indexOut = find(Data.exist_stat);
    end
    
    %% Get time information from simulation and determine index of required times
    if ~isempty(dimsInd.time)
        Data.times                          = EHY_getmodeldata_getDatenumsFromOutputfile(inputFile);
        [Data,time_index,~,index_requested] = EHY_getmodeldata_time_index(Data,OPT);
        Data.times                          = Data.times(index_requested); % if time-interval was used, this step is needed
        dims(dimsInd.time).index            = time_index(index_requested);
        dims(dimsInd.time).indexOut         = 1:length(dims(dimsInd.time).index);
    end
    
    %% Get layer information and type of vertical schematisation
    if ~isempty(dimsInd.layers)
        if exist('gridFile','var')
            gridInfo                  = EHY_getGridInfo(inputFile,{'no_layers'},'mergePartitions',0,'gridFile',gridFile);
        else
            gridInfo                  = EHY_getGridInfo(inputFile,{'no_layers'},'mergePartitions',0);
        end
        no_layers                     = gridInfo.no_layers;
        OPT                           = EHY_getmodeldata_layer_index(OPT,no_layers);
        dims(dimsInd.layers).index    = OPT.layer';
        dims(dimsInd.layers).size     = no_layers;
        dims(dimsInd.layers).indexOut = 1:length(OPT.layer);
    end
    
    %% Get horizontal grid information (cells / faces)
    if ~isempty(dimsInd.faces)
        dims(dimsInd.faces).index    = 1:dims(dimsInd.faces).size;
        dims(dimsInd.faces).indexOut = 1:dims(dimsInd.faces).size;
    end
    if ~isempty(dimsInd.m)
        OPT = EHY_getmodeldata_mn_index(OPT,inputFile);
        dims(dimsInd.m).index   = OPT.m;
        dims(dimsInd.m).indexOut = 1:length(OPT.m);
        dims(dimsInd.n).index   = OPT.n;
        dims(dimsInd.n).indexOut = 1:length(OPT.n);
    end
    
    %% Get sediment fractions information
    if ~isempty(dimsInd.sedfrac)
        sedfracName = vs_let(vs_use(inputFile,'quiet'),'map-const','NAMSED','quiet');
        if size(sedfracName,2) > 1
            warning('Using multiple (all) sediment fractions.');
        end
        dims(dimsInd.sedfrac).index    = 1:size(sedfracName,2);
        dims(dimsInd.sedfrac).indexOut = 1:size(sedfracName,2);
    end
    
    % dims.indexOut
    for iD=1:length(dims)
        if isfield(dims,'indexOut')
            dims(iD).sizeOut = length(dims(iD).indexOut);
        end
    end
    
    % assign dimsInd in caller
    fns = fieldnames(dimsInd);
    for iFns = 1:length(fns)
        if ~isempty(dimsInd.(fns{iFns}))
            assignin('caller',[fns{iFns} 'Ind'],dimsInd.(fns{iFns}))
        end
    end
end
