%Class to declare the most common WebExport
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebExport < handle
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
        function getOutputFormat(varInfo, metaInfo, options)
            %generate and output file in the format that the user select
            try
                options = Util.setDefault(options,'source','');
                if isempty(options.source)
                    errordlg('You have to select a source to convert.');
                    return;
                end;

                selectedFiles = [];
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

                selectedSubsets = [];
                options = Util.setDefault(options,'subsetsSelection','');
                if ~isempty(options.subsetsSelection)
                    selectedSubsets = regexp(options.subsetsSelection,';','split');
                end;

                vars = fieldnames(varInfo);
                meta = fieldnames(metaInfo);
                nrFile = 1;
                originalName = char(options.fileName);

                orderColumnText = {};
                for i=1:length(vars)
                    field = vars{i};
                    indexVarName = str2double(varInfo.(field).colNumber);
                    orderColumnText{indexVarName} = varInfo.(field).varShortName;
                end;

                %remove empty values
                orderColumnText(cellfun('isempty',orderColumnText)) = [];

                lengthSubsets = length(selectedSubsets);
                if lengthSubsets == 0
                    lengthSubsets = 1;
                end;
                %loop over all files selected.
                for kk=1:length(selectedFiles)
                    if isdir(options.source)
                        if ~strcmp(options.source(end), '\')
                            options.source = [options.source '\'];
                        end;
                        source = selectedFiles{kk};
                    else
                        source = options.source;
                    end;

                    %if the user does not select subset
                    try
                        if isempty(selectedSubsets)
                            lengthSubsets = 1;
                        else
                            conf = Configuration;
                            if isempty(exist('conf', 'var'))
                                conf = Configuration;
                            end;
                            options = Util.setDefault(options,'subsetFile','');
                            pathSubset = [conf.TEMP_FOLDER conf.TEMP_SUBSET_FOLDER '\' options.subsetFile];
                            load(pathSubset);
                        end;
                    catch
                        sct = lasterror;
                        errordlg(['Error to read the subset. Please check the data.' sct.message]);
                        return;
                    end;

                    [originalData,originalMetaData,originalCols] = Import.readImdcStandardFormat(source, orderColumnText);
                    %load the file in .mat
                    [originalDataset ~] = Dataset.loadData(source,0);
                    dataset = originalDataset;
                    dataset = Dataset.addFields(dataset, false);
                    originalColName = WebUtil.getOriginalColName(originalCols);

                    %Get the time column index.
                    timeColumn = find(strcmpi(originalColName, 'Time'));

                    %Loop over all subset selected
                    for ii=1:lengthSubsets
                        mData = originalData;
                        cColumns = originalCols;
                        cMetaData = originalMetaData;
                        fieldDataset = fieldnames(dataset);
                        varSelection = {};
                        try
                            for i=1:length(vars)
                                fieldVar = vars{i};
                                var = varInfo.(fieldVar).varShortName;
                                varSelection{i} = var;
                            end;
                            for i=1:length(fieldDataset)
                                ff = fieldDataset{i};
                                %if the field is not in selection It will be
                                %removed
                                if isfield(dataset.(ff), 'data')
                                    strVarDataset = ff;
                                    if isempty(find(strcmp(varSelection, strVarDataset), 1))
                                        indexCols = find(strcmp(originalColName, strVarDataset));
                                        %remove the columns from the data
                                        mData(:,indexCols) = [];
                                        %remove the column name
                                        cColumns(indexCols) = [];
                                    end;
                                end;
                            end;
                        catch
                            sct = lasterror;
                            errordlg(['Error to read the file. Please check the variables in the data.' sct.message]);
                            return;
                        end;

                        try
                            if ~isempty(selectedSubsets)
                                %Get the variable name in the subset division
                                varName = WebDataset.getVarSubsetDivision(subset);

                                %Get the data in the subset selection
                                subData  = WebDataset.getData(originalDataset.(varName),subset,str2num(selectedSubsets{ii}));

                                dataset.(varName).data = subData;
                                %Get the index according to the data extracted.
                                indexData = Util.getIndexOneD(originalDataset.(varName).data, subData);

                                newData = [];
                                newData = mData(indexData,:);
                            else
                                newData = mData;
                            end;
                        catch
                            sct = lasterror;
                            errordlg(['Error to get the subset selection. Please check the data.' sct.message]);
                            return;
                        end;

                        try
                            newMetadata = {};
                            for i=1:length(meta)
                                fieldMeta = meta{i};
                                %Set default metaName if not exist
                                metaInfo.(fieldMeta) = Util.setDefault(metaInfo.(fieldMeta),'metaName','');
                                metaText  = metaInfo.(fieldMeta).metaName;

                                %Set a default value to the sct if no exist the field
                                metaInfo.(fieldMeta) = Util.setDefault(metaInfo.(fieldMeta),'metaValue','');
                                metaValue = metaInfo.(fieldMeta).metaValue;

                                if ~isempty(metaText)
                                    %find the line where is the original metadata
                                    line = find(strcmpi(cMetaData, metaText));
                                    if ~isempty(line)
                                        %Set the text of the metadata
                                        newMetadata{i,1} = cMetaData{line,1};
                                        if ~isempty(metaValue)
                                            %set the value of metadata if exist
                                            newMetadata{i,2} = cMetaData{line,2};
                                        else
                                            newMetadata{i,2} = '';
                                        end;
                                    end;
                                end;
                            end;
                        catch
                            sct = lasterror;
                            errordlg(['Error to read the metadata. Please check the data.' sct.message]);
                            return;
                        end;

                        options = Util.setDefault(options,'outputFormat','');
                        %replace the name of the file with some patterns like
                        %autoincrements or dates.

                        options.fileName = DynamicText.replaceBasicPatterns(originalName, '', nrFile);
                        fileName = char(strcat(options.outputFolder, '\', options.fileName));

                        try
                            switch options.outputFormat
                                case 'IMDC_ASCII'
                                    finalFileName = [fileName '.txt'];
                                    colDecimals = [0 0];
                                    options = Util.setDefault(options,'stringAsciiFormat','');
                                    if ~isempty(options.stringAsciiFormat)
                                        colDecimals = str2num(options.stringAsciiFormat);
                                    end;
                                    Export.writeAsciiImdc(finalFileName, newData,'',cColumns,newMetadata,colDecimals,0);
                                case 'CSV'
                                    finalFileName = [fileName '.csv'];
                                    sctInput.strCSVFile = finalFileName;

                                    if ~isempty(timeColumn)
                                        %transform the time column in excel time
                                        %format.
                                        newData(:,timeColumn) = m2xdate(newData(:,timeColumn));
                                    end;

                                    sctInput.mData = newData;
                                    options = Util.setDefault(options,'applyHeader','');
                                    if ~isempty(options.applyHeader)
                                        options = Util.setDefaultNumberField(options, 'applyHeader');
                                        if options.applyHeader
                                            sctInput.cHeader = cColumns;
                                        end;
                                    end;

                                    options = Util.setDefault(options,'stringCsvFormat','');
                                    if ~isempty(options.stringCsvFormat)
                                        sctInput.strFormat = options.stringCsvFormat;
                                    end;

                                    options = Util.setDefault(options,'printMetadata','');
                                    if ~isempty(options.printMetadata)
                                        sctInput.printMetadata = options.printMetadata;
                                    end;

                                    Export.writeCsv(sctInput, newMetadata);
                                otherwise
                                    errordlg('Error in the file type selected.', 'Error');
                            end;
                        catch
                            sct = lasterror;
                            errordlg(['Error to write the file. ' sct.message]);
                            return;
                        end;

                        %increment the number of file created.
                        nrFile = nrFile + 1;
                    end;
                end;

            catch
                sct = lasterror;
                errordlg(['Error to convert the file. ' sct.message]);
                return;
            end;

            %save('C:\xampp\htdocs\codigoselecto\imdc_final\matlab_system\matlab\temp\debug\wkspc_getOutputFormat.mat');
        end;

        function realSeparator = getRealFileSeparator(colSeparator)
            %get the real char separator
            switch colSeparator
                case 'comma'
                    realSeparator = ',';
                case 'tab'
                    realSeparator = '\t';
                case 'space'
                    realSeparator = ' ';
                case 'colon'
                    realSeparator = ':';
                case 'semicolon'
                    realSeparator = ';';
                case 'pipe'
                    realSeparator = '|';
                otherwise
                    realSeparator = colSeparator;
            end;
        end;



    end
end