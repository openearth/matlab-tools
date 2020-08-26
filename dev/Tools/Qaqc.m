%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef Qaqc < handle
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
        function dataSet = Lisst(dataSet, options)
            % This script validates data from LISST in standard IMDC matlab structure
            % (type100X and 200X) and flags the data
            %
            % eg:
            % dataSet = Qaqc.Lisst(dataSet);
            % 
            % INPUTS: - dataSet: IMDC data structure
            %         - optional: sctructure with fields
            %           * limitsOptTrans: matrix with upper and lower limits for optical transmission, default [0.3, 0.98];
            %           * limitsDepth: matrix with upper and lower limits for optical transmission, default [0.2, 1e];
            % OUTPUTS: standardised IMDC data structure with parameter fields as described
            %          by IMDC.
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 01/2018
            % Modified by:
            % Date:
            
            if nargin < 2
                options = [];
            end
            if ~isfield(options,'limitsOptTrans')
                options.limitsOptTrans = [0.3, 0.98];
            end
            if ~isfield(options,'limitsDepth')
                options.limitsDepth = [0.2 1e10];
            end
            
            if ~isfield(options,'limitsVolConcTot')
                options.limitsVolConcTot = [0 1e100];
            end
            if ~isfield(options,'flagValueSusp')
                options.flagValueSusp = 2; % suspicious
            end
            if ~isfield(options,'flagValueInvalid')
                options.flagValueInvalid = 5; % invalid;
            end
            if ~isfield(options,'QaqcFields')
                options.QaqcFields = {'SedConcVol';
                    'PSD';'PSDcum';'PSDmean';'PSDD32';'PSDD43';'PSDstd';...
                    'PSDskewness';'PSDkurtosis';'PSD50';'PSD10';'PSD90';...
                    'PSD20';'PSD80';'VolConcTot'};
            end
            
            % select field
            Allfields = fieldnames(dataSet);
            for i = 1:length(Allfields)
                TmpFields = fieldnames(dataSet.(Allfields{i}));
               if ~strcmpi(TmpFields,'data')
                   Allfields{i} = '';
               end
            end
            Allfields(strcmpi(Allfields,'')) = [];
            
            % LOGBOOK
            if isfield(dataSet,'metaData')
                dataSet.metaData.history = [dataSet.metaData.history;...
                    {getenv('UserName'), datestr(now,'dd-mm-yyyy'), 'Dataset was validated/checked by QAQC.Lisst'}];
            else
                 dataSet.metaData.history = {getenv('UserName'), datestr(now,'dd-mm-yyyy'), 'Dataset was validated/checked by QAQC.Lisst'};
            end
            
            % SUSPICOIUS
            options.flagValue = options.flagValueSusp;
            % flagging data on Optical transmission
            [dataSet.OptTrans, mask] = Qaqc.Limits(dataSet.OptTrans, options.limitsOptTrans, options);
            for i = 1:length(options.QaqcFields)
                field = options.QaqcFields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask,:) = options.flagValue;
            end
            
            % flagging data on Total volume concentrations (value > 0)
            if isfield(dataSet, 'VolConcTot')
                [dataSet.VolConcTot, mask] = Qaqc.Limits(dataSet.VolConcTot, options.limitsVolConcTot, options);
                for i = 1:length(options.QaqcFields)
                    field = options.QaqcFields{i};
                    dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                    dataSet.(field).flag_values(mask,:) = options.flagValue;
                end
            end
            
            % INVALID DATA
            options.flagValue = options.flagValueInvalid;
            % laser reference >0.1 otherwise invalid
            
            if isfield(dataSet,'LaserRef')
                [dataSet.LaserRef, mask] = Qaqc.Limits(dataSet.LaserRef, [0.1 5], options);
                for i = 1:length(Allfields)
                    field = Allfields{i};
                    dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                    dataSet.(field).flag_values(mask,:) = options.flagValue;
                end
                if sum(mask) > 0
                    warning('Contact Sequoia supplier. Transmission reference too low! Replacement laser?');
                     dataSet.metaData.history = [dataSet.metaData.history;...
                    {'QAQC.Lisst','', 'Contact Sequoia supplier. Transmission reference too low! Replacement laser?'}];
                end
            end
            % flagging invalid data on Optical transmission
            [dataSet.OptTrans, mask] = Qaqc.Limits(dataSet.OptTrans, [0.1 0.995], options);
            for i = 1:length(options.QaqcFields)
                field = options.QaqcFields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask,:) = options.flagValue;
            end
            if sum(dataSet.OptTrans.data < 0.1) > 0
                warning('LISST data is too turbid. Use another path way.');
                dataSet.metaData.history = [dataSet.metaData.history;...
                    {'QAQC.Lisst','', 'LISST data is too turbid. Use another path way.'}];
            end
            if sum(dataSet.OptTrans.data > 0.995) > 0
                warning('LISST data is too clean. Check the background file.');
                dataSet.metaData.history = [dataSet.metaData.history;...
                    {'QAQC.Lisst','', 'LISST data is too clean. Check the background file.'}];
            end
            % flagging invalid data on depth
            [dataSet.Depth, mask] = Qaqc.Limits(dataSet.Depth, options.limitsDepth, options);
            for i = 1:length(Allfields)
                field = Allfields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask,:) = options.flagValue;
            end
           
            
            %
           
             
            
        end
        
         function [data, mask] = Limits(data, limits, options)
             % This script validates data (matrix/imdc structure) based on
             % a lower and upper limit. In case of structure the data is
             % flagged otherwise outliers has been replaced by NaN
             %
             % eg:
             % data = Qaqc.Lisst(data, limits, options);
             %
             % INPUTS: - data: nxm matrix or 
             %                 structure containing field data
             %         - limits: 1x2 matrix (lower limit, upper limit)
             %         - options:
             %              * flagValue= default NaN or 2 (suspicous);
             %
             % OUTPUTS: data matrix, or standardised IMDC data structure with parameter fields as described
             %          by IMDC.
             % STEPS:-
             %
             % International Marine and Dredging Consultants, IMDC
             % Antwerp Belgium
             %
             %
             %% Written by: JCA
             %
             % Date: 01/2018
             % Modified by:
             % Date:
             
             % defaults
             if nargin < 3
                options = [];
             end
             
             if ~isfield(options,'flagValue')
                if isstruct(data)
                    options.flagValue = 2; % suspicious
                else
                    options.flagValue = nan;
                end
             end
             % script
             if isstruct(data)
                mask = data.data < limits(1) | data.data > limits(2);
                data = Qaqc.ExistFlagValues(data);               
                data.flag_values(mask) = options.flagValue; 
             else
                  mask = data < limits(1) | data > limits(2);
                  data(mask) = options.flagValue;
             end             
         end
                 
         function data = ExistFlagValues(data)
             
             if ~isfield(data,'flag_values')
                 data.flag_values = [];
             end
             
             if isempty(data.flag_values)
                 data.flag_values = zeros(size(data.data));
             end
         end
      
             
        function dataSet = adcpLT(dataSet, options)
            % This script validates data from ascpLT in standard IMDC matlab structure
            % and flags the data
            %
            % eg:
            % dataSet = Qaqc.Awac(dataSet);
            % 
            % INPUTS: - dataSet: IMDC data structure
            %         - optional: sctructure with fields
            %           * limitsOptTrans: matrix with upper and lower limits for optical transmission, default [0.3, 0.98];
            %           * limitsDepth: matrix with upper and lower limits for optical transmission, default [0.2, 1e];
            % OUTPUTS: standardised IMDC data structure with parameter fields as described
            %          by IMDC.
            % STEPS:-
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: JCA
            %
            % Date: 01/2018
            % Modified by:
            % Date:
            
            if nargin < 2
                options = [];
            end
            
            if ~isfield(options,'limitsDepth')
                options.limitsDepth = [0.5 1e10];
            end
            if ~isfield(options,'limitsVel')
                options.limitsVel = [0 5];
            end
            if ~isfield(options,'limitsDegrees')
                options.limitsDegrees = [0 360];
            end
            if ~isfield(options,'flagValueSusp')
                options.flagValueSusp = 2; % suspicious
            end
            if ~isfield(options,'flagValueInvalid')
                options.flagValueInvalid = 5; % invalid;
            end
            if ~isfield(options,'QaqcFields')
                options.QaqcFields = {'Vel';
                    'VelDir';'VelX';'VelY'};
            end
            
            if ~isfield(options,'correctDepth')
                options.correctDepth = false;
            end
            % select field
            Allfields = fieldnames(dataSet);
            for i = 1:length(Allfields)
                TmpFields = fieldnames(dataSet.(Allfields{i}));
               if ~strcmpi(TmpFields,'data')
                   Allfields{i} = '';
               end
            end
            Allfields(strcmpi(Allfields,'')) = [];
            
            % LOGBOOK
            if isfield(dataSet,'metaData')
                dataSet.metaData.history = [dataSet.metaData.history;...
                    {getenv('UserName'), datestr(now,'dd-mm-yyyy'), 'Dataset was validated/checked by QAQC.Awac'}];
            else
                 dataSet.metaData.history = {getenv('UserName'), datestr(now,'dd-mm-yyyy'), 'Dataset was validated/checked by QAQC.Lisst'};
            end
            
            % SUSPICOIUS
            options.flagValue = options.flagValueSusp;
            % flagging data on velocity
            [dataSet.Vel, mask] = Qaqc.Limits(dataSet.Vel, options.limitsVel, options);
            for i = 1:length(options.QaqcFields)
                field = options.QaqcFields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask) = options.flagValue;
            end
            
            % flagging data on direction
            [dataSet.VelDir, mask] = Qaqc.Limits(dataSet.VelDir, options.limitsDegrees, options);
            for i = 1:length(options.QaqcFields)
                field = options.QaqcFields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask) = options.flagValue;
            end
            
            % INVALID DATA
            options.flagValue = options.flagValueInvalid;
            % flagging invalid data on depth
            [dataSet.WatPress, mask] = Qaqc.Limits(dataSet.WatPress, options.limitsDepth, options);
            if options.correctDepth;
                dataSet.WatPress.rawData = dataSet.WatPress.data;
                dataSet.WatPress.data = dataSet.WatPress.data - dataSet.WatPress.data(1); % subtract first value
                if isfield(dataSet,'Depth')
                   dataSet.Depth.rawData = dataSet.Depth.data; 
                   dataSet.Depth.data = dataSet.Depth.data - dataSet.Depth.data(1); 
                end
            end
            if ~isfield(dataSet,'Depth')
                dataSet = Dataset.addDefaultVariableFields(dataSet, 'Depth');
                dataSet.Depth.data = dataSet.WatPress.data;
            end
            [dataSet.Depth, mask] = Qaqc.Limits(dataSet.Depth, options.limitsDepth, options);           
            for i = 1:length(Allfields)
                field = Allfields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask,:) = options.flagValue;
            end
            %flagging the cells above water surface
            binSize = median(diff(dataSet.DistBin.data));
            mask =[];
            for iS = 1:length(dataSet.Depth.data)
                mask(iS,:) = (dataSet.Depth.data(iS) - binSize) < dataSet.DistBin.data; % the cell needs positioned completely below the water surface 
            end
            mask = logical(mask);
            for i = 1:length(options.QaqcFields)
                field = options.QaqcFields{i};
                dataSet.(field) = Qaqc.ExistFlagValues(dataSet.(field));
                dataSet.(field).flag_values(mask) = options.flagValue;
            end
        end

    end
end