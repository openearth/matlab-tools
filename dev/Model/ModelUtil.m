%Class to declare the most common ModelUtil
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef ModelUtil < handle
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
        
        function dataSet = addMagDir(dataSet)
            % adds magnitude and direction to a dataset
            %
            % dataSet = ModelUtil.addMagDir(dataSet)
            %
            % for now all fields which are known to be a vector (like
            % velocity and total load) are read , and then used to
            % calculate the magnitude and direction
            %
            % INPUT:
            %       -dataSet: a structure with data in IMDC format
            % OUTPUT:
            %       -dataSet: the same data set with added data for
            %       magnitude and direction (in degrees nautical convention)
            if isfield(dataSet,'VelX') && isfield(dataSet,'VelY')
                u = dataSet.VelX.data;
                v = dataSet.VelY.data;
                dataSet.VelMag.data = sqrt(u.^2+v.^2) ;
                dataSet.VelMag.unit = dataSet.VelX.unit;
                dataSet.VelMag.dim  = dataSet.VelX.dim;
                dataSet.VelDir.data = Calculate.calcDir(u,v);
                dataSet.VelDir.unit = 'deg';
                dataSet.VelDir.dim  = dataSet.VelX.dim;
            end
            if isfield(dataSet,'TotalLoadX') && isfield(dataSet,'TotalLoadY')
                u = dataSet.TotalLoadX.data;
                v = dataSet.TotalLoadY.data;
                dataSet.TotalLoadMag.data = sqrt(u.^2+v.^2) ;
                dataSet.TotalLoadMag.unit = dataSet.TotalLoadX.unit;
                dataSet.TotalLoadMag.dim  = dataSet.TotalLoadX.dim;
                dataSet.TotalLoadDir.data = Calculate.calcDir(u,v);
                dataSet.TotalLoadDir.unit = 'deg';
                dataSet.TotalLoadDir.dim  = dataSet.TotalLoadX.dim;
            end  
        end
        
