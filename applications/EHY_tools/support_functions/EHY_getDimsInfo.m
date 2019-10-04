function dims = EHY_getDimsInfo(inputFile,varName,gridFile)

modelType = EHY_getModelType(inputFile);
[typeOfModelFile, typeOfModelFileDetail] = EHY_getTypeOfModelFile(inputFile);
switch modelType
    case 'dfm'
        infonc          = ncinfo(inputFile,varName);       
        dimsNamesOnFile = {infonc.Dimensions.Name};
        
        %%% change names for easier handling 
        dimsNames = dimsNamesOnFile;
        % layers
        dimsNames = strrep(dimsNames,'laydim','layers');
        dimsNames = strrep(dimsNames,'nmesh2d_layer','layers');
        dimsNames = strrep(dimsNames,'mesh2d_nLayers','layers');
        % faces
        dimsNames = strrep(dimsNames,'nmesh2d_face','faces');
        dimsNames = strrep(dimsNames,'mesh2d_nFaces','faces');
        dimsNames = strrep(dimsNames,'nFlowElem','faces');
        dimsNames = strrep(dimsNames,'nNetElem','faces');
        % stations
        dimsNames = strrep(dimsNames,'cross_section','stations');
        dimsNames = strrep(dimsNames,'general_structures','stations');
        
        %%%
        dimsSizes = infonc.Size;
        for iD=1:length(dimsNames)
            dims(iD).nameOnFile = dimsNamesOnFile{iD};
            dims(iD).name       = dimsNames{iD};
            dims(iD).size       = dimsSizes(iD);
            dims(iD).index      = 1:dims(iD).size;
            dims(iD).indexOut   = 1:dims(iD).size;
        end
        
    case 'd3d'
        
        % time // always ask for time
        dims(1).name = 'time';
        
        % sediment fractions
        trim = vs_use(inputFile,'quiet');
        NAMSEDind = strmatch('NAMSED',{trim.ElmDef.Name});
        if ~isempty(NAMSEDind)
            dims(end+1).name = 'sedimentFraction';
        end
        
        % layers
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if ~isempty(strmatch('sedimentFraction',{dims(:).name,})) || (gridInfo.no_layers > 1 && ~ismember(varName,{'wl','wd','dps','S1'}))
            dims(end+1).name = 'layers';
        end
        
        if strcmp(typeOfModelFileDetail,'trih')
            % stations
            stationNames = EHY_getStationNames(inputFile,modelType,'varName',varName);
            if ~isempty(stationNames)
                dims(end+1).name = 'stations';
            end
        elseif strcmp(typeOfModelFileDetail,'trim')
            % faces/grid cells
            dims(end+1).name = 'm';
            dims(end+1).name = 'n';
        end
                  
    case 'delwaq'
        
        % time // always ask for time
        dims(1).name = 'time';
                
        if strcmp(typeOfModelFileDetail,'his')
            % stations
            stationNames = EHY_getStationNames(inputFile,modelType,'varName',varName);
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
        
    otherwise % SOBEK / SIMONA 
        
        % time // always ask for time
        dims(1).name = 'time';
        
        % layers
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if isfield(gridInfo,'no_layers') && gridInfo.no_layers > 1 && ~ismember(varName,{'wl','wd','dps'})
            dims(end+1).name = 'layers';
        end
        
        % stations
        stationNames = EHY_getStationNames(inputFile,modelType,'varName',varName);
        if ~isempty(stationNames)
             dims(end+1).name = 'stations';
        end

end