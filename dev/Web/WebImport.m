%Class to declare the most common WebImport
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebImport < handle
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
        function getImdcFileFormat(varInfo, metaInfo, options)
            %Transform data instrument to IMDC standard format
            try
                options = Util.setDefault(options,'source','');
                if isempty(options.source)
                    error('You have to select a source to convert.');
                end;

                options = Util.setDefault(options,'fileType','');
                if isempty(options.fileType)
                    error('You have to select a file type to convert.');
                end;

                vars = fieldnames(varInfo);
                meta = fieldnames(metaInfo);

                options = Util.setDefault(options,'filesSelected','');
                if ~isempty(options.filesSelected)
                    selectedFiles = regexp(options.filesSelected,';','split');
                end;

                if length(selectedFiles) > 1
                    dynLocs  = (options.fileName == '$');
                    if ~any(dynLocs)
                        errordlg('You have to set a dynamic name to text file in order to avoid overwriting files. Use the $### to generate an automatic number in the file name.');
                        return;
                    end;
                end;

                originalName = options.fileName;
                nrFile = 1;
                %loop over all files in the directory
                for jj=1:length(selectedFiles)
                    dataset = [];
                    if isdir(options.source)
                        if ~strcmp(options.source(end), '\')
                            options.source = [options.source '\'];
                        end;
                        source = [options.source selectedFiles{jj}];
                    else
                        source = options.source;
                    end;

                    %Verify what kind of data will be converted
                    try
                        switch options.fileType
                            case 'IMDC'
                                [mData, cMetaData, cColumns] = Import.readImdcOldFormat(source);
                            case 'OBS'
                                [mData,cMetaData, cColumns] = Import.readObs(source);
                            case 'JME'
                                [mData,cMetaData, cColumns] = Import.readJme(source);
                            case 'CTD'
                                [mData,cMetaData, cColumns] = Import.readCtd(source);
                            case 'RDR'
                                cMetaData = {};
                                [mData,cColumns] = Import.readRDR(source);
                            case 'ADCP'
                                %set 1 to change the time format to the
                                %imdc standard
                                [mData,cMetaData, cColumns] = Import.readAdcpCsv(source,1);
                            case 'GRAIN'
                                [mData,cMetaData, cColumns] = Import.readGrainSize(source,0);
                                allData = mData;
                                
                                %number data -> exlude the first/second row
                                mData = str2double(allData(3:end,1:end));
                                
                            case 'OTHER'
                                [mData,cMetaData, cColumns] = WebImport.readGenericAscii(source, options);

                            otherwise
                                errordlg('Error in the file type selected.', 'Error');
                                return;
                        end;
                    catch
                        sct = lasterror;
                        errordlg(['Error to read the file to convert. Please check the data.' sct.message]);
                        return;
                    end;

                    %Set the data values to the dataset structure
                    for i=1:length(vars)
                        fieldVar = vars{i};
                        var = varInfo.(fieldVar).varName;
                        col = varInfo.(fieldVar).colNumber;

                        field = var;
                        %Get all the user information fill of this variable
                        fieldInfo = WebImport.getInfoUserImport(varInfo, field);

                        if isempty(fieldInfo) && strcmpi(field, 'Time')
                            fieldInfo.varLongName = 'Time';
                            fieldInfo.varUnit = 'days';
                            fieldInfo.dim = {'T'};
                        end;
                        if ~isempty(fieldInfo)
                            %Get the long name default set in Configuration Class.
                            varLongName = Configuration.getLongNameVariable(field);
                            %If the variable name is not defined in the predifened structure names
                            %it fills the longname field with the user information.
                            if strcmpi(varLongName, 'undefined')
                                if isempty(fieldInfo.varLongName)
                                    dataset.(field).longname = 'undefined';
                                else if ~isempty(fieldInfo)
                                        dataset.(field).longname = fieldInfo.varLongName;
                                    else
                                        dataset.(field).longname = 'undefined';
                                    end;
                                end;
                            else
                                dataset.(field).longname = varLongName;
                            end;

                            %Set the default unit
                            varUnit = Configuration.getUnitVariable(field);
                            if ~isempty(varUnit)
                                dataset.(field).unit = varUnit;
                            else
                                if ~isempty(fieldInfo)
                                    fieldInfo = Util.setDefault(fieldInfo,'varUnit','');
                                    dataset.(field).unit = fieldInfo.varUnit;
                                end;
                            end;

                            %set the data
                            if isfield(fieldInfo, 'originalName') && ~strcmp(fieldInfo.originalName, '[]')
                                colIndex = strfind(cColumns,fieldInfo.originalName);
                            else
                                %replace the empty values in the columns
                                cColumns(cellfun('isempty', cColumns)) = {''};
                                colIndex = strfind(cColumns,fieldInfo.varLongName);
                            end;
                            
                            if strcmpi(var, 'SampleName') && strcmpi(options.fileType, 'GRAIN')
                               dataset.(var).data = allData(1:end,1);
                            else
                                realColIndex = find(not(cellfun('isempty', colIndex)));
                                if ~isempty(realColIndex)
                                    dataset.(var).data = mData(:,realColIndex);
                                else
                                    dataset.(var).data = mData(:,i);
                                end;
                                
                                varSize = size(dataset.(var).data);
                                %assing the dimension based on the selected
                                %data type
                                switch lower(options.dataType)                                    
                                    case 'timeserie'
                                        if varSize(2) > 1
                                            dataset.(var).dim = {'T', 'J'};
                                        else
                                            dataset.(var).dim = {'I'};
                                        end
                                        
                                    case 'transect'
                                        if varSize(2) > 2
                                            dataset.(var).dim = {'I', 'J', 'K'};
                                        elseif varSize(2) > 1
                                            dataset.(var).dim = {'I', 'J'};
                                        else
                                            dataset.(var).dim = {'I'};
                                        end
                                        
                                    case 'map'
                                        
                                    otherwise
                                        if varSize(2) > 1
                                            dataset.(var).dim = {'I', 'J'};
                                        else
                                            dataset.(var).dim = {'I'};
                                        end
                                end
                                
                            end

                            
                        end;

                    end;

                    %Add the Z to the dataset.
                    if strcmpi(options.fileType, 'ADCP')
                        zData = [];
                        for kk=1:length(cColumns)
                            colText = cColumns{kk};
                            %search in the file for the Velocities
                            velText = regexp(colText, 'VelX.*\d+.*', 'match');
                            if isempty(velText)
                                continue;
                            end;
                            numberInText = regexp(velText, '\d+.*', 'match');
                            %find the numbers in the columns name
                            if ~isempty(numberInText)
                                zVal = str2double(numberInText{1});
                                zData = [zData;zVal];
                            end;
                        end;
                        %add the Z data to dataset
                        dataset.Z.data = zData;
                        dataset.Z.longname = 'Elevation';
                        dataset.Z.unit = 'm';
                        dataset.Z.dim = {'T'};
                    end
                    
                    if strcmpi(options.fileType, 'GRAIN')
                        resultLine = str2double(allData(2,:));
                        resultIdxStart = find(~isnan(resultLine), 1, 'first');
                        %add the Result Between User Sizes (Sizes in um)
                        dataset.ResultUserSize.data = str2double(allData(2,resultIdxStart:end))';                        
                        
                        dataset.ResultUserSize.longname = 'Result Between User Sizes';
                        dataset.ResultUserSize.unit = 'um';
                        dataset.ResultUserSize.dim = {'I'};
                    end

                    if isfield(dataset, 'TimeTime') && isfield(dataset, 'TimeDate')
                        if ~strcmp(options.fileType, 'OTHER')

                            %newTime = WebImport.transformTimeToImdcFormat(dataset.TimeDate.data, 'dd/mm/yy', '/');
                            %TODO: fix the time format
                            dateTime = Time.dateTime2Num(dataset.TimeDate.data, dataset.TimeTime.data,0);
                            %Add the time to dataset struct
                            dataset.Time.data = dateTime;
                        else
                            dataset.Time.data = dataset.TimeDate.data;
                        end;
                        %delete the all fields with time information
                        dataset = rmfield(dataset, 'TimeDate');
                        dataset = rmfield(dataset, 'TimeTime');
                        dataset.Time.longname = 'Time';
                        dataset.Time.dim = {'T'};
                        dataset.Time.unit = 'days';
                    end;

                    %Set the metadata to the dataset
                    for i=1:length(meta)
                        fieldMeta = meta{i};
                        if ~isempty(metaInfo.(fieldMeta))
                            metaName = metaInfo.(fieldMeta).metaName;
                            %The original name is the text readed from the
                            %source file
                            metaInfo.(fieldMeta) = Util.setDefault(metaInfo.(fieldMeta),'originalName','');
                            longMetaName = metaInfo.(fieldMeta).originalName;
                            if ~isempty(metaName)
                                dataset.(metaName).longname = longMetaName;
                                dataset.(metaName).value = metaInfo.(fieldMeta).metaValue;
                            end;
                        end;
                    end;

                    %add the vel and veldir to the dataset
                    dataset = Dataset.addFields(dataset, false);

                    %Set the default options to save the file
                    options = Util.setDefault(options,'outputFolder','');
                    options = Util.setDefault(options,'fileName','temp');

                    options.fileName = DynamicText.replaceBasicPatterns(originalName, '', nrFile);
                    fileName = char(strcat(options.outputFolder, '\', options.fileName));
                    finalFileName = [fileName '.mat'];

                    saveOk = Dataset.saveData(dataset,finalFileName);
                    if ~saveOk
                        errordlg('Error! the file could not be saved.');
                        return;
                    end;
                    %increment the number of file created.
                    nrFile = nrFile + 1;
                end;
            catch
                sct = lasterror;
                errordlg(['Error to get the IMDC Standard Format. Please check the data.' sct.message]);
                return;
            end;
        end;

        function varInfo = getInfoUserImport(allUserData, varShortName)
            %Function to get all the information about one specific
            %variable, the information is the user fill in the web
            %interface
            try
                varInfo = '';
                vars = fieldnames(allUserData);
                for i=1:length(vars)
                    fieldVar = vars{i};
                    var = allUserData.(fieldVar).varName;
                    if strcmpi(varShortName, 'Time')
                        if strcmpi(var, 'TimeDate') || strcmpi(var, 'TimeTime')
                            allUserData.(fieldVar).varName = 'Time';
                            allUserData.(fieldVar).varLongName = 'Time';
                            varInfo = allUserData.(fieldVar);
                            return;
                        end;
                    else
                        if strcmpi(var, varShortName)
                            varInfo = allUserData.(fieldVar);
                            return;
                        else
                            varInfo = '';
                        end;
                    end;

                end;
            catch
                sct = lasterror;
                errordlg(['Error The user information is not valid. Please check the data.' sct.message]);
                return;
            end;
        end;

        function [data, metaData, columns] = importData(options)
            %INPUT: options: struct with source and fileType
            try
                %set default values in the global options structure
                options = Util.setDefault(options,'source','');
                options = Util.setDefault(options,'fileType','');

                if isempty(options.source)
                    errordlg('You have to select a file');
                    return;
                end;

                if isempty(options.fileType)
                    errordlg('You have to select a fileType');
                    return;
                end;

                %determine if a source is a directory to convert
                if isdir(options.source)
                    if ~strcmp(options.source(end), '\')
                        options.source = [options.source '\'];
                    end;
                    options = Util.setDefault(options,'filesSelected','');
                    if ~isempty(options.filesSelected)
                        selectedFiles = regexp(options.filesSelected,';','split');
                    else
                        errordlg('You need to select the files to convert');
                        return;
                    end;

                    %get the first file selected for the preview.
                    %source = [options.source selectedFiles{1}];
                    source = [options.source selectedFiles{1}];
                else
                    source = options.source;
                end;

                switch options.fileType
                    case 'IMDC'
                        [data, metaData, columns] = Import.readImdcOldFormat(source);
                    case 'IMDC-STANDARD'
                        [data,metaData,columns] = Import.readImdcStandardFormat(source);
                    case 'OBS'
                        [data,metaData,columns] = Import.readObs(source);
                    case 'JME'
                        [data,metaData,columns] = Import.readJme(source);
                    case 'CTD'
                        [data,metaData,columns] = Import.readCtd(source);
                    case 'ADCP'
                        [data,metaData, columns] = Import.readAdcpCsv(source,1);
                    case 'GRAIN'
                        [data,metaData, columns] = Import.readGrainSize(source,1);
                    case 'RDR'
                        metaData = {};
                        [data,columns] = Import.readRDR(source);
                    case 'OTHER'
                        %Pass the flag to indicate is just to see the preview
                        options.preview = 1;
                        [data,metaData, columns] = WebImport.readGenericAscii(source, options);
                    otherwise
                        errordlg('Error in the file type selected.', 'Error');
                end;

                if isa(data, 'char')
                    errordlg('The file could not be readed. Please verify the format');
                    return;
                end;
            catch
                sct = lasterror;
                errordlg(['Error to read the source file. Please check the data.' sct.message]);
                return;
            end;

        end;

        function [data, metaData, colNames] = readGenericAscii(source, options)
            %in the interface options I need
            %options.dataLine is the number of line when the data start
            %colSeparator
            %colDate
            %colTime
            %colStrFormat is the format which the user define the column
            %replaceWithEmpty characters to be excluded in the file, replace with NaN
            %options.footerLines: Number where start the footer lines: Optional

            try
                data = [];
                if isempty(source)
                    errordlg('Error. You have to select a source file');
                    return;
                end;

                %set the default values
                options = Util.setDefault(options,'dataLine',0);
                options = Util.setDefault(options,'colDate',1);
                options = Util.setDefault(options,'colTime',1);
                options = Util.setDefault(options,'footerLines',0);

                options = Util.setDefault(options,'colSeparator',' ');
                options = Util.setDefault(options,'dateFormat','mm/dd/YYYY');
                options = Util.setDefault(options,'selectedTimeFormat','hh:mm:ss');
                options = Util.setDefault(options,'separatorDate','');

                options = Util.setDefault(options,'replaceWithEmpty','');
                

                %convert to number if the values are char.
                options = Util.setDefaultNumberField(options, 'dataLine');
                options = Util.setDefaultNumberField(options, 'colDate');
                options = Util.setDefaultNumberField(options, 'colTime');
                options = Util.setDefaultNumberField(options, 'footerLines');

                colDate       = options.colDate;
                colTime       = options.colTime;
                colSeparator  = options.colSeparator;
                separatorDate = options.separatorDate;

                fid = fopen(source, 'r');
                nrHeaderLines = options.dataLine - 1;
                totalLinesToRead = options.footerLines - options.dataLine;

                %Get the real characters in the separators.
                colSeparator  = WebExport.getRealFileSeparator(colSeparator);
                separatorDate = WebExport.getRealFileSeparator(separatorDate);

                useMultipleAsOne = 1;
                if ~any(strcmp(colSeparator,{' ','\t'}))
                    useMultipleAsOne = 0;
                end;

                %DATE TIME PROCESSING
                try
                    exampleDate = datestr(now,options.dateFormat);
                catch
                    sct = lasterror;
                    errordlg(sct.message);
                    return;
                end;

                %Find the special characters is in the date
                dateSeparator = regexprep(options.dateFormat, '\w+', '');
                [firstPartDate, secondPartDate, thirdPartDate] = deal('');
                strParts       = Time.getDateParts(exampleDate, dateSeparator);
                firstPartDate  = strParts{1};

                if length(strParts) > 1
                    if ~isempty(strParts{2})
                        secondPartDate = strParts{2};
                    else
                        secondPartDate = '';
                    end;
                end;

                if length(strParts) > 2
                    if ~isempty(strParts{3})
                        thirdPartDate = strParts{3};
                    else
                        thirdPartDate = '';
                    end;
                end;

                isStringDate = 0;
                if ~isempty(firstPartDate)
                    firstCheck = str2double(firstPartDate);
                    if isnan(firstCheck)
                        formatDate = '%s';
                        isStringDate = 1;
                    else
                        formatDate = '%f';
                    end;
                end;

                if ~isempty(secondPartDate)
                    secondCheck = str2double(secondPartDate);
                    if isnan(secondCheck)
                        formatDate = [formatDate '%s'];
                        isStringDate = 1;
                    else
                        formatDate = [formatDate '%f'];
                    end;
                end;

                if ~isempty(thirdPartDate)
                    thirdCheck = str2double(thirdPartDate);
                    if isnan(thirdCheck)
                        formatDate = [formatDate '%s'];
                        isStringDate = 1;
                    else
                        formatDate = [formatDate '%f'];
                    end;
                end;

                %Find the special characters is in the date
                dateSeparator = regexprep(options.dateFormat, '\w+', '');
                sizeDateSep   = length(dateSeparator);
                formatDate    = [];
                if sizeDateSep > 0
                    for i=1:sizeDateSep
                        formatDate = [formatDate '%f' dateSeparator(i)];
                    end;
                else
                    formatDate = '%s';
                end;

                if ~isempty(dateSeparator)
                    if strcmp(formatDate(end), dateSeparator(end))
                        formatDate = [formatDate '%f'];
                    end;
                end;
                lengthCharsDate = length(find(formatDate == '%'));

                %Find the special characters is in the time
                timeSeparator = regexprep(options.selectedTimeFormat, '\w+', '');
                sizeDateSep   = length(timeSeparator);
                timeFormat    = [];
                if sizeDateSep > 0
                    for i=1:sizeDateSep
                        timeFormat = [timeFormat '%f' timeSeparator(i)];
                    end;
                else
                    timeFormat = '%s';
                end;

                if ~isempty(timeSeparator)
                    if strcmp(timeFormat(end), timeSeparator(end))
                        timeFormat = [timeFormat '%f'];
                    end;
                end;

                %Is necesary verify if there is a string format in the date column in order
                %to proccess the textscan file.
                if isStringDate == 0;
                    %build the datetime string format
                    if colDate < colTime
                        %if the colseparator is different of date/time separator
                        if ~strcmp(colSeparator, separatorDate)
                            strDateTimeFormat = [formatDate separatorDate timeFormat];
                        else
                            strDateTimeFormat = [formatDate timeFormat];
                        end;
                    else
                        if ~strcmp(colSeparator, separatorDate)
                            strDateTimeFormat = [timeFormat separatorDate formatDate];
                        else
                            strDateTimeFormat = [timeFormat formatDate];
                        end;
                    end;
                else
                    %suppose the date/time format are string
                    strDateTimeFormat = '%s%s';
                end;

                %verify if there is two different char to separate the columns
                if ~strcmp(colSeparator, separatorDate)
                    newSeparator = [separatorDate colSeparator];
                else
                    newSeparator = colSeparator;
                end;

                lowerColValue = 0;
                if colDate < colTime
                    lowerColValue = colDate;
                else
                    lowerColValue = colTime;
                end;

                idxCharDate = find(strDateTimeFormat == 's');
                %END DATE TIME PROCESSING

                %colsNumber = length(strfind(firstLine, colSeparator));
                nBufSize = 10000;

                %verify if columns name exist
                posibleColsNames = {};
                mData = {};
                headerLines = {};
                readLimit = 0;
                if options.dataLine >= 1
                    nrLines = 1;
                    i = 1;
                    dataReadFlag = 0;
                    oneRead = 0;
                    while (~feof(fid)) %&& dataReadFlag == 0
                        %if the file has columns named
                        if nrHeaderLines ~= 0
                            if nrLines == nrHeaderLines
                                firstLineDataPos = ftell(fid);
                                posibleColsNames = fgetl(fid);
                                frewind(fid);
                                fseek(fid,firstLineDataPos,0);
                                %posibleColsNames = textscan(fid,'%s',colsNumber,'delimiter',colSeparator);
                            end;
                        end;

                        if nrLines == options.dataLine
                            firstLinePos = ftell(fid);
                            %get the number of columns in the file excluding the date/time
                            firstLine = fgetl(fid);
                            %excluding the columns of time and date.
                            excludedStrDateTime = strrep(strDateTimeFormat,'%', '%*');

                            %if the date and time are not the first columns in the file
                            if colDate > 2 || colTime > 2
                                if colTime < colDate
                                    otherColsBeforeDateTime = [repmat('%s', 1, colTime-1) excludedStrDateTime];
                                else
                                    otherColsBeforeDateTime = [repmat('%s', 1, colDate-1) excludedStrDateTime];
                                end;
                                newStrFormatFirstLine = [otherColsBeforeDateTime '%[^\n]'];
                            else
                                newStrFormatFirstLine = [excludedStrDateTime '%[^\n]'];
                            end;

                            try
                                if useMultipleAsOne == 0
                                    scanFirstLine = textscan(firstLine,newStrFormatFirstLine,'delimiter',sprintf(newSeparator), 'BufSize', nBufSize, 'ReturnOnError', 0);
                                else
                                    scanFirstLine = textscan(firstLine,newStrFormatFirstLine,'delimiter',sprintf(newSeparator), 'BufSize', nBufSize, 'MultipleDelimsAsOne', 1, 'ReturnOnError', 0);
                                end;
                                scanFirstLine{1} = strtrim(scanFirstLine{1});
                            catch
                                sct = lasterror;
                                errordlg([sct.message 'Please verify the split characters']);
                                return;
                            end;

                            if isempty(scanFirstLine{1})
                                errordlg('The characters indicated could not be found in the file. Please check them.');
                                return;
                            end;

                            %if date and time are the last columns in the file
                            if colDate > 2 || colTime > 2
                                newText = '';
                                celId = 1;
                                for kk=1:length(scanFirstLine)
                                    if kk == 1
                                        newText = char(scanFirstLine{kk});
                                    else
                                        if ~isempty(scanFirstLine{kk})
                                            newText = [newText sprintf(colSeparator) char(scanFirstLine{kk})];
                                        end;
                                    end;

                                end;
                                scanFirstLine{1} = newText;
                            end;
                            charFirstLine = char(scanFirstLine{1});

                            %get the format of the columns to read them.
                            if isstrprop(sprintf(colSeparator), 'wspace')
                                contentFirstLine = regexp(char(scanFirstLine{1}), sprintf(colSeparator), 'split');
                            else
                                contentFirstLine = regexp(char(scanFirstLine{1}), ['\' colSeparator], 'split');
                            end;
                            columnsFormats = '';
                            nrCols = 0;
                            tempLower = lowerColValue-1;
                            if tempLower == 0
                                tempLower = 1;
                            end;
                            for ii=1:length(contentFirstLine)
                                %if the time or date there is not in the first column.
                                if nrCols == tempLower
                                    if tempLower == 1
                                        columnsFormats = [strDateTimeFormat columnsFormats];
                                    else
                                        columnsFormats = [columnsFormats strDateTimeFormat];
                                    end;

                                    %add date and time
                                    nrCols = nrCols + 2;
                                end;

                                if ~isempty(contentFirstLine{ii})
                                    
                                    
                                    %try first split in numbers to exclude
                                    %this kind of things: 15.788S
%                                     value = textscan(contentFirstLine{ii}, '%f');
%                                     if isempty(value{1})
%                                         columnsFormats = [columnsFormats '%s'];
%                                     else
%                                         columnsFormats = [columnsFormats '%f'];
%                                     end;
                                    
                                    value = str2double(contentFirstLine{ii});
                                    if isnan(value)
                                        columnsFormats = [columnsFormats '%s'];
                                    else
                                        columnsFormats = [columnsFormats '%f'];
                                    end;
                                    %determine the numbers of columns in the file
                                    nrCols = nrCols + 1;
                                else
                                    % columnsFormats = [columnsFormats '%f'];
                                    % nrCols = nrCols + 1;
                                end;

                                if length(contentFirstLine) == 1 && ~isempty(strDateTimeFormat)
                                    columnsFormats = [strDateTimeFormat columnsFormats];
                                end;
                            end;
                        elseif (nrLines > options.dataLine)
                            %cell with the content of the data, excluding metadata
                            %if isempty(mData)
                            %extract the date and time
                            if ~strcmp(colSeparator, separatorDate)
                                newColSeparator = [separatorDate colSeparator];
                            end;

                            if isempty(mData)
                                frewind(fid);
                                fseek(fid,firstLinePos,0);
                                %read the data in block, if the file does not have
                                %more than one header this is the final block.
                                try
                                    if useMultipleAsOne == 0
                                        if totalLinesToRead > 0
                                            mData = textscan(fid,columnsFormats,totalLinesToRead,'delimiter',sprintf(newSeparator), 'BufSize', nBufSize);
                                            readLimit = 1;
                                        else
                                            mData = textscan(fid,columnsFormats,'delimiter',sprintf(newSeparator), 'BufSize', nBufSize);
                                        end;

                                    else
                                        if totalLinesToRead > 0
                                            mData = textscan(fid,columnsFormats,totalLinesToRead,'delimiter',sprintf(newSeparator), 'MultipleDelimsAsOne', 1, 'BufSize', nBufSize);
                                            readLimit = 1;
                                        else
                                            mData = textscan(fid,columnsFormats,'delimiter',sprintf(newSeparator), 'MultipleDelimsAsOne', 1, 'BufSize', nBufSize);
                                        end;
                                    end;
                                catch
                                    sct = lasterror;
                                    errordlg([sct.message 'Please verify the split characters']);
                                    return;
                                end;
                                oneRead = 1;
                            else
                                %read the next block of lines in the file
                                actualPos = ftell(fid);
                                %if readLimit == 1 assume that the file does not have
                                %multi header
                                if readLimit == 1
                                    try
                                        footerLinesData = textscan(fid,'%s%[^\n]','delimiter',sprintf(newSeparator), 'Headerlines', nrHeaderLines, 'BufSize', nBufSize);
                                    catch
                                        sct = lasterror;
                                        errordlg([sct.message 'Please verify the footer information']);
                                        return;
                                    end;
                                else
                                    try
                                        if useMultipleAsOne == 0
                                            continuationData = textscan(fid,columnsFormats,'delimiter',sprintf(newSeparator), 'Headerlines', nrHeaderLines, 'BufSize', nBufSize);
                                        else
                                            continuationData = textscan(fid,columnsFormats,'delimiter',sprintf(newSeparator), 'MultipleDelimsAsOne', 1, 'Headerlines', nrHeaderLines, 'BufSize', nBufSize);
                                        end;

                                    catch
                                        sct = lasterror;
                                        errordlg([sct.message 'Please verify the split characters']);
                                        return;
                                    end;

                                    sizeContData = size(continuationData);

                                    tempData = mData;
                                    if oneRead == 1
                                        %delete the last value of the first column
                                        if length(tempData) > 1
                                            if size(tempData{1},1) > size(tempData{2},1)
                                                tempData{1}(end) = [];
                                            end;
                                        end;
                                        oneRead = 0;
                                    end;
                                    mData = {};
                                    %build the matrix of data with all the blocks of
                                    %data readed.
                                    for jj=1:length(continuationData)
                                        if jj == 1
                                            if sizeContData(2) > 1
                                                if length(continuationData{1}) > length(continuationData{2})
                                                    mData(:,jj) = {[tempData{jj}(1:end); continuationData{jj}(1:end-1)]};
                                                else
                                                    mData(:,jj) = {[tempData{jj}(1:end); continuationData{jj}(1:end)]};
                                                end;
                                            else
                                                mData(:,jj) = {[tempData{jj}(1:end); continuationData{jj}(1:end-1)]};
                                            end;
                                        else
                                            mData(:,jj) = {[tempData{jj}(1:end); continuationData{jj}(1:end)]};
                                        end
                                    end
                                end;
                            end;

                            dataReadFlag = 1;
                        else
                            currentLine       = fgetl(fid);
                            actualHeaderParts = length(strfind(currentLine, sprintf(colSeparator)));
                            actualFormat      = repmat('%s', 1, actualHeaderParts);
                            headerLines{i}    = currentLine;
                            i = i + 1;
                        end;

                        %nr line in the file
                        nrLines = nrLines + 1;
                    end
                    %b = textscan(posibleColsNames, colNamesFormat, 'headerlines', headerLines,  'delimiter', colSeparator);
                end;

                %close the file id
                fclose(fid);

                %Only if the date has a string format.
                if isStringDate == 1
                    %verify if the file has multiple header
                    if oneRead == 1
                        firstPattern = ['\w' '{' num2str(length(firstPartDate)) ',' num2str(length(firstPartDate)) '}'];
                        secondPattern = ['\w' '{' num2str(length(secondPartDate)) ',' num2str(length(secondPartDate)) '}'];
                        if ~isempty(thirdPartDate)
                            thirdPattern = ['\w' '{' num2str(length(thirdPartDate)) ',' num2str(length(thirdPartDate)) '}'];
                            formatDateValidation = regexp(mData{1}, [firstPattern dateSeparator(1) secondPattern dateSeparator(2) thirdPattern]);
                        else
                            formatDateValidation = regexp(mData{1}, [firstPattern dateSeparator(1) secondPattern dateSeparator(2)]);
                        end;
                    else
                        errordlg('An error was occured. Please verify the data.');
                        return;
                    end;

                    %Get the index values where the data is not valid.
                    idxData = [];
                    if ~isempty(formatDateValidation)
                        for kk=1:length(formatDateValidation)
                            if isempty(formatDateValidation{kk})
                                idxData = [idxData;kk];
                            end;
                        end;
                    end;

                    %clean bad data
                    if ~isempty(idxData)
                        for kk=1:length(mData)
                            mData{kk}([idxData]) = [];
                        end;
                    end;
                    if colDate < colTime
                        tempDateTime = [char(mData{colDate}) repmat(' ',length(mData{colTime}),1) char(mData{colTime})];
                    else
                        tempDateTime = [char(mData{colTime}) repmat(' ',length(mData{colTime}),1) char(mData{colDate})];
                    end;

                    tempMatformat = datenum(tempDateTime);
                    data = [tempMatformat tempMatformat mData(:,3:end)];
                end;


                timeInMatFormat = [];
                if isStringDate == 0
                    colsInDate = length(find(formatDate =='f'));
                    colsInTime = length(find(timeFormat =='f'));
                    strDate = [];
                    contSep = 1;

                    tempDate = [];
                    tempTime = [];
                    if colDate == colTime
                        for kk=colDate:colsInDate
                            tempDate = [tempDate mData{kk}];
                        end;
                        for jj=colTime:colsInTime
                            newIdx = colsInDate+jj;
                            tempTime = [tempTime mData{newIdx}];
                        end;
                    else
                        if colDate < colTime
                            for kk=colDate:colsInDate
                                tempDate = [tempDate mData{kk}];
                            end;
                            for jj=1:colsInTime
                                newIdx = colsInDate+jj;
                                tempTime = [tempTime mData{newIdx}];
                            end;
                        else
                            for kk=colTime:colsInTime
                                tempTime = [tempTime mData{kk}];
                            end;
                            for jj=1:colsInDate
                                newIdx = colsInTime+jj;
                                tempDate = [tempDate mData{newIdx}];
                            end;
                        end
                    end;

                    if ~isempty(dateSeparator)
                        dateFormatParts = Time.getDateParts(options.dateFormat, dateSeparator);
                        [yearIndex, monthIndex, dayIndex] = deal([]);
                        for i=1:length(dateFormatParts)
                            if ~isempty(strfind(lower(dateFormatParts{i}),'y'))
                                yearIndex = i;
                                continue;
                            end
                            if ~isempty(strfind(lower(dateFormatParts{i}),'m'))
                                monthIndex = i;
                                continue;
                            end
                            if ~isempty(strfind(lower(dateFormatParts{i}),'d'))
                                dayIndex = i;
                                continue;
                            end
                        end;

                        strDate = [tempDate(:,yearIndex),tempDate(:,monthIndex),tempDate(:,dayIndex)];

                        timeFormatParts = Time.getDateParts(options.selectedTimeFormat, timeSeparator);
                        [hourIndex, minuteIndex, secondIndex] = deal([]);
                        for i=1:length(timeFormatParts)
                            if ~isempty(strfind(lower(timeFormatParts{i}),'h'))
                                hourIndex = i;
                                continue;
                            end
                            if ~isempty(strfind(lower(timeFormatParts{i}),'m'))
                                minuteIndex = i;
                                continue;
                            end
                            if ~isempty(strfind(lower(timeFormatParts{i}),'s'))
                                secondIndex = i;
                                continue;
                            end
                        end;

                        %build the format time/date in order to apply the datenum function
                        if secondIndex > 0
                            strDate = [strDate, tempTime(:,hourIndex),tempTime(:,minuteIndex),tempTime(:,secondIndex)];
                        else
                            strDate = [strDate, tempTime(:,hourIndex),tempTime(:,minuteIndex),tempTime(:,secondIndex),zeros(length(tempTime),1)];
                        end;

                        %convert time to matlab format
                        try
                            dateInMatFormat = datenum(strDate);
                            options = Util.setDefault(options,'preview',0);

                            %IMPROVE PERFORMANCE
                            if options.preview == 1
                                tempDateTime = dateInMatFormat;
                                %dateInMatFormat = datestr(tempDateTime, 'yyyymmdd');
                                strDateFormat = datestr(tempDateTime, 'yyyymmdd');
                                strTimeFormat = datestr(tempDateTime, 'HHMMSS');
                                numDateFormat = [];
                                numTimeFormat = [];
                                nrDateData = size(strDateFormat);
                                nrTimeData = size(strTimeFormat);
                                for i=1:nrDateData(1)
                                    numDateFormat(i) = str2double(strDateFormat(i,1:end));
                                end;
                                for i=1:nrTimeData(1)
                                    numTimeFormat(i) = str2double(strTimeFormat(i,1:end));
                                end;

                                dateInMatFormat = numDateFormat';
                                timeInMatFormat = numTimeFormat';
                            end;
                        catch
                            sct = lasterror;
                            errordlg([sct.message ' Error, the format date is not valid. Please verify the format.']);
                            return;
                        end;
                    else
                        dateInMatFormat = Time.dateTime2Num(str2double(mData{colDate}), str2double(mData{colTime}),0);
                    end;

                    %add the other columns to the data matrix
                    if ~isempty(colTime)
                        if ~isempty(timeInMatFormat)
                            if colDate < colTime
                                data = [dateInMatFormat timeInMatFormat];
                            else
                                data = [timeInMatFormat dateInMatFormat];
                            end;
                        else
                            data = [dateInMatFormat dateInMatFormat];
                        end;
                    else
                        data = [dateInMatFormat];
                    end;
                    lengthDate = colsInDate + colsInTime;
                    if lengthDate == 0
                        if ~isempty(colTime)
                            lengthDate = 2;
                        else
                            lengthDate = 1;
                        end;
                    end;
                    try
                        for i=lengthDate+1:length(mData)
                            if i == length(mData)
                                %If the last col has one more element, delete it
                                if length(mData{i})-1 == length(mData{i-1})
                                    mData{i}(end) = [];
                                end;
                            end;
                            %avoid concat when mData has text
                            if ~isa(mData{i}, 'cell')
                                data = [data, mData{i}];
                            else
                                cellContent = mData{i};
                                cellData = nan(length(cellContent), 1);
                                for jj=1:length(cellContent)
                                    if ~isempty(cellContent{jj})
                                        myTemp = textscan(cellContent{jj}, '%f');
                                        if ~isempty(myTemp{1})
                                            cellData(jj) = myTemp{1};
                                        end;
                                    end
                                end
                                
                                data = [data, cellData];
                            end;
                        end;
                    catch
                        sct = lasterror;
                        errordlg([sct.message ' Error, The file contains some invalid string. Please check the file']);
                        return;
                    end;
                end;

                if isa(data, 'cell')
                    data = cell2mat(data);
                end;

                sizeFinalData = size(data);
                %replace by NaN if the user selected
                if ~isempty(options.replaceWithEmpty)
                    replaceWithEmpty = Util.strsplit(options.replaceWithEmpty, ',');
                    for jj=1:length(replaceWithEmpty)
                        replaceNumber = str2double(replaceWithEmpty{jj});
                        for kk=1:sizeFinalData(2)
                            %prelocate data
                            mask = zeros(sizeFinalData(1),1);
                            mask = data(:, kk) == replaceNumber;
                            data(mask, kk) = NaN;
                        end
                    end;
                end;

                colNames = {};
                %return the same number of columns in the colsNames.
                tempColNames = textscan(posibleColsNames, '%s', 'delimiter', colSeparator);
                
                if ~isempty(tempColNames)
                    tempColNames = tempColNames{1};
                    %if time and date are in the same column, add other colname
                    if floor(options.colDate) == floor(options.colTime)
                        if options.colDate > options.colTime
                            tempColNames = {tempColNames{options.colTime}, 'Date', tempColNames{options.colTime+1:end}}';
                        else
                            tempColNames = {tempColNames{options.colDate}, 'Time', tempColNames{options.colDate+1:end}}';
                        end
                    end
                    
                    for jj=1:sizeFinalData(2)
                        colNames{1,jj} = tempColNames{jj,1};
                    end;
                end

                metaData = {};
            catch
                sct = lasterror;
                errordlg(sct.message);
                return;
            end;
        end;

        function newTime = transformTimeToImdcFormat(time, timeFormat, strSeparator)
            newTime     = [];
            timeParts   = {};
            formatParts = Time.getDateParts(timeFormat, strSeparator);

            monthIdx     = strfind(formatParts, 'm');
            realMonthIdx = find(not(cellfun('isempty', monthIdx)));

            dayIdx     = strfind(formatParts, 'd');
            realDayIdx = find(not(cellfun('isempty', dayIdx)));

            yearIdx     = strfind(formatParts, 'y');
            realYearIdx = find(not(cellfun('isempty', yearIdx)));

            for ii = 1:length(time)
                timeParts = Time.getDateParts(time(ii), strSeparator);

                tempFormat = [timeParts{realYearIdx} timeParts{realMonthIdx} timeParts{realDayIdx}];

                newTime = [newTime; str2num(tempFormat)];
            end;
        end;

    end
end