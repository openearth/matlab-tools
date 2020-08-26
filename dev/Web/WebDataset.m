%Class to declare the most common WebDataset
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebDataset < handle
    %Public properties
    properties
        Property1;
    end

    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end

    %Private properties
    properties(SetAccess = private)

    end

    %Default constructor
    methods
        function obj = Template(property1)
            if nargin > 0
                obj.Property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.Property1(obj,property1)
            obj.Property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.Property1(obj)
            property1 = obj.Property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %Stactic methods
    methods (Static)
        function subset = addSubsetInformation(subset, dataToLoad)
            %add some extra information to the new subset
            try
                conf = Configuration;

                fields = fieldnames(dataToLoad);
                for k=1:length(fields)
                    varText = dataToLoad.(fields{k});
                    ix = find(strcmp(conf.VARIABLES, varText));
                    if ~isempty(ix)
                        subset.(varText).subsetSelected = dataToLoad.subsetSelected;
                        subset.(varText).type = dataToLoad.subsetType;
                        subset.(varText).subsetName = dataToLoad.subset;
                    end;
                end;
            catch
                sct = lasterror;
                errordlg(['Error to add the subset information. Please check the data.' sct.message]);
                return;
            end;
        end
        
        function subset = generateInterpolationSubset(dataset, options)            
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
                        interp(iArea).name = options.coefficientsNames{iArea};
                    end
                case 'transect'
                    if options.merge
                        % merge all points into 1 transect
                        interp(1).xData = options.coefficients(:,1);
                        interp(1).yData = options.coefficients(:,2);
                        interp(1).name  = options.coefficientsNames{1};
                    else
                        % define different transects
                        for iTrans = 1:size(options.coefficients, 1)
                            interp(iTrans).xData = options.coefficients(iTrans, 1):... %x1
                                options.coefficients(iTrans, 5):... %dx
                                options.coefficients(iTrans, 2);    %x2
                            interp(iTrans).yData = options.coefficients(iTrans, 3):... %y1
                                options.coefficients(iTrans, 6):... %dy
                                options.coefficients(iTrans, 4);    %y2
                            interp(iTrans).name = options.coefficientsNames{iTrans};
                        end
                    end
                case 'point'
                    interp = struct('xData', num2cell(options.coefficients(:,1)), ...
                        'yData', num2cell(options.coefficients(:,2)), ...
                        'name', options.coefficientsNames);
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
                    ind_layers = 1;
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
            
            subset = interp;
        end;
        
        function subset = generateSelectionSubset(dataset, options)
            %return the subset
            sizeOptions = size(options);
            subset = struct;
            flag2d = 1;
            for i=1:sizeOptions(2)
                variable = options(i).xVar;
                data = dataset.(variable).data;

                options(i) = Util.setDefault(options(i),'useMinValue',0);

                %use the limit of dataset
                if options(i).useMinValue == 1
                    if options(i).isIndex
                        if ~isempty(options(i).start)
                            options(i).start = str2double(options(i).start);
                        else
                            options(i).start = 1;
                        end
                    else
                        options(i).start = min(data);
                    end

                else
                    if strcmpi(variable, 'Time')
                        options(i).start = datenum(options(i).start);
                    elseif isa(options(i).start, 'char')
                        options(i).start = str2num(options(i).start);
                    end;
                end;

                options(i) = Util.setDefault(options(i),'useMaxValue',0);

                %use the limit of dataset
                if options(i).useMaxValue == 1
                    if options(i).isIndex
                        if ~isempty(options(i).end)
                            options(i).end = str2double(options(i).end);
                        else
                            options(i).end = length(data);
                        end
                    else
                        options(i).end = max(data(:));
                    end
                else
                    if strcmpi(variable, 'Time')
                        options(i).end = datenum(options(i).end);
                    elseif isa(options(i).end, 'char')
                        options(i).end = str2num(options(i).end);

                        if options(i).isIndex
                            if ~isempty(options(i).end)
                                options(i).end = str2double(options(i).end);
                            else
                                options(i).end = length(data);
                            end
                        else
                            options(i).end = max(data(:));
                        end
                    end;
                end;

                % TODO: time interval

                %if the selected value is time, transform the time to
                %matlab format
                if strcmpi(variable, 'Time')
                    timeStamp = Time.timeStamp(options(i),options(i).interval);
                    if options(i).isLoop
                        timeStampLoop = Time.timeStamp(options(i),options(i).loopInterval);
                    end
                    %% TODO: put invariable

                    %[subset.indexStart,subset.indexEnd] = Util.getIndexOneD(data,timeStamp);
                    %dataset.(variable).data = timeStamp;
                    subset.(variable).type  = options(i).subsetType;
                else
                    subset.(variable).type  = 'value';
                end;

                options(i) = Util.setDefault(options(i),'interval',1);
                options(i) = Util.setDefault(options(i),'isLoop',0);
                options(i) = Util.setDefault(options(i),'reduceDim',0);

                if options(i).isLoop == 1 && options(i).reduceDim == 1
                    % subset.indexPoint = (options(i).start:options(i).interval:options(i).end)';
                    % subset.dimIndexPoint = {variable};
                    options(i) = Util.setDefault(options(i),'loopInterval',1);
                    % loopInterval = options(i).loopInterval;
                    % flag2d = 0;
                end;
                if options(i).isLoop == 1
                    varToLoop = variable;
                    % options(i) = Util.setDefault(options(i),'loopLimit',1);
                    % loopLimit = options(i).loopLimit;
                end;
                if options(i).reduceDim == 1
                    varReduce = variable;
                end;
                %
                % variables{i} = variable;
            end;

            subset.indexPoint    = [];
            subset.dimIndexPoint = {};

            % loop over all dimensions
            nrIndexVec   = 1;
            nrIndexPoint = 1;

            nrDim = length(options);

            % copy data if necessary for two-dimensional processing
            if nrDim >= 2
                theVar = options(1).xVar;
                x1     = dataset.(theVar).data;

                theVar = options(2).xVar;
                y1     = dataset.(theVar).data;

                [x,y]  = Util.alwaysRepeatData(x1,y1');

                dataset.(options(1).xVar).data = x;
                dataset.(options(2).xVar).data = y;
            end;

            % extract 1d projection
            % if nrDim >= 2
            %     theVar = options(1).xVar;
            %     x      = dataset.(theVar).data(1,:);
            %     theVar = options(2).xVar;
            %     y      = dataset.(theVar).data(:,1);
            % end;

            % TODO: Note that it is assumed that 3d and 4d processing is done by doing combined 1d and 2d operations

            % loop over all dimensions
            for iOpt=1:nrDim
                %get variable name values and dimension
                theVar = options(iOpt).xVar;

                %check if the data has dim field.
                if ~isfield(dataset.(theVar), 'dim')
                    %assing a dim by default
                    dataset.(theVar).dim = {'I'};

                    % errordlg('The Selected Variable does not have the field Dim. Please, be sure your data has the right format.');
                    % return;
                end;

                theDim = dataset.(theVar).dim;
                if nrDim ==2
                    if iOpt==1
                        varData = x1;
                    else
                        varData = y1;
                    end;
                else
                    varData = dataset.(theVar).data;
                end

                % get size in direction of interest
                nrData = size(varData,iOpt);

                % set options for those directions where the dimension is reduced
                if options(iOpt).reduceDim
                    % select multiple data if there is a loop
                    if options(iOpt).isLoop
                        region = (options(iOpt).start:options(iOpt).loopInterval:options(iOpt).end)';
                    else
                        region = options(iOpt).start;
                    end

                    % look up index for coordinates
                    if options(iOpt).isCoordinate
                        if strcmpi(theVar,'Time')
                            if options(iOpt).isLoop
                                region = Time.timeStamp(options(iOpt),options(iOpt).loopInterval);
                            else
                                % start and end time the same to get only on evalue
                                myOptions     = options(iOpt);
                                myOptions.end = myOptions.start;
                                region        = Time.timeStamp(myOptions,1);
                            end
                        end
                        index = Util.getIndexOneD(varData,region);
                        if isnan(index(end))
                            index(end) = length(varData);
                        end
                    else
                        index = region;
                    end;

                    % add data to datastructure for subset scripts
                    subset.dimIndexPoint{nrIndexPoint} = theDim;
                    subset.indexPoint{nrIndexPoint}    = index;

                    nrIndexPoint = nrIndexPoint + 1;

                    if options(iOpt).isLoop
                        subset.(varToLoop).value = region;
                    end
                else
                    % set options for dimensions where multiple data are selected
                    if options(iOpt).isLoop
                        if strcmpi(theVar,'Time')
                            myOption   = options(iOpt);
                            loopRegion = Time.timeStamp(myOption,options(iOpt).loopInterval);
                        else
                            loopRegion = (options(iOpt).start:options(iOpt).loopInterval:options(iOpt).end)';
                        end

                        %define loop
                        if options(iOpt).isCoordinate
                            if totalFiles > 1
                                %if the user select a folder,
                                %generate subset per file
                                loopRegion = [loopRegion(1) loopRegion(end)];
                            end;

                            nrLoop = length(loopRegion)-1;
                            % preallocate structure
                            group(nrLoop).indexVec = {};
                            subset.group = group;
                            for j = 1:nrLoop
                                % look up coordinates
                                region = [loopRegion(j),loopRegion(j+1)];
                                index  = Util.getIndexOneD(varData,region);
                                if isnan(index(end))
                                    index(end) = length(varData);
                                end
                                % make series
                                index = index(1):options(iOpt).interval:index(end);

                                % add data to data structure (including overlap, which is only needed to the left, it is automatically there on the right)
                                if index(1)>1
                                    index = [index(1)-1,index]';
                                end;
                                subset.group(j).indexVec{nrIndexVec} = index;
                            end

                        else
                            % add data to data structure
                            for j = 1:length(loopRegion)-1
                                % add overlap
                                start = max(loopRegion(j)-1,1);
                                stop  = min(loopRegion(j+1)+1,nrData);

                                subset.group(j).indexVec{nrIndexVec} = start:options(iOpt).interval:stop;
                            end
                        end

                        subset.(varToLoop).value = loopRegion;
                    else
                        % no loops occur over this dimensions (i.e. only one subset)
                        if options(iOpt).isCoordinate

                            % look up coordinates
                            region   = [options(iOpt).start,options(iOpt).end];
                            indexBin = Util.getIndexOneD(varData,region);
                            index    = indexBin(1):options(iOpt).interval:indexBin(end);

                            % add overlap
                            if index(1)>1
                                index = [index(1)-1;index];
                            end;
                        else
                            % add overlap
                            start = min(options(iOpt).start-1,1);
                            stop  = max(options(iOpt).end+1,nrData);
                            index = (start:options(iOpt).interval:stop)';
                        end;
                        % add data to data structure
                        nrGroup = length(subset.group);
                        for iGroup = 1:nrGroup
                            subset.group(iGroup).indexVec{nrIndexVec} = index;
                        end;
                    end
                    % add data to data structure
                    subset.dimIndexVec{nrIndexVec} = theDim;
                    nrIndexVec = nrIndexVec + 1;
                end
            end

        end;

        function generateSubset(options)
            %generate subsets from the user options.
            %Output: save the new subsets in a temporal folder
            %options(1).file = 'C:\xampp\htdocs\codigoselecto\imdc_final\matlab_system\matlab\example data\testLongTermData.mat';
            %options(1).xVar = 'Time';
            %options(1).start = [2006 09 01 0 0 0];
            %options(1).end = [2006 09 06 0 0 0];
            %options(1).outputFolder = 'C:\Users\sebastian\Desktop\temp\generated_subsets';
            %options(1).subsetName = 'first_subdataset';
            %options(1).subsetType = 'daily';
            %options(1).interval = 1;
            %
            %options(2).file = 'C:\xampp\htdocs\codigoselecto\imdc_final\matlab_system\matlab\example data\testLongTermData.mat';
            %options(2).xVar = 'Time';
            %options(2).start = [2006 09 01 0 0 0];
            %options(2).end = [2006 09 16 0 0 0];
            %options(2).outputFolder = 'C:\Users\sebastian\Desktop\temp\generated_subsets';
            %options(2).subsetName = 'second_dataseet';
            %options(2).subsetType = 'weekly';
            %options(2).interval = 1;
            try
                options(1) = Util.setDefault(options(1),'filesSelected','');
                if ~isempty(options(1).filesSelected)
                    selectedFiles = regexp(options(1).filesSelected,';','split');
                end;

                %if totalFiles > 1 the selection change. the script generate 1
                %subset per file
                totalFiles = length(selectedFiles);

                %loop over all files selected.
                for kk=1:totalFiles
                    if isdir(options(1).file)
                        fileToProcess = selectedFiles{kk};
                    else
                        fileToProcess = options(1).file;
                    end;

                    dataset = '';

                    [dataset loadOk] = Dataset.loadData(fileToProcess, false);
                    if ~loadOk
                        errordlg('Error to read the source file. Please verify the format.');
                        return;
                    end;
                    
                    %choose selection or interpolation.
                    switch options(1).dataType
                        case 'selection'
                            %get the subset if the user wants selection.
                            subset = WebDataset.generateSelectionSubset(dataset, options);
                        case 'interpolation'
                            %get the subset if the user wants interpolation.
                            subset = WebDataset.generateInterpolationSubset(dataset, options);
                    end;
                    
                    JJJ = 1;
                    dataOut = WebDataset.getData(dataset.(varToLoop),subset, JJJ);

                    xVar = varToLoop;

                    %From here to the end of this function is for save the subset
                    if isfield(options(1), 'subsetName') && ~isempty(options(1).subsetName)
                        subsetName = [options(1).subsetName '_' options(1).subsetType];
                    else
                        subsetName = [options(1).subsetType '_temp_subset'];
                    end;

                    if ispc()
                        conf = Configuration;
                        tempFolder = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER];
                        if exist(tempFolder) ~= 7
                            mkdir([conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER]);
                        end;

                        %Name of subset
                        pathToSave = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER '\'];
                        subsetDate = num2str(now);

                        %replace the patterns in the file name
                        shortSubsetName = DynamicText.replaceBasicPatterns(subsetName, '', kk);
                        if isa(shortSubsetName, 'cell')
                            subsetName = shortSubsetName{1};
                        else
                            subsetName = shortSubsetName;
                        end;

                        nameSubset = [pathToSave subsetName '_' subsetDate];
                        subsetInfo.(xVar).name = nameSubset;
                        subsetInfo.(xVar).dateSubset = subsetDate;
                        %subsetInfo.(xVar).lengthSubset = length(subset.(xVar).indexStart);

                        subsetInfo.(xVar).lengthSubset = length(subset.(xVar).value) - 1;

                        subsetInfo.(xVar).referenceName = {};
                        for nrSubsets = 1:length(subset.(xVar).value)-1
                            if strcmp(xVar, 'Time')
                                subsetInfo.(xVar).referenceName{nrSubsets} = datestr(subset.(xVar).value(nrSubsets));
                            else
                                subsetInfo.(xVar).referenceName{nrSubsets} = subset.(xVar).value(nrSubsets);
                            end
                        end;

                        subsetInfo.(xVar).type = options(kk).subsetType;

                        %Indexes file to match dataset and subset
                        [datasetInfo.path, datasetInfo.name, datasetInfo.ext] = fileparts(fileToProcess);
                        nameIndexFile = [pathToSave conf.FILE_NAME_IDX_DS '_' options(1).subsetType '_' subsetName '_' subsetDate];
                    elseif isunix()
                        pathToSave = '/temp/';
                        nameSubset = [pathToSave subsetName '_' subsetDate];
                    end;

                    save([nameIndexFile '.mat'], 'datasetInfo', 'subsetInfo');
                    save([nameSubset '.mat'], 'subset');

                end;
            catch
                sct = lasterror;
                errordlg(['Error to generate the subset. ' sct.message]);

                return;
            end;
        end;

        function dataOut = getData(variable,subset, JJJ)
            % select a subset of data

            % Todo: loop over files
            % Todo : loop over all time steps in a model

            % todo: advanced selection such as  interpolation (matrix-vector product)
            % todo: advanced contraction such as depth-averaging

            % area quadrilateral (for interpolation on curvilinear grid)

            % way to make indexes
            % 1.) - start-interval-end
            % 2.) list of points/planes

            % input: a variable in INDC format (variable
            % a definition of a subset: wioth the following fields
            %
            % One must define either: start and end coordinates
            %--------------------------------------------------
            % subset.indexStart(JJJ,nrDim): start of a vector
            % subset.indexStride(JJJ,nrDim): interval of the vector (default is one)
            % subset.indexEnd(JJJ,nrDim): end of the vector
            %
            % Or a groud (more general)
            %--------------------------------------------------
            % subset.group(JJJ).indexVec{nrDim}: a cell array with for each
            % non-singleton dimension a column vector of the wanted points
            %----------------------------------------
            % additionally one may need to define points (if the selected data has a
            % lower dimension than the original
            % subset.indexPoint(nrDim):
            %----------------------------------------
            %Finally one defines the dimensions to which dimensions the points and
            %vector refer
            % subset.dimIndexVec{nrDim}: a cell array with the name of the dimension to
            % which the indexvvector refers
            % subset.dimIndexPoint{nrDim}: a cell array with the name of the dimensiosn
            % of the points
            %-----------------------------------------------
            % JJJ: the number of the instance of the subset that is used.
            %
            %Written by ABR
            %12-6-2013

            % make indexVec from start and end points if necessary
            if isfield(subset,'indexStart')
                nrVecDim = size(subset.indexStart,2);
                indexVec = cell(1,nrVecDim);
                for j = 1:nrVecDim
                    if isfield(subset,'indexStride')
                        indexVec{j} = subset.indexStart(JJJ,j):subset.indexStride(JJJ,j):subset.indexEnd(JJJ,j);
                    else
                        indexVec{j} = subset.indexStart(JJJ,j):subset.indexEnd(JJJ,j);
                    end;
                end;
            else
                % select the right set out of the cell array
                if isfield(subset,'group')
                    indexVec = subset.group(JJJ).indexVec;
                else
                    indexVec = {};
                end;

            end;


            % process  the point data
            if isfield(subset,'indexPoint')
                indexPoint = subset.indexPoint;   % matrix of points in subset (MxN)
            else
                indexPoint = [];
            end;

            % get sizes
            nrIndexVec = length(indexVec);
            nrIndexPoints = size(indexPoint,2);

            % check that the indexes are right
            nrData = size(variable.data);

            if sum(nrData>1) ~= nrIndexVec+nrIndexPoints
                error('The number of dimensions of the data does not match the subsets');
            end;

            % determine the size of the data
            nrDim = [1 cumprod(nrData(1:end-1))];

            % preallocate data
            index = 1;
            nrDimOut = zeros(1,nrIndexVec);

            % TODO: treat a list of point togethre (in case indexvec is a cell of
            % matrixces, rather than vectors

            % calculate linear index vector

            for i = 1:nrIndexVec
                % look for matching dimension
                if ~isfield(variable, 'dim')
                    variable.dim = subset.dimIndexVec{1};
                end;
                dimIndexVec = i;%strcmpi(subset.dimIndexVec{i},variable.dim);
                indexVecPerDim = indexVec{i}; %indexVecPerDim = indexVec{dimIndexVec};
                % make sure it is a column vector
                if size(indexVecPerDim,2)>size(indexVecPerDim,1)
                    indexVecPerDim = indexVecPerDim';
                end
                nrDimOut(i) = length(indexVecPerDim);

                % duplicate existing index for to make place for new data
                index = repmat(index,nrDimOut(i),1);

                % duplicate existing index for to make place for new data
                nrRepMat = cumprod([1 nrDimOut(1:i-1)]);
                nrRepMat = nrRepMat(i);
                newIndex = (indexVecPerDim'-1).*nrDim(dimIndexVec);
                indexExtra = repmat(newIndex,nrRepMat,1);
                indexExtra = indexExtra(:);

                % calculate index
                index = index + indexExtra;
            end;

            % add the linear index from the points
            for i = 1:nrIndexPoints
                dimIndexPoint = strcmpi(subset.dimIndexPoint{i},variable.dim);
                if isa(indexPoint, 'cell')
                    index = index + (indexPoint{JJJ,i}-1).*nrDim(dimIndexPoint);
                else
                    index = index + (indexPoint(JJJ,i)-1).*nrDim(dimIndexPoint);
                end
            end;

            % get the data
            dataVec = variable.data(:);
            mask = ~isnan(index);
            dataOut = nan(size(index));
            if isa(dataVec, 'cell')
                dataOut = repmat({''}, size(index,1), size(index,2));
            end
            dataOut(mask) = dataVec(index(mask));

            % transform to desired shape
            if isscalar(nrDimOut)
                nrDimOut = [nrDimOut 1];
            end;

            if ~isempty(nrDimOut)
                dataOut = reshape(dataOut,nrDimOut);
            end;

        end;

        function subsets = getSubsetFromDataset(datasetFile)
            %return all the subsets of one dataset.
            %Input: dataset path
            try
                subsets = [];
                conf = Configuration;
                tempFolder = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER];
                if exist(tempFolder) == 7
                    listFiles = dir(tempFolder);
                    nrFiles = size(listFiles);
                    i = 1;
                    j = 1;
                    invalidCharacters = {'.', '..'};
                    subsets = '';
                    while i < nrFiles(1)
                        if any(strcmp(listFiles(i).name, invalidCharacters))
                            i = i + 1;
                            continue;
                        end;
                        if regexp(listFiles(i).name, ['^' conf.FILE_NAME_IDX_DS])
                            load([tempFolder '\' listFiles(i).name]);
                            datasetInfo.path = strrep(datasetInfo.path,'\','/');
                            datasetFile = strrep(datasetFile,'\','/');
                            [datasetPath, datasetName, datasetExt] = fileparts(datasetFile);
                            if strcmp(datasetInfo.name,datasetName) && strcmp(datasetInfo.path,datasetPath) && strcmp(datasetInfo.ext,datasetExt)
                                varLoop = fieldnames(subsetInfo);
                                varLoop = varLoop{1};
                                subsetName = [subsetInfo.(varLoop).name '.mat'];
                                subsets(j).subsetName = subsetName;
                                subsets(j).lengthSubset = subsetInfo.(varLoop).lengthSubset - 1;
                                subsets(j).type = subsetInfo.(varLoop).type;
                                subsets(j).referenceName = subsetInfo.(varLoop).referenceName;
                                j = j + 1;
                            end;
                        end;
                        i = i + 1;
                    end;
                end;
            catch
                sct = lasterror;

                errordlg(sct.message);
                return;
            end;

        end;

        function varName = getVarSubsetDivision(subset)
            %Return the variable division in the subset
            fieldsSubset = fieldnames(subset);
            varName = '';
            for i=1:length(fieldsSubset)
                field = fieldsSubset{i};
                if isfield(subset.(field), 'value')
                    varName = field;
                end;
            end;

            if isempty(varName)
                errordlg('Error in the subset file');
                return;
            end;
        end;

        function [dataset loadOk] = loadModelData(sourceInfo, currentTimeStep)
            %Load a model Data in IMDC dataset structure
            %Input: sourceInfo: structure with
            %           sourcePath: ''
            %           sourceType: 'model'
            %           modelType: [1x0 char]
            %           startDate: [1x0 char]
            %           selectedVars: [1x0 char]

            if nargin < 2
                currentTimeStep = 1;
            end;

            dataset = struct;
            loadOk = false;

            %save a temporaly file with the model header
            conf = Configuration;
            tempFolder = fullfile([conf.TEMP_FOLDER conf.TEMP_DATASET_FOLDER]);

            [~, modelFileName, ~] = fileparts(sourceInfo.sourcePath);
            pathModelDataset = fullfile([tempFolder '\' modelFileName '.mat']);

            modelOptions = struct;
            %if the user select some variables / else
            %all the variables will be included
            if ~isempty(sourceInfo.selectedVars)
                selectedVars = regexp(sourceInfo.selectedVars,',','split');
                modelOptions.varNames = selectedVars;
            end;

            try
                switch lower(sourceInfo.modelType)
                    case 'delft3d'
                        if exist(pathModelDataset, 'file')
                            load(pathModelDataset);
                        else
                            %if the temp file does not exist read the header again.
                            [dataset,outDelftStruct] = Delft3D.readDelftHeader(sourceInfo.sourcePath, modelOptions);
                        end;
                        sctOptions.start = currentTimeStep;
                        dataset = Delft3D.readDelftData(dataset,outDelftStruct,sctOptions);
                    case 'telemac'
                        %needs read every time the header to update the fid
                        %if the temp file does not exist read the header again.
                        [dataset,outTelemacStruct,varNames] = Telemac.readTelemacHeader(sourceInfo.sourcePath, modelOptions);

                        modelOptions.start = currentTimeStep;
                        dataset = Telemac.readTelemacData(dataset,outTelemacStruct,varNames,modelOptions);

                end;
            catch
                return;
            end

            loadOk = true;
        end;

        function variableOperations(from, to, coordinate, variable, options)
            %Copy, Move and interpolate variable from one dataset to other
            %Inputs: from: dataset origen
            %        to: dataset destiny
            %        coordinate: x,y,z,s or t
            %        variable
            %        options: struct with
            %                   mode: copy, move, interpolate
            %                   interval: interpolation threshold
            %                   method: interpolation method

            if isempty(from) || isempty(to)
                errordlg('Error. You have to set the source and destination file.');
                return;
            end;

            options = Util.setDefault(options,'mode','');
            if isempty(options.mode)
                errordlg('Error. you have to select the mode to apply: copy, move or interpolate');
                return;
            end;

            if isempty(variable)
                errordlg('Error. You have to indicate the variable to copy.');
                return;
            end;

            if isdir(from)
                errordlg('Error. You have to select a file in the origin source');
                return;
            end;

            [fromData, loadOk] = Dataset.loadData(from,0);

            if ~loadOk
                errordlg('Error to read the source file. Please verify the format.');
                return;
            end;
            isDir = 0;
            if isdir(to)
                files = dir(to);
                if ~strcmp(to(end), '\')
                    to = [to '\'];
                    originalDestination = to;
                end;
                isDir = 1;
            else
                files(1).name = to;
            end;

            invalidCharacters = {'.', '..'};
            for ii=1:length(files)
                if any(strcmp(files(ii).name, invalidCharacters))
                    continue;
                end;
                if ~isdir(files(ii).name)
                    [toData, loadOk] = Dataset.loadData(files(ii).name,0);
                    if ~loadOk
                        errordlg('Error to read the destination file. Please verify the format.');
                        return;
                    end;

                    if ~isfield(fromData, coordinate) || ~isfield(toData, coordinate)
                        errordlg('Error. The selected coordinate does not exist in the files.');
                        return;
                    end;

                    if isfield(fromData, variable)
                        dataY = fromData.(variable).data;
                    else
                        errordlg('Error. The selected variable does not exist in the file.');
                        return;
                    end;

                    if isfield(options, 'interval')
                        if ~isempty(options.interval)
                            options.threshold = options.interval;
                        end;
                    end;

                    %interpolate data
                    options = Util.setDefault(options,'method','linear');
                    yi = Interpolate.interpThreshold(fromData.(coordinate).data,dataY,toData.(coordinate).data,options);

                    fields = fieldnames(fromData.(variable));
                    for i=1:length(fields)
                        field = fields{i};
                        if ~strcmp(field, 'data')
                            toData.(variable).(field) = fromData.(variable).(field);
                        end;
                    end;
                    toData.(variable).data = yi;

                    if isDir
                        to = [originalDestination files(ii).name];
                    end;

                    %copy, move, interpolate
                    switch options.mode
                        case 'copy'
                            saveOk = Dataset.saveData(toData,to);
                        case 'move'
                            %remove the var from the original dataset.
                            fromData = rmfield(fromData, variable);

                            %Save the finals datasets.
                            saveOk = Dataset.saveData(fromData,from);
                            saveOk = Dataset.saveData(toData,to);

                        case 'interpolate'
                            saveOk = Dataset.saveData(toData,to);
                        otherwise
                            errordlg('Error. The selected option is not valid');
                            return;
                    end;

                    if ~saveOk
                        errordlg('Error. The file could not been saved');
                        return;
                    end;

                end;
            end;
        end;

    end
end