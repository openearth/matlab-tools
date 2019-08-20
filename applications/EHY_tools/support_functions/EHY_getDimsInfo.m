function dims = EHY_getDimsInfo(inputFile,varName)

modelType = EHY_getModelType(inputFile);
switch modelType
    case 'dfm'
        infonc          = ncinfo(inputFile);
        variablesOnFile = {infonc.Variables.Name};
        nr_var          = strmatch(varName,variablesOnFile,'exact');
        
        dimsNamesOnFile = {infonc.Variables(nr_var).Dimensions.Name};
        
        %%% change names for easier handling 
        dimsNames = dimsNamesOnFile;
        % layers
        dimsNames = strrep(dimsNames,'laydim','layers');
        dimsNames = strrep(dimsNames,'nmesh2d_layer','layers');
        % faces
        dimsNames = strrep(dimsNames,'nmesh2d_face','faces');
        dimsNames = strrep(dimsNames,'mesh2d_nFaces','faces');
        dimsNames = strrep(dimsNames,'nFlowElem','faces');
        % stations
        dimsNames = strrep(dimsNames,'cross_section','stations');
        dimsNames = strrep(dimsNames,'general_structures','stations');
        
        %%%
        dimsSizes = infonc.Variables(nr_var).Size;
        for iD=1:length(dimsNames)
            dims(iD).nameOnFile = dimsNamesOnFile{iD};
            dims(iD).name       = dimsNames{iD};
            dims(iD).size       = dimsSizes(iD);
        end
        
    otherwise
        
        dims=struct;
        modelType = EHY_getModelType(inputFile);
        
        % time // always ask for time
        dims(1).name = 'time';
        
        % layers
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if gridInfo.no_layers > 1
            dims(end+1).name = 'layers';
        end
        
        % stations
        stationNames = EHY_getStationNames(inputFile,modelType,'varName',varName);
        if ~isempty(stationNames)
             dims(end+1).name = 'stations';
        end

end