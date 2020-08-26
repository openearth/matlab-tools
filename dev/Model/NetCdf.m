%Class to declare the most common NetCdf
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
% @author GLE

classdef NetCdf < handle
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
        
        
        function dataset = addNetCdfCoord(dataset,nrDim,sizeVar)
            % This function adds extra coordinates called (I,J,K) to the NetCdf file,
            % to be in accordance with the specifications.
            % INPUT: dataset: a IMDC standard dataset
            %   nrDim: the number of dimension to add (between 1 and3)
            % sizeVar (optional): a cell array with the coordinate variables that
            % should be used for gebnerating (e.f. {'lat','long'}. The
            % default is {'X','Y','Z'};
            
            if nrDim > 3 || nrDim < 1
                error('Nr of dimensions must be between 1 and 3');
            end;
            % the variable to use to determine the size of the
            % coordinate index
            if nargin == 2
                sizeVar = {'X','Y','Z'};
            end;
            % the name of the coordinate index
            coordNames = {'I','J','K'};
            for i = 1:nrDim
                varName = coordNames{i};
                if isfield(dataset, sizeVar{i})
                    dataset.(varName).data     = 1:size(dataset.(sizeVar{i}).data,i);
                    dataset.(varName).longname = [varName,' coordinate'];
                    dataset.(varName).dim      = {varName};
                end;
            end;
            
            %add the time
            % if isfield(dataset, 'Time')
            %     dataset.T.data     = 1:size(dataset.Time.data,1);
            %     dataset.T.longname = ['T',' coordinate'];
            %     dataset.T.dim      = {'T'};
            % end;
        end;
        
        function closeNetCdfData(sctFile)
            % close netcdf file
            netcdf.close(sctFile.fid);
        end;
        
        function sctFile = getNetCdfHeaderInfo(fileName, varNames)
            %return the same info as writeHeader without generating new
            %file -> based on existing file.
            %sctFile is an struct with:
            %       fid: xx
            %       varNames: {X cell}
            %       varid: [...]
            
            if ~exist(fileName,'file')
                error(['File ',fileName,' does not exist.']);
            end;
            
            fid = netcdf.open(fileName);
            varIds = zeros(1,numel(varNames));
            for ii=1:numel(varNames)
                varIds(ii) = netcdf.inqVarID(fid, varNames{ii});
            end
            
            sctFile.fid = fid;
            sctFile.varNames = varNames;
            sctFile.varid = varIds;
        end
        
        function typeNr = getCdfType(type)
            % Converts the type of a matlab variable to a netcdf variable
            switch type
                case 'single'
                    strType = 'NC_FLOAT';
                case 'double'
                    strType = 'NC_DOUBLE';
                case 'logical'
                    strType = 'NC_BYTE';
                case 'int64'
                    strType = 'NC_INT64';
                case 'int32'
                    strType = 'NC_INT';
                case 'int16'
                    strType = 'NC_SHORT';
                case 'int8'
                    strType = 'NC_BYTE';
                case 'uint64'
                    strType = 'NC_UINT64';
                case 'uint32'
                    strType = 'NC_UINT';
                case 'uint16'
                    strType = 'NC_USHORT';
                case 'uint8'
                    strType = 'NC_UBYTE';
                case 'char'
                    strType = 'NC_CHAR';
            end;
            typeNr = netcdf.getConstant(strType);
        end;
        
        function theData =  mergeCdf(theDir,mergeDim)
            % read all variables from multiple netcdf files. Use for IMDC
            % Telemac Netcdf.
            %
            % theData =  NetCdf.mergeCdf(theDir,mergeDim)
            %
            % INPUT: theDir: directory with Netcdf files, which are
            % assumed to have the extension .nc
            %      : mergeDim (optional): a string with  name of the
            %      dimension that is used for merging. Default = 'Station'
            %
            % OUTPUT: theData: structure with for each variable a field (with same name as the netcdf name) (in the field data)
            % i.e. theData.VELOCITY.data
            
            
            % default ioptions
            if nargin == 1
                mergeDim = 'Station';
            end
            
            % find files
            theFiles = dir(fullfile(theDir,'*.nc'));
            nrFiles = length(theFiles);
            if nrFiles ==0
                warning(['No netcdf files found in ',theDir]);
                return;
            end
            
            % read all Files
            for iF=1:nrFiles
                theFile = fullfile(theDir,theFiles(iF).name);
                allData(iF) = readCdfFile(theFile,mergeDim);
            end
            
            
            % data merge
            theVars = fieldnames(allData(1));
            nrVars = length(theVars);
            for iV=1:nrVars
                varName = theVars{iV};
                theData.(varName) = [];
                % check how to merge
                switch allData(iF).(varName).mergeDim
                    
                    case 0 % data the same in all files
                        theData.(varName) = allData(1).(varName).data;
                    case 1 % merge along first dimension
                        for iF=1:nrFiles
                            theData.(varName) = [theData.(varName);allData(iF).(varName).data];
                        end
                    case 2 % merge along second dimension
                        for iF=1:nrFiles
                            theData.(varName) = [theData.(varName);allData(iF).(varName).data];
                        end
                end
            end
        end
        
        
        function theData = quickLoadCdf(theFile,mergeDim)
            % read all data in a netcdf file
            %
            % theData = NetCdf.quickLoadCdf(theFile,mergeDim)
            %
            % INPUT:  theFile: filename of the netcdf file
            %         mergeDim: (optional). string with the name of the
            %         dimension used for merging (in mergeCdf)
            % OUTPUT: theData: structure with for each variable a field (with same name as the netcdf name) (in the field data)
            % i.e. theData.VELOCITY.data
            % i.e. theData.VELOCITY.mergeDim: fuirther, the merge dimension
            % per variable (for use in mergeCdf)
            
            % find the variables
            sctInfo = ncinfo(theFile);
            theVars = sctInfo.Variables;
            nrVars = length(theVars);
            
            % read all variables
            for i = 1:nrVars
                varName = theVars(i).Name;
                theData.(varName).data = ncread(theFile,varName);
                
                % check dimensions to find the dimension used for merging
                if nargin ==2
                    for j = 1:length(sctInfo.Variables(i).Dimensions)
                        theDim = sctInfo.Variables(i).Dimensions(j).Name;
                        theData.(varName).mergeDim = 0;
                        if strcmpi(theDim,mergeDim)
                            theData.(varName).mergeDim = j;
                            break;
                        end
                    end
                end
            end
        end
        
        function dataset = readNetCdf(strFile,dataset,sctOptions)
            % reads variables inside a NetCdf file
            %
            % dataset = readNetCdf(strFile,dataset,sctOptions)
            %
            % INPUTS:
            %  - strFile : the filename with NetCdf data
            %  - sctOptions: structure with the optional fields
            %               : 'start': start index of the time
            %               dimension
            %               (based on couting of one, just as in matlab)
            %               : 'stop': the number of steps that
            %               is read
            %               : note that the coordinate index for this variable is not modified (such as time).
            %               : 'varname': name of the variable to read (default
            %               is all variables)
            %               :'fieldFunction': a function handle to a function that
            %               changes the name of the variables
            %               of the form: function strNewName = fieldFunction(strOldname)
            
            % Open the file for reading
            if nargin == 1
                dataset = struct;
            end;
            if nargin <= 2
                sctOptions = struct;
            end;
            
            if ~exist(strFile,'file')
                error(['File ',strFile,' does not exist.']);
            end;
            
            fid = netcdf.open(strFile,'NC_NOWRITE');
            
            % save variables in structure array sctOUT
            [~,nNbVars,nGlobAtts] = netcdf.inq(fid);
            for k=1:nNbVars;
                % get data
                [strVarName,~,dimID] = netcdf.inqVar(fid,k-1);
                
                if isfield(sctOptions,'fieldFunction')
                    strVarName = sctOptions.fieldFunction(strVarName);
                end;
                
                if strcmp(strVarName,'time')
                    if nc_isatt(strFile,'time','units')
                        dataset.(strVarName).datenum = nc_cf_time(strFile,strVarName);
                        disp([mfilename,': added extra variable with dataset.time.datenum'])
                    end
                end
                
                % select only a single part of the data
                if nargin >2
                    % check if only certain variables must be read
                    doSave = 1;
                    if isfield(sctOptions,'varName')&& ~any(strcmpi(strVarName,sctOptions.varName))
                        doSave = 0;
                    end;
                    
                    if doSave
                        % determine which part of the data should be read
                        % with respect to the last coordinate
                        
                        theDim        = dataset.(strVarName).dim;
                        lastDimIsTime = strcmpi('time',theDim(end));
                        if lastDimIsTime
                            sizeDims = ModelUtil.getDims(fid,dimID);
                            % define start and end coordinates
                            nrDims = length(sizeDims);
                            start  = zeros(1,nrDims);
                            stop   = sizeDims;
                            start  = ModelUtil.changeSize(sctOptions,start,'start');
                            stop   = ModelUtil.changeSize(sctOptions,stop,'stop');
                            
                            dataset.(strVarName).data = ncread(strFile,strVarName,start,stop);
                        else
                            dataset.(strVarName).data = ncread(strFile,strVarName);
                        end;
                    end;
                else
                    dataset.(strVarName).data = ncread(strFile,strVarName);
                end;
                %Metadata
                attrs = ncinfo(strFile,strVarName);
                try
                    attrName = {attrs.Attributes.Name};
                    a = {attrs.Attributes.Name};
                catch
                    attrName = {};
                    a = attrs.Name;
                end
                % Dim
                if ~isempty(attrs.Dimensions);
                    dataset.(strVarName).dim = {attrs.Dimensions.Name};
                end
                %Units
                f1 = find(strcmpi(attrName,'units'));
                if ~isempty(f1);
                    dataset.(strVarName).unit = attrs.Attributes(f1).Value;
                end
                %standard_name
                f1 = find(strcmpi(attrName,'standard_name'));
                if ~isempty(f1);
                    dataset.(strVarName).StandardName = attrs.Attributes(f1).Value;
                end
                %long_name
                f1 = find(strcmpi(attrName,'long_name'));
                if ~isempty(f1);
                    dataset.(strVarName).LongName = attrs.Attributes(f1).Value;
                end
                
            end;
            
            % close file
            netcdf.close(fid);
        end
        
        function [dataset, sctOptions] = readNetCdfHeader(strFile,sctOptions)
            % reads the header inside a netcdf file
            %
            % #INPUTS:  - strFile : the filename with NetCdf data
            %           - sctOptions: structure with the optional fields
            %                           sctOptions.AttFunction: function
            %                           handle to a function that changes
            %                           the names of the attributes of the
            %                           form strNewname = AttFunction(strOldName)
            %
            %                           sctOptions.fieldFunction: function
            %                           handle to a function that changes
            %                           the names of the variable of the
            %                           form strNewname = fieldFunction(strOldName)
            %
            %                           sctOptions.globalAttFunction: function
            %                           handle to a function that changes
            %                           the names of the global attributes of the
            %                           form strNewname = globalFunction(strOldName)
            %
            % #OUTPUTS: - sct : structure array containing the NetCdf data from the file
            %                   'strRunName_1.tsout3N'
            %           - sctDataType: structure containing the attributes of the data
            %           (normally, unit, longname, vectorname etc.) of the form
            %               sctDataType.varname.attributename
            %           - sctAttributes: structure containing the dlobal attributes of
            %           the data, with the form sctAttribute.attributename
            %
            % The function opens the file strRunName_1.tsout3N and saves everything in
            % the structure array sct.
            %
            % International Marine and Dredging Consultants (IMDC)
            % Antwerp, Belgium
            %
            % Written by: BDC
            % Date: 25/01/2010
            % Modified by: NZI
            % Date:
            % Modified: ABR (19/11/2010)
            % open NetCdf model output
            % Modified: ABR (4/12/2012)
            % extra option to read variables partially
            
            % process option
            if nargin == 1
                sctOptions = struct;
            end;
            
            % Open the file for reading
            if ~exist(strFile,'file')
                error(['File ',strFile,' does not exist.']);
            end;
            
            fid = netcdf.open(strFile,'NC_NOWRITE');
            
            [nDim,nNbVars,nGlobAtts] = netcdf.inq(fid);
            % read dimensions
            for k=1:nDim
                [dimName, dimLen] = netcdf.inqDim(fid,k-1);
                sctOptions.dim.(dimName).size = dimLen;
            end
            
            % save variables in structure array sctOUT
            
            for k=1:nNbVars;
                % get data
                [strVarName,~,dimID,nNumAtt] = netcdf.inqVar(fid,k-1);
                for j = 1:nNumAtt
                    strAttName = netcdf.inqAttName(fid,k-1,j-1);
                    
                    if isfield(sctOptions,'AttFunction')
                        strAttNameNew = sctOptions.AttFunction(strAttName);
                    else
                        strAttNameNew = strAttName;
                    end;
                    
                    if isfield(sctOptions,'fieldFunction')
                        strVarName = sctOptions.fieldFunction(strVarName);
                    end;
                    
                    attn =  netcdf.getAtt(fid,k-1,strAttName);
                    while strAttNameNew(1)=='_';
                        strAttNameNew = strAttNameNew(2:end);
                    end
                    dataset.(strVarName).(strAttNameNew) = netcdf.getAtt(fid,k-1,strAttName);
                    
                end;
                
                dimNames = cell(numel(dimID),1);
                for j=1:numel(dimID)
                    [dimNames{j}, ~] = netcdf.inqDim(fid,dimID(j));
                end
                dataset.(strVarName).dim = dimNames;
            end;
            
            % read global attributes
            for nI =1:nGlobAtts
                strAttName = netcdf.inqAttName(fid,netcdf.getConstant('NC_GLOBAL'),nI-1);
                if isfield(sctOptions,'globalAttFunction')
                    strAttNameNew = sctOptions.globalAttFunction(strAttName);
                else
                    strAttNameNew = strAttName;
                end;
                strAttNameNew = strrep(strAttNameNew,' ','_');
                strAttNameNew = strrep(strAttNameNew,'*','_');
                dataset.(strAttNameNew) = netcdf.getAtt(fid,netcdf.getConstant('NC_GLOBAL'),strAttName);
            end;
            
            % close file
            netcdf.close(fid);
        end
        
        function writeNetCdf(dataset,strFile,sctOptions)
            % writes a netcdf file of the standard dataset
            % INPUTS: - dataset: data in satndard format
            %         - strFile: the name of the output file
            %         - sctOptions: a structure with the fields:
            %              *sctOptions.fieldNameFunction: a function hanlde
            %              with a conversion function that changes the
            %              names of the fields with form:
            %               function strNewname = fieldNameFunction(strOldname)
            %              *sctOptions.propertyNameFunction: a function
            %              that changes the names of the properties with
            %              the form:
            %              function strNewname = propertyNameFunction(strOldname)
            %              *sctOptions.globalPropertyNameFunction: a function
            %              that changes the names of the global properties with
            %              the form:
            %              function strNewname = globalPropertyNameFunction(strOldname)
            
            % Open file for writing
            try
                fid =  netcdf.create(strFile,'CLOBBER');
            catch
                errordlg(['Could not create ',strFile,'.']);
                return;
            end;
            
            varNames = fieldnames(dataset);
            nrVars   = length(varNames);
            
            % determine
            % loop over all variables
            for i = 1:nrVars
                theVarName = varNames{i};
                theVar     = dataset.(theVarName);
                
                %processing a variable with attributes
                if isstruct(theVar)
                    theVar = dataset.(theVarName).data;
                    isVar = 1;
                    % anomalous treatement of the coordinates
                elseif any(strcmpi(theVarName,{'time'}))
                    theVar = dataset.(theVarName);
                    isVar = 1;
                else
                    isVar = 0;
                end;
                
                % make new variale name using a convertion function
                if isfield(sctOptions,'fieldNameFunction')
                    theVarName = sctOptions.fieldNameFunction(theVarName);
                end;
                
                if isVar
                    % make dimension
                    varSize = size(theVar);
                    dimid   = zeros(1,length(varSize));
                    for j = 1:length(varSize)
                        dimid(j) = netcdf.defDim(fid,[theVarName,'_dim',num2str(j)],varSize(j));
                    end;
                    
                    % determine type
                    varInfo = whos('theVar');
                    varType = NetCdf.getCdfType(varInfo.class);
                    
                    % make variable
                    varid(i) = netcdf.defVar(fid,theVarName,varType,dimid);
                else
                    % processing global attributes
                    
                    % make new attribute name using a convertion function
                    if isfield(sctOptions,'globalPropertyNameFunction')
                        theVarName = sctOptions.globalPropertyNameFunction(theVarName);
                    end;
                    
                    attId = netcdf.getConstant('NC_GLOBAL');
                    netcdf.putAtt(fid,attId,theVarName,theVar);
                end;
            end;
            
            % write data
            % loop over all variables
            for i = 1:nrVars
                theVarName = varNames{i};
                theVar     = dataset.(theVarName);
                
                % end define mode
                netcdf.endDef(fid);
                
                % write variables that have been defined
                if isstruct(theVar)
                    
                    % write variable (field data)
                    netcdf.putVar(fid,varid(i),theVar.data);
                    
                    % write attributes (uis all other field except data)
                    attNames = fieldnames(theVar);
                    netcdf.reDef(fid);
                    for j = 1:length(attNames)
                        theAttName = attNames{j};
                        if ~strcmpi(theAttName,'data')
                            theAtt = theVar.(theAttName);
                            % make new attribute name
                            if isfield(sctOptions,'propertyNameFunction')
                                theAttName = sctOptions.propertyNameFunction(theAttName);
                            end;
                            netcdf.putAtt(fid,varid(i),theAttName,theAtt);
                        end;
                    end;
                    % anomalous treatement for coordinates
                    % for the moment only for time
                elseif any(strcmpi(theVarName,{'time'}))
                    netcdf.putVar(fid,varid(i),theVar);
                    netcdf.reDef(fid);
                else
                    netcdf.reDef(fid)
                end;
            end;
            
            % close file
            netcdf.close(fid);
        end;
        
        function writeNetCdfData(dataset,sctFile,sctOptions)
            % writes a netcdf file of the standard dataset
            % INPUTS: - dataset: data in satndard format
            %         - sctFile: the file information about the netccdf
            %         file (from writeNetCdfHeader)
            %         - sctOptions: a structure with the fields:
            %              *sctOptions.start: the start of the time
            %              variable for output
            %              * sctOptions.excludeVar: cell array of
            %              variables that are not written to the file
            
            if nargin == 2
                sctOptions = struct;
            end;
            
            % write data
            nrVars = length(sctFile.varNames);
            for i = 1:nrVars
                % select variable
                theVarName = sctFile.varNames{i};
                
                % step over variables that should be excluded
                if isfield(sctOptions,'excludeVar')&& any(strcmpi(theVarName,sctOptions.excludeVar))
                    continue;
                end;
                
                theVar = dataset.(theVarName);
                
                % write variables that have been defined
                if isstruct(theVar)
                    theVar = dataset.(theVarName).data;
                    theDim = dataset.(theVarName).dim;
                    lastDimIsTime = strcmpi('time',theDim(end));
                    
                    % make sure that 1d vars are row variables (thus
                    % that the last dimension increases)
                    sizeDims = size(theVar);
                    nrNonSingleDims = sum(sizeDims>1);
                    if (nrNonSingleDims==1 &&  lastDimIsTime )
                        if length(theDim) == 1
                            theVar = ModelUtil.makeRow(theVar); %no applied if the variable is a row based vector time dependant.
                        end
                    end
                    
                    sizeDims = size(theVar);
                    % define start and end coordinates
                    
                    nrDims = length(sizeDims);
                    start  = ones(1,nrDims);
                    
                    % make sure one data value at the time is
                    % written
                    count = sizeDims;
                    extractLastDim = (nrDims <= length(theDim));
                    
                    % select data to write
                    if lastDimIsTime && isfield(sctOptions,'start')
                        % In case the dataset has the same number of
                        % dimensions as specified in the field dim, the
                        % last dimension should be disposed of
                        if ~extractLastDim
                            %                             count(ind) = 1;
                            start(end) = sctOptions.start;
                            % theVar = ModelUtil.getData(theVar,start,start+count-1);
                        else
                            % otherwise, the complete variable should
                            % be added to the file
                            if length(count)>1
                                %guarantee the dim orders
                                start = [start,sctOptions.start];
                            end;
                        end;
                    end;
                    
                    % verwijderen singleton dimensions with one
                    start(1:end-numel(theDim)) = [];
                    count(1:end-numel(theDim)) = [];
                    
                    %conversion from matlab to netcdf numbering
                    start = start -1;
                    
                    
                    netcdf.putVar(sctFile.fid,sctFile.varid(i),start,count,theVar);
                end;
            end;
        end;
        
        function sctFile = writeNetCdfHeader(dataset,strFile,sctOptions)
            % writes a header of  a netcdf file of the standard dataset
            % INPUTS: - dataset: data in satndard format
            %         - strFile: the name of the output file
            %         - sctOptions: a structure with the fields:
            %              *sctOptions.fieldNameFunction: a function hanlde
            %              with a conversion function that changes the
            %              names of the fields with form:
            %               function strNewname = fieldNameFunction(strOldname)
            %              *sctOptions.propertyNameFunction: a function
            %              that changes the names of the properties with
            %              the form:
            %              function strNewname = propertyNameFunction(strOldname)
            %              *sctOptions.globalPropertyNameFunction: a function
            %              that changes the names of the global properties with
            %              the form:
            %              function strNewname = globalPropertyNameFunction(strOldname)
            %               *sctOptions.excludeVar: a cell array with
            %               variable names that are not written to the
            %               file.
            %               This can for example be used to exclude
            %               coordinate variables I and J from ending iup in
            %               the file (while they are still used for the
            %               dimensions).
            % OUTPUT: sctFile: a structure with infor about the NetCdf data
            % to write (used as input in writeNetCdfData)
            
            % Open file for writing
            if nargin ==2
                sctOptions = struct;
            end;
            try
                fid =  netcdf.create(strFile,'CLOBBER');
            catch
                errordlg(['Could not create ',strFile,'.']);
                return;
            end;
            
            idUnlim  = netcdf.getConstant('NC_UNLIMITED');
            varNames = fieldnames(dataset);
            nrVars   = length(varNames);
            
            % determine make dimensions loop over all variables
            dimensions = fieldnames(sctOptions.dim);
            nrdim      = numel(dimensions);
            coordName  = dimensions;
            
            for i=1:nrdim
                % define coordinates in file
                if ~strcmpi(dimensions{i},'time')
                    coordDim(i) = netcdf.defDim(fid,dimensions{i},sctOptions.dim.(dimensions{i}).size);
                else
                    % unlimited value for time
                    coordDim(i) = netcdf.defDim(fid,dimensions{i},idUnlim);
                end;
            end
            % loop over all variables
            for i = 1:nrVars
                theVarName = varNames{i};
                
                % delete variables that are not needed (as given in
                % excludeVar
                if isfield(sctOptions,'excludeVar')&& any(strcmpi(theVarName,sctOptions.excludeVar))
                    continue;
                end;
                
                theVar = dataset.(theVarName);
                
                %processing a variable with attributes
                if isstruct(theVar)
                    %theVar = dataset.(theVarName).data;
                    isVar   = 1;
                    theDim  = dataset.(theVarName).dim;
                else
                    isVar = 0;
                end;
                
                % make new variale name using a convertion function
                if isfield(sctOptions,'fieldNameFunction')
                    theVarName = sctOptions.fieldNameFunction(theVarName);
                end;
                
                if isVar
                    dimid = [];
                    for j=1:numel(dataset.(theVarName).dim)
                        for k=1:nrdim
                            if strcmp(dimensions{k},dataset.(theVarName).dim(j))
                                dimid(j)=coordDim(k);
                            end
                        end
                    end
                    
                    % determine type
                    if isfield(dataset.(theVarName),'type')
                        varType = NetCdf.getCdfType(dataset.(theVarName).type);
                    else
                        temp    = dataset.(theVarName).data;
                        varInfo = whos('temp');
                        varType = NetCdf.getCdfType(varInfo.class);
                    end
                    % make variable
                    varid(i) = netcdf.defVar(fid,theVarName,varType,dimid);
                else
                    % processing global attributes
                    % make new attribute name using a convertion function
                    if isfield(sctOptions,'globalPropertyNameFunction')
                        theVarName = sctOptions.globalPropertyNameFunction(theVarName);
                    end;
                    
                    attId = netcdf.getConstant('NC_GLOBAL');
                    netcdf.putAtt(fid,attId,theVarName,theVar);
                end;
            end;
            
            % write data
            % loop over all variables
            for i = 1:nrVars
                theVarName = varNames{i};
                if isfield(sctOptions,'excludeVar')&& any(strcmpi(theVarName,sctOptions.excludeVar))
                    continue;
                end;
                
                theVar = dataset.(theVarName);
                % write variables that have been defined
                if isstruct(theVar)
                    % write attributes (all other field except .data and .dim)
                    attNames = fieldnames(theVar);
                    for j = 1:length(attNames)
                        theAttName = attNames{j};
                        
                        if ~strcmpi(theAttName,'data') && ~strcmpi(theAttName,'dim' ) && ~strcmpi(theAttName,'type' ) && ~strcmpi(theAttName,'datenum' )
                            theAtt = theVar.(theAttName);
                            % make new attribute name
                            if isfield(sctOptions,'propertyNameFunction')
                                theAttName = sctOptions.propertyNameFunction(theAttName);
                                % if strcmpi(theAttName,'_FillValue')
                                %     theAtt=-999;
                                % end
                                if isempty(theAtt)
                                    theAtt=' ';
                                end
                            end;
                            netcdf.putAtt(fid,varid(i),theAttName,theAtt);
                        end;
                    end;
                end;
            end;
            % end definition mode
            netcdf.endDef(fid);
            
            % save data for further use
            sctFile.fid      = fid;
            sctFile.varNames = varNames;
            sctFile.varid    = varid;
        end;
        
    end
end