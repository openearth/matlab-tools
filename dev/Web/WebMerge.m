%Class to declare the most common WebMerge
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebMerge < handle
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
        function mergeData(file1, file2, coordinate, options)
            %merge data according to the selecting options from the webinterface
            % Options values:
            %   - mergeType: first, second, both, none
            %   - outputFolder
            %   - finalFileName

            if isempty(file1) || isempty(file2)
                errordlg('Error. You have to set the source and destination file.');
                return;
            end;

            if isempty(coordinate)
                errordlg('Error. You have to indicate the coordinate to merge.');
                return;
            end;

            if isdir(file1)
                errordlg('Error. You have to select a file in the origin source');
                return;
            end;

            [fromData, loadOk] = Dataset.loadData(file1,0);

            if ~loadOk
                errordlg('Error to read the source file. Please verify the format.');
                return;
            end;

            [toData, loadOk] = Dataset.loadData(file2,0);
            if ~loadOk
                errordlg('Error to read the destination file. Please verify the format.');
                return;
            end;

            if ~isfield(fromData, coordinate) || ~isfield(toData, coordinate)
                errordlg('Error. The selected coordinate does not exist in the files.');
                return;
            end;

            options = Util.setDefault(options,'mergeType','first');

            switch options.mergeType
                case 'first'
                    allCoordinateValues             = [fromData.(coordinate).data;toData.(coordinate).data];
                    uniqueValues                    = unique(allCoordinateValues);
                    datasetMerged                   = fromData;
                    datasetMerged.(coordinate).data = uniqueValues;
                case 'second'
                    allCoordinateValues             = [toData.(coordinate).data;fromData.(coordinate).data];
                    uniqueValues                    = unique(allCoordinateValues);
                    datasetMerged                   = toData;
                    datasetMerged.(coordinate).data = uniqueValues;
                case 'both'
                    allCoordinateValues             = [toData.(coordinate).data;fromData.(coordinate).data];
                    datasetMerged                   = toData;
                    datasetMerged.(coordinate).data = sort(allCoordinateValues);
                case 'none'
                    [~, indexesFrom, indexesTo] = intersect(fromData.(coordinate).data,toData.(coordinate).data);

                    newFrom = fromData;
                    newTo   = toData.dataset;

                    newFrom.(coordinate)(indexesFrom) = NaN;
                    newTo.(coordinate)(indexesTo)     = NaN;

                    newData = [newFrom.(coordinate);newTo.(coordinate)];
                    datasetMerged.(coordinate).data = newData;
                otherwise
                    errordlg('The selected method is Invalid.', 'Invalid method');
                    return;
            end

            %set the output directory
            options = Util.setDefault(options,'outputFolder','');
            if isempty(options.outputFolder)
                errordlg('Error. You have to select a folder to save the final file');
                return;
            end;

            %get the final file name including its path
            options = Util.setDefault(options,'fileName','temp');
            fileName = char(strcat(options.outputFolder, '\', options.fileName));
            finalFileName = [fileName '.mat'];

            saveOk = Dataset.saveData(datasetMerged,finalFileName);

            if ~saveOk
                errordlg('Error. The file could not been saved');
                return;
            end;
        end;
    end
end