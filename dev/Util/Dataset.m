%Class to declare the most common Dataset
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Dataset < handle
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
        function dataset = addFields(dataset, onlyMetadata)
            % add direction magnitude
            % onlyMetadata set true to add just metadata information to the
            % dataset
            % Vel
            % VelDir
            % VelX
            % VelY
            
            % add magnitude and direction
            if isfield(dataset,'VelX') && isfield(dataset,'VelX')
                if onlyMetadata == true
                    % add magnitude
                    dataset = Dataset.addMetaData(dataset,'VelX','Vel','m/s',0,'Velocity magnitude');
                    
                    % add direction
                    dataset = Dataset.addMetaData(dataset,'VelX','VelDir','degrees',1,'Velocity direction');
                else
                    uX = dataset.VelX.data;
                    uY = dataset.VelY.data;
                    
                    % add magnitude
                    dataset.Vel.data = sqrt(uX.^2 +uY.^2);
                    dataset = Dataset.addMetaData(dataset,'VelX','Vel','m/s',0,'Velocity magnitude');
                    
                    % add direction
                    dataset.VelDir.data = Calculate.calcDir(uX,uY);
                    dataset = Dataset.addMetaData(dataset,'VelX','VelDir','degrees',1,'Velocity direction');
                end;
            end;
            
            % add X and Y component
            
            if isfield(dataset,'Vel') && isfield(dataset,'VelDir')
                if onlyMetadata == true
                    % add x component
                    dataset = Dataset.addMetaData(dataset,'Vel','VelX','m/s',0,'Velocity in x direction');
                    
                    % add direction
                    dataset = Dataset.addMetaData(dataset,'Vel','VelY','m/s',0,'Velocity in y direction');
                else
                    U = dataset.Vel.data;
                    theta = dataset.VelDir.data;
                    
                    % add x component
                    dataset.VelX.data = U.*cosd(90-theta);
                    dataset = Dataset.addMetaData(dataset,'Vel','VelX','m/s',0,'Velocity in x direction');
                    
                    % add direction
                    dataset.VelY.data = U.*sind(90-theta);
                    dataset = Dataset.addMetaData(dataset,'Vel','VelY','m/s',0,'Velocity in y direction');
                end;
            end;
            
            % add fields with nothing
            if isfield(dataset,'Time')
                if ~onlyMetadata
                    dataset.ZeroTime.data = zeros(size(dataset.Time.data));
                end
                dataset = Dataset.addMetaData(dataset,'Time','ZeroTime','-',1,'Dummy data with zeros');
            end
            
        end
        
        function dataset = addMetaData(dataset,fieldIn,fieldOut,defaultUnit,forceUnit,longName)
            %add metadata to the selected dataset
            %example: dataset = Dataset.addMetaData(dataset,'Time','ZeroTime','-',1,'Dummy data with zeros');   
            if isfield(dataset.(fieldIn), 'dim')
                dataset.(fieldOut).dim = dataset.(fieldIn).dim;
            end;
            if forceUnit ||  ~isfield(dataset.(fieldIn),'unit')
                dataset.(fieldOut).unit = defaultUnit;
            else
                dataset.(fieldOut).unit = dataset.(fieldIn).unit;
            end;
            
            dataset.(fieldOut).longname = longName;
        end
        
        function dataSet = fieldfunction(dataSet,funcHandle, parameters,excludeVar)
            % applies a function on all fields of a dataset
            %
            % dataSet = fieldfunction(dataSet,funcHandle, parameters, excludeVar)
            %
            % INPUT: 
            % - dataSet: an IMDC format dataset
            % - functionhandle:  a fuinction handle
            % - parameters: parameters to a function
            % - excludeVar (optional): names of the variables to exclude
            % 
            % OUTPUT:
            % - dataSet: the modified dataset
            
            if nargin ==3
                excludevar = {};
            end
            allFields = fieldnames(dataSet);
            nrField = length(allFields);
            for i=1:nrField
                fieldName = allFields{i};
                if ~any(strcmpi(fieldName,excludeVar))
                    dataSet.(fieldName).data = funcHandle(dataSet.(fieldName).data,parameters);
                end
            end
        end
            
        
        function [variables metadata] = getDatasetInfo(dataset)
            %get the Variables and Metadata in the dataset
            %Input: dataset in IMDC defined standar format
            %Output: Variables, Metadata structs
            variables = struct;
            metadata = struct;
            
            if isempty(dataset)
                return;
            end;
            
            fields = fieldnames(dataset);
            for i=1:numel(fields)
                %get the current field
                currentField = fields{i};
                
                %if true is a variable / else metadata
                if isfield(dataset.(currentField), 'data') || isfield(dataset.(currentField), 'unit')
                    variables.(currentField) = dataset.(currentField);
                else
                    metadata.(currentField) =  dataset.(currentField);
                end;
            end;
            
            %clean the data field in order to reduce the amount of send
            %data
            allVar = fieldnames(variables);
            for i=1:numel(allVar)
                if isfield(variables.(allVar{i}), 'data')
                    variables.(allVar{i}).data =  num2str(size(variables.(allVar{i}).data));
                end
            end;
            
        end;
        
        function [dataset, loadOk] = loadData(fileName,metaDataOnly)
            % loads dataset in IMDC format
            %
            % [dataset, loadOk] = loadData(fileName,metaDataOnly)
            %
            % INPUT:
            %   fileName: path and filename of dataset to load
            %   metaDataOnly: boolean indicated whether only metatdata is load or also
            %   the data
            % OUTPUT:
            %   dataset: dataset in IMDC format
            %   loadOk: boolean indicating that the data was loaded succesfully
            %
            dataset = struct;
            loadOk = false;
            if nargin==1
                metaDataOnly = false;
            end
            
            %TODO: fix it to read models
            if isfield(fileName, 'sourcePath')
                fileName = fileName.sourcePath;
            end;
            
            % load metadata
            try
                tmpmetadata = load(fileName,'metaData');
            catch
                return;
            end;
            
            %load data
            if ~metaDataOnly
                try
                    tmpdata = load(fileName,'data');
                catch
                    return;
                end;
            end
            
            for iFile = 1:length(tmpmetadata.metaData)
                if isfield(tmpmetadata,'metaData')
                    if iFile ==1
                        dataset = tmpmetadata.metaData(iFile);
                    else
                        dataset(iFile) = tmpmetadata.metaData(iFile);
                    end
                else
                    return;
                end;
                
                % load data
                if ~metaDataOnly
                    % add data to datastructure
                    if isfield(tmpdata,'data')
                        fieldName = fieldnames(tmpdata.data);
                        for iField = 1:length(fieldName)
                            theField = fieldName{iField};
                            dataset(iFile).(theField).data = tmpdata.data(iFile).(theField);
                        end;
                    else
                        return;
                    end;
                end;
            end
            
            loadOk = true;
        end;
        
        function dataset = removeMissingValues(dataset)
            %remove missing values from the dataset variables and replaace
            %them with fill_values field
            fields = fieldnames(dataset);
            for ii=1:numel(fields)
                field = fields{ii};
                
                if isfield(dataset.(field), 'MissingValue') && isfield(dataset.(field), 'FillValue') && isfield(dataset.(field), 'data')
                    missingValues = dataset.(field).data(:) == dataset.(field).MissingValue;
                    
                    if any(logical(missingValues))
                        dataset.(field).data(missingValues) = dataset.(field).FillValue;
                    end
                end
            end
        end
        
        function saveOk = saveData(allDataset,fileName)
            % saves dataset in IMDC standard format to disk
            %
            % saveOk = saveData(allDataset,fileName)
            %
            % INPUT: dataset: a structure with a dataset in IMDC standard format
            %        fileName: the filename to save data to dsik
            % OUTPUT: saveOk: boolean that indicates whether the data was saved
            % correctly
            
            % Written by ABR
            % Date: 13-6-2013
            
            % split up datastructure
            nrFile   = length(allDataset);
            data(nrFile)     = struct;
            metaData(nrFile) = struct;
            for iFile = 1:nrFile
                dataset = allDataset(iFile);
                fieldName = fieldnames(dataset);
                
                for iField = 1:length(fieldName)
                    theField = fieldName{iField};
                    
                    currentSize = [];
                    
                    if ~strcmpi(theField,'metadata') & isfield(dataset.(theField),'data')
                        % copy  the data
                        data(iFile).(theField) = dataset.(theField).data; %#ok<STRNU>
                        currentSize = size(dataset.(theField).data);
                        dataset.(theField) = rmfield(dataset.(theField),'data');
                    end;
                    % copy the metadata
                    metaData(iFile).(theField) = dataset.(theField); %#ok<STRNU>
                    
                    if ~isempty(currentSize)
                        metaData(iFile).(theField).size = mat2str(currentSize);
                    end
                    
                end;
            end    
                % save the two datafields
                try
                    save(fileName,'metaData','data')
                    saveOk = true;
                catch
                    saveOk = false;
                end;
            
        end;
        
        function showDataset(dataset)
            % show contents of a dataset
            fieldName = fieldnames(dataset);
            
            % check all group names
            for i = 1:length(fieldName)
                % determine group information
                
                theFieldName =  fieldName{i};
                disp(theFieldName);
                disp(dataset.(theFieldName));
                disp('**********************');
            end;
        end;
        
        function dataset = createDataset(varargin)
            % create standardised IMDC structure
            %
            % dataset = createDataset
            %           or
            % dataset = createDataset(dataset,Nadd)
            %           or
            % dataset = createDataset(N)
            %
            % INPUT: dataset = structure
            %       N = number of elements that you want in the new
            %       structure
            %       Nadd = number of elements  that you want to add to
            %       dataset
            % OUTPUT: dataset: a structure with a standardised fields dataset in IMDC standard format
            %       dataset(iN).metaData.timezone: Number of hours to be added
            %       to UTC (eg: UTC: 0, UTC+1:1, UTC-1, -1,...)
            %      dataset(iN).metaData.coordinateSystem: Horizontal coordinate system (e.g WGS84-UTM31)
            %      dataset(iN).metaData.creator:  The person who created the dataset
            %      dataSet(iN).metaData.description: Any comments about the dataset
            %      dataset(iN).metaData.flag_expl: Explanation of the flag values, used in quality control of the data.
            %                {0, 'NOT_VALIDATED';
            %                 1, 'VALIDATED';
            %                 2, 'SUSPICIOUS';
            %                 3, 'CALCULATED';
            %                 4, 'MANUAL_EDIT';
            %                 5, 'INVALID'};
            %     dataset(iN).metaData.history: A cell array. Each change to the dataset should add an extra line to the cell array, containing:
            %                      Author, date, method and description. eg. ABR, 5-2-2013, Calculation.applyCalculation, added variable SedConc
            %     dataset(iN).metaData.description: Any comments about the dataset
            %     dataset(iN).metaData.ic: Identification code
            %     dataset(iN).metaData.institution: The institution that owns the data
            %     dataset(iN).metaData.location: (mandatory) the location of the data
            %     dataset(iN).metaData.projectnr: Project number
            %     dataset(iN).metaData.serialnr: Serial number of the monitoring device
            %     dataset(iN).metaData.instrument: instrument type
            %     dataset(iN).metaData.source: The origen of the dataset
            %     dataset(iN).metaData.title:  Title of the dataset
            %     dataset(iN).metaData.verticalCoordinateSystem: Vertical coordinate system (e.g NAP, TAW)
            
            % Written by JCA
            % Date: 26-8-2016
            
            % input
            dataset = [];
            dataset = struct(dataset);
            if isempty(varargin)
                N = 1;
            else
                if isnumeric(varargin{1})
                    N = 1:1:varargin{1};
                elseif isstruct(varargin{1})
                    dataset = varargin{1};
                    Nadd = 1;
                    if length(varargin) == 2
                        Nadd = varargin{2};
                    end
                    N = length(dataset)+1:1:length(dataset)+Nadd;
                end
            end
            
            % if there are variable fields copies these field to the new
            % elements
            thefields = fieldnames(dataset);
            thefields(strcmpi(thefields,'metaData')) = [];
            
            for iN = N
                %The person who created the dataset
                dataset(iN).metaData.creator = getenv('UserName');
                %Project number
                dataset(iN).metaData.projectnr = [];
                
                % Title of the dataset
                dataset(iN).metaData.title = '';
                %Explanation of the flag values, used in quality control of the data.
                dataset(iN).metaData.flag_expl = {0, 'NOT_VALIDATED';
                    1, 'VALIDATED';
                    2, 'SUSPICIOUS';
                    3, 'CALCULATED';
                    4, 'MANUAL_EDIT';
                    5, 'INVALID'};
                %Possible values are:
                %            NOT_VALIDATED = 0;
                %            VALIDATED = 1;
                %            SUSPICIOUS = 2;
                %            CALCULATED = 3;
                %            MANUAL_EDIT = 4;
                %Any comments about the dataset
                dataset(iN).metaData.description = {};
                % A cell array. Each change to the dataset should add an extra line to the cell array, containing:
                %Author, date, method and description. e.g.
                %ABR, 5-2-2013, Calculation.applyCalculation, added variable SedConc
                dataset(iN).metaData.history = {getenv('UserName'),datestr(now,'dd-mm-yyyy'), 'Dataset was created'};
                %	Identification code
                dataset(iN).metaData.ic = [];
                % The institution that owns the data
                dataset(iN).metaData.institution = '';
                %(mandatory) the location of the data
                dataset(iN).metaData.location = '';
                % Serial number of the monitoring device
                dataset(iN).metaData.serialnr = '';
                dataset(iN).metaData.instrument = '';
                %The origen of the dataset
                dataset(iN).metaData.source = '';
                % Horizontal coordinate system (e.g WGS84-UTM31)
                dataset(iN).metaData.coordinateSystem = '';
                % Vertical coordinate system (e.g NAP, TAW)
                dataset(iN).metaData.verticalCoordinateSystem = '';
                % timezone UTC+1
                dataset(iN).metaData.timezone = [];
                % add extra variabele fields if exist;
                for iF = 1:length(thefields)
                   dataset = Dataset.addDefaultVariableFields(dataset, thefields(iF), iN); 
                end
            end
        end
        function fieldname = getVariabelFieldname(varargin)
            % get the standardized variable field name te
            %
            % fieldname = getVariabelFieldname( value, field name)
            % or [dataset, fieldname] = getVariabelFieldname(value)
            %
            % INPUT: value: a 1XN cell or 1XN matrix to look in the database
            %        field: (optionally) the field name (string) where you want to look to find the
            %        other fields and add the those field to dataset eg.
            %        'longname', 'variableid' or 'shortname' [default: 'shortname'].
            % OUTPUT: fieldname: variable field name
            %
            
            % Written by JCA
            % Date: 26-8-2016
            
            value = varargin{1};
            field = 'shortname';
            if length(varargin) > 1
                field = varargin{2};
            end
            
            table = Dataset.getDefaultVariableList;
            fields = {'variableid', '/','longname', 'shortnameorg', 'shortname', '/'};
            MaskLook = strcmpi(fields, field);
            table(1,:) = [];
            if iscell(value)
                Mask = strcmpi(table(:, MaskLook), value);
            else
                Mask = cell2mat(table(:, MaskLook)) == value;
            end
            if sum(Mask) > 1
                error('No unique value is found.')
            elseif sum(Mask) == 0
                error('No corresponsible value is found.');
            end
            fieldname = table{Mask,5};
            
        end
        function [dataset, fieldname] = addDefaultVariableFields(varargin)
            % add the standardized variable fields to dataset and look for
            % the dynamic variable field based on a value
            %
            % [dataset, fieldname] = addDefaultFields(dataset, value, field name)
            % or [dataset, fieldname] = addDefaultFields(dataset, value)
            %
            % INPUT: dataset: a N structure with a dataset in IMDC standard format
            %        value: a string or ID value to look in the database
            %        field: (optionally) the field name (string) where you want to look to find the
            %        other fields and add the those field to dataset eg.
            %        'longname', 'variableid' or 'shortname' [default: 'shortname'].
            %        last field: (optionally) the number of element N or matrix with elements where you want to add the new fields
            %                         (default: all the elements)
            % OUTPUT: dataset: a structure with a dataset in IMDC standard format
            %               dataset(iN).(shortname).longname = variable name;
            %               dataset(iN).(shortname).classid = class id of the variable;
            %               dataset(iN).(shortname).variableid = variable id of the variable;
            %               dataset(iN).(shortname).data: (mandatory field) data of the variable
            %               dataset(iN).(shortname).dim: cell array stating for each dimension of the variable what the corresponding coordinate is: e.g. {‘T’,’X’,’Y’}: means that a 3D array contains time variation in the first dimension, X variation in the second and Y variation in the third.
            %               dataset(iN).(shortname).flag_values: Quality control values: (see flag_meaning ) Use type uint8 to save space;
            %               dataset(iN).(shortname).nodata_value: Value for no-data. Default should be NaN.
            %               dataset(iN).(shortname).unit:  Units in which data is expressed
            %               dataset(iN).(shortname).calibration.equation: for example : y = ax²+bx+c or y=x+a
            %               dataset(iN).(shortname).calibration.x: 	Name of
            %               predictor variable
            %               dataset(iN).(shortname).calibration.parameters: Value of the parameters in equation
            %        shortname: variable field name
            %
            
            % Written by JCA
            % Date: 26-8-2016
            
            dataset = varargin{1};
            value = varargin{2};
            field = 'shortname';
            N = 1:length(dataset);
            if length(varargin) > 2
                for i = 3:length(varargin)
                    if isnumeric(varargin{i})
                       N =  varargin{i};
                    else
                        field = varargin{i};
                    end
                end
            end
            
            table = Dataset.getDefaultVariableList;
            fields = {'variableid', '/','longname', 'shortnameorg', 'shortname', '/'};
            MaskLook = strcmpi(fields, field);
            table(1,:) = [];
            if ~isnumeric(value)
                Mask = strcmpi(table(:, MaskLook), value);
            else
                Mask = cell2mat(table(:, MaskLook)) == value;
            end
            if sum(Mask) > 1
                error('No unique value is found.')
            elseif sum(Mask) == 0
                %warning('No corresponsible parameter is found in IMDC parameter list.');
                fieldname = value;
            else
                fieldname = table{Mask,5};
            end
            for iN = N
                if sum(Mask) > 0
                    dataset(iN).(fieldname).longname = table{Mask,3};
                    dataset(iN).(fieldname).classid = table{Mask,2};
                    dataset(iN).(fieldname).variableid = table{Mask,1};
                else
                    dataset(iN).(fieldname).longname = '<unknown>';
                    dataset(iN).(fieldname).classid = '';
                    dataset(iN).(fieldname).variableid = '';
                end
                % (mandatory field) data of the variable
                dataset(iN).(fieldname).data = [];
                % cell array stating for each dimension of the variable what the corresponding coordinate is: e.g. {‘T’,’X’,’Y’}: means that a 3D array contains time variation in the first dimension, X variation in the second and Y variation in the third.
                dataset(iN).(fieldname).dim  =  [];
                % Quality control values: (see flag_meaning ) Use type uint8 to save space.
                dataset(iN).(fieldname).flag_values = [];
                % 	Value for no-data. Default should be NaN.
                dataset(iN).(fieldname).nodata_value = [];
                % Units in which data is expressed
                if sum(Mask) > 0
                    dataset(iN).(fieldname).unit = ['<', table{Mask,6}, '>'];
                else
                    dataset(iN).(fieldname).unit = '<unknown>';
                end
                %		For example : y = ax²+bx+c
                dataset(iN).(fieldname).calibration.equation = '';
                %	Name of predictor variable
                dataset(iN).(fieldname).calibration.x = '';
                % Value of the parameters in equation
                dataset(iN).(fieldname).calibration.parameters = [];
            end
        end
        
        function dataSet = addDefaultVarData(dataSet,fields)
            % add metatadata to variables in a dataset
            %
            % dataSet = addDefaultVarData(dataSet,fields)
            % 
            % INPUT
            % - dataSet: the dataset to which default data is to be added
            % - fields: the fields for which metadat is wanted. possible
            % values are 'variableid', 'classid','longname', 'shortnameorg', 'shortname', 'unit'
            
            table = Dataset.getDefaultVariableList;
            table(1,:) = [];
            %find the fields that need to be added
            defaultFields = {'variableid', 'classid','longname', 'shortnameorg', 'shortname', 'unit'};
            indexField    =  find(strcmpi('shortname',defaultFields));
            nrMeta = length(fields);
            maskLook =  zeros(nrMeta,1);
            for i=1:nrMeta
                tmp =  find(strcmpi(fields(i), defaultFields));
                if~isempty(tmp)
                    maskLook(i) = tmp;
                end
            end
            % loop over all variables
            varNames  = fieldnames(dataSet);
            nrField = length(varNames);
            for iField =1:nrField
                theVar = varNames{iField};
                % no metadata for metadata
                if  strcmpi(theVar,'metadata')
                    continue
                end
                % add metadata
                for iMeta = 1:nrMeta
                    if maskLook(iMeta)>0
                        ind = find(strcmpi(theVar,table(:,indexField)), 1);
                        if ~isempty(ind)
                            dataSet.(theVar).(fields{iMeta}) = table{ind,maskLook(iMeta)};
                        end
                    end
                end
            end
                
        end
             
        function files = searchData(folder, ext, format)
            % search function to list files (or subfolders) in a folder structure (incl.
            % subfolders
            %
            % files = Dataset.searchData(folder, ext, format)
            %
            % INPUT: folder = path of the main folder
            %        ext = extension or word the search (eg. *.MAT)
            %        format = cell or structure (default: structure) 
            %
            %     NOTE: if ext is empty, the subfolders are given
            %
            % OUTPUT: a N x structure where
            %         folder = path of folder
            %         name = filename
            %         bytes = size of the file in bytes
            %         date = date of modification
            %         (see function dir for more info about the fields)
            %
            %        or Nx1 cell where file paths are listed 
            %
            % Written by JCA
            % Date: 26-11-2019
          
            if nargin < 3
                format = 'structure';
            end
            files = [];
            % find all (sub)folders and list them in cell 'subfolders'
            subfolders = {folder,0};
            bRun = true;
            k=0;
            while bRun
                ind = find(cell2mat(subfolders(:,2)) == 0);
                for i = ind'
                    sct = dir(subfolders{i,1});
                    subfolders{i,2} = 1;
                    for j = 1:length(sct)
                        if (~strcmpi(sct(j).name,'.') && ~strcmpi(sct(j).name,'..'))
                            if sct(j).isdir == true
                                ks = size(subfolders,1)+1;
                                subfolders(ks,:) = {[subfolders{i,1},'\', sct(j).name,'\'],0};
                                if strcmpi(format,'structure') && isempty(ext)
                                   k = k+1;
                                   fields = fieldnames(sct);
                                   for  iFields = 1:length(fields)
                                       files(k).(fields{iFields}) = sct(j).(fields{iFields});
                                   end
                                end
                                    
                            end
                        end
                        
                    end
                    clear sct;
                end
                if size(subfolders,1) == sum(cell2mat(subfolders(:,2)))
                    bRun = false;
                end
            end
            
            % find files in folder structure based on ext
            if ~isempty(ext)
                k = 0;
                for i = 1:size(subfolders,1)
                    sct = dir([subfolders{i}, ext]);
                    for j = 1:length(sct)
                        if ~isempty(sct) && ~strcmpi(sct(j).name(1),'~')
                            k = k+1;
                            if strcmpi(format,'cell')
                                files{k,1} = fullfile(subfolders{i},sct(j).name);
                            else
                                fields = fieldnames(sct);
                                for  iFields = 1:length(fields)
                                    files(k).(fields{iFields}) = sct(j).(fields{iFields});
                                end
                            end
                        end
                    end
                end
            elseif strcmpi(format,'cell')
                files = subfolders(:,1);
            end
        end
        
        function table = getDefaultVariableList
            % get the standard IMDC variable list with longname, id, etc.
            %
            % table = getStandardVariableList
            %
            % INPUT: /
            % OUTPUT: table: a n x 6 cell with headerline
            %
            
            % Written by JCA
            % Date: 26-8-2016
            table = {
                'Variable_ID'	,	'Variable_Class_ID'	,	'Standard_Name'	,	'Short_Name (orginal)'	,	'Variable name to be used in scripts/datastructure'	,	'Unit'	;
                1	,	0	,	'Easting'	,	''	,	'X'	,	'm'	;
                2	,	0	,	'Northing'	,	''	,	'Y'	,	'm'	;
                3	,	0	,	'Elevation'	,	''	,	'Z'	,	'm'	;
                4	,	0	,	'Latitude'	,	''	,	'Lat'	,	'dec deg'	;
                5	,	0	,	'Longitude'	,	''	,	'Long'	,	'dec deg'	;
                6	,	0	,	'Time'	,	''	,	'Time'	,	'days'	;
                7	,	0	,	'Sigma coordinate'	,	''	,	'Sigma'	,	'-'	;
                8	,	0	,	''	,	''	,	''	,	''	;
                9	,	0	,	''	,	''	,	''	,	''	;
                10	,	1	,	'Velocity magnitude'	,	'VEL'	,	'Vel'	,	'm/s'	;
                11	,	1	,	'Velocity direction'	,	''	,	'VelDir'	,	'deg [nautical]'	;
                12	,	1	,	'Velocity in X direction'	,	''	,	'VelX'	,	'm/s'	;
                13	,	1	,	'Velocity in Y direction'	,	''	,	'VelY'	,	'm/s'	;
                105	,	1	,	'Velocity in Z direction'	,	''	,	'VelZ'	,	'm/s'	;
                106	,	1	,	'Velocity in X direction in the lowest 50% of the water column'	,	''	,	'VelXbot50'	,	'm/s'	;
                107	,	1	,	'Velocity in Y direction in the lowest 50% of the water column'	,	''	,	'VelYbot50'	,	'm/s'	;
                108	,	1	,	'Velocity in X direction in the uppper 50% of the water column'	,	''	,	'VelXtop50'	,	'm/s'	;
                109	,	1	,	'Velocity in Y direction in the upper 50% of the water column'	,	''	,	'VelYtop50'	,	'm/s'	;
                15	,	1	,	'Discharge'	,	'Q'	,	'Q'	,	'm3/s'	;
                16	,	1	,	'Surface elevation'	,	'SWL'	,	'WatLev'	,	'm'	;
                17	,	1	,	'Water depth'	,	'WD'	,	'Depth'	,	'm'	;
                18	,	1	,	'Water pressure'	,	'WP'	,	'WatPress'	,	'dbar'	;
                19	,	1	,	'absolute pressure'	,	''	,	'AbsPress'	,	'dbar'	;
                20	,	1	,	''	,	''	,	''	,	''	;
                21	,	1	,	'Ground water level'	,	'GWL'	,	'GroundWatLev'	,	'm'	;
                22	,	1	,	'Wave height'	,	'WH'	,	'WaveHeight'	,	'm'	;
                23	,	1	,	'Wave frequency'	,	'WF'	,	'WaveFreq'	,	'Hz'	;
                24	,	1	,	'Wave period'	,	''	,	'WavePeriod'	,	's'	;
                25	,	1	,	'Wave orbital velocity amplitude magnitude'	,	''	,	'WaveVel'	,	'm/s'	;
                26	,	1	,	'Wave direction'	,	'WD'	,	'WaveDir'	,	'deg [nautical]'	;
                27	,	1	,	'Wave spectra'	,	'WS'	,	'WaveSpec'	,	'm2'	;
                28	,	2	,	'Bottom elevation'	,	''	,	'BotZ'	,	'm'	;
                29	,	2	,	'Bottom Depth'	,	'DEP'	,	'BotDep'	,	'm'	;
                30	,	2	,	'Ground level elevation'	,	'LEV'	,	'GroundZ'	,	'm'	;
                31	,	2	,	'Optical transmission'	,	'OT'	,	'OptTrans'	,	'-'	;
                32	,	2	,	'Backscatter'	,	'BS'	,	'BackScat'	,	'-'	;
                33	,	2	,	'Turbidity'	,	'TUR'	,	'Turbidity'	,	'NTU'	;
                34	,	2	,	'Sediment concentration'	,	'SC'	,	'SedConc'	,	'mg/l'	;
                35	,	2	,	'Density'	,	'DEN'	,	'Density'	,	'kg/m3'	;
                36	,	2	,	'Grain size distribution (granulometry)'	,	'GSD'	,	'GrainSizeDist'	,	''	;
                37	,	2	,	'Granulometric variables'	,	'GVAR'	,	'GranVar'	,	''	;
                38	,	2	,	'Secchi depth'	,	'SD'	,	'SecchiDep'	,	''	;
                39	,	2	,	'Compaction'	,	'COM'	,	'Compaction'	,	''	;
                40	,	2	,	'Sediment type'	,	'ST'	,	'SedType'	,	''	;
                41	,	2	,	'Dry matter'	,	'DM'	,	'DryMatter'	,	''	;
                42	,	2	,	'Water content'	,	'WC'	,	'WaterContent'	,	'-'	;
                43	,	2	,	'Mud content'	,	'MC'	,	'MudConcent'	,	'-'	;
                44	,	2	,	'Clay content'	,	'CC'	,	'ClayContent'	,	'-'	;
                45	,	2	,	'Sand content'	,	'SC'	,	'SandContent'	,	'-'	;
                46	,	2	,	'gravel content'	,	'GC'	,	'GravelContent'	,	'-'	;
                47	,	2	,	'Organic Carbon'	,	'OC'	,	'OrgCarbon'	,	''	;
                48	,	2	,	'Organic matter'	,	'OM'	,	'OrgMatter'	,	''	;
                49	,	2	,	'sediment sample'	,	'SS'	,	'SedSample'	,	''	;
                50	,	2	,	'Sedimentation velocity'	,	'SVEL'	,	'FallVel'	,	'm/s'	;
                51	,	2	,	'Erosion flux'	,	''	,	'ErFlux'	,	'kg/m2/s'	;
                52	,	2	,	'Deposition flux'	,	''	,	'DepFlux'	,	'kg/m2/s'	;
                53	,	2	,	'Sedimentation/erosion'	,	'SEDER'	,	'BedFlux'	,	'kg/m2/s'	;
                54	,	2	,	'Bedload in x direction'	,	''	,	'BedLoadX'	,	''	;
                55	,	2	,	'Bedload in y direction'	,	''	,	'BedLoadY'	,	''	;
                56	,	2	,	'Total load in x direction'	,	''	,	'TotalLoadX'	,	''	;
                57	,	2	,	'Total load in y direction'	,	''	,	'TotalLoadY'	,	''	;
                58	,	2	,	'Bathymetric evolution'	,	'BEVOL'	,	'BathEvol'	,	''	;
                59	,	2	,	'Boring'	,	'BOR'	,	'Boring'	,	''	;
                60	,	2	,	'Subbottom profiling'	,	'SUBP'	,	'SubBotProf'	,	''	;
                61	,	2	,	'Physical tests'	,	'PT'	,	'PhysTest'	,	''	;
                62	,	2	,	'Areas'	,	''	,	'Area'	,	'm2'	;
                63	,	2	,	'Volumes'	,	'VOL'	,	'Vol'	,	'm3'	;
                64	,	3	,	'Wind velocity magnitude'	,	''	,	'WindVelMag'	,	'm/s'	;
                65	,	3	,	'Wind velocity direction'	,	''	,	'WindVelDir'	,	'deg [nautical]'	;
                66	,	3	,	'Wind velocity in X direction'	,	''	,	'WindVelX'	,	'm/s'	;
                67	,	3	,	'Wind velocity in Y direction'	,	''	,	'WindVelY'	,	'm/s'	;
                68	,	3	,	'Precipitation'	,	'PRE'	,	'Precipitation'	,	'mm'	;
                69	,	3	,	'Evaporation'	,	'EVA'	,	'Evaporation'	,	'?'	;
                70	,	3	,	'Evapotranspiration'	,	'EVT'	,	'Evapotrans'	,	'?'	;
                71	,	3	,	'Atmospheric humidity'	,	'AHUM'	,	'AtmHum'	,	''	;
                72	,	3	,	'Solar radiation'	,	'SR'	,	'SolarRad'	,	''	;
                73	,	3	,	'Air pressure'	,	'AP'	,	'AirPress'	,	'dbar'	;
                74	,	3	,	'Irradiance'	,	'IRR'	,	'Irrad'	,	''	;
                75	,	4	,	'Diatoms'	,	'DIA'	,	'Diatoms'	,	''	;
                76	,	4	,	'Macroinvertebrates'	,	'MAC'	,	'MacroInv'	,	''	;
                77	,	4	,	'Plankton'	,	'PLAN'	,	'Plankton'	,	''	;
                78	,	4	,	'Vegetation'	,	'VEG'	,	'Vegetation'	,	''	;
                79	,	4	,	'Fish'	,	'FI'	,	'Fish'	,	''	;
                80	,	4	,	'Birds'	,	'BI'	,	'Birds'	,	''	;
                81	,	4	,	'Zooanimals'	,	'ZOO'	,	'ZooAnimals'	,	''	;
                82	,	5	,	'Nutrients C'	,	'NC'	,	'NutrC'	,	''	;
                83	,	5	,	'Nutrients N'	,	'NN'	,	'NutrN'	,	''	;
                84	,	5	,	'Nutrients O2'	,	'NO2'	,	'NutrO2'	,	''	;
                85	,	5	,	'Nutrients P'	,	'NP'	,	'NutrP'	,	''	;
                86	,	5	,	'Nutrients S'	,	'NS'	,	'NutrS'	,	''	;
                87	,	5	,	'Nutrients Si'	,	'NSI'	,	'NutrSi'	,	''	;
                88	,	5	,	'Pigments'	,	'PI'	,	'Pigments'	,	''	;
                89	,	5	,	'Conductivity'	,	'CON'	,	'Cond'	,	'mS/cm'	;
                90	,	5	,	'Salinity'	,	'SAL'	,	'Sal'	,	'psu'	;
                91	,	5	,	'Temperature'	,	'TEMP'	,	'Temp'	,	'deg C'	;
                92	,	5	,	'Alcalinity'	,	'ALC'	,	'Alcal'	,	''	;
                93	,	5	,	'Chlorinity'	,	'CHL'	,	'Chlor'	,	''	;
                94	,	5	,	'PH'	,	'PH'	,	'PH'	,	'-'	;
                95	,	5	,	'Hardness'	,	'HARD'	,	'Hardmess'	,	''	;
                96	,	6	,	'Metals'	,	'ME'	,	'Metals'	,	''	;
                97	,	6	,	'PAKs'	,	'PAK'	,	'Paks'	,	''	;
                98	,	6	,	'Pesticides'	,	'PES'	,	'Pesticides'	,	''	;
                99	,	6	,	'PCBs'	,	'PCB'	,	'PCB'	,	''	;
                100	,	7	,	'Executed infrastucture works'	,	'INF'	,	'Infrastructure'	,	''	;
                101	,	7	,	'Spatial execution plans'	,	'PLANS'	,	'Plans'	,	''	;
                102	,	7	,	'Photos'	,	'PHOT'	,	'Photos'	,	''	;
                103	,	7	,	'Diverse'	,	'DIV'	,	'Diverse'	,	'' ;
                104,    7   ,   'Battery voltage', 'Battery', 'Battery', 'V'
                };
            
        end
    end
end