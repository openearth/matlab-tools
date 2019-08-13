function dims = EHY_getDimsInfo(inputFile,varName)

modelType = EHY_getModelType(inputFile);
switch modelType
    case 'dfm'
        infonc          = ncinfo(inputFile);
        variablesOnFile = {infonc.Variables.Name};
        nr_var          = strmatch(varName,variablesOnFile,'exact');
        
        dimsNames = {infonc.Variables(nr_var).Dimensions.Name};
        dimsSizes = infonc.Variables(nr_var).Size;
        for iD=1:length(dimsNames)
            dims(iD).name = dimsNames{iD};
            dims(iD).size = dimsSizes(iD);
        end
        
    otherwise
        
        dims=struct;
        modelType = EHY_getModelType(inputFile);
        
        % time // always ask for time
        dims(1).name = 'time';
        
        % laydim
        gridInfo = EHY_getGridInfo(inputFile,{'no_layers'});
        if gridInfo.no_layers > 1
            dims(end+1).name = 'laydim';
        end
        
        % stations
        stationNames = EHY_getStationNames(inputFile,modelType,'varName',varName);
        if ~isempty(stationNames)
             dims(end+1).name = 'stations';
        end

end