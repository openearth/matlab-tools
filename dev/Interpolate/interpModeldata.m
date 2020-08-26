function interpModeldata(dataset, options)

%% CHECK INTERPOLATION TYPE
interp = struct([]);
switch lower(options.interpType)
    case 'area'
        % create interpolation areas
        for iArea = 1:size(options.coefficients, 1)
            xData = options.coefficients(iArea, 1):... %x1
                    options.coefficients(iArea, 5):... %dx
                    options.coefficients(iArea, 2);    %x2
            yData = options.coefficients(iArea, 3):... %y1
                    options.coefficients(iArea, 6):... %dy
                    options.coefficients(iArea, 4);    %y2
            
            % generated area
            [interp(iArea).xData, interp(iArea).yData] = meshgrid(xData, yData);
            interp(iArea).name = options.names{iArea};
        end
    case 'transect'
        if options.merge
            % merge all points into 1 transect
            interp(1).xData = options.coefficients(:,1);
            interp(1).yData = options.coefficients(:,2);
            interp(1).name = options.name{1};
        else
            % define different transects
            for iTrans = 1:size(options.coefficients, 1)
            	interp(iTrans).xData = options.coefficients(iTrans, 1):... %x1
                                       options.coefficients(iTrans, 5):... %dx
                                       options.coefficients(iTrans, 2);    %x2
                interp(iTrans).yData = options.coefficients(iTrans, 3):... %y1
                                       options.coefficients(iTrans, 6):... %dy
                                       options.coefficients(iTrans, 4);    %y2
                interp(iTrans).name = options.names{iTrans};
            end
        end
    case 'point'
        interp = struct('xData', num2cell(options.coefficients(:,1)), ...
                        'yData', num2cell(options.coefficients(:,2)), ...
                        'name', options.name);
    otherwise
        % Incorrect selection
end

%% Perform Interpolation
%%%%%%%%%%%%%%%%
%%%%% TODO %%%%%
%%%%%%%%%%%%%%%%
switch lower(options.step2InterpType)
    case 'interpolation'
        % create a new layer at the new interpolation depth
        
        % select layers for interpolation
        switch lower(options.referenceSystem)
            case 'watlev'
                
            case 'standard'
                
            case 'bed'
                
        end
        zData = dataset.(options.zVar).data(:,:,:,ind_layers);
    case 'selection'
        % Interpolate the selected layers
        
        if ~options.selectAllLayers % select all requested layers
            zData = dataset.(options.zVar).data(:,:,:,options.layer);
        else
            zData = dataset.(options.zVar).data;
        end
    case 'depth average'
        % interpolate the layers in the selected range and create a depth
        % average result
        
        
        % identify layers to be used in for depth average
        ind_layers = dataset.(options.referenceSystem).data >= options.minValue && ... %% OK????
                     dataset.(options.referenceSystem).data <= options.maxValue;
        zData = dataset.(options.zVar).data(:,:,:,ind_layers);
        
end

%% Preprocess interpolation
if isfield(dataset, 'IKLE') % <- field exclusive to triangle grids
    for iInterp = 1:numel(interp)
        sctInterp = Triangle.interpTrianglePrepare(dataset.IKLE.data, ...
            dataset.(options.xVar).data, dataset.(options.yVar).data, ...
            interp(iInterp).xData,interp(iInterp).yData);
                
    end
else
    for iInterp = 1:numel(interp)
        sctInterp(iInterp) = Curvilinear.curvelinInterpPrepare(...
            dataset.(options.xVar).data, dataset.(options.yVar).data, ...
            interp(iInterp).xData,interp(iInterp).yData);
                
    end
end

%% Perform interpolation
if isfield(dataset, 'IKLE')
    
else
    for iInterp = 1:numel(interp)
        interp(iInterp).zData = zeros(size(dataset.(options.zVar).data, 1), size(interp(iInterp).xData, 1), ...
                                      size(interp(iInterp).yData, 2), size(zData, 3)); % T x X x Y x Z
        for iTimestep = 1:size(dataset.(options.zVar).data, 1)
            
            interp(iInterp).zData(iTimestep,:,:,:) = Curvilinear.curvelinInterp(sctInterp(iInterp), ...
                                                     squeeze(zData(iTimestep,:,:,:)));
            
        end
    end
end