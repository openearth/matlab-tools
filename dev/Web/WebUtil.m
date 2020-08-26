%Class to declare the most common WebUtil
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebUtil < handle
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
        function filesName = getFileNamesInFolder(myPath)
            filesName = {};
            invalidCharacters = {'.', '..'};
            contentFolder = dir(myPath);
            cont = 1;
            for i=1:length(contentFolder)
                if any(strcmp(contentFolder(i).name, invalidCharacters))
                    continue;
                end;
                if contentFolder(i).isdir == 0
                    filesName{cont} = contentFolder(i).name;
                    cont = cont + 1;
                end;
            end;
            [filesName,index] = sort_nat(filesName, 'descend');
        end

        function cols = getOriginalColName(cols)
            %Remove the unit text from the columns in the files.

            for i=1:length(cols)
                indexChar = find(cols{i} == '[');
                cols{i}(indexChar:end) = '';
                cols{i} = strtrim(cols{i});
            end;
        end;

        function outputJson  = getSourceDataInformation(inputJson)
            %This function get all the information about the source file
            %selected. The selected input can be a file, folder or model
            %Input: Json string from Web.
            %Output: Json string with all the dataset information

            try
                outputJson = '';
                if isempty(inputJson)
                    errordlg('You need to select a source');
                    return;
                end;

                elements = loadjson(inputJson);
                if isa(elements, 'cell')
                    inputData = elements{1,1};
                else
                    inputData = elements;
                end

                if ~isfield(inputData, 'sourceType') || ~isfield(inputData, 'sourcePath')
                    errordlg('An error was ocurred. Please check your source selection');
                    return;
                end;

                switch lower(inputData.sourceType)
                    case 'folder'
                        if ~isdir(inputData.sourcePath)
                            errordlg('An error was ocurred. Please check your source selection');
                            return;
                        end

                        allData = struct;
                        fileErrors = '';
                        folderInfo = dir(inputData.sourcePath);
                        cont = 1;
                        for i=1:numel(folderInfo)
                            currentFileName = folderInfo(i).name;

                            %skip all the folders and no valid names
                            if any(strcmp(currentFileName, {'.', '..'})) || folderInfo(i).isdir
                                continue;
                            end

                            %skip all the files with different extension
                            [~,~,ext] = fileparts(currentFileName);
                            if ~strcmpi(ext, '.mat')
                                continue;
                            end;

                            %load the dataset ->just the metadata
                            [dataset, loadOk] = Dataset.loadData(fullfile(inputData.sourcePath,currentFileName),true);

                            %if there is an error in one of the files,
                            %store its name
                            if ~loadOk
                                fileErrors = [fileErrors ' ' currentFileName];
                                continue;
                            end;

                            myFile = strcat('file', num2str(cont));

                            %Add the subsets of dataset
                            subsets = WebDataset.getSubsetFromDataset(fullfile(inputData.sourcePath,currentFileName));

                            %get the variables/metadata
                            [variables metadata] = Dataset.getDatasetInfo(dataset);

                            %add the filepath and name info
                            files.path = fullfile(inputData.sourcePath,currentFileName);
                            files.name = currentFileName;

                            %add the current dataset into a struct
                            allData.(myFile).variables = variables;
                            allData.(myFile).metadata  = metadata;
                            allData.(myFile).subsets   = subsets;
                            allData.(myFile).files     = files;

                            %number of the right files
                            cont = cont + 1;
                        end;

                        %display the files with errors
                        if ~isempty(fileErrors)
                            errordlg(['An error was occured trying to read the following files: ' fileErrors]);
                        end;

                    case 'file'
                        %check if the file exist.
                        if ~exist(inputData.sourcePath, 'file')
                            errordlg('An error was ocurred. Please check your source selection');
                            return;
                        end

                        %check if the selected file has the rigth extension
                        [~,~,ext] = fileparts(inputData.sourcePath);
                        if ~strcmpi(ext, '.mat')
                            errordlg('An error was ocurred. You need to select a .mat file');
                            return;
                        end;

                        %load the dataset ->just the metadata
                        [dataset, loadOk] = Dataset.loadData(inputData.sourcePath,true);

                        %if there is an error reading the file
                        if ~loadOk
                            errordlg(['An error was occured trying to read the file: ' inputData.sourcePath]);
                            return;
                        end;

                        %get the variables/metadata
                        [variables metadata] = Dataset.getDatasetInfo(dataset);

                        %add the current dataset into a struct
                        myData.variables = variables;
                        myData.metadata  = metadata;

                        %Add the subsets of dataset
                        subsets = WebDataset.getSubsetFromDataset(inputData.sourcePath);
                        myData.subsets = subsets;

                        %add the filepath and name info

                        [~,currentFileName,ext] = fileparts(inputData.sourcePath);
                        files.path = inputData.sourcePath;
                        files.name = [currentFileName ext];

                        myData.files = files;

                        %add the current dataset into a struct
                        allData.file1 = myData;

                    case 'model'
                        %check if the file exist.
                        if ~exist(inputData.sourcePath, 'file')
                            errordlg('An error was ocurred. Please check your source selection');
                            return;
                        end

                        %save a temporaly file with the model header
                        conf = Configuration;
                        tempFolder = fullfile([conf.TEMP_FOLDER conf.TEMP_DATASET_FOLDER]);
                        if exist(tempFolder, 'dir')
                            mkdir(tempFolder);
                        end;

                        [~, modelFileName, ~] = fileparts(inputData.sourcePath);
                        pathModelDataset = fullfile([tempFolder '\' modelFileName '.mat']);

                        %get info about the model header dataset
                        infoModelDataset = dir(pathModelDataset);

                        %get info about the source model file
                        infoSourceModel = dir(inputData.sourcePath);

                        %select the right model
                        switch lower(inputData.modelType)
                            case 'delft3d'
                                modelOptions = struct;
                                %if the user select some variables / else
                                %all the variables will be included
                                if ~isempty(inputData.selectedVars)
                                    selectedVars = regexp(inputData.selectedVars,',','split');
                                    modelOptions.varNames = selectedVars;
                                end;

                                if isempty(infoModelDataset)
                                    %read the header of the model
                                    [dataset,outDelftStruct] = Delft3D.readDelftHeader(inputData.sourcePath, modelOptions);

                                    %save the header dataset
                                    save(pathModelDataset, 'dataset', 'outDelftStruct');
                                else
                                    %compare if the source file has been
                                    %update
                                    if infoSourceModel.datenum > infoModelDataset.datenum
                                        [dataset,outDelftStruct] = Delft3D.readDelftHeader(inputData.sourcePath, modelOptions);

                                        %save the header dataset
                                        save(pathModelDataset, 'dataset', 'outDelftStruct');
                                    else
                                        %load the saved header
                                        load(pathModelDataset);
                                    end
                                end;

                                %return the model header in the output sct

                                %allData.modelDataset = dataset;
                                %allData.sctStruct    = outDelftStruct;

                            case 'telemac'
                                modelOptions = struct;
                                if isempty(infoModelDataset)
                                    %read the header of the model
                                    [dataset,outTelemacStruct,varNames] = Telemac.readTelemacHeader(inputData.sourcePath, modelOptions);

                                    %save the header dataset
                                    save(pathModelDataset, 'dataset', 'outTelemacStruct', 'varNames');
                                else
                                    %compare if the source file has been
                                    %update
                                    if infoSourceModel.datenum > infoModelDataset.datenum
                                        [dataset,outTelemacStruct,varNames] = Telemac.readTelemacHeader(inputData.sourcePath, modelOptions);

                                        %save the header dataset
                                        save(pathModelDataset, 'dataset', 'outTelemacStruct', 'varNames');
                                    else
                                        %load the saved header
                                        load(pathModelDataset);
                                    end
                                end;

                                %return the model header in the output sct

                                %allData.modelDataset = dataset;
                                %allData.sctStruct    = outTelemacStruct;
                                allData.varNames     = varNames;
                                
                                %add the other variables to the dataset
                                for jj=1:numel(varNames)
                                    if isempty(varNames{jj})
                                        continue;
                                    end
                                    
                                    if ~isfield(dataset, varNames{jj})
                                        dataset.(varNames{jj}).data = [];
                                    end;
                                end;
                        end;

                        %The files will be the number of times in
                        %the model. to improve the performance I
                        %only send the total of time steps
                        if isfield(dataset.Time, 'data')
                            totalTimeSteps = numel(dataset.Time.data);

                            files.name = num2str(totalTimeSteps);
                        else
                            totalTimeSteps = 1;
                        end;

                        [variables metadata] = Dataset.getDatasetInfo(dataset);
                        %add the current dataset into a struct
                        myData.variables = variables;
                        myData.metadata  = metadata;

                        %add the filepath and name info
                        files.path = fullfile(inputData.sourcePath);
                        [~, name , ~] = fileparts(files.path);
                        files.name = name;

                        myData.files = files;

                        %TODO: VERIFY THE SUBSETS IN THE MODELS
                        myData.subsets = totalTimeSteps;

                        %add the current dataset into a struct
                        allData.file1 = myData;

                end;

                %convert the big structure into json
                outputJson = savejson(allData);

            catch
                errordlg('An error was ocurred. Please check your source selection');
                return;
            end;

        end;

    end
end