%         function [Q,sctInterp] = calcDischargeUnstructered(dataSet,xT,yT,timeFlag,ts, sctInterp)            
%             % calculates the discharge for 2D unstructured model data
%             %
%             % [Q,sctInterp] = calcDischargeUnstructered(dataSet,xT,yT,timeFlag, sctInterp)
%             %
%             % INPUT :
%             %      - dataSet: data in IMDC standard format
%             %      - xT, yT : vectors with x and y coordinates of the
%             %      transect. Note that this must be resampled already!
%             %      - timeFlag :1 in case of discharge time series, 
%             %                  2 in case of discharge along a transect at a time instant. default is zero 
%             %      - ts = time step in case timeFlag=2
%             %      - sctInterp (optional): structure with interpolation
%             %      data
%             %
%             % OUTPUT : 
%             %      - Q : the discharge
%             %      - sctInterp: a structure with interpolation info
%             %
%             %
%               
% %           % interpolate data
% % 
%             if nargin < 4
%                 timeFlag = 0;
%             elseif isstruct(timeFlag)
%                  error('Function call has changed. Update your script');   
%             end
%             if ~exist('sctInterp','var')
%                 xT = Util.makeColVec(xT);
%                 yT = Util.makeColVec(yT);
%                 sctInterp = Triangle.interpTrianglePrepare(dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,xT,yT,false);                
%             end                   
%             
%              if exist('ts','var')
%                 tt = ts;
%              end
%             
% %           interpolate
%             uInt = Triangle.interpTriangle(sctInterp,dataSet.VelX.data);
%             vInt = Triangle.interpTriangle(sctInterp,dataSet.VelY.data);
%             hInt = Triangle.interpTriangle(sctInterp,dataSet.Depth.data);
%             
% %           project velocities
%             uC  = Calculate.projectVector(uInt,vInt,xT,yT);
%             q   = uC.*hInt; 
%             dx  = sqrt(diff(xT).^2 + diff(yT).^2);
%            
%             if timeFlag == 1
% %               varying in time
%                 Q=zeros(1,length(dataSet.Time.data));
%                 for t = 1:length(dataSet.Time.data)
%                     q1(:,1) = q(:,t);
%                     dx  = sqrt(diff(xT).^2 + diff(yT).^2);
% %                     calculate discharge and  integrate
%                     Q(1,t) = 0.5.*nansum(dx.*(q1(1:end-1,1)+q1(2:end,1)));
%                 end
%             elseif timeFlag == 2
%                     Q1 = q(:,tt);
%                     Q = Q1;
%             else                 
% %                 calculate discharge and integrate
%                  Q = 0.5.*nansum(dx.*(q(1:end-1)+q(2:end)));
%             end
%         end

        function [Q,sctInterp] = calcDischargeUnstructered(dataSet,xT1,yT1,timeFlag,ts, sctInterp)            
            % calculates the discharge for 2D unstructured model data
            %
            % [Q,sctInterp] = calcDischargeUnstructered(dataSet,xT,yT,timeFlag, sctInterp)
            %
            % INPUT :
            %      - dataSet: data in IMDC standard format
            %      - xT, yT : vectors with x and y coordinates of the
            %      transect. Note that this must be resampled already!
            %      - timeFlag :1 in case of discharge time series, 
            %                  2 in case of discharge along a transect at a time instant. 
            %                  0 default value 
            %      - ts = time step in case timeFlag=2
            %      - sctInterp (optional): structure with interpolation
            %      data
            %
            % OUTPUT : 
            %      - Q : the discharge
            %      - sctInterp: a structure with interpolation info
            %
            %

            % interpolate data
            % allow non cell arrays for backward compatibility
            if ~iscell(xT1) 
                if ~iscell(yT1)
                    xT1 = mat2cell(xT1,size(xT1,1),size(xT1,2));
                    yT1 = mat2cell(yT1,size(yT1,1),size(yT1,2));
                else
                    error('xT and yT must be the same type');
                end
            else
                if ~iscell(yT1)
                    error('xT and yT must be the same type');
                end
            end
            nrTrans = length(xT1);
            
            if timeFlag == 0
                Q2 = zeros(nrTrans,150000);
                Q = zeros(nrTrans,150000);
                % Q = zeros(nrTrans,1); % in case of time mean
            end

            if timeFlag == 1
                Q = zeros(nrTrans,length(dataSet.Time.data));
            end
            if timeFlag == 2
                Q = zeros(nrTrans,200);
            end
        
            
            % loop over all transects

            for iTrans = 1:nrTrans
                
                xT = xT1{iTrans};
                yT = yT1{iTrans};

                xT = Util.makeColVec(xT);
                yT = Util.makeColVec(yT);
                sctInterp(iTrans) = Triangle.interpTrianglePrepare(dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,xT,yT,false);
                
                if exist('ts','var')
                    tt = ts;
                end
                                   
                % interpolate
                uInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.VelX.data);
                vInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.VelY.data);
                hInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.Depth.data);
            
                % project velocities
                uC  = Calculate.projectVector(uInt,vInt,xT,yT);
                q   = uC.*hInt; 
                dx  = sqrt(diff(xT).^2 + diff(yT).^2);
                
           
                if timeFlag == 1
                    % varying in time
                    q1 = zeros(length(dx)+1,1);
                    for t = 1:length(dataSet.Time.data)
                        q1(:,1) = q(:,t);                
                        dx  = sqrt(diff(xT).^2 + diff(yT).^2);
                        % calculate discharge and integrate
                        Q(iTrans,t) = 0.5.*nansum(dx.*(q1(1:end-1,1)+q1(2:end,1)));
                    end
                    
                    
                elseif timeFlag == 2
                        q1 = zeros(length(dx)+1,tt);
                        q1(:,tt) = q(:,tt);
                         Q1 = q1(:,tt); % in case you want the discharge
                        % per meter width
