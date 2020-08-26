%Class to replace some text patterns with some usefull data information,
%like dataset date, dataset author, etc.
% @author ABR
% @author SEO
% @version 1.0, 04/14/04
%

classdef DynamicText < handle
    %Public properties
    properties
        property1;
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
                obj.property1 = property1;
            end
        end
    end

    %Set methods
    methods
        function set.property1(obj,property1)
            obj.property1 = property1;
        end
    end

    %Get methods
    methods
        function property1 = get.property1(obj)
            property1 = obj.property1;
        end
    end

    %Public methods
    methods

    end

    %Private methods
    methods (Access = 'private')

    end

    %% Static methods
    methods (Static)
        function structArray =  copyArrayStrucField(structure,field)
            % copies a field from an array of structure to a cellarray
            % INPUT: structure: an array of structures
            %        field: the field name of the field to copy
            % OUTPUT: structArray: a cell array with the data of the structure

            nrStructure = length(structure);
            structArray = cell(nrStructure,1);
            for i = 1:nrStructure
                structArray{i} = structure(i).(field);
            end;
        end

        function textOut = dynamicText(textIn,dataset,subset,JJ)
            %replace patterns in string with dataset/subset information
            %Example:
            % dataset.name = 'AdcpData';
            % dataset.institute = 'IMDC';
            % dataset.Time.data = datenum([2010 1 1 0 0 0])+(0:20);
            % dataset.Time.dim = {'T'};
            % dataset.Time.unit = 'days';
            % dynText = 'data from $AdcpData.institute'
            % textOut = dynamicText(dynText,dataset,subset,jj)
            try
                %INPUT
                DYNSIGN = '$';
                WORDSEP  = ' ';
                LINESEP = '\n';

                % check if there is dynamic text, if not just copy output
                dynLocs  = (textIn == DYNSIGN);
                if ~any(dynLocs)
                    textOut = textIn;
                    return;
                end;

                % determine names of datasets and fields

                datasetName =  DynamicText.copyArrayStrucField(dataset,'name');
                if nargin >2
                    subsetName =  DynamicText.copyArrayStrucField(subset,'name');
                end;

                % parse text separate each lines

                cLines = regexp(textIn,'\n','split');
                %cLines = strsplit(textIn,LINESEP);
                nrLines = length(cLines);

                % parse each line
                textOut = cell(nrLines,1);
                for i = 1:nrLines
                    % look for each token
                    words = regexp(cLines{i},' ','split');
                    %words = strsplit(cLines{i},WORDSEP);
                    nrWords = length(words);
                    textOut{i} = [];

                    for j = 1:nrWords
                        theWord = words{j};
                        if isempty(theWord)
                            continue;
                        end;
                        % lookup  dynamic text
                        if theWord(1)~=DYNSIGN
                            textOut{i} = [textOut{i},' ',theWord];
                        else
                            %generate dynamic text

                            %dynParts = strSplit(theWord,'.');
                            dynParts      = regexp(theWord,'\.','split');
                            datasetIndex  = strcmpi(datasetName,dynParts{1}(2:end));
                            % subsetIndex = strcmpi(subsetName,dynParts(2));
                            myDataset     = dataset(datasetIndex);

                            % determine what to do based on the lengths of the parts
                            %
                            % dataset.something
                            %
                            nrDynParts = length(dynParts);
                            if nrDynParts == 2
                                parts = DynamicText.parseBrackets(dynParts{2});
                                if length(parts)>1
                                    % dataset.var()
                                    theData  = myDataset.(parts{1}).data;
                                    dataSize = size(theData);
                                    indices  = DynamicText.parseBetween(parts{2},JJ);
                                    linIndex = DynamicText.linindex(indices,dataSize);
                                    strTxt   = num2str(theData(linIndex));
                                else
                                    if isfield(myDataset,dynParts{2})
                                        % dataset.metadata
                                        strTxt = myDataset.(dynParts{2});
                                        if ~ischar(strTxt)
                                            strTxt = num2str(strTxt);
                                        end
                                    else
                                        % dataset.shortcut
                                        varName = DynamicText.shortcutVarName(dynParts{2});
                                        myData  = myDataset.(varName);
                                        theData = myData.data;
                                        strTxt  = DynamicText.shortcutValue(dynParts{2},theData);
                                    end
                                end

                            end;
                            %
                            % dataset.something.anotherthing
                            %
                            if nrDynParts==3
                                parts = DynamicText.parseBrackets(dynParts{2});
                                if length(parts)==1
                                    % no subset
                                    % dataset.var.metadata
                                    strTxt = myDataset.(dynParts{2}).(dynParts{3});
                                    if ~ischar(strTxt)
                                        strTxt = num2str(strTxt);
                                    end
                                else
                                    % with subset

                                    % find subset
                                    theIndex = strcmpi(parts{1},subsetName);
                                    mySubset = subset(theIndex);

                                    %find subsetindex
                                    if strcmpi(parts{2},'$loopIndex');
                                        theIndex = JJ;
                                    else
                                        theIndex = str2double(parts{2});
                                    end

                                    % process third part
                                    parts3 = DynamicText.parseBrackets(dynParts{3});
                                    if length(parts3)>1
                                        % dataset.subset().var()
                                        myData   = myDataset.(parts3{1});
                                        theData  = WebDataset.getData(myData,mySubset,theIndex);
                                        dataSize = size(theData);
                                        indices  = DynamicText.parseBetween(parts3{2},JJ);
                                        linIndex = DynamicText.linindex(indices,dataSize);
                                        strTxt   = num2str(theData(linIndex));
                                    else
                                        % dataset.subset().shortcut
                                        varName = DynamicText.shortcutVarName(parts3{1});
                                        myData  = myDataset.(varName);
                                        theData = WebDataset.getData(myData,mySubset,theIndex);
                                        strTxt  = DynamicText.shortcutValue(parts3{1},theData);
                                    end;
                                end;
                            end;
                            textOut{i} = [textOut{i},' ',strTxt];
                        end;

                    end;

                end;
            catch
                sct = lasterror;
                errordlg(['Error to apply the replacement pattern. Please check your information.' sct.message]);
                return;
            end;
        end;

        function index = linindex(input,dataSize)
            %Compute linear indices
            k = [1 cumprod(dataSize(1:end-1))];
            index = 1;
            for i = 1:length(input),
                index = index + (input(i)-1)*k(i);
            end
        end

        function indices = parseBetween(input,JJ)
            % find indices between brackets
            parts = regexp(input,'\,','split');
            if isempty(parts)
                if strcmpi(input,'$loopIndex')
                    indices = JJ;
                else
                    indices = str2double(input);
                end;
            else
                nrParts = length(parts);
                indices= zeros(1,nrParts);
                for i = 1:nrParts
                    if strcmpi(parts{i},'$loopIndex')
                        indices(i) = JJ;
                    else
                        indices(i) = str2double(parts{i});
                    end;
                end;
            end;
        end

        function parts = parseBrackets(input)
            % splits up parts between brackets
            parts = {''};
            bracketStart = find(input=='(');
            if isempty(bracketStart)
                parts = {input};
            else
                bracketEnd = find(input==')');
                if ~isempty(bracketEnd)
                    parts{1} = input(1:bracketStart-1);
                    parts{2} = input(bracketStart+1:bracketEnd-1);
                end;
            end;
        end

        function textOut = replaceBasicPatterns(textIn, subsetDate, JJ)
            %this function replace basic patterns in text, the patterns are
            %date and number in the file.
            %Input: textIn is the text to convert
            %SubsetDate is the date of the subset
            %JJ is the number of the file that would be replaced.

            try

                DYNSIGN = '$';
                WORDSEP  = ' ';
                LINESEP = '\n';

                % check if there is dynamic text, if not just copy output
                dynLocs  = (textIn == DYNSIGN);
                if ~any(dynLocs)
                    textOut = textIn;
                    return;
                end;

                % parse text separate each lines
                cLines = regexp(textIn,'\n','split');
                %cLines = strsplit(textIn,LINESEP);
                nrLines = length(cLines);

                % parse each line
                textOut = cell(nrLines,1);
                for i = 1:nrLines
                    % look for each token
                    words = regexp(cLines{i},'_','split');
                    %words = strsplit(cLines{i},WORDSEP);
                    nrWords = length(words);
                    textOut{i} = [];

                    for j = 1:nrWords
                        theWord = words{j};
                        if isempty(theWord)
                            continue;
                        end;
                        % lookup  dynamic text
                        if theWord(1)~=DYNSIGN
                            textOut{i} = [textOut{i},theWord];
                        else
                            %generate dynamic text

                            %dynParts = strSplit(theWord,'.');
                            dynParts = regexp(theWord,'\.','split');

                            nrDynParts = length(dynParts);
                            strTxt = '';
                            if nrDynParts == 1
                                nrCharacters = length(dynParts{1}(2:end));
                                if ~isempty(regexp(dynParts{1}(2:end), '^#'))
                                    strTxt = sprintf(strcat('%0', num2str(nrCharacters), 'd'), JJ);
                                else
                                    if ~isempty(regexp(dynParts{1}(2:end), '^Date'))
                                        if ~isempty(subsetDate)
                                            strTxt = datestr(nanmean(subsetDate),'yyyymmddTHHMMSS');
                                        else
                                            strTxt = datestr(now,'yyyymmddTHHMMSS');
                                        end;
                                    end;
                                end;
                            end;
                            textOut{i} = [textOut{i},'_',strTxt];
                        end;
                    end;
                end;
            catch
                sct = lasterror;
                errordlg(['Error to apply the replacement pattern. Please check your information.' sct.message]);
                return;
            end;
        end;

        function strTxt = shortcutValue(dynTxt,theData)
            % lookup shortcuts
            switch lower(dynTxt)
                case 'startmonth'
                    strTxt = datestr(theData(1),'mmm');
                case 'month'
                    strTxt = datestr(nanmean(theData),'mmm');
                case 'endmonth'
                    strTxt = datestr(theData(end),'mmm');
                case 'startyear'
                    strTxt = datestr(theData(1),'yyyy');
                case 'year'
                    strTxt = datestr(nanmean(theData),'yyyy');
                case 'endyear'
                    strTxt = datestr(theData(end),'yyyy');
                case 'startdate'
                    strTxt = datestr(theData(1),'dd-mmm');
                case 'date'
                    strTxt = datestr(nanmean(theData),'dd-mmm');
                case 'enddate'
                    strTxt = datestr(theData(end),'dd-mmm');
                case 'starttime'
                    strTxt = datestr(theData(1),'HH:MM');
                case 'time'
                    strTxt = datestr(nanmean(theData),'HH:MM');
                case 'endtime'
                    strTxt = datestr(theData(end),'HH:MM');
                otherwise
                    strTxt = 'UNDEFINED_SHORCUT';
            end;
        end

        function varName = shortcutVarName(dynTxt)
            % lookup shortcut variable name
            switch lower(dynTxt)
                case {'startmonth',  'month','endmonth', 'startyear','year', 'endyear','startdate','date','enddate','starttime','time','endtime'}
                    varName = 'Time';
                otherwise
                    varName = '';
            end;

        end

    end
end