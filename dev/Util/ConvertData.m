%Class to declare the most common ConvertData
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef ConvertData < handle
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
        function dataset = convertAirPressure(datasetFile, airPressureFile, options)
            if isnan(options.density) || options.density<=0
                errordlg('Wrong value for the density');
                return;
            end;

            if isnan(options.g) || options.g<=0
                errordlg('Wrong value for g');
                return;
            end;

            if isnan(options.level)
                errordlg('Wrong value for the reference level');
                return;
            end;
            try
                press2Depth = 1e4/(options.g * options.density);
                colPressBaro = options.colAirPressure;
                airPressureData = load(airPressureFile);
                load(datasetFile);

                timeBaro = Time.dateTime2Num(airPressureData(:,1),airPressureData(:,2));

                % interpoleren gaten in de barometer file
                vMask = isnan(airPressureData(:,colPressBaro));
                airPressureData(vMask) = interp1(timeBaro(~vMask),airPressureData(~vMask,colPressBaro),timeBaro(vMask));
                %interpoleren barometer data at times of pressure measurement

                vPresBaro = interp1(timeBaro,airPressureData(:,colPressBaro),dataset.Time);
                %extrapoleren luchtdrukdata mbv nearest neighbour
                vMask = isnan(vPresBaro);
                vPresBaro(vMask) = interp1(timeBaro,airPressureData(:,colPressBaro),dataset.Time(vMask),'nearest','extrap');

                if min(timeBaro)>min(dataset.Time) || max(timeBaro)<max(dataset.Time)
                    h = warndlg('The air pressure file does not include the complete measurement period. Extrapolation is used');
                end;

                if isfield(options, 'relativeYes')
                    vPresBaro  = vPresBaro - vPresBaro(1);
                end;

                %vWaterLevel = press2Depth.*(handles.mData(:,handles.nColPres) - vPresBaro) + nRef;
                %TODO - ask if handles.mData(:,handles.nColPres) is dataset.depth
                dataset.waterLevel = press2Depth.*(dataset.depth - vPresBaro) + nRef;
            catch
                errordlg('Cannot perform correction');
                return;
            end;
        end;

        function dataset = correctWaterLevel(dataFile)
            %TODO: spilt up loading water level data and use a general
            %structure
            %load water level file
            load(dataFile);
            % TODO preguntar que es mData
            vTime = Time.dateTime2Num(mData(:,1),mData(:,2));

            %interpolate water levels
            vWL = interp1(vTime,mData(:,3),myData.time);

            %calculate new reference levels and depths
            dataset.depth = vWL - myData.depth;
            dataset.Z = nanmean(vWL) - myData.Z;
        end;
    end
end