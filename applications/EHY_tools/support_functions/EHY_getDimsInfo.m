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
            no_dims   = length(dimsNames);
            for iD = 1:no_dims
                ind = no_dims-iD+1;
                dims(ind).name       = dimsNames{iD};
                dims(ind).size       = dimsSizes(iD);
                dims(ind).index      = 1:dimsSizes(iD);
                dims(ind).indexOut   = 1:dimsSizes(iD);
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
            if ~isempty(NAMSEDind)
                if strcmp(typeOfModelFileDetail,'trim')
                    sedfracName = squeeze(vs_let(vs_use(inputFile,'quiet'),'map-const','NAMSED','quiet'));
                elseif strcmp(typeOfModelFileDetail,'trih')
                    sedfracName = squeeze(vs_let(vs_use(inputFile,'quiet'),'his-const','NAMSED','quiet'));
                end
                if size(sedfracName,2) > 1
                    dims(end+1).name = 'sedimentFraction';
                end
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
    dimsInd.layers = find(ismember({dims(:).name},{'layers','laydim','nmesh2d_layer','mesh2d_nLayers','depth'})); % depth is needed for cmems
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
        dims(dimsInd.stations).sizeOut  = length(Data.requestedStations);
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
        [OPT,msize,nsize] = EHY_getmodeldata_mn_index(OPT,inputFile);
        dims(dimsInd.m).index    = OPT.m;
        dims(dimsInd.m).indexOut = 1:length(OPT.m);
        dims(dimsInd.m).size     = msize;
        dims(dimsInd.n).index    = OPT.n;
        dims(dimsInd.n).indexOut = 1:length(OPT.n);
        dims(dimsInd.n).size     = nsize;
    end
    
    %% Get sediment fractions information
    if ~isempty(dimsInd.sedfrac)
        sedfracName = squeeze(vs_let(vs_use(inputFile,'quiet'),'map-const','NAMSED','quiet'));
        if size(sedfracName,1) > 1 && (isempty(OPT.sedimentName) || size(OPT.sedimentName,1) > 1 )
%             warning('Using multiple (all) sediment fractions.');
            dims(dimsInd.sedfrac).index    = 1:size(sedfracName,1);
            dims(dimsInd.sedfrac).indexOut = 1:size(sedfracName,1);
        else
            b = blanks(20-length(OPT.sedimentName));
            dims(dimsInd.sedfrac).index    = find(all(ismember(sedfracName,[OPT.sedimentName b]),2));
            dims(dimsInd.sedfrac).indexOut = find(all(ismember(sedfracName,[OPT.sedimentName b]),2));
        end
    end
    
    %%
    % dims.sizeOut
    for iD = 1:length(dims)
        if ~isfield(dims(iD),'sizeOut') || isempty(dims(iD).sizeOut)
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
