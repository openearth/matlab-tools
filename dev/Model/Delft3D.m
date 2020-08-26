%Class to declare the most common Delft3D
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Delft3D < handle
    %Public properties
    properties
        Property1;
        DELFT_ALL_MAP_VARS;
        DELFT_ALL_HIST_VARS;
    end
    
    %Dependand properties
    properties (Dependent = true, SetAccess = private)

    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    properties (Constant)
        DELFT_MAP_VARS = {'fileName', 'OUTPUT_LAYERS', 'S1', 'KFU', 'KFV', 'U1', 'V1', 'TAUKSI', ...
            'TAUETA', 'TAUMAX', 'UMNLDF', 'VMNLDF', 'VICUV', 'MNKSRC', 'WINDU', 'WINDV', 'PATM', ...
            'ITMAPC', 'FLOW_SIMDAT', 'FLOW_SYSTXT', 'FLOW_RUNTXT', 'FILE_VERSION', 'ITDATE', 'TZONE', ...
            'TUNIT', 'DT', 'SIMDAT', 'SELMAP', 'NMAX', 'MMAX', 'KMAX', 'LSTCI', 'LTUR', 'NOSTAT', 'NSRC', ...
            'NTRUV', 'GRDANG', 'XCOR', 'YCOR', 'XZ', 'YZ', 'ALFAS', 'KCU', 'KCV', 'KCS', 'DP0', 'DPS', ...
            'DPU0', 'DPV0', 'DRYFLP', 'NOROW', 'NOROCO', 'IROCOL', 'THICK', 'NAMCON', 'MNSTAT', ...
            'NAMST', 'NAMSRC', 'COORDINATES', 'LAYER_MODEL', 'GSQS', 'PPARTITION', 'ZK', 'VICWW', ...
            'D1', 'B1', 'DICWW', 'RICH', 'RHO', 'VORTIC', 'ENSTRO', 'NAMSED', 'WS', 'SBUU', 'SBVV', ...
            'SSUU', 'SSVV', 'RCA', 'BODSED', 'DPSED', 'DPS0', 'RTUR1', 'GRO'};
        
        DELFT_MAP_VARS_NEW_NAME = {'', '', 'WatLev', '', '', 'VelX', 'VelY', 'TauX', 'TauY', 'TauMax',...
            '', '', 'EddyViscH', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',...
            '', '', '', '', '', '', '', '', 'X', 'Y', 'Alpha', '', '', '', '', 'BotDepth', '', '', '', '',...
            '', '', 'Sigma', 'NameConst', '', '', '', '', '', '', '', 'Z', 'EddyViscV', 'Depth', 'BotZ',...
            'EddyDiffV', 'Richardson', 'Density', 'Vorticity', 'Entrophy', 'NameSed', 'FallVel', 'BedLoadX',...
            'BedLoadY', 'SuspLoadX', 'SuspLoadY', 'BedConc', 'SedAvaliable', 'SedThickness', 'BotDepthIni',...
            'Epsilon', 'Sal'};
        
        DELFT_HIST_VARS = {'ITHISC', 'fileName', 'FLOW_SIMDAT', 'FLOW_SYSTXT', 'FLOW_RUNTXT', ...
            'FILE_VERSION', 'ITDATE', 'TZONE', 'TUNIT', 'DT', 'SIMDAT', 'SELHIS', 'NOSTAT', 'NTRUV', ...
            'LSTCI', 'LTUR', 'KMAX', 'MNSTAT', 'XYSTAT', 'NAMST', 'GRDANG', 'ALFAS', 'DPS', 'THICK', ...
            'NAMCON', 'COORDINATES', 'LAYER_MODEL', 'ZKFS', 'ZWL', 'ZCURU', 'ZCURV', 'ZQXK', 'ZQYK', ...
            'ZTAUKS', 'ZTAUET', 'Dep', 'ZCURW', 'ZWS', 'ZBDSED', 'ZDPSED', 'ZDPS', 'ZSBU', 'ZSBV', ...
            'ZSSU', 'ZSSV', 'ZVICWW', 'ZDICWW', 'ZRICH', 'ZRHO', 'ZTUR', 'MNSTAT'};
        
        DELFT_HIST_VARS_NEW_NAME = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '',...
            '', '', '', '', 'ObsPoint', '', '', '', '', '', '', '', '', 'WatLev', 'VelX',...
            'VelY', 'DistX', 'DistY', '', '', 'Depth', 'VelZ', 'FallVel', 'SedAvaliable',...
            'SedThickness', 'BotDepth', 'BedLoadX', 'BedLoadY', 'SuspLoadX', 'SuspLoadY',...
            'EddyViscV', 'EddyDiffV', 'Richardson', 'Density', 'Epsilon', 'ObsPointIdx'};
        
        %ini variables to read by default
        DELFT_INI_VARS = {'ITDATE', 'ITMAPC', 'ITHISC', 'XYSTAT', 'DT', 'TUNIT', 'ALFAS'};
    end    

    
    %Default constructor
    methods
        function obj = Delft3D()
            %get all the Delft 3D variables and store them into a key/value map
            obj.DELFT_ALL_MAP_VARS = containers.Map(obj.DELFT_MAP_VARS,obj.DELFT_MAP_VARS_NEW_NAME);
            obj.DELFT_ALL_HIST_VARS = containers.Map(obj.DELFT_HIST_VARS,obj.DELFT_HIST_VARS_NEW_NAME);
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
        
        
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        function keyVarDelft = getDelftVarsToInclude(obj, myVariables, fileType)
            if nargin < 3
                fileType = 'trim';
            end;
            
            keyVarDelft = {};
            
            keyVarDelft = obj.DELFT_INI_VARS; %initial vars to load always
            for kk=1:length(myVariables)
                %get the original key from Delft
                if strcmpi(fileType, 'trim')
                    temp = Util.getKeyFromMapValue(obj.DELFT_ALL_MAP_VARS, myVariables{kk});
                else
                    temp = Util.getKeyFromMapValue(obj.DELFT_ALL_HIST_VARS, myVariables{kk});
                end;
                
                if ~isempty(temp)
                    keyVarDelft{length(keyVarDelft)+1} = temp;
                else
                    indexCell = strfind(keyVarDelft, myVariables{kk});
                    %look for the value index
                    key = find(not(cellfun('isempty', indexCell)));
                    if isempty(key)
                        keyVarDelft{length(keyVarDelft)+1} =  myVariables{kk};
                    end;
                end;
            end;

        end
        
    end
    
    %Stactic methods
    methods (Static)
        function sctOut = addDelftMetadata(sctOut, sctIn)
            %add the metadata to a delft variable Structure and clean
            %unnecesary fields
            elementFieldNames = fieldnames(sctIn);
            metadataNames     = Delft3D.lookupMetadata(elementFieldNames);
            
            for k = 1:length(metadataNames)
                if ~isempty(metadataNames{k})
                    sctOut.(metadataNames{k}) = sctIn.(elementFieldNames{k});
                end;
            end;
        end
        
        function delftDateTime = calcDelftTime(dataset)
            % calculates the time for delft3d and return the time info
            
            % get the initial time
            initialDate = dataset.ITDATE.data;
            
            yyyy        =  floor(initialDate(1)/1e4);
            mm          =  floor((initialDate(1)-yyyy*1e4)/100);
            dd          =  initialDate(1)-yyyy*1e4 - mm*1e2;
            startDate   = datenum([yyyy mm dd 0 0 0]);
            
            % get the conversion factor (to days)
            fac = dataset.TUNIT.data*dataset.DT.data /3600/24;
            
            % get time steps
            if isfield(dataset,'ITMAPC')
                dateTime = dataset.ITMAPC;
            else
                dateTime = dataset.ITHISC;
            end;
            
            newTimeData = startDate + fac.*dateTime.data;
            delftDateTime.data = newTimeData;
            delftDateTime.dim = {'T'};
            
            % put metadata in the Time structure and clean innecesary
            % fields
            delftDateTime = Delft3D.addDelftMetadata(delftDateTime, dateTime);
            
            % TODO: still look up if all times are needed. aklso see if
            % it works for his-files
        end
        
        function newDataset = cleanDelftDataset(dataset)
            %remove unnecesary fields from one dataset
            fieldsToRemove = {'ElmQuantity', 'ElmDefOffset', 'SizeDim', 'TypeVal', 'NByteVal', 'NByte'};
            
            if ~isa(dataset, 'struct')
                %return an empty struct;
                newDataset = struct;
                return;
            end;
            
            %initialize the newDataset with the original
            newDataset = dataset;
            datasetFields  = fieldnames(dataset);
            
            %loop over all variables
            for i=1:length(datasetFields)
                for j=1:length(fieldsToRemove) %loop over fields to remove
                    if isfield(dataset.(datasetFields{i}), fieldsToRemove{j})
                        %remove the current field.
                        newDataset.(datasetFields{i}) = rmfield(newDataset.(datasetFields{i}), fieldsToRemove{j});
                    end;
                end;
            end;
        end;
        
        function dataset = convertDelftFieldData(dataset,sctStructure)
            % non-trivial changes of variables
            
            % splitting up concentrations into sediment and salinity
            if isfield(sctStructure,'R1') && isfield(sctStructure.R1, 'data')
                sizeVar  = size(sctStructure.R1.size);
                nrVar    = sizeVar(end); %dataset.R1.size(end);
                
                nrDim    = length(sizeVar);%length(dataset.R1.size);
                nrSedVar = sctStructure.LSED.data;
                
                % check if there is sediment
                if nrSedVar > 0
                    % check if there is something else
                    if nrVar>nrSedVar
                        if nrDim == 3
                            dataset.Sal.data     = sctStructure.R1.data(:,:,1);
                            dataset.SedConc.data = sctStructure.R1.data(:,:,2:end);
                            dataset.Sal.dim      = {'I', 'J', 'K'};
                            dataset.SedConc.dim  = {'I', 'J', 'K'};
                        else % if nrDim ==4
                            dataset.Sal.data     = sctStructure.R1.data(:,:,:,1);
                            dataset.SedConc.data = sctStructure.R1.data(:,:,:,2:end);
                            dataset.Sal.dim      = {'I', 'J', 'K', 'M'};
                            dataset.SedConc.dim  = {'I', 'J', 'K', 'M'};
                        end
                        
                        %add metadata and clean fields
                        dataset.SedConc = Delft3D.addDelftMetadata(dataset.SedConc, sctStructure.R1);
                    end
                else
                    dataset.Sal.data = sctStructure.R1.data;
                end
                
                %add metadata and clean fields
                dataset.Sal = Delft3D.addDelftMetadata(dataset.Sal, sctStructure.R1);
            end
            
            % splitting up turbulence quantities
            if isfield(sctStructure,'RTUR1') && isfield(sctStructure.RTUR1, 'data')
                if nrDim == 3
                    dataset.K.data       = sctStructure.RTUR1.data(:,:,1);
                    dataset.Epsilon.data = sctStructure.RTUR1.data(:,:,2);
                    dataset.K.dim        = {'I', 'J', 'K'};
                    dataset.Epsilon.dim  = {'I', 'J', 'K'};
                else % if nrDim ==4
                    dataset.K.data       = sctStructure.RTUR1.data(:,:,:,1);
                    dataset.Epsilon.data = sctStructure.RTUR1.data(:,:,:,2);
                    dataset.K.dim        = {'I', 'J', 'K', 'M'};
                    dataset.Epsilon.dim  = {'I', 'J', 'K', 'M'};
                end
                
                %add metadata and clean fields
                dataset.K = Delft3D.addDelftMetadata(dataset.K, sctStructure.RTUR1);
                dataset.Epsilon = Delft3D.addDelftMetadata(dataset.Epsilon, sctStructure.RTUR1);
            end
            
            if isfield(sctStructure, 'GRO') && isfield(sctStructure.GRO, 'data')
                sizeVar  = size(sctStructure.GRO.size);
                nrVar    = sizeVar(end); %dataset.R1.size(end);
                
                nrDim    = length(sizeVar);%length(dataset.R1.size);
                nrSedVar = sctStructure.LSED.data;
                
                % check if there is sediment
                if nrSedVar > 0
                    % check if there is something else
                    if nrVar>nrSedVar
                        if nrDim == 3
                            dataset.Sal.data     = sctStructure.GRO.data(:,:,1);
                            dataset.SedConc.data = sctStructure.GRO.data(:,:,2:end);
                            dataset.Sal.dim      = {'I', 'J', 'K'};
                            dataset.SedConc.dim  = {'I', 'J', 'K'};
                        else % if nrDim ==4
                            dataset.Sal.data     = sctStructure.GRO.data(:,:,:,1);
                            dataset.SedConc.data = sctStructure.GRO.data(:,:,:,2:end);
                            dataset.Sal.dim      = {'I', 'J', 'K', 'M'};
                            dataset.SedConc.dim  = {'I', 'J', 'K', 'M'};
                        end
                        
                        %add metadata and clean fields
                        dataset.SedConc = Delft3D.addDelftMetadata(dataset.SedConc, sctStructure.GRO);
                    end
                else
                    dataset.Sal.data = sctStructure.GRO.data;
                end
                
                %add metadata and clean fields
                dataset.Sal = Delft3D.addDelftMetadata(dataset.Sal, sctStructure.GRO);
            end;
            
            if isfield(sctStructure, 'ZTUR') && isfield(sctStructure.ZTUR, 'data')
                sizeVar  = size(sctStructure.ZTUR.size);
                nrDim    = length(sizeVar);
                if nrDim == 3
                    dataset.K.data       = sctStructure.ZTUR.data(:,:,1);
                    dataset.Epsilon.data = sctStructure.ZTUR.data(:,:,2);
                    dataset.K.dim        = {'I', 'J', 'K'};
                    dataset.Epsilon.dim  = {'I', 'J', 'K'};
                else % if nrDim ==4
                    dataset.K.data       = sctStructure.ZTUR.data(:,:,:,1);
                    dataset.Epsilon.data = sctStructure.ZTUR.data(:,:,:,2);
                    dataset.K.dim        = {'I', 'J', 'K', 'M'};
                    dataset.Epsilon.dim  = {'I', 'J', 'K', 'M'};
                end
                
                %add metadata and clean fields
                dataset.K       = Delft3D.addDelftMetadata(dataset.K, sctStructure.ZTUR);
                dataset.Epsilon = Delft3D.addDelftMetadata(dataset.Epsilon, sctStructure.ZTUR);
            end;
            
            % calculating discharge for his file
            if isfield(sctStructure, 'ZQXK') && isfield(sctStructure.ZQXK, 'data')
                alfa = sctStructure.ALFAS.data;
                UX   = sctStructure.ZQXK.data;
                UY   = sctStructure.ZQYK.data;
                
                sizeU = size(UX);
                nrDim = length(sizeU);
                
                dataset.DistX.data = zeros(sizeU);
                dataset.DistY.data = zeros(sizeU);
                
                if nrDim == 3
                    for i = 1:sizeU(2)
                        
                        %rotate values
                        dataset.DistX.data(:,i,:) = cosd(alfa(i)).*UX - sind(alfa(i)).*UY;
                        dataset.DistY.data(:,i,:) = sind(alfa(i)).*UX + cosd(alfa(i)).*UY;
                    end
                    dataset.DistX.dim = {'Time', 'nrPoints', 'Z'};
                    dataset.DistY.dim = {'Time', 'nrPoints', 'Z'};
                elseif nrDim == 2
                    
                    for i=1:numel(UX(1,:))
                        %rotate values
                        dataset.DistX.data(:,i) = cosd(alfa(i)).*UX(:,i) - sind(alfa(i)).*UY(:,i);
                        dataset.DistY.data(:,i) = sind(alfa(i)).*UX(:,i) + cosd(alfa(i)).*UY(:,i);
                    end;
                    
                    %add the dimension
                    dataset.DistX.dim = {'Time', 'nrPoints'};
                    dataset.DistY.dim = {'Time', 'nrPoints'};
                else

                    %rotate values
                    dataset.DistX.data = cosd(alfa).*UX' - sind(alfa).*UY;
                    dataset.DistY.data = sind(alfa).*UX' + cosd(alfa).*UY;
                    
                    %add the dimension
                    dataset.DistX.dim = {'Time'};
                    dataset.DistY.dim = {'Time'};                    
                end
                
                %add metadata and clean fields
                dataset.DistX = Delft3D.addDelftMetadata(dataset.DistX, sctStructure.ZQXK);
                dataset.DistY = Delft3D.addDelftMetadata(dataset.DistY, sctStructure.ZQYK);
            end;
            
            % calculating velocities for his file
            if isfield(sctStructure,'ZCURU') && isfield(sctStructure.ZCURU, 'data') % only availbale in hist data (at zeta points)
                alfa = sctStructure.ALFAS.data;
                UX   = sctStructure.ZCURU.data;
                UY   = sctStructure.ZCURV.data;
                
                sizeU = size(UX);
                nrDim = length(sizeU);
                
                dataset.VelX.data = zeros(sizeU);
                dataset.VelY.data = zeros(sizeU);
                
                if nrDim == 3
                    for i = 1:sizeU(2)

                        
                        %rotate values
                        dataset.VelX.data(:,i,:) = cosd(alfa(i)).*UX - sind(alfa(i)).*UY;
                        dataset.VelY.data(:,i,:) = sind(alfa(i)).*UX + cosd(alfa(i)).*UY;
                    end
                    dataset.VelX.dim = {'Time', 'nrPoints', 'Z'};
                    dataset.VelY.dim = {'Time', 'nrPoints', 'Z'};
                elseif nrDim == 2

                    
                    for i=1:numel(UX(1,:))
                        %rotate values
                        dataset.VelX.data(:,i) = cosd(alfa(i)).*UX(:,i) - sind(alfa(i)).*UY(:,i);
                        dataset.VelY.data(:,i) = sind(alfa(i)).*UX(:,i) + cosd(alfa(i)).*UY(:,i);
                    end;
                    
                    %add the dimension
                    dataset.VelX.dim = {'Time', 'nrPoints'};
                    dataset.VelY.dim = {'Time', 'nrPoints'};
                else                    
                    
                    %rotate values
                    dataset.VelX.data = cosd(alfa).*UX' - sind(alfa).*UY;
                    dataset.VelY.data = sind(alfa).*UX' + cosd(alfa).*UY;                    
                    
                    %add the dimension
                    dataset.VelX.dim = {'Time'};
                    dataset.VelY.dim = {'Time'};                    
                end
                
                %add metadata and clean fields
                dataset.VelX = Delft3D.addDelftMetadata(dataset.VelX, sctStructure.ZCURU);
                dataset.VelY = Delft3D.addDelftMetadata(dataset.VelY, sctStructure.ZCURV);
            end
            
            % calculating velocities for map file
            if isfield(sctStructure,'U1') && isfield(sctStructure.U1, 'data')
                %get the time size
                timeSize = size(sctStructure.Time.data,1);
                
                alfa = sctStructure.ALFAS.data;
                uX   = sctStructure.U1.data;
                uY   = sctStructure.V1.data;
                
                sizeU = size(uX);
                timeIdx = find(timeSize == sizeU);
                nrDim = length(sizeU);
                
                if nrDim == 3
                    dataset.VelX.data = zeros(sizeU);
                    dataset.VelY.data = zeros(sizeU);
                    for i = 1:sizeU(timeIdx)
                        %interpolate values
                        if timeIdx == 1
                            newUX = Interpolate.uVarAtC(squeeze(uX(i,:,:)));
                            newUY = Interpolate.vVarAtC(squeeze(uY(i,:,:)));
