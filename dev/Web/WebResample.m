%Class to declare the most common WebResample
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebResample < handle
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
        function resampleData(from, to, coordinate, variable, options)
            % Resample data according to the  Web interface.
            % Options values:
            %    - start
            %    - end
            %    - averagin interval: avgInterval
            %    - max interpolation interval: interpInverval
            %    - resampleMethod : mean, sum, min, max, int
            %    - outputFolder
            %    - fileName

            if isempty(from) || isempty(to)
                errordlg('Error. You have to set the source and destination file.');
                return;
            end;

            if isempty(variable)
                errordlg('Error. You have to indicate the variable to copy.');
                return;
            end;

            if isempty(coordinate)
                errordlg('Error. You have to indicate the coordinate to copy.');
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

            [toData, loadOk] = Dataset.loadData(to,0);
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

            options = Util.setDefault(options,'resampleMethod','mean');

            try
                switch options.resampleMethod
                    case 'mean'
                        yNew = Resample.resampleMean(fromData.(coordinate).data, dataY, toData.(coordinate).data);
                    case 'sum'
                        yNew = Resample.resampleSum(fromData.(coordinate).data, dataY, toData.(coordinate).data);
                    case 'min'
                        yNew = Resample.resampleMin(fromData.(coordinate).data, dataY, toData.(coordinate).data);
                    case 'max'
                        yNew = Resample.resampleMax(fromData.(coordinate).data, dataY, toData.(coordinate).data);
                    case 'int'
                        yNew = Resample.resampleInt(fromData.(coordinate).data, dataY, toData.(coordinate).data);

                    otherwise
                        errordlg('The selected method is Invalid.', 'Invalid method');
                        return;
                end
            catch
                sct = lasterror;
                errordlg(sct.message);
                return;
            end;

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

            %build the new dataset
            newDataset = toData;
            newDataset.(variable).data = yNew;

            saveOk = Dataset.saveData(newDataset,finalFileName);

            if ~saveOk
                errordlg('Error. The file could not been saved');
                return;
            end;
        end


    end
end