%                         Q1 = 0.5.*(dx.*(q1(1:end-1,tt)+q1(2:end,tt)));
                        Q(iTrans,1:length(Q1)) = Q1;
                else   
                      j = (length(dx)+1)*length(dataSet.Time.data);
                      % calculate discharge and integrate
                      q1 = q;
                      Q1 = 0.5.*nansum(dx.*(q1(1:end-1)+q1(2:end)));
                      Q2(iTrans,1:j-1) = Q1';
                      Q = Q2;
                      % for time mean 
                      % Q(iTrans,1) = mean(Q2(iTrans,1:j-1),2);
                      
                end
            end 
            
    end          


        
        function [F,Q,sctInterp] = calcFlux(dataSet,xTall,yTall, scalarVar, absVal, sctInterp)
            % calculates the discharge for 3D unstructured model data
            %
            % [F,Q,sctInterp] = calcFlux(dataSet,xTall,yTall, scalarVar, absVal, sctInterp)
            %
            % INPUT :
            %      - dataSet: data in IMDC standard format
            %      - xTall, yTall : cell area with vectors with x and y coordinates of the
            %      transect. Each cell is a transect. Note that this must be resampled already!
            %      - scalarVar: a cell array with the names of the
            %      variables for which the flux needs to be calculated
            %      - absVal: (optional) if true. the absolute value is used to
            %      calculate the discharge, thus giving some value of the
            %      exchange. default is false.
            %      - sctInterp (optional): structure with interpolation
            %      data
            %
            % OUTPUT : 
            %      - F: matrix  with the fluxes of each scalar defined in
            %      scalarVar for each transect in xTall yTall
            %      - Q: vector with the discharge for each transect in
            %      xTall yTall
            %      - sctInterp: a structure with interpolation info
            %
            %
            if length(size(dataSet.VelX))>2
                error('Maximum amount of dimensions for velocity is 2');
            end
            
            % interpolate data

            if nargin <5
                absVal = false;
            end
            if isstruct(absVal)
                error('I had to make changes which affect the compatibility of the script. Sorry. Now change your function call.');
            end
            
            % interpolate data
            
            % allow non cell arrays for backward compatibility
            if ~iscell(xTall) 
                if ~iscell(yTall)
                    xTall = mat2cell(xTall,size(xTall,1),size(xTall,2));
                    yTall = mat2cell(yTall,size(yTall,1),size(yTall,2));
                else
                    error('xT and yT must be the same type');
                end
            else
                if ~iscell(yTall)
                    error('xT and yT must be the same type');
                end
            end
            nrTrans = length(xTall);
            nrVar = length(scalarVar);
            
            % preallocate output data
            Q = zeros(nrTrans,1);
            F = zeros(nrTrans,nrVar);
            
            % loop over all transects
            for iTrans = 1:nrTrans
                
                xT = xTall{iTrans};
                yT = yTall{iTrans};
            
                if nargin <6
                    xT = Util.makeColVec(xT);
                    yT = Util.makeColVec(yT);
                    sctInterp(iTrans) = Triangle.interpTrianglePrepare(dataSet.IKLE.data,dataSet.X.data,dataSet.Y.data,xT,yT,false);
                end
                
                % interpolate
                uInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.VelX.data);
                vInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.VelY.data);
                zInt = Triangle.interpTriangle(sctInterp(iTrans),dataSet.Z.data);
                
                % project velocities
                theDir = atan2(diff(yT),diff(xT))*180/pi;
                if any(diff(theDir)>1e-3)
                    error('Not straight polylines not yet implemented');
                end
                %[u,v] = Calculate.rotateVector(uInt,vInt,theDir(1));
                [v,u] = Calculate.projectVector(uInt,vInt,xT,yT);
                dx  = sqrt(diff(xT).^2 + diff(yT).^2);
                dz  = diff(zInt,1,2);
                % depth avg
                if absVal
                    v = abs(v);
                end
                q   = 0.5.*nansum(dz.*(v(:,1:end-1)+v(:,2:end)),2);
                
                % calculate discharge and  integrate
                Q(iTrans) = 0.5.*nansum(dx.*(q(1:end-1)+q(2:end)));

                for i = 1:nrVar
                    c    = Triangle.interpTriangle(sctInterp(iTrans),dataSet.(scalarVar{i}).data);
                    uc   = v.*c;
                    f    = 0.5.*nansum(dz.*(uc(:,1:end-1)+uc(:,2:end)),2);
                    F(iTrans,i) = 0.5.*nansum(dx.*(f(1:end-1)+f(2:end)));
                end
            
            end
        end
        
        function var = changeSize(sctOptions,var,varName)
            % determine the new start and end dimensions for reading
            % the last dimension is modified
            % note that 1 is substracted from the values, because netCDF is zeros
            % bases, while matlab is one-bases
            if isfield(sctOptions,varName)
                x = sctOptions.(varName);
                %if length(var)>2

                if var(end)>0
                    if strcmpi(varName,'start')
                        var(end) = x-1;
                    else
                        var(end) = x;
                    end
                end
            end
        end

        function datasetOut = convertDataset(dataSet,type)
            % lookup table with standard variable names
            %  
            % datasetOut = ModelUtil.convertDataset(dataSet,type)
            %
            % INPUT:
            %       - dataset: the dataset to change
            %       - type:    a string with the type of dataset. Currently allowed
            %                  values are : 'coherens', ...
            % OUTPUT:
            %       - datasetOut: structure with updated variable names

            names = fieldnames(dataSet);
            for i=1:length(names)
                newName = ModelUtil.lookupVarName(names{i},type);
                if ~isempty(newName)
                    datasetOut.(newName) = dataSet.(names{i});
                else
                    datasetOut.(names{i}) = dataSet.(names{i});
                end
            end
        end
        
        function dataSet = copyMetaData(dataSet,sourceName,targetName)        
            % copies all metadata from one variable to the next
            %
            % dataSet = ModelUtil.copyMetaData(dataSet,sourceName,targetName)  
            %
            % INPUT:
            %        -dataSet: dataset in IMDC standard format  
            %        - sourceName: name of the variable from which the
            %                      metadata are copied
            %        - targetName: name of the variable to which the
            %                      metadata are copied
            
            % OUTPUT:
            %        -dataSet: updated dataset  
            allFields = fieldnames(dataSet.(sourceName));
            if ~isfield(dataSet,targetName)
                dataSet.(targetName) = struct;
            end
            
            for iField = length(allFields)
                theField = allFields{iField};
                if ~strcmp(theField,'data')
                    dataSet.(targetName).(theField) = dataSet.(sourceName).(theField);  
                end
            end
        end

        function y = getData(x,start,stop,stride)
            % This function selects data from multidimensional arrays
            % TODO: USE LINEAR INDEXING (MUCH FASTER/ ROBUST)
            % INPUT:
            %   x: a array with between 2 and 5 dimensions
            %   start: a vector (with the same size as the number of
            %   dimensions of x, specifying the start of the selected
            %   data for each dimension
            %   stop: a vector (with the same size as the number of
            %   dimensions of x, specifying the end of the selected
            %   data for each dimension
            %   stride: a vector (with the same size as the number of
            %   dimensions of x, specifying the interval spacing of the
            %   data for each dimension

            if nargin == 3
                stride = ones(size(start));
            end
            switch ndims(x)
                case 2
                    y = x(start(1):stride(1):stop(1),start(2):stride(2):stop(2));
                case 3
                    y = x(start(1):stride(1):stop(1),start(2):stride(2):stop(2),...
                        start(3):stride(3):stop(3));
                case 4
                    y = x(start(1):stride(1):stop(1),start(2):stride(2):stop(2),...
                        start(3):stride(3):stop(3),start(4):stride(4):stop(4));
                case 5
                    y = x(start(1):stride(1):stop(1),start(2):stride(2):stop(2),...
                        start(3):stride(3):stop(3),start(4):stride(4):stop(4),...
                        start(5):stride(5):stop(5),start(6):stride(6):stop(6));
                otherwise
                    error('The maximum number of dimensions is 5');
            end
            y = squeeze(y);
        end

        function sizeDims = getDims(mCdfID,dimID)
            % determines the dimensions of the arrays to be read (ans returns a vector
            % with these dimensions
            for i=1:length(dimID)
                [~, sizeDims(i)] = netcdf.inqDim(mCdfID,dimID(i));
            end
        end

        function newName = lookupVarName(name,type)
            %  lookup-table  with the names of the variables inside models
            %  and in the stadardized data structure
            % if not
            newName = [];
            switch (type)
                case 'ws_grid'
                    switch (name)
                        case 'time'
                            newName = 'T';
                        case 'x'
                            newName = 'X';
                        case 'y'
                            newName = 'Y';
                        case 'mslp'
                            newName = 'AirPress';
                        case 'hs'
                            newName = 'WaveHeight';
                        case 'vgrd10m'
                            newName = 'WindVelY';
                        case 'dpm'
                            newName = 'WaveDir';
                        case 'tm01'
                            newName = 'WavePeriod';
                        case 'ugrd10m'
                            newName = 'WindVelX';
                    end
                case 'coherens'
                    % extra test for old style variable names. to be
                    % deleted.
                    if ~isempty(strfind(name,'_01'))
                        name = name(1:end-3);
                    end
                    switch (name)
                        % Velocities
                        case 'umvel'
                            newName = 'VelX';
                        case 'vmvel'
                            newName = 'VelY';
                        case 'uvel'
                            newName = 'VelX';
                        case 'vvel'
                            newName = 'VelY';
                        case 'wphys'
                            newName = 'VelZ';

                            % TODO: MAKE DIFFERENCE BETWEEN DEPTH AVERAGE
                            % AND 3D VARIABLES

                        % water level/depth
                        case 'zeta'
                            newName = 'WatLev';
                        case 'deptotatc'
                            newName = 'Depth';
                        case 'depmeanatc'
                            newName = 'BotZ';

                        % Coordinates
                        case 'xout'
                            newName = 'X';
                        case 'yout'
                            newName = 'Y';
                        case 'zout'
                            newName = 'Z';
                        case 'time'
                            newName = 'Time';
                        case 'gscoordatc'
                            newName = 'Sigma';

                        % Tracers
                        case 'sal'
                            newName = 'Sal';
                        case 'temp'
                            newName = 'Temp';

                        % Waves
                        case 'waveheight'
                            newName = 'WaveHeight';
                        case 'waveperiod'
                            newName = 'WavePeriod';
                        case 'wavevel'
                            newName = 'WaveVel';
                        case 'wavedir'
                            newName = 'WaveDir';

                        %Sediment
                        case 'wfall'
                            newName = 'FallVel';
                        case 'bottom_sed_flux'
                            newName = 'BedFlux';
                        case 'cvol'
                            newName = 'SedConc';
                        case 'qbedatu'
                            newName = 'BedLoadX';
                        case 'qbedatv'
                            newName = 'BedLoadY';
                        case 'qtotatu'
                            newName = 'TotalLoadX';
                        case 'qtotatv'
                            newName = 'TotalLoadY';
                    end
                case 'delft3d'
                    % IMPORTANT; DO NOT PUT VARIABLE NAMES HERE THAT ARE USED IN CONVERTING DATA (SUCH R1 AND UZ AND Z)
                    switch (name)
                        case 'WPHY'
                            newName = 'VelZ';

                        % water level/depth
                        case 'S1'
                            newName = 'WatLev';
                        case 'D1'
                            newName = 'Depth';
                        case 'B1'
                            newName = 'BotZ';

                        % Coordinates
                        case 'XZ'%'XCOR'
                            newName = 'X';
                        case 'YZ' %'YCOR'
                            newName = 'Y';
                        case 'ZK'
                            newName = 'Z';
                        case 'THICK'
                            newName = 'Sigma';

                        case 'TAUMAX'
                            newName = 'TauMax';
                        case 'VICWW'
                            newName = 'EddyViscV';
                        case 'DICWW'
                            newName = 'EddyDiffV';
                        case 'VICUV'
                            newName = 'EddyViscH';
                        case 'RICH'
                            newName = 'Richardson';
                        case 'RHO'
                            newName = 'Density';
                        case 'VORTIC'
                            newName = 'Vorticity';
                        case 'ENSTRO'
                            newName = 'Entrophy';
                        case 'NAMCON'
                            newName = 'NameConst';
                        case 'NAMSED'
                            newName = 'NameSed';

                            %map-sed-series group
                        case 'WS'
                            newName = 'FallVel';
                        case 'SBUU'
                            newName = 'BedLoadX';
                        case 'SBVV'
                            newName = 'BedLoadY';
                        case 'SSUU'
                            newName = 'SuspLoadX';
                        case 'SSVV'
                            newName = 'SuspLoadY';
                        case 'RCA'
                            newName = 'BedConc';
                        case 'DPS'
                            newName = 'BotDepth';
                        case 'BODSED'
                            newName = 'SedAvaliable';
                        case 'DPSED'
                            newName = 'SedThickness';

                        case 'ALFAS'
                            newName = 'Alpha';
                        case 'DPS0'
                            newName = 'BotDepthIni';

                            %  HIS files
                        case 'Dep'
                            newName = 'Depth';
                        case 'ZWL'
                            newName = 'WatLev';
                        case 'ZCURW'
                            newName = 'VelZ';
                        case 'ZWS'
                            newName = 'FallVel';
                        case 'ZBDSED'
                            newName = 'SedAvaliable';
                        case 'ZDPSED'
                            newName = 'SedThickness';
                        case 'ZDPS'
                            newName = 'BotDepth';
                        case 'ZSBU'
                            newName = 'BedLoadX';
                        case 'ZSBV'
                            newName = 'BedLoadY';
                        case 'ZSSU'
                            newName = 'SuspLoadX';
                        case 'ZSSV'
                            newName = 'SuspLoadY';
                        case 'ZQXK'
                            newName = 'DistX';
                        case 'ZQYK'
                            newName = 'DistY';
                        case 'ZVICWW'
                            newName = 'EddyViscV';
                        case 'ZDICWW'
                            newName = 'EddyDiffV';
                        case 'ZRICH'
                            newName = 'Richardson';
                        case 'ZRHO'
                            newName = 'Density';
                        case 'NAMST'
                            newName = 'ObsPoint';
                    end
                case 'telemac'
                    % find number in the string
                    theNum = regexp(name,'\d*','match');
                    if ~isempty(theNum)
                        theNum = theNum{1};
                    end
                    theName= regexp(name,'\D*','match');
                    name = strtrim(theName{1});
                    switch (name)
                        % Velocities
                        case 'VELOCITY U'
                            newName = 'VelX';
                        case 'VELOCITY V'
                            newName = 'VelY';
                        case 'VELOCITY W'
                            newName = 'VelZ';
                        case {'U_VELOCITY_BOT','U VELOCITY BOT'}
                            newName = 'VelXbot';
                        case {'V_VELOCITY_BOT','V VELOCITY BOT'}
                            newName = 'VelYbot';
                        case {'U_VELOCITY_TOP','U VELOCITY TOP'}
                            newName = 'VelXtop';
                        case {'V_VELOCITY_TOP','V VELOCITY TOP'}
                            newName = 'VelYtop';
                        case 'HIGHEST VELOCITY'
                            newName = 'VelHigh';

                        % water level/depth
                        case 'FREE SURFACE'
                            newName = 'WatLev';
                        case 'WATER DEPTH'
                            newName = 'Depth';
                        case 'BOTTOM'
                            newName = 'BotZ';
                        case 'HIGH WATER MARK'
                            newName = 'WatLevHigh';

                        % Coordinates
                        case 'ELEVATION Z'
                            newName = 'Z';

                        % Tracers
                        case 'SALINITY'
                            newName = 'Sal';
                        case 'NUX SALINITY'
                            newName = 'NuXSal';
                        case 'NUZ SALINITY'
                            newName = 'NuZSal';
                        case 'TEMPERATURE'
                            newName = 'Temp';
                        case 'NUX TEMPERATURE'
                            newName = 'NuXTemp';
                        case 'NUZ TEMPERATURE'
                            newName = 'NuZTemp';
                        case 'RELATIVE DENSITY'
                            newName = 'RelDens';
                        case 'TRACER'
                            newName = 'Tracer';
                        case 'SSC'
                            newName = 'SedConc';
                        case 'TBT'
                            newName = 'TBT';
                        case 'SEDIMENT'
                            newName = 'SedConc';
                        case 'BED EVOLUTION'
                            newName = 'BathEvol';   
                        case 'BED THICKNESS'
                            newName = 'BedThick';  
                            
                       % Turbulence     
                        case 'TURBULENT ENERGY'
                            newName = 'TurbEnergy';
                        case 'DISSIPATION'
                            newName = 'TurbDiss';
                       % diffusivities
                        case 'NUX FOR VELOCITY'
                            newName = 'NuX';
                        case 'NUY FOR VELOCITY'
                            newName = 'NuY';
                        case 'NUZ FOR VELOCITY'
                            newName = 'NuZ';
                         
                       % Meteo
                        case 'WIND ALONG X'
                           newName = 'WindVelX';
                        case 'WIND ALONG Y'
                           newName = 'WindVelY';
                        case 'AIR PRESSURE'
                           newName = 'AirPress';
                        case 'PRESSURE'
                           newName = 'AirPress';
                        case 'AIR TEMPERATURE'
                            newName= 'AirTemp';
                        case 'RELATIVEHUMIDITY'
                            newName = 'RelHumid';
                        case 'SHORT-WAVE RAD'
                            newName = 'SwRad';
                        case 'LONG-WAVE RAD'
                            newName = 'LwRad';
                            
                       % wave properties (Artemis)
                        case 'WAVE HEIGHT HM'
                            newName = 'WaveHeight';
                        case 'WAVE HEIGHT'
                            newName = 'WaveHeight';
                        case 'STILL WATER H'
                            newName = 'WatLev';
                        case 'PHASE VELOCITY'
                            newName = 'c'; 
                        case 'GROUP VELOCITY'
                            newName = 'cg';
                        case 'WAVE NUMBER'
                            newName = 'WaveNumber';
                        case 'T'
                            newName = 'WavePeriodT';   
                        case 'TM'
                            newName = 'WavePeriodTm';
                        case 'WAVE INCIDENCE'
                            newName = 'WaveIncidence';
                        case 'QB'
                            newName = 'WaveBreakingQb';
                        case 'MEAN DIRECTION'
                            newName = 'MeanDirection';
                        case 'WAVE SPREAD'
                            newName = 'WaveSpread';
                        case 'PEAK PERIOD TPD'
                            newName = 'PeakPeriod';
                            
                       % sediment transport (Sisyphe)
                        case 'SOLID DISCH'
                            newName = 'BedLoadTot';
                        case 'SOLID DISCH X'
                            newName = 'BedLoadX';
                        case 'SOLID DISCH Y'
                            newName = 'BedLoadY'; 
                        case 'EVOLUTION'
                            newName = 'BathEvol';
                            
                        % shear stress & boundary layer
                        case {'FRICTION VELOCIT','FRICTION VEL.'}
                            newName = 'FrictionVel';
                        case 'TOP BOUND LAY'
                            newName = 'BlTop';
                        case 'BOT BOUND LAY'
                            newName = 'BlBot';

                        % Miscellaneous
                        case 'PRIVE'
                            newName = 'Prive';
                        case 'NUDGEFACT'
                            newName = 'NudgeFact';
                        case 'VISCSPONGE'
                            newName = 'ViscSponge';
                        case 'DIFFSPONGE'
                            newName = 'DiffSponge';
                        otherwise
                            newName = strrep(name,' ','_');
                    end
                    if ~isempty(theNum)
                        newName = [newName,theNum];
                    end
            end
        end

        function x = makeRow(x)
            % checks for 1D vectors that they are row vectors
            %
            % x = makeRow(x)
            %
            % INPUT: 
            %        - x: a vector
            % OUTPUT
            %        - x: a row vector with the same data as x
            
            % look for 1D vectors
            sizeX = size(x);
            nrDim = sum(sizeX~=1);

            if nrDim == 1
                % look for column vectors and make them row vectors
                if sizeX(1)>sizeX(2)
                    x = x';
                end
            end
        end
        
        function dx = maxDxRegular(x)
            %find the maximum grid spaciong for a regular grid
            %
            % dx = maxDx(x)
            %
            % INPUT:
            %          -x
            % OUTPUT:
            %         -dx: the maximum mesh size
            % NOTE: does not work on curvilinear grids or rotated meshes
            
            dx = 0;
            for i=1:ndims(x)
                dxTmp = diff(x,1,i);
                dx = max(max(max(max(dx,abs(dxTmp(:))))));
            end
        end

        function dataSet = readCoherens(fileName)
            % reads netcdf data for Coherens (complete file)
            %
            % dataSet = readCoherens(filename)
            %
            % INPUT: 
            %          - fileName: the name of the coherens file
            %
            % OUTPUT: 
            %          - dataSet: a dataset in IMDC format conaining all
            %          data for the file

            % reads the header
            dataSet  = NetCdf.readNetCdfHeader(fileName);

            % reads all varaibles for all time steps (still change?)
            dataSet = NetCdf.readNetCdf(fileName,dataSet);

            % converts the data structure to the standardized one
            dataSet = ModelUtil.convertDataset(dataSet,'coherens');

            % convert the time
            dataSet.Time = datenum(dataSet.Time.data','yyyy/mm/dd;HH:MM:SS:FFF');
        end

        function dataSet = readIMDC(filename)
            % reads netcdf data in IMDC format (complete file)
            %
            % dataSet = readIMDC(filename)
            %
            % INPUT: 
            %          - fileName: the name of the netcdf file
            %
            % OUTPUT: 
            %          - dataSet: a dataset in IMDC format conaining all
            %          data for the file
            
            % reads the header
            sctOptions.AttFunction = @Model.removeUnderscore;
            dataSet  = NetCdf.readNetCdfHeader(filename,sctOptions);

            % reads all variables for all time steps (still change?)
            dataSet = NetCdf.readNetCdf(filename,dataSet);

            % rename variable
            dataSet = ModelUtil.convertDataset(dataSet,'ws_grid');
        end

        function newName = removeUnderscore(oldName)
            % removes an underscore form a name
            %
            % newName = removeUnderscore(oldName)
            %
            %INPUT: 
            %          - oldName: string with the old name
            %
            %OUTPUT: 
            %          - newName: string with the new name
            %
            if oldName(1) ~= '_';
                newName = oldName;
            else
                newName = oldName(2:end);
            end
        end

        function z = sigmaCoor(sigma, waterlevel, bedlevel)
            % calculates z coordinates from sigma coordinates
            % 
            % z = sigmaCoor(sigma, waterlevel, bedlevel)
            %
            % INPUT:
            %        - sigma:      [Kx1] vector with siogma coordinates (between
            % 0 and 1)
            %        - waterlevel: [MxN matrix] with water level elevations
            %        - bedlevel:   [MxN matrix] with bed level elevations
            %
            % OUTPUT: 
            %        - z: [MxNxK array]  with z elevations
            %
            % NOTE: for delft3D calculate sigma (at the center of each layer) with
            % sigmaEdge = [0 cumsum(thickness)];
            % sigma = 0.5.*(sigmaEdge(1:end-1)+sigmaEdge(2:end));

            nrSigma = length(sigma);
            sizeWl = size(waterlevel);
            depth  = waterlevel - bedlevel;
            % preallocate
            z = nan([sizeWl, nrSigma]);
            % calculate elevation for each layer
            for i = 1:nrSigma
                z(:,:,i) = sigma(i).*depth;
            end
        end
        
        function z = vertGrid(nrLayer,dl,du)
            % determines a vertical grid using a tanh stretching
            %
            % z = ModelUtil.vertGrid(nrLayer,dl,du)
            %
            % INPUT:  
            %         -nrLayer: the number of layers
            %         -dl:      grid stretching near the bed (default = 1.83); 0 means no
            %                   stretching
            %         -du:      grid stretching near the bed (default = du); 0 means no
            %                         stretching; at least one of du and dl must be
            %                         non-zero (i.e. 0.00001)
            %
            %
            % OUTPUT: 
            %         - z: a 1xN vector withgrid coordinates (between 0 and 1)
            %
            % REFERENCES: See GOTM manual for more details
            %
            k = 0:nrLayer-1;
            if nargin == 1
                dl = 1.83;
            end
            if nargin <= 3
                du = dl;
            end
            
            z = (tanh((dl+du).*k./(length(k)-1) -dl) + tanh(dl))./(tanh(dl)+tanh(du));

        end
    
        function zz = vertCoord(bottom, surface,zPlane,sigma,isZ)
            % vertical coordinate transforms as in Telemac
            
            %options (add to interface)
            minDep = 0.01;
            disMinBot = 0.2;
            disMinSur = 0.2;
            minDz = 0.0;
            
            % correct free surface
            surface = max(surface,bottom+minDep);
            
            % preallocate
            nrPoin  = length(bottom);
            nrLayer = length(zPlane);
            if nrLayer < 3
                error('At least three layers are needed');
            end
            zz = zeros(nrPoin,nrLayer);
            
            % set top and free surface
            dep           = surface-bottom;
            zz(:,1)       = bottom;
            zz(:,nrLayer) = surface;
            
            % set z-layers
            
            for i = 1:nrLayer-1
                if isZ(i)
                    rpls = (nrLayer-i)/nrLayer;
                    rpli = (i-1)/nrLayer;
                    disBot = min(dep,disMinBot);
                    disSur = min(dep,disMinSur);
                    zz(:,i) = min(surface-disSur.*rpls,max(zPlane(i),bottom+disBot.*rpli));
                end
            end
            % sigma layers
            i1 = 2;
            while i1 ~=nrLayer
                if (isZ(i1))
                    i1 = i1+1;
                else
                    i2 = i1;
                    % look for sequences of sigma planes
                    while (~isZ(i2+1) && i2+1 ~= nrLayer)
                        i2 = i2 +1;
                    end
                    % sigma transformation between i1 and i2
                    for i=i1:i2
                        zz(:,i) = zz(:,i1-1) + sigma(i).*(zz(:,i2+1)-zz(:,i1-1) );
                    end
                    i1 = i2 +1;
                end
            end
            
            % check nans in layers
            if any(isnan(zz(:)))
                error('Nan values in layers');
            end
            % check layer depths
            for i=2:nrLayer
                dz = zz(:,i)-zz(:,i-1);
                if any(dz<0)
                    error('Negative layer depths');
                end
            end
            
            % smash elements
            if minDz>0
                for i = 2:nrLayer-1
                    mask = zz(:,i)<zz(:,i-1)+minDz;
                    zz(mask,i) = zz(mask,i-1);
                end
            end
        end
        
    end
end