%                             newUX = squeeze(uX(i,:,:));
%                             newUY = squeeze(uY(i,:,:));
                            %rotate values
                            dataset.VelX.data(i,:,:) = cosd(alfa).*newUX - sind(alfa).*newUY;
                            dataset.VelY.data(i,:,:) = sind(alfa).*newUX + cosd(alfa).*newUY;
                        else
                            newUX = Interpolate.uVarAtC(uX(:,:,i));
                            newUY = Interpolate.vVarAtC(uY(:,:,i));
%                             newUX = uX(:,:,i);
%                             newUY = uY(:,:,i);                            
                            %rotate values
                            dataset.VelX.data(:,:,i) = cosd(alfa).*newUX - sind(alfa).*newUY;
                            dataset.VelY.data(:,:,i) = sind(alfa).*newUX + cosd(alfa).*newUY;
                        end
                    end
                    
                    dataset.VelX.dim = {'I', 'J', 'K'};
                    dataset.VelY.dim = {'I', 'J', 'K'};
                else
                    %interpolate values
                    newUX = Interpolate.uVarAtC(uX);
                    newUY = Interpolate.vVarAtC(uY);
%                     newUX = uX;
%                     newUY = uY;  
                    %rotate values
                    dataset.VelX.data = cosd(alfa).*newUX - sind(alfa).*newUY;
                    dataset.VelY.data = sind(alfa).*newUX + cosd(alfa).*newUY;
                    
                    %add the dimension
                    dataset.VelX.dim = {'I', 'J'};
                    dataset.VelY.dim = {'I', 'J'};
                end;
                
                %add metadata and clean fields
                dataset.VelX = Delft3D.addDelftMetadata(dataset.VelX, sctStructure.U1);
                dataset.VelY = Delft3D.addDelftMetadata(dataset.VelY, sctStructure.V1);
            end
            
            % calculating Bottom stress for map file
            if isfield(sctStructure,'TAUKSI') && isfield(sctStructure.TAUKSI, 'data')
                timeSize = size(sctStructure.Time.data,1);
                alfa = sctStructure.ALFAS.data;
                u    = sctStructure.TAUKSI.data;
                v    = sctStructure.TAUETA.data;
                
                sizeU = size(u);
                timeIdx = find(timeSize == sizeU);
                nrDim = length(sizeU);
                
                if nrDim == 3
                    %TODO: verify the 3D case
                    dataset.TauX.data = zeros(sizeU);
                    dataset.TauY.data = zeros(sizeU);
                    for i = 1:sizeU(timeIdx)
                        if timeIdx == 1
                            newUX = Interpolate.uVarAtC(squeeze(uX(i,:,:)));
                            newUY = Interpolate.vVarAtC(squeeze(uY(i,:,:)));
                            
                            %rotate values
                            dataset.TauX.data(i,:,:) = cosd(alfa).*newUX - sind(alfa).*newUY;
                            dataset.TauY.data(i,:,:) = sind(alfa).*newUX + cosd(alfa).*newUY;
                        else
                            %interpolate values
                            newUX = Interpolate.uVarAtC(u(:,:,i));
                            newUY = Interpolate.vVarAtC(v(:,:,i));
                            
                            %rotate values
                            dataset.TauX.data(:,:,i) = cosd(alfa).*newUX - sind(alfa).*newUY;
                            dataset.TauY.data(:,:,i) = sind(alfa).*newUX + cosd(alfa).*newUY;
                        end                        
                    end
                    
                    %add the dimension
                    dataset.TauX.dim = {'I', 'J', 'K'};
                    dataset.TauY.dim = {'I', 'J', 'K'};
                else
                    %interpolate values
                    newUX = Interpolate.uVarAtC(u);
                    newUY = Interpolate.vVarAtC(v);
                    
                    %rotate values
                    dataset.TauX.data = cosd(alfa).*newUX - sind(alfa).*newUY;
                    dataset.TauY.data = sind(alfa).*newUX + cosd(alfa).*newUY;
                    
                    %add the dimension
                    dataset.TauX.dim = {'I', 'J'};
                    dataset.TauY.dim = {'I', 'J'};
                end;
                
                %add metadata and clean fields
                dataset.TauX = Delft3D.addDelftMetadata(dataset.TauX, sctStructure.TAUKSI);
                dataset.TauY = Delft3D.addDelftMetadata(dataset.TauY, sctStructure.TAUETA);
            end            

            
            % TODO: nog afmaken
        end
        
        function dataset = convertDelftFieldHeader(dataset)
            % non-trivial changes of variables
            
            % splitting up concentrations into sediment and salinity
            if isfield(dataset,'R1')
                nrVar    = dataset.R1.size(end);
                nrSedVar = dataset.LSED.data;
                % check if there is sediment
                if nrSedVar > 0
                    % check if there is something else
                    dataset.SedConc.data = [];
                    if nrVar>nrSedVar
                        dataset.Sal.data = [];
                    end
                else
                    dataset.Sal.data = [];
                end
            end
            
            
            % splitting up turbulence quantities
            if isfield(dataset,'RTUR1')
                dataset.K.data       = [];
                dataset.Epsilon.data = [];
            end
            
            % calculating velocities at C-nodes
            
            % TODO: nog afmaken
        end
        
        function dataset = convertDelftFieldName(datasetIn, dataset, varsToAdd)
            % change fieldnames in delft3d
            
            %inclue all the variables existing in the datasetIn
            if nargin < 3
                varsToAdd = {};
            end
                        
            fieldName = fieldnames(datasetIn);
            nrField   = length(fieldName);
            delftObj = Delft3D;
            
            fileType = 'trim';
            idxFileType = strfind(datasetIn.fileName, 'trim');
            if isempty(idxFileType)
                fileType = 'trih';
            end;
            
            for i = 1:nrField
                theField = fieldName{i};
                newName = {''};
                try
                    if strcmpi(fileType, 'trim')
                        if delftObj.DELFT_ALL_MAP_VARS.isKey(theField)
                            newName = delftObj.DELFT_ALL_MAP_VARS.values({theField});
                        end;
                    else
                        if delftObj.DELFT_ALL_HIST_VARS.isKey(theField)
                            newName = delftObj.DELFT_ALL_HIST_VARS.values({theField});
                        end;
                    end;
                    
                    newName = newName{1,1};
                catch
                    errorlog = ['The field does not exist in the current dataset' theField];
                end;

                addVar = 1;
                if ~isempty(newName)                                        
                    if ~isempty(varsToAdd)
                        if ~any(strcmpi(theField, varsToAdd))
                            addVar = 0;
                        end;
                    end;
                    
                    %if the var is included 
                    if addVar
                        if isfield(datasetIn.(theField), 'data')
                            dataset.(newName).data = datasetIn.(theField).data;
                        end;
                        
                        % put metadata in a structure
                        elementFieldNames = fieldnames(datasetIn.(theField));
                        metadataNames     = Delft3D.lookupMetadata(elementFieldNames);
                        
                        for k = 1:length(metadataNames)
                            if ~isempty(metadataNames{k})
                                dataset.(newName).(metadataNames{k}) = datasetIn.(theField).(elementFieldNames{k});
                            end;
                        end;
                    end
                end
            end
        end
        
        function dataset = getCoordinatesData(dataset,sctStructure)
            %get the coordinates for the hist file
            if isfield(sctStructure,'XYSTAT') && isfield(sctStructure.XYSTAT, 'data')
                dataCoor = squeeze(sctStructure.XYSTAT.data);
                x = dataCoor(1,:)';
                y = dataCoor(2,:)';
                
                dataset.X.data = x;
                dataset.Y.data = y;
                
                %add the dimension
                dataset.X.dim = {'I'};
                dataset.Y.dim = {'J'};
                
                %add additional metadata
                dataset.X = Delft3D.addDelftMetadata(dataset.X, sctStructure.XYSTAT);
                dataset.Y = Delft3D.addDelftMetadata(dataset.Y, sctStructure.XYSTAT);
            end
        end;
        
        function   outputNames = lookupMetadata(inputNames)
            % return the IMDC standar names according to the Delft3d field
            nrInput     =  length(inputNames);
            outputNames = cell(1,nrInput);
            for i = 1:nrInput
                switch  inputNames{i}
                    case 'ElmName'
                        outputNames{i} = 'originalname';
                    case 'ElmUnits'
                        outputNames{i} = 'unit';
                    case 'ElmDescription'
                        outputNames{i} = 'longname';
                    case 'NDim'
                        outputNames{i} = '';
                    case 'SizeDim'
                        outputNames{i} = '';
                    case 'TypeVal'
                        outputNames{i} = '';
                    case 'NByteVal'
                        outputNames{i} = '';
                    case 'originalname'
                        outputNames{i} = 'originalname';
                    case 'unit'
                        outputNames{i} = 'unit';
                    case 'longname'
                        outputNames{i} = 'longname';
                    otherwise
                        outputNames{i} = '';
                end;
            end;
        end;
        
        function dataset = readDelftData(dataset,sctStructure,sctOptions)
            % reads a time step in a delft 3d (Nefis) file.
            %
            % TODO: documentation
            % split in 2 parts (header, data)
            % read only specified variables
            % sctOptions.varName
            % sctOptions.start
            
            % open dataset for reading
            sctData = vs_use(sctStructure.fileName,'quiet');
            
            %get Groupsize
            nrGroup   = length(sctData.GrpDat);
            sizeGroup = zeros(nrGroup,1);
            
            for i = 1:nrGroup
                sizeGroup(i) = sctData.GrpDat(i).SizeDim;
            end;
            
            % get group names
            groupNames = vs_disp(sctData);
            
            if nargin == 2
                sctOptions = struct;
            end;
            
            
            %initialize the Delft3d class;
            delftObj = Delft3D;
            keyVarDelft = {};
            if isfield(sctOptions,'varNames')
                myVariables = sctOptions.varNames;
                keyVarDelft = delftObj.getDelftVarsToInclude(myVariables);
            end;
            
            % check all group names
            for i = 1:length(groupNames);
                % determine group information
                theGroupName =  groupNames{i};
                sctGroup     = vs_disp(sctData,theGroupName,[]);
                
                % determine group dimensions
                % one number for each dimension; 0 means everything
                theGroupIndex = cell(1,sctGroup.NDim);
                for j = 1:sctGroup.NDim
                    theGroupIndex{j} = 0;
                end;
                
                % determine all elements in the group
                elements = vs_disp(sctData,theGroupName);
                
                % loop over all elements
                for j = 1:length(elements)
                    theElementName = elements{j};
                    newElementName = strrep(theElementName,'-','_');
                    
                    sctElement = vs_disp(sctData,theGroupName,theElementName);
                    
                    if ~isempty(newElementName)
                        doRead    =  sizeGroup(i)>1;
                        doNotRead = isfield(sctOptions,'varNames') && ~any(strcmpi(newElementName,keyVarDelft));
                        
                        if doRead && ~doNotRead
                            % determine the index
                            theElementIndex = cell(sctElement.NDim,1);
                            
                            for k = 1:sctElement.NDim
                                theElementIndex{k} = 0;
                            end;
                            
                            % select time step
                            if isfield(sctOptions,'start')
                                theGroupIndex(end) = {sctOptions.start};
                            end
                           
                            % read the data for constants (for selected % fields)
                            sctStructure.(newElementName).data = squeeze(vs_let(sctData,theGroupName,theGroupIndex,theElementName,theElementIndex,'quiet'));
                        end
                    end;
                end;
                
                sctStructure.Time = dataset.Time;
                
                dataset = Delft3D.convertDelftFieldName(sctStructure,dataset, keyVarDelft);
                
                dataset = Delft3D.convertDelftFieldData(dataset,sctStructure);

                
                %set the dimension
                dataset = Delft3D.setDimDataset(dataset, sctStructure, 'hist');
                
                %remove unnecesary fields from one dataset
                dataset = Delft3D.cleanDelftDataset(dataset);
            end;
        end;
        
        function [dataset,sctStructure] = readDelftHeader(fileName,sctOptions)
            % reads a delft 3d (Nefis) file.
            % split in 2 parts (header, data)
            % read only specified variables
            % sctOptions.startDate
            % sctOptions.start
            % sctOptions.end
            % sctOptions.varNames
            
            % open dataset for reading
            sctData = vs_use(fileName,'quiet');
            
            %get Groupsize
            nrGroup   = length(sctData.GrpDat);
            sizeGroup = zeros(nrGroup,1);
            for i = 1:nrGroup
                sizeGroup(i) = sctData.GrpDat(i).SizeDim;
            end;
            % get group names
            groupNames = vs_disp(sctData);
            
            if nargin == 1
                sctOptions = struct;
            end;
            
            %determine which kind of result are you reading
            fileType = 'trim';
            idxFileType = strfind(fileName, 'trim');
            if isempty(idxFileType)
                fileType = 'trih';
            end;
            
            % copy filename
            sctStructure.fileName = fileName;
            nrStep = 0;
            
            %initialize the Delft3d class;
            delftObj = Delft3D;
            keyVarDelft = {};
            if isfield(sctOptions,'varNames')
                myVariables = sctOptions.varNames;
                keyVarDelft = delftObj.getDelftVarsToInclude(myVariables, fileType);
            end;

            % check all group names
            for i = 1:length(groupNames);
                % determine group information
                theGroupName =  groupNames{i};
                sctGroup     = vs_disp(sctData,theGroupName,[],'quiet');
                
                % determine group dimensions
                % one number for each dimension; 0 means everything
                theGroupIndex = cell(1,sctGroup.NDim);
                for j = 1:sctGroup.NDim
                    theGroupIndex{j} = 0;
                end;
                
                % determine all elements in the group
                elements = vs_disp(sctData,theGroupName);
                
                % loop over all elements
                for j = 1:length(elements)
                    theElementName = elements{j};
                    newElementName = strrep(theElementName,'-','_');
                    
                    sctElement = vs_disp(sctData,theGroupName,theElementName,'quiet');
                    nrStep     = max(sctGroup.NDim,nrStep);
                    
                    sctStructure.(newElementName).size = sctElement.SizeDim;
                    if ~isempty(newElementName)
                        doRead    = sizeGroup(i)==1  || ~isempty(strfind(theGroupName,'info')) || ~isempty(strfind(theGroupName,'map-infsed-serie')) || ~isempty(strfind(theGroupName,'map-info-series'));
                        
                        doNotRead = isfield(sctOptions,'varNames') && ~any(strcmpi(newElementName, keyVarDelft));
                        
                        if doRead && ~doNotRead
                            % determine the index
                            theElementIndex = cell(sctElement.NDim,1);
                            for k = 1:sctElement.NDim
                                theElementIndex{k} = 0;
                            end;
                            
                            % read the data for constants (for selected fields)
                            sctStructure.(newElementName).data = squeeze(vs_let(sctData,theGroupName,theGroupIndex,theElementName,theElementIndex,'quiet'));
                        end
                        
                        % put metadata in a structure
                        elementFieldNames = fieldnames(sctElement);
                        metadataNames     = strrep(elementFieldNames,'-','_');
                        for k = 1:length(metadataNames)
                            if ~isempty(metadataNames{k})
                                sctStructure.(newElementName).(metadataNames{k}) = sctElement.(elementFieldNames{k});
                            end;
                        end;
                    end;
                end;
            end;
            
            % CONEV
            sctStructure = Delft3D.convertDelftFieldHeader(sctStructure);
            
            % change names and delete unknown variables
            dataset = Delft3D.convertDelftFieldName(sctStructure, [], keyVarDelft);
            
            %remove unnecesary fields from one dataset
            dataset = Delft3D.cleanDelftDataset(dataset);
            
            % determine time
            dataset.Time = Delft3D.calcDelftTime(sctStructure);
            
            %get coordinates data
            dataset = Delft3D.getCoordinatesData(dataset,sctStructure);
        end;
        
        function dataset = readDelftHisData(dataset, sctStructure, sctOptions)
            % Reads Delf3D hist file
            % split in 2 parts (header, data)
            % read only specified variables
            
            % open dataset for reading
            sctData = vs_use(sctStructure.fileName,'quiet');
            
            %get Groupsize
            nrGroup   = length(sctData.GrpDat);
            sizeGroup = zeros(nrGroup,1);
            
            for i = 1:nrGroup
                sizeGroup(i) = sctData.GrpDat(i).SizeDim;
            end;
            
            % get group names
            groupNames = vs_disp(sctData);
            
            if nargin == 2
                sctOptions = struct;
            end;
            
            % check all group names
            for i = 1:length(groupNames)
                % determine group information
                theGroupName =  groupNames{i};
                sctGroup     = vs_disp(sctData,theGroupName,[]);
                
                % determine group dimensions
                % one number for each dimension; 0 means everything
                theGroupIndex =cell(1,sctGroup.NDim);
                for j = 1:sctGroup.NDim
                    theGroupIndex{j} = 0;
                end;
                
                % determine all elements in the group
                elements = vs_disp(sctData,theGroupName);
                
                % loop over all elements
                for j = 1:length(elements)
                    theElementName  = elements{j};
                    newElementName  = strrep(theElementName,'-','_');
                    sctElement      = vs_disp(sctData,theGroupName,theElementName);
                    
                    if ~isempty(newElementName)
                        doRead    =  sizeGroup(i)>1;
                        doNotRead = isfield(sctOptions,'varNames') && ~any(strcmpi(newElementName,sctOptions.varNames));
                        
                        if doRead && ~doNotRead
                            % determine the index
                            theElementIndex = cell(sctElement.NDim,1);
                            for k = 1:sctElement.NDim
                                theElementIndex{k}  = 0;
                            end;
                            
                            % select time step
                            if isfield(sctOptions,'start')
                                theGroupIndex(end) = {sctOptions.start};
                            end
                            
                            % vs_let returns a matrix
                            % vs_get a cell array
                            % read the data
                            sctStructure.(newElementName).data = vs_let(sctData,theGroupName,theGroupIndex,theElementName,theElementIndex,'quiet');
                        end;
                    end
                end;
            end;
            
            sctStructure.Time = dataset.Time;
            

            dataset = Delft3D.convertDelftFieldName(sctStructure,dataset);
            
            dataset = Delft3D.convertDelftFieldData(dataset,sctStructure);
            
            dataset = Delft3D.setDimDataset(dataset, sctStructure, 'hist');
            
            %remove unnecesary fields from one dataset
            dataset = Delft3D.cleanDelftDataset(dataset);
        end;
        
        function dataset = setDimDataset(dataset, sctStructure, fileType)
            %get the model fields
            fieldsModel = fieldnames(sctStructure);
            for i=1:length(fieldsModel)
                theField = fieldsModel{i};
                
                %get the transformed variable name
                currentVar  = ModelUtil.lookupVarName(theField,'delft3d');
                
                %check if the field is present in the current dataset
                if isfield(dataset, currentVar)
                    %check if the Ndim field is present in the model sct
                    if isfield(sctStructure.(theField), 'NDim')
                        currentDim = sctStructure.(theField).NDim;
                        switch fileType
                            case 'map'
                                if currentDim == 1
                                    dim = {'I'};
                                elseif currentDim == 2
                                    dim = {'I', 'J'};
                                elseif currentDim == 3
                                    %guarantee the data is 3d
                                    if sctStructure.(theField).SizeDim(3) > 1
                                        dim = {'I', 'J', 'K'};
                                    else
                                        %the dimension could be 3 but the Z
                                        %value is 1
                                        dim = {'I', 'J'};
                                    end
                                elseif currentDim == 4
                                    dim = {'I', 'J', 'K', 'M'};
                                end
                            case 'hist'
                                if currentDim == 1
                                    dim = {'I'}; %observation points
                                elseif currentDim == 2
                                    if sctStructure.(theField).SizeDim(2) > 1
                                        dim = {'T', 'I'};
                                    else
                                        %the dimension could be 2 but the Z
                                        %value is 1
                                        dim = {'I'};
                                    end                                    
                                elseif currentDim == 3
                                    dim = {'T', 'I', 'J'};
                                elseif currentDim == 4
                                    dim = {'T', 'I', 'J', 'K'};
                                end
                        end
                        %add the dimension to the dataset field
                        dataset.(currentVar).dim = dim;
                    end;
                end;
            end;
        end
        
        function showDelft(fileName)
            % show the contents of a Delft3d file
            
            % open dataset for reading
            sctData = vs_use(fileName);
            % get group names
            groupNames = vs_disp(sctData);
            
            % check all group names
            for i = 1:length(groupNames);
                % determine group information
                theGroupName =  groupNames{i};
                elements     = vs_disp(sctData,theGroupName);
                
                for j = 1:length(elements)
                    theElementName = elements{j};
                    disp([theGroupName,' - ',theElementName])
                end;
            end;
        end;
        
    end
end