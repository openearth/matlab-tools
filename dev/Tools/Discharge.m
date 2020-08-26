%Class with a template to make new Classes
%
% @author ABR
% @author SEO
% @version
%

classdef Discharge < handle
    %Public properties
    properties
        Property1;
    end
    
    %Dependand properties
    properties(Dependent = true, SetAccess = private)
        
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
        function set.Property1(obj, property1)
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
    methods(Access = 'private')
        
    end
    
    %Stactic methods
    methods(Static)
        function sctOut = main(sctIn)
            % main function to calculate discharges
            %
            % sctOut = main(sctIn)
            %
            % INPUT:
            % - sctIn.soundSpeedMethod: method to calculate the velocity of
            % sound. valid options are 'mackenzie' and 'urick' (default)
            %
            % - sctIn.thresholdGlobal: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurous data in the global filter/
            % - sctIn.medianWindow: [2x1] size of the window for applying the
            % median filter (in x and y direction). Must be odd.
            % - sctIn.thresholdMedian: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurious data in the median filter
            % - sctIn.fileName: Winriver file (.pd0) to be used in the
            % processing
            % - sctIn.xRef: [2x1]: x coordinates (relative) of the theoretical
            % transect
            % - sctIn.yRef: : [2x1]: y coordinates (relative) of the theoretical
            % transect
            % - sctIn.salinity: salinity used to calculate the sound
            % velocity
            % - sctIn.temperature (deg C): temperature used to calculate
            % the sound velocity (default: 10)
            % - sctIn.method: processing method 'extractProfile' (default)
            % or 'locProfile'
            % - sctInput.invDistFac: coeffcioent used in interpolation.
            % default = 2
            % - sctIn.maxDx: distance used to determine the coordinates of
            % the points form the datafile
            % - sctIn.minT: minimum time the ADCP has to be at a location
            % in order to detremine the points in the datafile
            % - sctIn.distLeft: distance from the left bank to the first measurmenet point (i.e. bank
            % closes to the
            % - sctIn.facLeft: factor to use for determining the estimate
            % of the left bank: use 0.35 for a riangular profile and 0.91
            % for a rectanguylar profile
            % - sctIn.nBinULeft: number of samples used for edge estimate
            % left bank (default =1)
            % - sctIn.distRight: as distLeft but for the distance to the
            % bank from the last coordinate
            % - sctIn.facRight: as facRight but for the the other bank
            % - sctIn.nBinURight: number of samples used for edge estimate
            % left bank (default =1)
            % - sctIn.facTop: factor for determining the estimate of the
            % top
            % - sctIn.nBinTop: number of samples used for top estimate
            % (default 2)
            % - sctIn.topDischargeMethod: interpolation method: constant or
            % Power (default)
            % - sctIn.nBinBot: number of samples used for top estimate
            % (default 2)
            % - sctIn.facBot: factor for determining the estimate of the
            % bottom. Default 6/7, which is derived theoretically for a
            % power law velocity profile

            % sctIn.minNrPoint: minium number of points for calcul;ating
            % the discharge (default = 7)
            % - sctIn.plotCheck: logical: if true, three plots are made:
            % 1.) Location of the measurement points and the transect
            % 2.) Time series with raw data, filtered data and interpolated
            % data
            % 3.) Velocity profiles at each extracted coordinate
            % - sctIn.savePath: path to save DischargeApp. Default: C:\Program Files (x86)\DischargeApp 
            % - sctIn.figSave: logical to save created figures in
            % savePath\figures
            % - sctIn.watLev: apply waterlevel correction to ADCP Data
            % (default = 0)

            % OUTPUT:
            % - sctOut.Qtot: tital discharge
            % - sctOut.Qmid: discharge from integrating the profiles
            % - sctOut.Qtop: discharge estimate at the top
            % - sctOut.Qbot: discharge estimate at the bottom
            % - sctOut.Qleft:  discharge estimate at bank closest to the
            % first point
            % - sctOut.Qright: discharge estimate at bank closest to the
            % last point
            % -sctOut.qLocal: discharge per point (for each bin)
            
            % set default values
            sctIn = Util.setDefault(sctIn, 'soundSpeedMethod', 'urick');
            sctIn = Util.setDefault(sctIn, 'thresholdGlobal', 3);
            sctIn = Util.setDefault(sctIn, 'medianWindow', [7, 7]);
            sctIn = Util.setDefault(sctIn, 'thresholdMedian', 3);
            sctIn = Util.setDefault(sctIn, 'salinity', 0);
            sctIn = Util.setDefault(sctIn, 'temperature', 10);
            sctIn = Util.setDefault(sctIn, 'invDistFac', 2);
            sctIn = Util.setDefault(sctIn, 'minT', 50);
            sctIn = Util.setDefault(sctIn, 'maxDx', 0.5);
            sctIn = Util.setDefault(sctIn, 'distLeft', 0);
            sctIn = Util.setDefault(sctIn, 'facLeft', 0.35);
            sctIn = Util.setDefault(sctIn, 'nBinULeft', 1);             
            sctIn = Util.setDefault(sctIn, 'distRight', 0);
            sctIn = Util.setDefault(sctIn, 'facRight', 0.35);
            sctIn = Util.setDefault(sctIn, 'nBinURight', 1); 
            sctIn = Util.setDefault(sctIn, 'facTop', 1.0);
            sctIn = Util.setDefault(sctIn, 'nBinUTop', 2);
            sctIn = Util.setDefault(sctIn, 'topDischargeMethod','Constant');
            sctIn = Util.setDefault(sctIn, 'facBot', 1/(1 + 1 / 6));  % determined on the base of a logaritmic profile
            sctIn = Util.setDefault(sctIn, 'nBinUBot', 2);            
            sctIn = Util.setDefault(sctIn, 'savePath','C:\Program Files (x86)\DischargeApp');
            sctIn = Util.setDefault(sctIn, 'plotCheck', true);
            sctIn = Util.setDefault(sctIn, 'minNrPoint', 7);
            sctIn = Util.setDefault(sctIn, 'minDist', 0.5);
            sctIn = Util.setDefault(sctIn, 'method', 'extractProfile');
            sctIn = Util.setDefault(sctIn, 'sheetName', '');
            sctIn = Util.setDefault(sctIn, 'useMag', false);
            sctIn = Util.setDefault(sctIn, 'useBottom', false);
            sctIn = Util.setDefault(sctIn, 'depAdcp', 0.05);
            sctIn = Util.setDefault(sctIn, 'saveFig', false);
            sctIn = Util.setDefault(sctIn, 'bmAlignment', 0); 
            sctIn = Util.setDefault(sctIn, 'watLev', 0); 

            
            
            %read winriver file
            
            [~, ~, ext] = fileparts(sctIn.fileName);
            if strcmpi(ext, '.xls') || strcmpi(ext, '.xlsx')
                sctOut = Discharge.valeport(sctIn); 
            else
                sctOut = Discharge.adcpDischarge(sctIn);
            end
        end
        
        
        function sctOut = valeport(sctIn)
            % set default
            sctIn = Util.setDefault(sctIn, 'binSize', 0.0);
            
            % extra function to use the valeport
            if isempty(sctIn.sheetName)
                [x, sheetNames] = xlsfinfo(sctIn.fileName);
                [index, x] = listdlg('PromptString', 'Select a sheet to process:', ...
                    'SelectionMode', 'single', ...
                    'ListString', sheetNames);
                sheetName = sheetNames{index};
                %sheetName = inputdlg('Give the name of the sheet to process');
                %sheetName = strtrim(sheetName{1});
            else
                sheetName = sctIn.sheetName;
            end
            
            tmpData = Discharge.readXls(sctIn, sheetName);
            
            % calculate discharge
            for i = length(tmpData.vel):-1:1
                uC = tmpData.vel{i}';
                distC = tmpData.distance';
                if size(tmpData.dep{i}, 1) > 1
                    zC = tmpData.dep{i}';
                    % sort the data
                    ind = size(zC, 2):-1:1;
                    zC = zC(:, ind);
                    uC = uC(:, ind);
                else
                    zC = repmat(tmpData.dep{i}, length(tmpData.distance), 1);
                end
                hC = tmpData.depth';
                bedC = -tmpData.depth';
                [uC, zC] = Discharge.deleteNan(uC, zC);
                
                sctIn.distLeft = tmpData.distLeft;
                sctIn.distRight = tmpData.distRight;
                
                % integrate discharge
                tmp = Discharge.edgeEstimateValeport(sctIn, uC, distC, zC, hC, bedC);
                if size(uC, 2) > 1
                    qTmp = -Integrate.trapeziumRule(zC', uC');
                else
                    qTmp = hC' .* uC';
                    tmp.Qtop = 0;
                    tmp.Qbot = 0;
                end
                tmp.qLocal = 0.5 .* (diff(distC') .* (qTmp(1:end-1) + qTmp(2:end)));
                tmp.Qmid = nansum(tmp.qLocal);
                
                % put output together
                tmp.Qtot = nansum([tmp.Qmid, tmp.Qtop, tmp.Qbot, ...
                    tmp.Qleft, tmp.Qright]);
                                
                tmp.timeRange = [];
                if ~(isnan(tmpData.timeStart) && isnan(tmpData.timeEnd))
                    tmp.timeRange = [tmpData.timeStart, tmpData.timeEnd];
                end
                tmp.location = tmpData.location;
                
                if sum(isnan([tmp.Qmid, tmp.Qtop, tmp.Qbot, ...
                        tmp.Qleft, tmp.Qright])) > 0
                    warning('nan value is detected in Q data');
                end
                sctOut(i) = tmp;
                
                if sctIn.plotCheck
                    ax = subplot(length(tmpData.vel), 1, i);
                    Profile.x = [min(distC) - tmpData.distLeft; distC; max(distC) + tmpData.distRight];
                    Profile.z = [0; bedC; 0];
                    
                    if size(uC, 1) > 2 && size(uC, 2) > 2
                        contourf(ax, repmat(distC', size(zC, 2), 1), zC', uC', 'linestyle', 'none'); hold on;
                        
                        %                       else
                        %                           Profile.u = [0;uC';0];
                        %                         pcolor(ax, Profile.x, repmat(zC,size(Profile.x)),Profile.u); hold on;
                    end
                    colorbar;
                    plot(ax, Profile.x, Profile.z, '-k', 'linewidth', 1); hold on;
                    plot(ax, Profile.x, zeros(size(Profile.x)), '-b', 'linewidth', 1); hold on;
                    plot(ax, repmat(distC', size(zC, 2), 1), zC', 'o', 'color', [.5, .5, .5]);
                    axis equal;
                    if ~isempty(sctOut(i).timeRange) 
                        title(ax, ['Discharge calibration at ', sctOut(i).location, ' on ', datestr(nanmean(sctOut(i).timeRange), 'dd-mmm-yy HH:MM')]);
                    else
                        title(ax, ['Discharge calibration at ', sctOut(i).location]);
                    end
                    %plotOptions.contourType = 'pcolor';
                    %Plot.contourFigure(ax, repmat(distC',size(zC,2),1), zC', uC', plotOptions);
                end
            end
            
            
        end
        
        function [uC, zC] = deleteNan(uCin, zCin)
            % delete nans from valeport data
            
            % preallocate
            uC = nan(size(uCin));
            zC = nan(size(uCin));
            nrPoin = size(uCin, 1);
            
            for i = 1:nrPoin
                % find last good value
                lastValid = find(~isnan(uCin(i, :)), 1, 'last');
                tmpU = uCin(i, 1:lastValid);
                tmpZ = zCin(i, 1:lastValid);
                % find nans
                mask = ~isnan(tmpU);
                nrData = sum(mask);
                % add dtaa
                uC(i, 1:nrData) = tmpU(mask);
                zC(i, 1:nrData) = tmpZ(mask);
            end
            
        end
        
        function tmpData = readXls(sctIn, sheetName)
            tmpData = [];
            tmpData = Util.setDefault(tmpData, 'date', nan);
            tmpData = Util.setDefault(tmpData, 'location', '');
            tmpData = Util.setDefault(tmpData, 'timeStart', nan);
            tmpData = Util.setDefault(tmpData, 'timeEnd', nan);
            
            % read the data
            [~, ~, raw] = xlsread(sctIn.fileName, sheetName);
            %[~,~,raw] = xlsread(sctIn.fileName,sheetName,'B10:Z200');
            mask = cellfun(@isnumeric, raw);
            txt = raw; txt(mask) = {''};
            num = raw; num(~mask) = {nan};
            num = cell2mat(num);
            
            %  % add some metadata
            tmpData.fileName = sctIn.fileName;
            tmpData.sheetName = sheetName;
            % location name
            mask = regexpi(txt, '(location)|(locatie)','ignorecase');
            [indRow, indCol] = find(cellfun(@(x) ~isempty(x), mask) == true);
            
            try tmpData.location = txt{indRow, indCol+2};end
            % date and time
            mask = regexpi(txt, '(datum)|(date)','ignorecase');
            [indRow, indCol] = find(cellfun(@(x) ~isempty(x), mask) == true);
            if ~isempty(txt{indRow, indCol+2})
                try tmpData.date = datenum(txt{indRow, indCol+2}, 'dd/mm/yyyy');end
            end
            
            mask = regexpi(txt, '(begintijd)|(voor metingen)');
            [indRow, indCol] = find(cellfun(@(x) ~isempty(x), mask) == true);
           
            if ~isnan(tmpData.date) && ~isempty(indRow)
                tmpData.timeStart = tmpData.date + num(indRow, indCol+2);
            elseif ~isempty(indRow)
                tmpData.timeStart = num(indRow, indCol+2);
            end
            
            mask = regexpi(txt, '(eindtijd)|(na metingen)','ignorecase');
            [indRow, indCol] = find(cellfun(@(x) ~isempty(x), mask) == true);
            if ~isnan(tmpData.date) && ~isempty(indRow)
                tmpData.timeEnd = tmpData.date + num(indRow, indCol+2);
            elseif ~isempty(indRow)
                 tmpData.timeEnd = num(indRow, indCol+2);
            end
            
            % shape/vorm
            mask = regexpi(txt,'(shape)|(vorm)');
            [indRow, indCol] = find(cellfun(@(x) ~isempty(x),mask)==true);
            tmpData.shape.type = '';
            tmpData.shape.size = nan;
            
            if ~isempty(indRow)    
                tmpData.shape.type = txt(indRow, indCol+2);
                tmpData.shape.size = num(indRow, indCol+3:1:indCol+5); 
            end
            
            % cut the file
            mask = cellfun(@(x) strcmpi(x, 'LO'), txt);
            [StartRow, StartCol] = find(mask == true);
            mask = cellfun(@(x) strcmpi(x, 'RO'), txt);
            [x, EndCol] = find(mask == true);
            txt = txt(StartRow:end, StartCol:EndCol);
            num = num(StartRow:end, StartCol:EndCol);
            
            % look for left and right bank
            if ~strcmpi(txt{1, 1}, 'LO')
                errMsg = 'The location of the left bank is not in cell B10';
                error(errMsg);
            end
            rbIndex = find(strcmpi('RO', txt(1, :)));
            if isempty(rbIndex)
                errMsg = 'The location of the right bank is not found';
                error(errMsg);
            end
            
            %             % check if there is 0 below LO
            %             if raw{2,1}==0 &&  isnumeric(raw{3,1})
            %                 corfacLB = 1;
            %             else
            %                 corfacLB = 0;
            %             end
            %
            %
            %             % read depth and distance
            %             tmpData.distance  = num(2,corfacLB+1:rbIndex-1);
            %             tmpData.depth     = num(3,corfacLB+1:rbIndex-1);
            %             tmpData.distLeft  = num(2,corfacLB+1);%
            %             tmpData.distRight = num(2,rbIndex-0)-num(2,rbIndex-1);
            % upper commended part modified by JCA
            %             if ~isnumeric(raw{3,1})
            %                 error('The excel file contains non numeric values');
            %             else
            % find the first depth (refered to water surface) Left bank
            if rbIndex > size(num, 2)
                error('Add 0 below LO')
            end
            mask = num(3, 1:rbIndex) > 0;
            Start = find(mask, 1, 'first');
            if Start == 1
                Start = 2;
                tmpData.facLeft = 0.9;
            end
            
            % find the first latest zero
            mask = flip(num(3, 1:rbIndex)) > 0;
            End = rbIndex - find(mask, 1, 'first') + 1;
            if End == rbIndex
                End = End - 1;
                tmpData.facRight = 0.9;
            end
            % read depth and distance
            if ~isnan(tmpData.shape.size) & ~isempty(tmpData.shape.type)
                Start = 2; End = rbIndex-1;
            end            
            tmpData.distance = num(2, Start:End);
            tmpData.depth = num(3, Start:End);
            tmpData.distLeft = num(2, Start) - num(2, Start-1); % modified by JCA
            tmpData.distRight = num(2, rbIndex) - num(2, End);
            %end
            % determine depth of measurements and number of points
            depCol = txt(5:end, 1);
            % find the number of points
            nrMeasurement = 0;
            nrNan = 0;
            nrPoint = 0;
            TotValues = length(depCol) - sum(cellfun(@isempty, depCol));
            for i = 1:length(depCol)
                dep = str2double(strtok(depCol{i}));
                % start new measurement
                if isnan(dep)
                    %                     if nrNan == 1
                    %                         nrMeasurement = nrMeasurement + 1;
                    %                     else
                    %                         break;
                    %                     end
                    if (nrMeasurement * (nrPoint)) >= TotValues
                        break;
                    elseif nrMeasurement == 1
                        nrPoint = i - 1;
                    end
                    nrNan = nrNan + 1;
                elseif nrNan > 0 || nrMeasurement == 0; % modified by JCA
                    nrMeasurement = nrMeasurement + 1;
                    nrNan = 0;
                else
                    nrNan = 0;
                end
            end
            if nrPoint == 0
                nrPoint = length(depCol);
            end
            % read all data (backwards in order to avoid preallocation
            for j = nrMeasurement:-1:1
                for i = nrPoint:-1:1
                    n = (j - 1) * (nrPoint + 1) + i;
                    tmpData.dep{j}(i) = -str2double(strtok(depCol{n})) / 100;
                end
            end
            % read the velocity profiles
            for j = nrMeasurement:-1:1
                i2 = j * (nrPoint + 1) + 3;
                i1 = (j - 1) * (nrPoint + 1) + 5;
                %tmpData.vel{j} = num(i1:i2,(1:rbIndex-2)+corfac);
                tmpData.vel{j} = num(i1:i2, Start:End); % Modified by JCA
            end
            % find reference
            cWord = {'bodem', 'bed'};
            tmpData.usedReference = 'surface';
            for i = 1:length(cWord)
                mask = regexpi(txt, (['\w*', cWord{i}, '\w*']));
                if sum(sum(cellfun(@isempty, mask))) < (size(txt, 1) * size(txt, 2))
                    tmpData.usedReference = 'bed';
                end
            end
            % set the correct reference; the script uses water surface
            switch lower(tmpData.usedReference)
                case 'bed'
                    for i = 1:length(tmpData.dep)
                        tmpBed = tmpData.dep{i};
                        for iP = 1:length(tmpData.depth)
                            tmpData.dep{i}(iP, :) = -(tmpData.depth(1, iP) + tmpBed);
                        end
                        tmpData.dep{i} = tmpData.dep{i}';
                    end
                    
            end
            tmpData.usedReference = 'surface';
            
            
        end
        
        function sctOut = adcpDischarge(sctIn)
            %
            dataSet = Discharge.readAdcpData(sctIn.fileName, 0.0, sctIn);
            [currentFileLocation, currentFileName, currentFileExt] = fileparts(sctIn.fileName);
            
            % correct blanking
            %             for i=1:length(dataSet.blankingDepth.data)
            %                 ind = find(~isnan(dataSet.VelX.data(i,:)),1,'last');
            %                 if ~isempty(ind)
            %                     dataSet.blankingDepth.data(i) = dataSet.Z.data(i,ind);
            %                 else
            %                     dataSet.blankingDepth.data(i) = nan;
            %                 end
            %             end
            %             dataSet.blankingDepth.data = Interpolate.interpNan(dataSet.blankingDepth.data);
                       
            % get salinity from winriver file and correct for change of
            % soundvelocity
            
            dataSet = Discharge.correctSoundVel(dataSet, sctIn);
            
            % get binSize
            sctIn.binSize = dataSet.MetaData.binsize;
           if isfield(sctIn,'xRef')
                xRef=dataSet.X.data([1 end])
                yRef=dataSet.Y.data([1 end])
                % Re-project data on reference line
                [x, y, dist] = Calculate.projectOnRef(dataSet.X.data, dataSet.Y.data, xRef, yRef);
                dataSet.dist = abs(dist);
            else
            [xRef, yRef]= Discharge.FitTheoreticalTransect(dataSet,sctIn);
            
            % now check the direction
            
            %quick hack. I do not like it
            %             uXmean = nanmean(dataSet.VelX.data(:));
            %             uYmean = nanmean(dataSet.VelY.data(:));
            %             uMean  = sqrt(uXmean.^2+uYmean.^2);
            %             nX     = -uYmean./uMean; % cos
            %             nY     = uXmean./uMean;  % sin
            %
            % still can give division by zero
            %             xRef = [x(1), x(end)];
            %             yRef = nY.*nX.*[x(1), x(end)];
            
         
            % project data on reference line (no sorting is needed because points are determined from this)
            [x, y, dist] = Calculate.projectOnRef(dataSet.X.data, dataSet.Y.data, xRef, yRef);
            dataSet.dist = abs(dist);			
            dataSet.rico = atan(diff(dataSet.Y.data)./diff(dataSet.X.data));
            dataSet.rico(abs(dataSet.rico)>2*pi)=rem(dataSet.rico(abs(dataSet.rico)>2*pi),2*pi)
            dataSet.rico(dataSet.rico<0)=2*pi+dataSet.rico(dataSet.rico<0);
%             dataSet.rico(:,2)=dataSet.rico(:,1)*180/pi;

            dataSet.ricoRef = atan(diff(yRef)/diff(xRef));
            dataSet.ricoRef(dataSet.ricoRef<0)= 2*pi+dataSet.ricoRef(dataSet.ricoRef<0);

            % plot track and delete pre loops
            figure;
            subplot(211); hold on; grid on;
            title('Tracks');
            plot(x,y,'r*','displayname','Theoretical')
            plot(dataSet.X.data, dataSet.Y.data,'k*-','displayname','Measured')
%             while 
            % remove loops at the start of the transect
            dataSet= Discharge.RemovePreTransectLoops(dataSet,sctIn);
			
            % make new fit to the transect
            [xRef, yRef]= Discharge.FitTheoreticalTransect(dataSet,sctIn);

            % Re-project data on reference line 
            [x, y, dist] = Calculate.projectOnRef(dataSet.X.data, dataSet.Y.data, xRef, yRef);
            dataSet.dist = abs(dist);


            %           end
            % plot reprojected data
            subplot(211); hold on;
            plot(x,y,'y*','displayname','Theoretical bis')

            subplot(212); grid on; hold on;
            plot(x,y,'r*','displayname','Theoretical bis')
            plot(dataSet.X.data, dataSet.Y.data,'b*-','displayname','Corrected') 
			
            if sctIn.saveFig
                    if ~exist(fullfile(sctIn.savePath,'figures'), 'dir')
                        mkdir(fullfile(sctIn.savePath,'figures'))
                    end
                    UtilPlot.saveFig(fullfile(sctIn.savePath,'figures',[currentFileName,'_RemoveApproach']));
            end

            
          end
            
            theta = 180 / pi * atan2(diff(yRef), diff(xRef));            
%             theta(theta<0) =  theta(theta<0) + 360;

            % apply corrections         
            % correct for Magnetic variation/ beam misalignment
            [VelXcorrected, VelYcorrected] = Calculate.rotateVector(dataSet.VelX.data, dataSet.VelY.data, sctIn.bmAlignment, 'degrees');
            
            % Rotate vector on theoretical transect
            [uCrossRaw, uAlongRaw] = Calculate.rotateVector(VelXcorrected, VelYcorrected, theta);
            
%              correct for rotation of Negative theta
            if theta<0
                 uCrossRaw= -uCrossRaw;
                 uAlongRaw = -uAlongRaw;
            end
            
            z = dataSet.Z.data;
            [nrX, nrZ] = size(dataSet.VelY.data);

        
            % outlier detection
            orgMask = isnan(dataSet.VelX.data) | isnan(dataSet.VelY.data);
            maskU = Filter.removeOutlierGlobal(dataSet.VelX.data, sctIn);
            maskV = Filter.removeOutlierGlobal(dataSet.VelY.data, sctIn);
            mask = maskU | maskV;
            maskU = Filter.removeOutliersMedian2d(dataSet.VelX.data, sctIn);
            maskV = Filter.removeOutliersMedian2d(dataSet.VelY.data, sctIn);
            maskOut = false(nrX, nrZ);
            % filter sudden changes in depth
            maskDep = Filter.removeOutliersMedian1d(dataSet.BotZ.data, sctIn);
            maskDep2D = repmat(maskDep, 1, size(mask, 2));
            
            
            % mask blanking depths
            for i = 1:nrX
                maskOut(i, :) = z(i, :) > dataSet.blankingDepth.data(i);
            end
            maskInOut = maskU | maskV | mask | maskDep2D;
            maskIn = maskInOut | orgMask;
            clear mask;
            
            
            % interpolate nans
            uCrossMasked = uCrossRaw;
            uAlongMasked = uAlongRaw;
            uCrossMasked(maskIn) = nan;
            uAlongMasked(maskIn) = nan;
            t = repmat(dataSet.Time.data, 1, size(z, 2));
            % normalize weight z and t equally
            tNorm = (max(t(:)) - min(t(:))) * length(t);
            zNorm = max(z(:)) - min(z(:)) * length(z);
            uCross = uCrossMasked;
            uCross(maskOut) = Interpolate.InvDist(t(~maskIn)./tNorm, z(~maskIn)./zNorm, uCross(~maskIn), t(maskOut)./tNorm, z(maskOut)./zNorm, sctIn.invDistFac);
            uAlong = uAlongMasked;
            uAlong(maskOut) = Interpolate.InvDist(t(~maskIn)./tNorm, z(~maskIn)./zNorm, uAlong(~maskIn), t(maskOut)./tNorm, z(maskOut)./zNorm, sctIn.invDistFac);
            
            [uX, uY] = Calculate.rotateVector(uAlong, uCross, -theta);
            
            % also for bottom depths
            dataSet.BotZ.data(maskDep) = nan;
            dataSet.BotZ.data = Interpolate.interpNan(dataSet.BotZ.data);
            
            % plot quiver
            figure; hold on; grid on
            quiver(repmat(dataSet.X.data,1,size(VelXcorrected,2)), repmat(dataSet.Y.data,1,size(VelYcorrected,2)),dataSet.VelX.data, dataSet.VelY.data, 0, 'r', 'linewidth', 2,'displayname','Original');
            quiver(repmat(dataSet.X.data,1,size(VelXcorrected,2)), repmat(dataSet.Y.data,1,size(VelYcorrected,2)),VelXcorrected , VelYcorrected, 0, 'k', 'linewidth', 2,'displayname','Magnetic Correction');
            quiver(repmat(x,1,size(VelXcorrected,2)), repmat(y,1,size(VelYcorrected,2)),uCrossRaw, uAlongRaw, 0, 'b', 'linewidth', 2,'displayname','Projected along and across transect');
            quiver(repmat(x,1,size(VelXcorrected,2)), repmat(y,1,size(VelYcorrected,2)),uX, uY, 0, 'y', 'linewidth', 2,'displayname','Projected');
            axis equal
            figureTitle = strrep(strcat('Vectors of theoretical transect:', ' ', currentFileName, currentFileExt),'_','-');
            title( {figureTitle})
            legend('show')
            
            if sctIn.saveFig
                    if ~exist(fullfile(sctIn.savePath,'figures'), 'dir')
                        mkdir(fullfile(sctIn.savePath,'figures'))
                    end
                    UtilPlot.saveFig(fullfile(sctIn.savePath,'figures',[currentFileName,'_QuiverProjections']));
            end
                  
            % put profiles together            
            % plot to check outlier detection
            if sctIn.plotCheck
                roundVal = 0.25;
                roundValU = 0.25;
                yLim = [Calculate.roundToVal(min(dataSet.BotZ.data(:)), roundVal, 'floor'), ...
                    Calculate.roundToVal(max(dataSet.WatLev.data(:)), roundVal, 'ceil')];
                
                cLim = [Calculate.roundToVal(min(uCross(:)), roundValU, 'floor'), ...
                    Calculate.roundToVal(max(uCross(:)), roundValU, 'ceil')];
                
                UtilPlot.reportFigureTemplate('portrait'); % create figure
%               figure('pos', [100, 100, 1200, 800])
                % raw data
                subplot(3, 1, 1)
                pcolor(t, z, uCrossRaw);
                hold on;
                plot(t, dataSet.WatLev.data, t, dataSet.BotZ.data);
%                 xlabel('Time [s]');
                ylabel('Z [m]');
                dynamicDateTicks;
                caxis(cLim);
                shading flat
                ylim(yLim);
                title('Raw data')
                colorbar
                
                % after filtering
                subplot(3, 1, 2)
                pcolor(t, z, uCrossMasked);
                hold on;
                plot(t, dataSet.WatLev.data, t, dataSet.BotZ.data);
%                 xlabel('Time [s]');
                ylabel('Z [m]');
                dynamicDateTicks;
                caxis(cLim);
                shading flat
                ylim(yLim);
                title('Filtered data')
                colorbar
                
                % interpolated
                subplot(3, 1, 3)
                pcolor(t, z, uCross);
                hold on;
                plot(t, dataSet.WatLev.data, t, dataSet.BotZ.data);
                xlabel('Time [s]');
                ylabel('Z [m]');
                dynamicDateTicks;
                caxis(cLim);
                shading flat
                ylim(yLim);
                title('Interpolated data')
                colorbar
                
                % adding figure title:
                figureTitle = strrep(strcat('Outlier Detection for:', ' ', currentFileName, currentFileExt),'_','-');
                ha = axes('Position', [0, 0, 1, 1], 'Xlim', [0, 1], 'Ylim', [0, 1], 'Box', 'off', 'Visible', 'off', 'Units', 'normalized', 'clipping', 'off');
                text(0.3, 1, {figureTitle}, 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 9, 'Interpreter', 'None');
                
                if sctIn.saveFig
                    if ~exist(fullfile(sctIn.savePath,'figures'), 'dir')
                        mkdir(fullfile(sctIn.savePath,'figures'))
                    end
                    UtilPlot.saveFig(fullfile(sctIn.savePath,'figures',[currentFileName,'_Trans']));
                end
                
            end
            
            % now the three types of processing
            switch lower(sctIn.method)
                case 'extractprofile'
                    
                    %1.) extract profiles
                    %[profStart, profEnd] = Discharge.extractProfileLoc(dataSet, dist, sctIn);
                    nrCoor = sctIn.minNrPoint;
                    sctTmp.xLabel = 'Time [s]';
                    sctTmp.yLabel = 'Dist [m]';
                    sctTmp.currentFileName = currentFileName;
                    sctTmp.savePath = sctIn.savePath;
                    tPlot = dataSet.Time.data;
                    tPlot = 86400 * (tPlot - min(tPlot));
                    if ~isfield(sctIn, 'maskFile')
                        maskAll = Discharge.selectZonesManual(tPlot, dataSet.dist, nrCoor, sctTmp);
                    else
                        tmp = load(sctIn.maskFile, 'mask');
                        maskAll = tmp.mask;
                        clear tmp;
                    end
                    %nrCoor = length(profStart);
                    xC = zeros(nrCoor, 1);
                    yC = zeros(nrCoor, 1);
                    uC = nan(nrCoor, nrZ);
                    vC = nan(nrCoor, nrZ);
                    zC = zeros(nrCoor, nrZ);
                    tC = zeros(nrCoor, 1);
                    hC = zeros(nrCoor, 1);
                    bedC = zeros(nrCoor, 1);
                    distC = zeros(nrCoor, 1);
                    xyCell = cell(nrCoor, 1);
                    for i = 1:nrCoor
                        %mask = profStart(i):profEnd(i);
                        mask = maskAll{i};
                        xyCell{i} = [dataSet.X.data(mask), dataSet.Y.data(mask)];
                        xC(i) = nanmean(x(mask));
                        yC(i) = nanmean(y(mask));
                        if isfield(sctIn, 'distLoc')
                            distC(i) = sctIn.distLoc(i);
                        else
                            distC(i) = nanmean(dataSet.dist(mask));
                        end
                        tC(i) = nanmean(t(mask));
                        uTmp = uCross(mask, :);
                        % check that at least half of the data is not nan
                        depMask = sum(~isnan(uTmp), 1) > 0.5 .* size(uTmp, 1);
                        uAvg = nanmean(uTmp(:, depMask));
                        uC(i, 1:length(uAvg)) = uAvg;
                        uTmp = uAlong(mask, :);
                        uAvg = nanmean(uTmp(:, depMask));
                        vC(i, 1:length(uAvg)) = uAvg;
                        zC(i, :) = nanmean(z(mask, :));
                        bedC(i) = nanmean(dataSet.BotZ.data(mask));
                        hC(i) = nanmean(dataSet.WatLev.data(mask)-dataSet.BotZ.data(mask));
                        % perform checks
                        dt = (max(t(mask)) - min(t(mask))) * 86400;
                        if dt < sctIn.minT
                            error(['The time of point ', num2str(i), ' is not large enough']);
                        end
                        dx = repmat(x(mask), 1, sum(mask)) - repmat(x(mask)', sum(mask), 1);
                        dy = repmat(y(mask), 1, sum(mask)) - repmat(y(mask)', sum(mask), 1);
                        dx2 = dx.^2 + dy.^2;
                        if max(dx2) > (sctIn.maxDx)^2
                            error(['The maximum distance in point ', num2str(i), ' is too large']);
                        end
                        
                    end
                    
                    % PLOT TO CHECK PROFILE LOCATIONS
                    if sctIn.plotCheck
                        figure('pos', [100, 100, 1200, 800])
                        plot(x, y, ':k', dataSet.X.data, dataSet.Y.data, '-k', xC, yC, 'ok');
                        hold on
                        myColor = 'rgbcym';
                        afac = 0.5;
                        for i = 1:nrCoor
                            j = 1 + mod(i-1, length(myColor));
                            plot(xyCell{i}(:, 1), xyCell{i}(:, 2), myColor(j));
                            % add velocities
                            uAl = afac .* nanmean(uC(i, :));
                            uCr = afac .* nanmean(vC(i, :));
                            theta = atan2(diff(yRef), diff(xRef));
                            quiver(xC(i), yC(i), uAl.*cos(theta), uAl.*sin(theta), 0, myColor(j), 'linewidth', 2);
                            quiver(xC(i), yC(i), uCr.*cos(theta+pi/2), uCr.*sin(theta+pi/2), 0, myColor(j), 'linewidth', 2);
                        end
                        xlabel('X [m]')
                        ylabel('Y [m]')
                        legend('Transect', 'Data', 'Coordinates')
                        grid on
                        axis equal
                        figureTitle = strrep(strcat('Profile Location for:', ' ', currentFileName, currentFileExt),'_','-');
                        title(gca, figureTitle, 'FontWeight', 'bold', 'FontSize', 13, 'Interpreter', 'None');
                    end
                    
                    % plot profiles
                    if sctIn.plotCheck
                        figure('pos', [100, 100, 1200, 800])
                        roundVal = 0.5;
                        minVel = min(min(uC(:)), min(vC(:)));
                        maxVel = max(max(uC(:)), max(vC(:)));
                        uLim = [Calculate.roundToVal(minVel, roundVal, 'floor'), ...
                            Calculate.roundToVal(maxVel, roundVal, 'ceil')];
                        zLim = [Calculate.roundToVal(min(bedC(:)), roundVal, 'floor'), ...
                            Calculate.roundToVal(max(zC(:)), roundVal, 'ceil')];
                        for i = 1:nrCoor
                            subplot(ceil(nrCoor/3), 3, i)
                            plot(uC(i, :), zC(i, :), vC(i, :), zC(i, :));
                            grid on
                            legend({'Cross', 'Along'}, 'location', 'best')
                            title(['Measurement point', num2str(i)])
                            xlabel('u [m/s]');
                            ylabel('z [m]');
                            xlim(uLim);
                            ylim(zLim);
                        end
                        
                        % adding figure title:
                        figureTitle = strcat('Measurements Points for:', ' ', currentFileName, currentFileExt);
                        ha = axes('Position', [0, 0, 1, 1], 'Xlim', [0, 1], 'Ylim', [0, 1], 'Box', 'off', 'Visible', 'off', 'Units', 'normalized', 'clipping', 'off');
                        text(0.4, 1, {figureTitle}, 'center', 'VerticalAlignment', 'top', 'FontWeight', 'bold', 'FontSize', 13, 'Interpreter', 'None');
                        axis equal
                    end
                    
                    if length(xC) < sctIn.minNrPoint
                        error(['At least ', num2str(sctIn.minNrPoint), ' points must be present']);
                    end
                    if sctIn.useMag
                        uC = sqrt(uC.^2+vC.^2);
                    end
                    
                    
                    % add edge estimations
                    sctOut = Discharge.edgeEstimateAdcp(sctIn, uC, distC, zC, hC, bedC);
                    % integrate discharge
                    % The minus sign is there because the distances in zC
                    % are also negative
                    qTmp = -nansum(diff(zC').*uC(:, 1:end-1)');
                    sctOut.qLocal = 0.5 .* (diff(distC') .* (qTmp(1:end-1) + qTmp(2:end)));
                    sctOut.Qmid = sum(sctOut.qLocal);
                    sctOut.theta=theta;
                    % put output together
                    sctOut.Qtot = nansum([sctOut.Qmid, sctOut.Qtop, sctOut.Qbot, ...
                        sctOut.Qleft, sctOut.Qright]);
                    
                case 'locprofile'
                    if sctIn.plotCheck
                        figure('pos', [100, 100, 1200, 800])
                        plot(x, y, ':k', dataSet.X.data, dataSet.Y.data, '-r');
                        xlabel('X [m]')
                        ylabel('Y [m]')
                        legend('Transect', 'Data')
                        grid on
                        axis equal
                    end
                    % determine discharge (without edge estimate)                    
                    qTmp = -nansum(diff(z').*uCross(:, 1:end-1)');
                    dx = diff(dataSet.dist');
                    dq = qTmp(1:end-1) + qTmp(2:end);
                    mask = dx > 0;
                    sctOut.qLocal = 0.5 .* abs(dx(mask).*dq(mask));
                    sctOut.Qmid = nansum(sctOut.qLocal);
                    qCum = cumsum(sctOut.qLocal./sctOut.Qmid);
                    minFrac = (1:sctIn.minNrPoint) / sctIn.minNrPoint;
                    sctOut.location = zeros(length(minFrac), 1);
                    for i = 1:length(minFrac)
                        [~, ind] = min(abs(minFrac(i)-qCum));
                        sctOut.location(i) = dataSet.dist(ind);
                    end
                    sctIn.minDist;
                    
                case 'distprofile'
                    % integrate discharges                   
                    % vector plot
                    uMean = nanmean(uX, 2);
                    vMean = nanmean(uY, 2);
                    
                    
                    if sctIn.useMag
                        uCross = sqrt(uCross.^2+uAlong.^2);
                    end
                    
                    
                    qTmp = nansum(-diff(z').*uCross(:, 1:end-1)'); 
                    dx = diff(dataSet.dist');
                    dq = qTmp(1:end-1) + qTmp(2:end);
                    mask = dx > 0;
                    hC = dataSet.WatLev.data - dataSet.BotZ.data;
                    bedC = dataSet.BotZ.data;                    
                    
                    % calculate Qbot, Qleft, Qright, Qtop
                    sctOut = Discharge.edgeEstimateAdcp(sctIn, uCross, dataSet.dist, z, hC,bedC);

                    % calculate Qmid
                    sctOut.qLocal = 0.5 .* (dx(mask) .* dq(mask));
                    sctOut.Qmid = nansum(sctOut.qLocal);
                    sctOut.theta=theta;
                    % sctOut.XYRef=[xRef yRef];


                    
                    % put output together
                    sctOut.Qtot = nansum([sctOut.Qmid, sctOut.Qtop, sctOut.Qbot, ...
                                          sctOut.Qleft, sctOut.Qright]);
                    sctOut.dist = max(dataSet.dist);                   
                    
                    
                    
                    
                    % create figure
                    UtilPlot.reportFigureTemplate('portrait'); % create figure
                    quiver(dataSet.X.data, dataSet.Y.data, uMean, vMean)
                    axis equal
                    figureTitle = strrep(strcat('Quiverplot for:', ' ', currentFileName, currentFileExt),'_','-');
                    title([{figureTitle},' Total Discharge: ',num2str(sctOut.Qtot)]);
                                        
                    if sctIn.saveFig          
                        if ~exist(fullfile(sctIn.savePath,'figures'), 'dir')
                            mkdir(fullfile(sctIn.savePath,'figures'));
                        end
                        UtilPlot.saveFig(fullfile(sctIn.savePath,'figures',[currentFileName,'_Quiver']));
                    end

                    
                    
                otherwise
                    error('Unknown method');
            end
            %
            stop;
        end
        
        function mask = selectZonesManual(x, y, nrPoint, sctOpt)
            % manually extract zones
            
            if nargin == 3
                sctOpt = struct;
            end
            sctOpt = Util.setDefault(sctOpt, 'xlabel', 'x');
            sctOpt = Util.setDefault(sctOpt, 'ylabel', 'y');
            sctOpt = Util.setDefault(sctOpt, 'saveSelection', true);
            
            %make a figure
            figure;
            plot(x, y);
            hAx = gca;
            grid on
            
            xlabel(sctOpt.xlabel)
            ylabel(sctOpt.ylabel)
            title(['Still ', num2str(nrPoint), ' points to select']);
            
            % Construct a questdlg with three options
            choice = questdlg('Make a selection', ...
                'Point selection', ...
                'New selection', 'Select existing one', 'Select existing one');
            % Handle response
            switch choice
                case 'New selection'
                    selectOption = 1;
                case 'Select existing one'
                    selectOption = 2;
            end
            
            if selectOption == 2
                while true
                    if exist('defaultPath', 'var')
                        defaultPath = defaultPath;
                    else
                        defaultPath = fullfile(sctOpt.savePath, 'selections');
                    end
                    
                    [filename, pathname, ~] = uigetfile( ...
                        {'*.mat', 'Select previous point selection'}, ...
                        'Pick a file', ...
                        defaultPath, ...
                        'MultiSelect', 'off');
                    
                    filteredFiles = struct();
                    if pathname ~= 0
                        load(fullfile(pathname, filename));
                        loaded = true;
                        tmpPlot = cell(nrPoint, 1);
                        for i = 1:nrPoint
                            hold on
                            title(['Still ', num2str(nrPoint-i), ' points to select']);
                            tmpPlot{i} = plot(x(mask{i}), y(mask{i}), 'r', 'linewidth', 2);
                        end
                    else
                        errordlg('You should select a valid file');
                    end
                    
                    choiceSel = questdlg('Use selection', ...
                        'Do you want to use this selection?', ...
                        'Yes', 'No', 'Yes');
                    
                    switch choiceSel
                        case 'Yes'
                            break;
                        case 'No'
                            for i = 1:nrPoint
                                delete(tmpPlot{i});
                            end
                            
                    end
                    
                end
            else
                % select data
                mask = cell(nrPoint, 1);
                for i = 1:nrPoint
                    hold on
                    while true
                        [xBox, yBox] = Util.rbboxSelect(hAx);
                        maskTmp = x >= min(xBox) & x <= max(xBox) & y >= min(yBox) & y <= max(yBox);
                        if sum(maskTmp) > 0
                            mask{i} = maskTmp;
                            %update plot
                            pBox = plot(xBox, yBox, 'k');
                            txtPoint = text(mean(xBox), mean(yBox), num2str(i));
                            
                            choiceSelection = questdlg('Selection Option', ...
                                'Selection Option', ...
                                'Confirm selection', 'Discard selection', 'Confirm selection');
                            
                            switch choiceSelection
                                case 'Confirm selection'
                                    confirmSelection = 1;
                                case 'Discard selection'
                                    confirmSelection = 0;
                            end
                            
                            if confirmSelection
                                plot(x(mask{i}), y(mask{i}), 'r', 'linewidth', 2)
                                break;
                            else
                                delete(txtPoint);
                                delete(pBox);
                            end
                        else
                            title(['No data for point ', num2str(i), '. Try again']);
                            %                        msgbox(['No data for point ',num2str(i),'. Try again']);
                            %                        pause(0.2);
                        end
                    end
                    %                     mask{i} = maskTmp;
                    %                     %update plot
                    %                     plot(xBox, yBox, 'k');
                    %                     text(mean(xBox), mean(yBox), num2str(i));
                    title(['Still ', num2str(nrPoint-i), ' points to select']);
                    %                     plot(x(mask{i}), y(mask{i}), 'r', 'linewidth', 2)
                end
            end
            
            
            if sctOpt.saveSelection && selectOption == 1
                selLocation = fullfile(sctOpt.savePath, 'selections');
                if exist(selLocation, 'dir') ~= 7
                    mkdir(selLocation)
                end
                
                save(fullfile(selLocation, [sctOpt.currentFileName, '___', datestr(now, 30), '.mat']))
            end
        end
function [xRef, yRef]= FitTheoreticalTransect(dataSet,sctIn)
			% determine the theoretical transect
            x = dataSet.X.data;
            y = dataSet.Y.data;
			[a, b, c] = Fit.fitLine(x, y);           
            % FAILS if b==0
            if (abs(a) > 1e-5)
                xRef = [x(1), x(end)];
                yRef = -(a .* xRef + c) ./ b;
            else
                yRef = [y(1), y(end)];
                xRef = -(b .* yRef + c) ./ a;
            end
            
            % check if a reference line is predifined
            if isfield(sctIn, 'xRef') && isfield(sctIn, 'yRef')
                xRef = sctIn.xRef;
                yRef = sctIn.yRef;
            end
end
            
        
      function dataSet = RemovePreTransectLoops(dataSet, sctIn)
                       
            % distance of projected points on theoretical profile from xRef,yRef
            [distLB, indLB] = nanmin(dataSet.dist); % left bank
            [distRB, indRB] = nanmax(dataSet.dist); % right bank
            
            % find indices that do not fit along direction transect in the
            % first and last 40 samples
            angle=pi/2;
            nSamples=20-1;
            [indRicoLB] = find(or(dataSet.rico(1:nSamples)>dataSet.ricoRef+angle,dataSet.rico(1:nSamples)<dataSet.ricoRef-angle)); % left bank
            [indRicoRB] = find(or(dataSet.rico(end-nSamples:end)>dataSet.ricoRef+angle,dataSet.rico(end-nSamples:end)<dataSet.ricoRef-angle)); % left bank
            indRicoRB = indRicoRB+size(dataSet.rico,1)-nSamples-1;
            % determine left or right
            ndir = 1;
            if nanmedian(diff(dataSet.dist)) < 0
                ndir = -1;
            end
                        
            if ndir == 1 % from left to rights
                mask = unique([1:indLB-1, indRB+1:length(dataSet.dist),indRicoLB',indRicoRB']);
            else % from right to left / or from max to min
                mask = unique([1:indRB-1, indLB+1:length(dataSet.dist),indRicoLB',indRicoRB']);
            end
            
            dataSet.VelX.data(mask,:) = [];
            dataSet.VelY.data(mask,:) = [];
            dataSet.X.data(mask,:) = [];
            dataSet.Y.data(mask,:) = [];
            dataSet.Z.data(mask,:) = [];
            dataSet.Time.data(mask,:) = [];
            dataSet.BotZ.data(mask,:) = [];
            dataSet.blankingDepth.data(mask,:) = [];
            dataSet.WatLev.data(mask,:) = [];
            dataSet.Temp.data(:,mask) = [];
            dataSet.Sal.data(mask) = [];
            dataSet.dist(mask,:) = [];            
      end
            
        function sctOut = edgeEstimateValeport(sctIn, u, s, z, h, bed)
            % calculate estmates at the edges of a profile
            % water level is always zero!
            % u = velocity
            % s = distance
            % z = levels refered to water level
            % h = -bed; height of the water level
            % bed = -h
            % [nBinURight nBinLeft] number of bins left and right for the edge estimate
            
            % OUTPUT:
            %  sctOut.Qleft 
            %  sctOut.Qright
            %  sctOut.Qtop
            %  sctOut.Qbot
            
            % [left right]
            % depth averages and water depths
            uTmp = u(1:sctIn.nBinULeft,:);
            hTmp = h(1:sctIn.nBinULeft);
            uLeft = nanmean(nanmean(uTmp,2));
            hLeft = nanmedian(hTmp);
            
            uTmp = u(end-sctIn.nBinURight:end, :);
            hTmp = h(end-sctIn.nBinULeft:end);            
            uRight = nanmean(nanmean(uTmp,2));
            hRight = nanmedian(hTmp);
            
            sctOut.Qleft = sctIn.distLeft .* sctIn.facLeft .* uLeft .* hLeft;
            sctOut.Qright = sctIn.distRight .* sctIn.facRight .* uRight .* hRight;
            
            % top (take into account that z level is at half the cell)
            depBin = sctIn.binSize;
            dh = -(z(:, 1) - 0.5 * depBin);
            mask = dh > -z(:, 1);
            dh(mask) = z(mask, 1);
            uTmp = u(:, 1);
            qTop = 0.5 .* nansum(diff(s).*(dh(1:end-1) .* uTmp(1:end-1) + dh(2:end) .* uTmp(2:end)));
            sctOut.Qtop = sctIn.facTop .* qTop;
            
            % bottom
            % find bed profile
            ind = Discharge.lastInd(u);
            dh = zeros(size(ind));
            uTmp = zeros(size(ind));
            for i = 1:length(ind)
                dh(i) = -bed(i) + z(i, ind(i)) + 0.5 * depBin;
                uTmp(i) = u(i, ind(i));
            end
            qBot = 0.5 .* nansum(diff(s).*(dh(1:end-1) .* uTmp(1:end-1) + dh(2:end) .* uTmp(2:end)));
            sctOut.Qbot = sctIn.facBot .* qBot;
            
        end
        
        function sctOut = edgeEstimateAdcp(sctIn, u, s, z, h, bed)
            % calculate estmates at the edges of a profile
            % edge: mean velocity of the number of points specified by
            % nBinURight/Left
            % bottom: mean lower layers, to do: Power Law (QRev)
            % Top: mean upper layers, to do: Constant, Power Law (default), three point fit (QRev)
            % u = velocity
            % s = distance
            % z = levels refered to water level
            % h = -bed; height of the water level
            % bed = -h
            % [nBinURight nBinLeft] number of points left and right for the edge estimate
            % sctIn.watLev = Waterlevel correction (default:0)
            
            % OUTPUT:
            %  sctOut.Qleft 
            %  sctOut.Qright
            %  sctOut.Qtop
            %  sctOut.Qbot
            
            % [left right]
            % depth averages and water depths
            uTmp = u(1:sctIn.nBinULeft,:);
            hTmp = h(1:sctIn.nBinULeft);
            uLeft = nanmean(nanmean(uTmp,2));
            hLeft = nanmedian(hTmp);
            
            uTmp = u(end-sctIn.nBinURight:end, :);
            hTmp = h(end-sctIn.nBinULeft:end);            
            uRight = nanmean(nanmean(uTmp,2));
            hRight = nanmedian(hTmp);
            
            sctOut.Qleft = sctIn.distLeft .* sctIn.facLeft .* uLeft .* hLeft;
            sctOut.Qright = sctIn.distRight .* sctIn.facRight .* uRight .* hRight;
            
            % top (take into account that z level is at half the cell)

            dx = abs(([diff(s);0] + [0;diff(s)])).*0.5;
            dx = repmat(dx,1,size(u,2));
            dz = abs([diff(z,1,2) diff(z(:,end-1:end),1,2)]);
            uTmp= zeros(size(dx,1),1);
            depBin = sctIn.binSize;
            dzTop = sctIn.watLev-(z(:, 1) + 0.5 * depBin);
            qAreaTop= dzTop.*dx(:,1);
            switch sctIn.topDischargeMethod
                case  'Constant'
            uTmp = nanmean(u(:,1:sctIn.nBinUTop),2);
            qTop = uTmp.*qAreaTop;
                case  'Power'
            
                  
%             uTmp=nanmean(u,1)
%             uTmp_err=nanstd(u,1)
% 
% %             p=polyfit(log(z),log(u),1)
% %             b=p(1);
% %             a=exp(p(2));
% %             uTmp = a*x
%             figure; hold on;
%             scatter(u(:),z(:))
%             plot(uTmp,z(1,:))
%             
%             p=polyfit(log(z(1,:)),log(utmp),1)
%             b=p(1);
%             a=exp(p(2));
%             uTmp = a*x
            
            
           end
           qTop = uTmp.*qAreaTop;
           sctOut.Qtop = nansum(sctIn.facTop .* qTop);

            
            % bottom
            % find bed profile
            ind = Discharge.lastInd(u);
            dzBot = zeros(size(ind));
            uTmp = zeros(size(ind));
            for iB = 1:length(ind)
                dzBot(iB) = abs(h(iB) + (z(iB, ind(iB)) - 0.5 *dz(iB,ind(iB)))); % half of the binsize
                if ind(iB)-sctIn.nBinUBot+1 > 1
                    uTmp(iB) = nanmean(u(iB, (ind(iB)-sctIn.nBinUBot+1):ind(iB)),2);
                else
                    uTmp(iB) = nanmean(u(iB, 1:ind(iB)),2); 
                end
            end
            areaBot =  dzBot.*dx(:,1); 
            sctOut.Qbot = nansum(sctIn.facBot .* areaBot.*uTmp);            
        end
        
        function ind = lastInd(x)
            % find the last non-nan value in the second dimension
            [nrX, nrInd] = size(x);
            ind = nrInd .* ones(nrX, 1);
            for i = 1:nrX
                tmp = find(~isnan(x(i, :)), 1, 'last');
                if ~isempty(tmp)
                    ind(i) = tmp;
                end
            end
            
        end
        
        
        function [profStart, profStop] = extractProfileLoc(dataSet, dist, sctIn)
            % extracts profiles from a time series based on location
            
            maxDx = sctIn.maxDx;
            minT = sctIn.minT / 86400;
            
            t = dataSet.Time.data;
            dt = (max(t) - min(t)) / length(t);
            nrT = round(minT/dt);
            
            % velocity determination method
            uBoat = diff(dist) ./ diff(t) / 86400;
            uBoatFilt = Filter.lowpassFilter(uBoat, 15, 2);
            dist = Filter.lowpassFilter(dist, 15, 2);
            uBoat = diff(dist) ./ diff(t) / 86400;
            
            
            % determine points, based on distance
            edges = Calculate.roundToVal(min(dist), maxDx, 'floor'):maxDx:Calculate.roundToVal(max(dist), maxDx, 'ceil');
            [counts, distBin] = hist(dist, edges);
            indPoints = counts > nrT;
            allPoints = distBin(indPoints);
            nrPoints = sum(indPoints);
            % now determine accurately from the data
            profStart = zeros(nrPoints, 1);
            profStop = zeros(nrPoints, 1);
            
            for i = 1:nrPoints
                mask = dist > allPoints(i) - maxDx / 2 & dist < allPoints(i) + maxDx / 2;
                dMean = nanmedian(dist(mask));
                dMin = dMean - maxDx / 2;
                dMax = dMean + maxDx / 2;
                %disp(num2str([dMin dMean dMax]))
                mask = dist > dMin & dist < dMax;
                profStart(i) = find(mask, 1, 'first');
                profStop(i) = find(mask, 1, 'last');
                %figure; plot(mask)
            end
            ind = 1:length(t);
            tmp = zeros(size(t));
            for i = 1:length(profStart)
                mask = ind >= profStart(i) & ind <= profStop(i);
                tmp(mask) = i;
            end
            figure; plot(t, dist, t, tmp); grid on
            
        end
        
        function dataSet = correctSoundVel(dataSet, sctIn)
            % corrects data using the the sound speed
            
            % use data from data set or from input
%             if isfield(dataSet.Sal)
%                 salinity = dataSet.Sal.data;
%             else
%                 salinity = sctIn.salinity;
%             end
%             if isfield(dataSet.Temp)
%                 temperature = dataSet.Temp.data;
%             else
%                 temperature = sctIn.temperature;
%             end
            
            % use salinity provided or 0 (default)
            salinity = sctIn.salinity;
            temperature = sctIn.temperature;
            

            depth = dataSet.WatLev.data(end,1) - dataSet.Z.data(1,end);
            
            % calculate the speed of sound
            %soundSpeedAdcp = Physics.calculateSoundVelocity(temperature, sctIn.salinityWinRiver, depth, sctIn.soundSpeedMethod);
            soundSpeedAdcp = 1500 ; 
            soundSpeedReal = Physics.calculateSoundVelocity(temperature, salinity, depth, sctIn.soundSpeedMethod);
            
            % copy data if needed
            if numel(soundSpeedReal) == 1
                soundSpeedReal = repmat(soundSpeedReal, size(dataSet.VelX.data));
            end
            if numel(soundSpeedAdcp) == 1
                soundSpeedAdcp = repmat(soundSpeedAdcp, size(dataSet.VelX.data));
            end
            corFac = soundSpeedReal ./ soundSpeedAdcp;
            
            % correct velocity
            dataSet.VelX.data = dataSet.VelX.data .* corFac;
            dataSet.VelY.data = dataSet.VelY.data .* corFac;
            
            % correct depths (not needed for the moment, but included anyway)
%             depth = corFac .* depth;
%             nrZ = size(depth, 2);
%             dataSet.Z.data = repmat(dataSet.WatLev.data, nrZ, 1) - cumsum(depth, 2);
            
        end
        
        function dataSet = readAdcpData(fileName, watLev, sctIn)
            % reads a winriver file
            % INPUT:
            %     - fileName: winriver file to be read
            %     - watLev (optional): water level
            %OUTPUT:
            %     - dataSet.VelX.data: dataTmp.velEast';
            %     - dataSet.VelY.data: dataTmp.velNorth';
            %     - dataSet.X.data: dataTmp.posShipEastRel;
            %     - dataSet.Y.data: dataTmp.posShipNorthRel;
            %     - dataSet.Z.data: watLev - repmat(dataTmp.BinDepth', nrX, 1);
            %     - dataSet.Time.data: time;
            %     - dataSet.BotZ.data: watLev - dataTmp.BTdepth;
            %     - dataSet.blankingDepth.data: watLev - dataTmp.DepthSidelobe;
            %     - dataSet.WatLev.data: watLev .* ones(size(dataTmp.BTdepth));
            %     - dataSet.Temp.data: double(dataTmp.temperature) / 100.0;
            %     - dataSet.Sal.data: double(dataTmp.salinity) / 100.0;
            %     - dataSet.MetaData.binsize: double(dataTmp.binsize) / 100;

            if nargin == 1
                watLev = 0.0;
            end
            
            dataTmp = readADCP(fileName);
            dataTmp.VEL = double(dataTmp.VEL);
            dataTmp.btvel = double(dataTmp.btvel);
            
            %By default, difecho = 50, cortres = 64, erveltres = 0.8 m/s

%         difecho
%         threshold above which difference between echo intensities for all
%         beams and the mean is high enough to be rejected
%
%         cortres
%         threshold in low correlation
%
%         erveltres
%         threshold in error velocity
            
            
%             dataTmp.difecho=1;
%             dataTmp.cortres=65;
%             dataTmp.erveltres=0.8;
%             
            
            [dataTmp.VEL, dataTmp.btvel] = filterADCP(dataTmp,'');%,'cortres',65); % mm/s => m/s
            [dataTmp.VEL, dataTmp.btvel] = corADCP(dataTmp, 'e'); % to earth coordinates m/s; easting (1,3D), northing(2,3D), upwards(3,3D), error(4,3D)
            
            useBottom = true;
            if isfield(sctIn, 'useBottom')
                useBottom = sctIn.useBottom;
            end
            if useBottom % use bottom track
                dataTmp.VELwater(:, :, 1) = dataTmp.VEL(:, :, 1) - repmat(dataTmp.btvel(:, 1)', size(dataTmp.VEL, 1), 1); %easting m/s
                dataTmp.VELwater(:, :, 2) = dataTmp.VEL(:, :, 2) - repmat(dataTmp.btvel(:, 2)', size(dataTmp.VEL, 1), 1); % northing m/s
                dataTmp.VELwater(:, :, 3) = dataTmp.VEL(:, :, 3) - repmat(dataTmp.btvel(:, 3)', size(dataTmp.VEL, 1), 1); % upwards m/s
                dataTmp.VELwater(:, :, 4) = dataTmp.VEL(:, :, 4) - repmat(dataTmp.btvel(:, 4)', size(dataTmp.VEL, 1), 1); % error m/s
            else 
                dataTmp.VELwater(:, :, 1) = dataTmp.VEL(:, :, 1);
                dataTmp.VELwater(:, :, 2) = dataTmp.VEL(:, :, 2);
                dataTmp.VELwater(:, :, 3) = dataTmp.VEL(:, :, 3);
                dataTmp.VELwater(:, :, 4) = dataTmp.VEL(:, :, 4);
            end
            
            % bottom track depth (+ correct for ADCP depth)
            [x, y, z] = depthADCP(dataTmp);
            z = z - sctIn.depAdcp;
            dataTmp.BTdepth = abs(nanmedian([z(:, :, 1); z(:, :, 2); z(:, :, 3); z(:, :, 4)], 1))'; % median
            
            % cell depth
            dataTmp.BinDepth = (0:1:double(dataTmp.nbins) - 1)' .* double(dataTmp.binsize) / 100 + double(dataTmp.distmidbin1) / 100; %metres
            
            % filtering side lobe
            index = strfind(dataTmp.sysconfstr{1}, 'Beam angle:');
            dataTmp.BeamAngle = str2double(dataTmp.sysconfstr{1}(index + (11:13)));
            dataTmp.DepthSidelobe = dataTmp.BTdepth .* cosd(dataTmp.BeamAngle);
            
            dataTmp.MaskSidelobe = false(size(dataTmp.VELwater(:, :, 1)));
            for i = 1:length(dataTmp.DepthSidelobe)
                dataTmp.MaskSidelobe(dataTmp.DepthSidelobe(i)+0.5*dataTmp.binsize/100 <= dataTmp.BinDepth, i) = true;
            end
            
            
            % water velocity in 2D components
            dataTmp.velEast = dataTmp.VELwater(:, :, 1);
            dataTmp.velNorth = dataTmp.VELwater(:, :, 2);
            
            dataTmp.velEast(dataTmp.MaskSidelobe) = nan;
            dataTmp.velNorth(dataTmp.MaskSidelobe) = nan;
            
            % vessel velocity in 2D components
            dataTmp.velShipEast = dataTmp.btvel(:, 1);
            dataTmp.velShipNorth = dataTmp.btvel(:, 2);
            
            %position vessel
            dataTmp.timeV1C(:, 1) = dataTmp.timeV1C(:, 1) + 2000;
            time = datenum(dataTmp.timeV1C);
            timestep = diff(time) * 24 * 60 * 60; % seconds
            
            % Calculate u v ship speed
            uShip = Interpolate.interpNan(dataTmp.velShipEast);
            vShip = Interpolate.interpNan(dataTmp.velShipNorth);
            dataTmp.posShipEastRel = cumsum([0; uShip(1:end-1) .* timestep]); % x-position referred to first measurement
            dataTmp.posShipNorthRel = cumsum([0; vShip(1:end-1) .* timestep]); % y-position referred to first measurement
            
            x = squeeze(x);
            y = squeeze(y);
            
            nrX = size(x, 1);
            
            % now collect only what is needed(including repmat)
            dataSet.VelX.data = dataTmp.velEast';
            dataSet.VelY.data = dataTmp.velNorth';
            
            dataSet.X.data = dataTmp.posShipEastRel;
            dataSet.Y.data = dataTmp.posShipNorthRel;
            dataSet.Z.data = watLev - repmat(dataTmp.BinDepth', nrX, 1);
            dataSet.Time.data = time;
            dataSet.BotZ.data = watLev - dataTmp.BTdepth;
            dataSet.blankingDepth.data = watLev - dataTmp.DepthSidelobe;
            dataSet.WatLev.data = watLev .* ones(size(dataTmp.BTdepth));
            dataSet.Temp.data = double(dataTmp.temperature) / 100.0;
            %TODO: double check conversion factor for salinity
            dataSet.Sal.data = double(dataTmp.salinity) / 100.0;
            dataSet.MetaData.binsize = double(dataTmp.binsize) / 100;
            
        end
        
        function [velPer, velPar] = calculateVelTransect(velX, velY, heading)
            % this function calculates the velocity components according
            % the predefined transect.
            % 
            % [velPer, velPar] = Discharge.calculateVelTransect(velX, velY, heading)
            %
            % # input
            %  velX = east orientated velocity component
            %  velY =  north orientated velocity component
            %  heading = heading of the predefined line in degrees (convention from
            %  left to right bank) OR matrix with x-coordinates (column 1) 
            % and y-coordinates (column 2).
            %
            % # output
            %  velpar = velocity parallel to the transect (positive is from left to
            %  right)
            % velPer = velocity perpendicular on the transect (in the direction of the flow)
            %
            % WRITTEN BY: JCA
            % DATE: 2019
            
            if size(heading,2) == 2
                heading = 90 - atan2d(heading(:,2), heading(:,1));
                % calculate the heading of the line (parts)
            end
            heading(heading<0) = heading(heading<0) + 360; 
            theta = (heading - 90);
            [velPar, velPer] = Calculate.rotateVector(velX, velY, theta);
      
        end
    end
end