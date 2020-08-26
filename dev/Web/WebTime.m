%Class to declare the most common WebTime
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef WebTime < handle
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
        function convertTime(source, options)
            %change time by adding/subtracting
            if isempty(source)
                errordlg('Error. You have to set the source file.');
                return;
            end;

            [sourceData, loadOk] = Dataset.loadData(source,0);
            if ~loadOk
                errordlg('Error to read the source file. Please verify the format.');
                return;
            end;

            if ~isfield(sourceData, 'Time')
                errordlg('Error. The selected file does not have the Time variable.');
                return;
            end;

            %set default options.
            options = Util.setDefault(options,'type','days');
            options = Util.setDefault(options,'timeDifference',0);
            options = Util.setDefaultNumberField(options, 'timeDifference');

            %determine conversion factor
            switch options.type
                case 'seconds'
                    convertFactor = 1/(24*3600);
                case 'minutes'
                    convertFactor = 1/(24*60);
                case 'hours'
                    convertFactor = 1/24;
                case 'days'
                    convertFactor = 1;
                case 'weeks'
                    convertFactor = 7;
                otherwise
                    errordlg('Error. The conversion type is not valid');
                    return;
            end;
            % calculate time difference in days
            timeDifference = convertFactor * options.timeDifference;

            %apply the time correction
            newTime = sourceData.Time.data + timeDifference;
            sourceData.Time.data = newTime;

            %TODO SET THE TIME ZONE

            saveOk = Dataset.saveData(sourceData,source);
            if ~saveOk
                errordlg('Error. The file could not been saved');
                return;
            end;
        end;

    end
end