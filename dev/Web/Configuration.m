%Class to define the configuration variables in all the system. It is used
%for declare constants as well.
% @author ABR
% @author SEO
% @version 1.0, 
%

classdef Configuration < handle
    %Public properties
    properties
        
    end
    
    %Dependand properties
    properties (Constant)
        TEMP_FOLDER = 'C:\Windows\Temp\';
        TEMP_SUBSET_FOLDER = 'matlab_subset';
        TEMP_DATASET_FOLDER = 'matlab_dataset';
        DEBUG_FOLDER = 'C:\temp_matlab_system\debug\';
        
        %file name index dataset subset
        FILE_NAME_IDX_DS = 'indexDataset2Subset';
        
        VARIABLES = {'X', 'Y', 'Z', 'Lat', 'Long', 'Time', 'Sigma', 'Vel', 'VelDir', 'VelX', ...
            'VelY', 'VelZ', 'Q', 'WatLev', 'Depth', 'WatPress', 'AbsPress', 'GroundWatLev', ...
            'WaveHeight', 'WaveFreq', 'WavePeriod', 'WaveVel', 'WaveDir', 'WaveSpec', 'BotZ', ...
            'BotDep', 'GroundZ', 'OptTrans', 'BackScat', 'Turbidity', 'SedConc', ...
            'Density', 'GrainSizeDist', 'GranVar', 'SecchiDep', 'Compaction', 'SedType', ...
            'DryMatter', 'WaterContent', 'MudConcent', 'ClayContent', 'SandContent', 'GravelContent', ...
            'OrgCarbon', 'OrgMatter', 'SedSample', 'FallVel', 'ErFlux', 'DepFlux', 'BedFlux', 'BathEvol', ...
            'Boring', 'SubBotProf', 'PhysTest', 'Area', 'Vol', 'WindVelMag', 'WindVelDir', 'WindVelX', ...
            'WindVelY', 'Precipitation', 'Evaporation', 'Evapotrans', 'AtmHum', 'SolarRad', 'AirPress', ...
            'Irrad', 'Diatoms', 'MacroInv', 'Plankton', 'Vegetation', 'Fish', 'Birds', 'ZooAnimals', ...
            'NutrC', 'NutrN', 'NutrO2', 'NutrP', 'NutrS', 'NutrSi', 'Pigments', 'Cond', 'Sal', ...
            'Temp', 'Alcal', 'Chlor', 'PH', 'Hardmess', 'Metals', 'Paks', 'Pesticides', 'PCB', ...
            'Infrastructure', 'Plans', 'Photos', 'Diverse', 'IKLE', 'ZeroTime', 'TimeDate', 'TimeTime', ...
            'Dist', 'SampleName', 'D10', 'D20', 'D50', 'D80', 'D90', 'DsurfMean', 'DvolMean', 'GsdBelow2', 'GsdAbove2',...
            'GsdBelow63', 'GsdAbove63', 'GsdBelow4', 'Gsd2_63', 'Gsd4_63', 'Gsd63_2000', 'Gsd4_8', 'Gsd8_16', 'Gsd16_31',...
            'Gsd31_63', 'Gsd63_125', 'Gsd125_250', 'Gsd250_500', 'Gsd500_1000', 'Gsd1000_2000', 'GsdFreq'
            };
        
        VARS_LONGNAMES = {'Easting', 'Northing', 'Elevation', 'Latitude', 'Longitude', 'Time', 'Sigma coordinate', ...
            'Velocity magnitude', 'Velocity_direction', 'Velocity in x direction', 'Velocity in y direction', ...
            'Velocity in Z direction', 'Discharge', 'Surface elevation', 'Water depth', 'Water pressure', ...
            'absolute pressure', 'Ground water level', 'Wave height', 'Wave frequency', 'Wave period', ...
            'Wave orbital velocity amplitude magnitude', 'Wave direction', 'Wave spectra', ...
            'Bottom elevation', 'Bottom Depth', 'Ground level elevation', 'Optical transmission', ...
            'Backscatter', 'Turbidity', 'Sediment concentration', 'Density', 'Grain size distribution (granulometry)', ...
            'Granulometric variables', 'Secchi depth', 'Compaction', 'Sediment type', 'Dry matter', ...
            'Water content', 'Mud content', 'Clay content', 'Sand content', 'gravel content', 'Organic Carbon', ...
            'Organic matter', 'sediment sample', 'Sedimentation velocity', 'Erosion flux', 'Deposition flux', ...
            'Sedimentation/erosion', 'Bathymetric evolution', 'Boring', 'Subbottom profiling', 'Physical tests', ...
            'Areas', 'Volumes', 'Wind velocity magnitude', 'Wind velocity direction', 'Wind velocity in X direction', ...
            'Wind velocity in Y direction', 'Precipitation', 'Evaporation', 'Evapotranspiration', 'Atmospheric humidity', ...
            'Solar radiation', 'Air pressure', 'Irradiance', 'Diatoms', 'Macroinvertebrates', 'Plankton', ...
            'Vegetation', 'Fish', 'Birds', 'Zooanimals', 'Nutrients C', 'Nutrients N', 'Nutrients O2', ...
            'Nutrients P', 'Nutrients S', 'Nutrients Si', 'Pigments', 'Conductivity', 'Salinity', ...
            'Temperature', 'Alcalinity', 'Chlorinity', 'PH', 'Hardness', 'Metals', 'PAKs', 'Pesticides', ...
            'PCBs', 'Executed infrastucture works', 'Spatial execution plans', 'Photos', 'Diverse', 'IKLE','ZeroTime', 'TimeDate', 'TimeTime',...
            'Distance','Sample Name','Grain Size Distribution 10','Grain Size Distribution 20','Grain Size Distribution 50',...
            'Grain Size Distribution 80','Grain Size Distribution 90','Grain Size Distribution Surface weighted mean',...
            'Grain Size Distribution Volume weighted mean','Grain Size Distribution','Grain Size Distribution','Grain Size Distribution',...
            'Grain Size Distribution','Grain Size Distribution','Grain Size Distribution 2-63µm','Grain Size Distribution 4-63µm',...
            'Grain Size Distribution 63-2000µm','Grain Size Distribution 4-8µm','Grain Size Distribution 8-16µm','Grain Size Distribution 16-31µm',...
            'Grain Size Distribution 31-63µm','Grain Size Distribution 63-125µm','Grain Size Distribution 125-250µm',...
            'Grain Size Distribution 250-500µm','Grain Size Distribution 500-1000µm','Grain Size Distribution 1000-2000µm',...
            'Grain Size Distribution Mass Frequency'
            };
        
        UNITS = {'m','m','m','dec deg','dec deg','days','-','m/s','deg [nautical]','m/s','m/s','m/s','m3/s','m','m','dbar', ...
            'dbar','m','m','Hz','s','m/s','deg [nautical]','m2','m','m','m','-','-','NTU','mg/l','kg/m3','?','?','','','', ...
            '','-','-','-','-','-','','','','m/s','kg/m2/s','kg/m2/s','kg/m2/s','','','','','m2','m3','m/s','deg [nautical]', ...
            'm/s','m/s','mm','?','?','','','dbar','','','','','','','','','','','','','','','','mS/cm','psu','deg C','', ... 
            '','-','','','','','','','','','','', '','', '',...
            '','','µm','µm','µm','µm','µm','µm','µm','','','','','','','','','','','','','','','','','','',
            };
        
        TIME_VARS = {'Time','TransectTime'};
        PLOTS_COLORBAR = {'color_quiver', 'contour', 'polar'};
        NOAPPLY_LIMITS = {'polar', 'vertical_line', 'horizontal_line'};
        TITLE_FORMATS = {'dd-mmm','mmm-yyyy','mmm-yyyy','yyyy'};
        XTICK_FORMATS = {'HH:MM','dd-mmm','dd-mmm','dd-mmm'};
        
        GRID_SIZE = 50/2;
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Default constructor
    methods
        function obj = Configuration()
           
        end
    end
    
    %Set methods
    methods

    end
    
    %Get methods
    methods

    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'protected')

    end
    
    %% Static method    
    methods (Static)
        function varLongName = getLongNameVariable(varShortName)
            %Get the long name of a variable from your short name
            mapObj = containers.Map(Configuration.VARIABLES,Configuration.VARS_LONGNAMES);
            if ~isempty(varShortName) && isKey(mapObj,varShortName)
               varLongName = mapObj(varShortName);
            else
                varLongName = 'undefined';
            end
        end;
        
        function varShortName = getShortNameVariable(varLongName)
            %Get the short name of a variable from your long name
            mapObj = containers.Map(Configuration.VARS_LONGNAMES, Configuration.VARIABLES);
            if ~isempty(varLongName) && isKey(mapObj,varLongName)
                varShortName = mapObj(varLongName);
            else
                varShortName = 'undefined';
            end
        end;
        
        function varUnit = getUnitVariable(varShortName)
            %Get the long name of a variable from your short name
            mapObj = containers.Map(Configuration.VARIABLES,Configuration.UNITS);
            if ~isempty(varShortName) && isKey(mapObj,varShortName)
                varUnit = mapObj(varShortName);
            else
                varUnit = '';
            end
        end;
        
        function dataset = addExtraInfoDataset(dataset)
            %add the longname and unit fields to dataset
            fieldsDataset = fieldnames(dataset);
            for ii=1:length(fieldsDataset)
                field = fieldsDataset{ii};
                if isfield(dataset.(field), 'data')
                    %set the default value in the struct if it does not
                    %exist.
                    dataset.(field) = Util.setDefault(dataset.(field), 'longname', '');
                    dataset.(field) = Util.setDefault(dataset.(field), 'unit', '');
                    if isempty(dataset.(field).longname)
                        varLongName = Configuration.getLongNameVariable(field);
                        dataset.(field).longname = varLongName;
                    end;

                    if isempty(dataset.(field).unit)
                        varUnit = Configuration.getUnitVariable(field);
                        dataset.(field).unit = varUnit;
                    end;
                end;
            end;
        end;
    end
    
    
end