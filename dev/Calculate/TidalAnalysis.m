% Class tidalAnalysis %%
%
% @author ABR
% @author Sebastian Osorio
% @version 0.8, 10/02/2014
%

classdef TidalAnalysis < handle
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
        
        function ind = matchComp(name, allName)
           % matches components in t_tide format
           %
           % ind = matchComp(name, allName)
           %
           % INPUT
           % -allName: array with names of the components in ttide format
           % -name: name of the component to look for
           %
           % OUTPUT
           % -ind: index of the component; 0  means not found
           ind = 0;
           name = strtrim(name);
           for j=1:size(allName,1)
                theName = strtrim(allName(j,:));
                if strcmpi(theName,name)
                    ind = j;
                    break;
                end
           end
        end
        
        function wlNew =  adaptTide(t,wl,components,deltaPhi,deltaA)
            % reconstruct tide using tTide
            % 
            % wlNew =  adaptTide(t,wl,deltaPhi,deltaA)
            % INPUT
            % - t : time (datys)
            % - wl: water level
            % - components: cell array with the name of the components to
            % correct
            % -deltaPhi: shift of the phase (in degrees) for each
            % component in components
            % deltaA (optional) :  shift in amplitude to apply
            %
            % OUTPUT
            % wlNew: new time series applying the corrcetions
            
            % make column vectors
            t  = Util.makeColVec(t);
            wl = Util.makeColVec(wl);            
            
            % decomposition and remainder
            [tideStruc,wlRec] = TidalAnalysis.ttide(t,wl);
            wlDif = wl-wlRec;
            
            % change conponents
            for i=1:length(components)
                ind = TidalAnalysis.matchComp(components{i}, tideStruc.name);
                if ind==0
                    warning(['Component ',components{i},' not found']);
                end
                % correct phase
                tideStruc.tidecon(ind,3) = tideStruc.tidecon(ind,3)+deltaPhi(i);
                % coorect amplitude
                if nargin==5
                    tideStruc.tidecon(ind,1) = tideStruc.tidecon(ind,1)+deltaA(i);
                end
            end

            % reconstruction (adding remainder)
             wlNew = t_predic(t,tideStruc);
             wlNew = wlNew + wlDif;
           
        end
        
        function [tideStruc,hRec] = ttide(t,wl,components)
            % wrapper around t_tide
            %
            % [tideStruc,hRec] = ttide(t,wl,components)
            %
            % t: time  (Matlab time format)
            % wl: water level
            % components: (optional) components on which the analysis is
            % performed
            
            interval = nanmedian(diff(t))*24;
            [tmp,hRec] = t_tide(wl,'interval',interval,'error','wboot','start_time',t(1),'output','none');
            % extract components
            if nargin==3
                % look for match
                ind = zeros(length(components),1);
                for i=1:length(components)
                    ind(i) = TidalAnalysis.matchComp(components{i}, tmp.name);
                end
                % check that all components are found
                if any(ind==0)
                    error('some components were not found');
                end
                tideStruc.name = tmp.name(ind,:);
                tideStruc.freq = tmp.freq(ind,:);
                tideStruc.tidecon = tmp.tidecon(ind,:);
                tideStruc.type = tmp.type;
            else
                tideStruc = tmp;
            end
            
        end
        
        function [tFlood,tEbb,tTide] = tidalAssym(tHw,tLw,sctOpt)
            % determines tidal assummetry characteristics
            %
            % [tFlood,tEbb,tTide] = tidalAssym(tHw,tLw,sctOpt)
            
            % set defaults
            if nargin <3
                sctOpt = struct;
            end
            sctOpt = Util.setDefault(sctOpt,'dtMax',15/24);
            sctOpt = Util.setDefault(sctOpt,'dtMin',10/24);
            
            % opreaklocate
            tFlood = nan(length(tLw),1);
            tEbb   = nan(length(tLw),1);
            tTide  = nan(length(tLw),1);
            
            % it is assumed that time serie starts and ends with LW
            n = 0;
            for i=1:length(tLw)-1
                tLw1 = tLw(i);
                tLw2 = tLw(i+1);
                dt   = tLw2-tLw1;
                % check length of the tide
                if dt>sctOpt.dtMax || dt<sctOpt.dtMin
                    continue;
                end  
                % find high water in between low waters
                ind = find(tHw>tLw1 & tHw<tLw2);
                % only consider one high water in between
                if length(ind)~=1
                    continue
                end
                % add data
                n = n +1;
                tFlood(n) = tHw(ind)-tLw1;
                tEbb(n)   = -tHw(ind)+tLw2;
                tTide(n)  = tLw2-tLw1;
            end
            
            % delete emptydata
            if n<length(tLw)
                tFlood(n+1:end) = [];
                tEbb(n+1:end) = [];
                tTide(n+1:end) = [];
            end
        end
        
        function [hw,lw,tHw,tLw ] = tideStats(t,wl,threshold,sctOpt)
            % determines tidal characteristics of water level time series
            %
            % [hw,lw,tHw,tLw ] = tideStats(t,wl,sctOpt)
            %
            % INPUTL
            % t : time [day]
            % wl: water level [m]
            % threshold: threshold for peak det method [m]
            % sctOpt: structure with options (optional)
            
            % determine high and low waters
            if nargin< 4
                sctOpt = struct;
            end
            sctOpt =  Util.setDefault(sctOpt,'method','peakdet');
            if nargin >= 3 
                sctOpt =  Util.setDefault(sctOpt,'threshold',threshold);
            end
            [indexHigh,indexLow] = TidalAnalysis.calcHwLw(wl,[],sctOpt);
            
            % get characteristics of tide
            hw = wl(indexHigh);
            lw = wl(indexLow);
            tHw = t(indexHigh);
            tLw = t(indexLow);
            
        end
        function [ind1,ind2]  = match(t1,t2,maxDt)
            % matches  data by a threshold
            %
            % [ind1,ind2]  = match(t1,t2,maxDt)
            % INPUT: 
            % - t1 and t2: vectors to match
            % -  maxDt: theshold for matching
            % OUTPUT:
            % ind1 and ind2: index vector such that abs(t1(ind1)-t2(ind2) <
            % maxDt
            
            % match data by Time
            
            % preallocate
            ind1 = zeros(size(t1));
            ind2 = zeros(size(t1));
            n = 0;
            
            % compare all data
            for i=1:length(t1)
                mask = abs(t1(i)-t2)<maxDt;
                if sum(mask)>0
                    if sum(mask) ==1
                        n = n+1;
                        ind1(n) = i;
                        ind2(n) = find(mask);
                    else
                        error('Multiple matches found');
                    end
                end
            end
            if n<length(ind1)
                ind1(n+1:end) = [];
                ind2(n+1:end) = [];
            end
            
        end
        
        function data = ttideCompare(t,tRef,wl,wlRef,sctOpt)
            % ttide comparison of two time_series
            
            if nargin ==4
                sctOpt = struct;
            end
            
            % select common period
            tStart = max(min(t),min(tRef));
            tEnd   = min(max(t),max(tRef));
            mask   = t>=tStart & t<=tEnd;
            t  = t(mask);
            wl = wl(mask);
            mask   = tRef>=tStart & tRef<=tEnd;
            tRef  = tRef(mask);
            wlRef = wlRef(mask);
            
            
            % use t_tide
            if isfield(sctOpt,'components')
                tds    = TidalAnalysis.ttide(t   ,wl,   sctOpt.components);
                tdsRef = TidalAnalysis.ttide(tRef,wlRef,sctOpt.components);
            else
                tds    = TidalAnalysis.ttide(t   ,wl);
                tdsRef = TidalAnalysis.ttide(tRef,wlRef);
            end
            
            % compare all components
            n = 0;
            for i=1:length(tds.name)
                ind = TidalAnalysis.matchComp(tds.name(i,:), tdsRef.name);
                if ind>0
                    n = n+1;
                    name = ['comp',strtrim(tds.name(i,:))];
                    data.(name).freq = tds.freq(i);
                    data.(name).ampl = tds.tidecon(i,1);
                    data.(name).amplRef  = tdsRef.tidecon(ind,1);
                    data.(name).phase    = tds.tidecon(i,3);
                    data.(name).phaseRef = tdsRef.tidecon(ind,3);
                    data.(name).amplDiff  = data.(name).ampl-data.(name).amplRef;
                    tmp = data.(name).phase-data.(name).phaseRef;
                    tmp(tmp<0) = tmp(tmp<0)+360;
                    tmp(tmp>360) = tmp(tmp>360)-360;
                    data.(name).phaseDiff = tmp;
                end
            end
        end
        
        function data = tideCompare(t,tRef,wl,wlRef,maxDh,maxDt,sctOpt)
            % compares tidal data from two datasets
            %
            %  data = tideCompare(t,tRef,wl,wlRef,maxDh,maxDt,sctOpt)
            %
            % INPUT
            % -t,tRef: vectors with time of the two datasets
            % -wl, wlRef: vectors with water level data to compare
            % maxDh: threshold for determining the peaks in peakdet
            % maxDt: threshold for matching high and low waters (in days)
            
            if nargin< 7
                sctOpt = struct;
            end
            % calculate characteristics
            [hw1,lw1,tHw1,tLw1 ] = TidalAnalysis.tideStats(t,wl,maxDh,sctOpt);
            [hw2,lw2,tHw2,tLw2 ] = TidalAnalysis.tideStats(tRef,wlRef,maxDh,sctOpt);
            
            % match data by time
            
            % high water
            [ind1,ind2]  = TidalAnalysis.match(tHw1,tHw2,maxDt);
            hw1  = hw1(ind1);
            hw2  = hw2(ind2);
            tHw1 = tHw1(ind1);
            tHw2 = tHw2(ind2);
            
            % low water
            [ind1,ind2]  = TidalAnalysis.match(tLw1,tLw2,maxDt);
            lw1  = lw1(ind1);
            lw2  = lw2(ind2);
            tLw1 = tLw1(ind1);
            tLw2 = tLw2(ind2);
            
            % calculate statistics
            [data.rmseHw,data.rmse0Hw,data.biasHw]    = Statistics.quickStatistics(hw1,hw2);
            [data.rmseLw,data.rmse0Lw,data.biasLw]    = Statistics.quickStatistics(lw1,lw2);
            [data.rmseThw,data.rmse0Thw,data.biasThw] = Statistics.quickStatistics(tHw1,tHw2);
            [data.rmseTlw,data.rmse0Tlw,data.biasTlw] = Statistics.quickStatistics(tLw1,tLw2);
        end
        
        function [indexHigh,indexLow] = calcHwLw(watLev,period,sctOption)
            % determines the moments of high and low water
            %
            %[indexHigh,indexLow] = calcHwLw(watLev,period,sctOption)
            %
            % INPUT:
            % watLev: a vector with the water levels.
            % period: period (in number of time steps!) for the difference
            % between consecutive low water or high water values. This
            % value is used to remove doubles. Recommended value for a
            % semi-diurnal tide is 9 hours. If period is empty no check on
            % doubles is performed.
            % sctOption: a structure with fields (optional)
            % -deleteAvg: 1 if maxima above and minima below the mean water
            % level should be deleted. defaults = 0
            % -method: alowed values is 'peakdet': using this, the external
            % function peakdet is used. It is STRONGLY RECOMMANDED to use
            % this option
            % -theshold: the threshold value (in m) used in peakdef.
            % -startWithLow: first and lmast extremm is low water (default
            % = true)
            %
            % OUTPUT
            % indexHigh: a vector with the index of the moments of High
            % water in watLev. ie. all the high waters can be found with
            % watLev(indexHigh)
            % indexLow: a vector with the index of the moments of Low
            % water in watLev
            
            %             filterSize = 2;
            %             iEnd       = length(watLev) + filterSize;
            %             maskHigh   = true(size(watLev));
            %             maskLow    = true(size(watLev));
            %             watLev     = [nan(filterSize,1);watLev;nan(filterSize,1)];
            %             iStart     = filterSize+1;
            %
            %             % look for local minima, maxima
            %             filters = -filterSize:2:filterSize;
            %             filters(filters==0) = [];
            %             for i = filters
            %                 maskHigh = (watLev(iStart:iEnd) > watLev(iStart+i:iEnd+i)) & maskHigh;
            %                 maskLow  = (watLev(iStart:iEnd) < watLev(iStart+i:iEnd+i)) & maskLow;
            %             end;
            
            % find extreme values
            
            if nargin ==2
                sctOption = struct;
            end
            if isempty(period)
                period = 0;
            end
            sctOption =  Util.setDefault(sctOption,'method','');
            sctOption =  Util.setDefault(sctOption,'startWithLow',true);
            if isfield(sctOption,'method') && strcmpi(sctOption.method,'peakdet')
                % use external peak det function
                sctOption =  Util.setDefault(sctOption,'threshold',0.5);
                [tabHigh, tabLow] = peakdet(watLev,sctOption.threshold);
                indexHigh = tabHigh(:,1);
                indexLow  = tabLow(:,1);
            else
                % use traditional method (looking at inflection points
                maskHigh = (watLev(2:end-1)>= watLev(1:end-2)) & (watLev(2:end-1)>= watLev(3:end));
                maskLow  = (watLev(2:end-1)<= watLev(1:end-2)) & (watLev(2:end-1)<= watLev(3:end));
                
                % determine indices
                indexHigh = find(maskHigh) + 1;
                indexLow  = find(maskLow)  + 1;
            end
            
            % set options
            if nargin ==2
                sctOption.deleteAvg = 0;
            end
            sctOption = Util.setDefault(sctOption,'deleteAvg',0);
            
            
            % delete low water below average etc.
            if isfield(sctOption,'deleteAvg') && sctOption.deleteAvg
                meanWl = nanmedian(watLev);
                indexHigh(watLev(indexHigh) < meanWl) = [];
                indexLow(watLev(indexLow) > meanWl)   = [];
            end
            
            % delete double indices
            indexHigh = TidalAnalysis.deleteNonLocal(watLev,indexHigh,period,'max');
            indexLow  = TidalAnalysis.deleteNonLocal(watLev,indexLow ,period,'min');
            
            % make sure series start and end with low water
            if sctOption.startWithLow
                if indexHigh(1)<indexLow(1)
                    indexHigh = indexHigh(2:end);
                end
                if indexHigh(end)>indexLow(end)
                    indexHigh = indexHigh(1:end-1);
                end
            end
            end
        
        function  calcHwLwPlot(time,watLev,indexHigh,indexLow)
            % plots tidal analysis results to check
            hw = watLev(indexHigh);
            lw = watLev(indexLow);
            tHw = time(indexHigh);
            tLw = time(indexLow);
            
            plot(time,watLev,'-r',tHw,hw,'^r',tLw,lw,'vr')
            grid on
        end
        
        function [TTi,T] = calcTideTerms (u3,z,c3,t,sctOption)
            % performs an analysis of tidal transport terms
            %
            % [TTi,T] = calcTideTerms (u3,z,c3,t,sctOption)
            %
            % INPUT:
            %    - u3: matrix with velocity profiles (nrTxnrZ) 
            %    - z:  matrix with elevations of the velocities 
            %    - c3: matrix with concentration profiles (nrTxnrZ) (nrTxnrZ) 
            %    - sctOptions: options used in calcHwLw (see tthere)
            %
            % OUTPUT: 
            % - TTi, a matrix whith for each tidal period the
            % following terms:
            % - TTi(:,1): advection by tidal mean current
            % - TTi(:,2): dispersion by correnlation between steady and oscilatory
            % components
            % - TTi(:,3): Stokes wave transport
            % - TTi(:,4): dispersion by oscilatory components
            % - TTi(:,5): shear dispersion by steady components
            % - TTi(:,6): shear disperions by steady and fluctuating components
            % - TTi(:,7): shear disperions by steady and fluctuating components
            % - TTi(:,8): shear disperions by fluctuating components
            % - T: corresponding Time
            %
            %
            % The method is based on 
            % De Nijs, Michael Aegidius Johannes. 
            % On sedimentation processes in a stratified estuarine system. 
            % Diss. TU Delft, Delft University of Technology, 2012.
            
            % determine water level and depth
            wl = z(:,end);
            h  = z(:,end)-z(:,1);
            nrZ = size(z,2);
            nrT = size(z,1);
            
            % tidal analysis
            [~,indexLow] = TidalAnalysis.calcHwLw(wl,[],sctOption);
            nrTide = length(indexLow)-1;
            
            % depth average and decompositions
            u2 = Integrate.intThreshold(z,u3,2)./h;
            c2 = Integrate.intThreshold(z,c3,2)./h;
            % preallocate
            uV = zeros(nrT,nrZ);
            cV = zeros(nrT,nrZ);
            for iZ=1:nrZ
                uV(:,iZ) = u3(:,iZ)-u2;
                cV(:,iZ) = c3(:,iZ)-c2;
            end
            
            %preallocate 
            TTi = zeros(nrTide,8);
            T   = zeros(nrTide,1);
            for iT=1:nrTide
                % calculate tidal averages 
                mask = indexLow(iT):indexLow(iT+1);
                nrM  = length(mask);
                h0   = mean(h(mask));
                ht   = h(mask) -h0;
                u20  = mean(u2(mask)); 
                u2t  = u2(mask)-u20;
                u30  = mean(uV(mask,:));
                u3t  = uV(mask,:)-repmat(u30,nrM,1);
                c20  = mean(c2(mask)); 
                c2t  = c2(mask)-c20;
                c30  = mean(cV(mask,:));
                c3t  = cV(mask,:)-repmat(c30,nrM,1);
                z0   = mean(z(mask,:)); 
                zM   = z(mask,:);
                
                % calculate transport terms
                TTi(iT,1) = h0.*u20.*c20;
                TTi(iT,2) = u20.*mean(ht.*c2t);
                TTi(iT,3) = c20.*mean(ht.*u2t);
                TTi(iT,4) = mean(ht.*u2t.*c2t);
                TTi(iT,5) = Integrate.intThreshold(z0',u30'.*c30');
                TTi(iT,6) = mean(Integrate.intThreshold(zM,repmat(u30,nrM,1).*c3t,2));
                TTi(iT,7) = mean(Integrate.intThreshold(zM,repmat(c30,nrM,1).*u3t,2));
                TTi(iT,8) = mean(Integrate.intThreshold(zM,u3t.*c3t,2));
                
                T (iT)   = 0.5.*(t(indexLow(iT))+t(indexLow(iT+1)));
            end
            
        end
        
        function index = deleteDouble(index,period)
            % deletes repeated indices (i.e. indices that arecloser than period intervals together)
            % INPUT:
            % index: a vector with indices to a another vector
            % period: threshold value used in deleting (in number of
            % indices)
            % OUTPUT:
            % index: an updated version of index
            
            i = 1;
            % note that the length of index changes as indexes are deleted
            while i < length(index)
                if index(i+1)-index(i)<period
                    % delete value closer than threshold
                    index(i+1) = [];
                    % do not increase the value.
                else
                    % go the next value
                    i = i + 1;
                end
                
            end
        end
        
        function index = deleteNonLocal(wl,index,period,type)
            % deletes non local maxima (i.e. indices that arecloser than period intervals together)
            % INPUT:
            % wl: water levels
            % index: a vector with indices to a another vector
            % period: threshold value used in deleting (in number of
            % indices)
            % type: 'max' or 'min'
            % OUTPUT:
            % index: an updated version of index
            
            if strcmpi(type,'max')
                numType = 1;
            else
                numType = 0;
            end
            i = 1;
            % note that the length of index changes as indexes are deleted
            while i < length(index)
                if index(i+1)-index(i)<period
                    wlDiff = wl(index(i+1)) - wl(index(i));
                    if (numType && wlDiff>0) || (~numType && wlDiff<0)
                        index(i) = [];
                    else
                        index(i+1) = [];
                    end
                    % do not increase the value.
                else
                    % go the next value
                    i = i + 1;
                end
                
            end
        end
        
        
        function type = findNeapSpring(type,time,invtime,timeHw,timeLw,value,nrPhase,isLw)
            % helper function used in neapSpringMoon
            
            sizeHw = length(timeHw);
            for i = 1:length(time)-1
                % it is checked what the first HW is, that comes after
                % spring tide and before neap tide or the opposite
                
                % based on HW
                minIndex = find(time(i)<timeHw & invtime(i)>timeHw,1,'first');
                maxIndex = min(minIndex+nrPhase-1,sizeHw(1));
                
                %find the low water moments correpsoning to the moments
                %of high water that were found previously
                % based on LW
                if ~isempty(minIndex) && ~isempty(maxIndex)
                    if isLw
                        minIndex = find(timeHw(minIndex)>timeLw,1,'last');
                        maxIndex = find(timeHw(maxIndex)<timeLw,1,'first');
                    end
                    type(minIndex:maxIndex) = value;
                end
            end
        end
        
        function [type,Hmin,Hmax] = meanNeapSpring(H,threshold)
            % determines the kind of tide
            % The caluclation is based on the tidal amplitude and a threshold value the fraction of tides considered springtide or neaptide.
            %
            % INPUT:
            % H: vector with tidal amplitudes (from waterLevelAmp)
            % threshold: a threshold value (between 0 and 1) to determine
            % which tides are considered neap ( water levels smaller than threshold percentile), mean or spring
            %
            % OUTPUT:
            % type: vector with value of -1, 0 or 1 (neap (-1), mean (0) or spring(+1))
            % Hmin: water level that corresponds to the change from neap to
            % mean tide
            % Hmax: the water level that corresponds with the change from
            % mean to spring tide
            
            % threshold for neaptide
            Hmin = prctile(H,100*threshold);
            % threshold for spring tide
            Hmax = prctile(H,(1-threshold)*100);
            
            % determine the type
            type = -1.* (H<Hmin) + (H>Hmax);
        end
        
        function [type] = neapSpringMoon(timeMoon,phaseMoon,timeHw,timeLw,sctOptions)
            % determines the kind of tide based on the phase of the moon.
            % Spring tide are the 7 HW following one hour after new or full moon. Neap tide is the 7
            % HW following 1 or 3 quarter
            %
            % INPUT:
            % timeMoon: time of moon phases
            % phaseMoon: pahse of the Moon (2 = 1st quarter, 1 = new
            % moon, 4 = last quarter, 3 = full moon
            % timeHw: time of High Water
            % timeLw: time of Low Water
            % sctOptions: structure with options
            % nNumber: number of HW/LW after phase of the moon (default is
            % 7)
            % isLw: one if the data start with LW, 0 otherwise
            %
            % OUTPUT:
            % type: vector with value of -1, 0 or 1 (neap (-1), mean (0) or spring(+1))
            
            nrPhase = 7;
            isLw = 1;
            if nargin>4
                if isfield(sctOptions,'nrPhase')
                    nrPhase = sctOptions.nrPhase;
                end
                if isfield(sctOptions,'isLw')
                    isLw = sctOptions.isLw ;
                end
            end
            
            % DETERMINE THE TIME OF SPRING AND NEAP
            timeSpring = timeMoon(phaseMoon==1 | phaseMoon==3) +1/24;
            timeNeap   = timeMoon(phaseMoon==2 | phaseMoon==4) +1/24;
            
            % CHECK IF SERIES START WITH SPRINGTIDE
            % AND END WITH NEAP TIDE
            if length(timeNeap)~= length(timeNeap)
                error('The number of neap tides must be equal to the number spring tides, in the data file with data of the moon.');
            end
            if timeSpring(1)>timeNeap(1)
                error('The first moon in the data file of the moon must be a spring tide');
            end
            
            % PREALLOCATE
            sizeLW = size(timeLw);
            type   = zeros(sizeLW(1),1);
            
            % LOOK FOR THE 7 TIDES FOLLOWING SPRING MOON
            type = TidalAnalysis.findNeapSpring(type,timeSpring,timeNeap(1:end-1),timeHw,timeLw,1,nrPhase,isLw);
            
            % LOOK FOR THE 7 TIDES FOLLOWING NEAP
            type = TidalAnalysis.findNeapSpring(type,timeNeap,timeSpring(2:end),timeHw,timeLw,-1,nrPhase,isLw);
        end
        
        function sctData = phaseAverage(data,type,indexLow,indexHigh,DT)
            % calculates the averages of the different periods
            %
            % It is assumed that all variables in use have the same time stamp and ar all
            % resampled to have regular time intervals
            %
            %INPUT:
            % data: vector with data to take phase avg
            % type: vector indicating neap (-1), mean (0) or spring tide
            % (1) (from meanNeapSpring)
            % indexHigh: a vector containing the indices of the moments of
            % High water (from calcHwLw)
            % indexLow: a vector containing the indices of the moments of
            % Low water (from calcHwLw)
            % DT: the time stamp in the used data
            %
            % OUTPUT:
            %sctData: a a structure with the fields neap, mean and spring,
            %containing the phase averages for each of these periods
            
            nrPeriods = length(indexLow)-1;
            nrData    = length(data);
            
            nrPhasePeriod = 2*max(diff(indexLow))+1;
            indexPhaseHw  =  max(diff(indexLow))+1;
            
            sumNeap   = zeros(nrPhasePeriod,1);
            sumMean   = zeros(nrPhasePeriod,1);
            sumSpring = zeros(nrPhasePeriod,1);
            nrNeap    = zeros(nrPhasePeriod,1);
            nrMean    = zeros(nrPhasePeriod,1);
            nrSpring  = zeros(nrPhasePeriod,1);
            
            % make time grid
            sctData.tTide = DT.* (-indexPhaseHw+1:indexPhaseHw-1);
            for i=1:nrPeriods
                %determine shift in data
                indHigh = (indexHigh>indexLow(i)) & (indexHigh<indexLow(i+1));
                indHigh = indexHigh(indHigh);
                
                if ~isempty(indHigh)
                    if  (indHigh(1) - indexPhaseHw+1)>=1 && (indHigh(end)+ indexPhaseHw-1)<=nrData
                        %mask for selecting data
                        maskData = (indHigh - indexPhaseHw+1) : (indHigh + indexPhaseHw-1);
                        % mask for putting data
                        maskAvg = 1:nrPhasePeriod;
                    elseif (indHigh(1) - indexPhaseHw+1)<1
                        % lower edge, use smaller sample
                        maskData = 1:(indHigh + indexPhaseHw-1);
                        maskAvg  = 1-(indHigh - indexPhaseHw):nrPhasePeriod;
                    elseif  indHigh(end)+ indexPhaseHw-1>nrData
                        % upper edge, use smaller sample
                        maskData = (indHigh - indexPhaseHw):nrData;
                        maskAvg  = 1:length(maskData);
                    end
                    
                    % select data in period
                    dataSelect  = data(maskData);
                    nrDataAdded = ones(size(maskAvg))';
                    
                    %delete Nan values
                    maskNan = isnan(dataSelect);
                    
                    dataSelect(maskNan)  = 0;
                    nrDataAdded(maskNan) = 0;
                    % determine average tide type
                    switch type(i)
                        case -1 %(neap)
                            sumNeap(maskAvg) = sumNeap(maskAvg) + dataSelect;
                            nrNeap(maskAvg)  = nrNeap(maskAvg) + nrDataAdded;
                        case 0 %mean
                            sumMean(maskAvg) = sumMean(maskAvg) + dataSelect;
                            nrMean(maskAvg)  = nrMean(maskAvg) + nrDataAdded;
                        case 1% spring
                            sumSpring(maskAvg) = sumSpring(maskAvg) + dataSelect;
                            nrSpring(maskAvg)  = nrSpring(maskAvg) + nrDataAdded;
                    end
                end
            end
            % calculate averages
            sctData.neap   = sumNeap./nrNeap;
            sctData.mean   = sumMean./nrMean;
            sctData.spring = sumSpring./nrSpring;
        end
        
        function period =  tidalPeriod(indexLow,indexHigh,time)
            % calculates the period (from LW to the next LW)
            % period =  TidalAnalysis.tidalPeriod(indexLow,indexHigh,time)
            % INPUT:
            % indexLow: Vector index denoting occurrance of low water (from
            % calcHwLw)
            % indexHigh: Vector index denoting occurrance of high water (from
            % calcHwLw)
            % time: a vector with the time
            % OUTPUT:
            % period: duration of each period (in days)
            
            
            tStart    =   time(indexLow(1:end-1));
            tEnd      =   time(indexLow(2:end));
            period    =  tEnd - tStart;
            
            
        end
        
        function tableTide = tideTable(t,h,tStart,tEnd,sctOption)
            % puts all tides of a time series in a table
            %
            % tableTide = tideTable(t,h,tStart,tEnd)
            %
            % INPUT
            % - t: time of the water levels
            % - h: water level time series
            % - tStart and tEmd: start and end time of the table to
            % generate
            % OUTPUT
            %  - tableTide : a cell array
            [indexHigh,indexLow] = TidalAnalysis.calcHwLw(h,[],sctOption);
            tHw = t(indexHigh);
            tLw = t(indexLow);
            sctTime.start = tStart;
            sctTime.end = tEnd;
            tDays = Time.timeStampDay(sctTime);
            nrDays = length(tDays)-1;
            tableTide = cell(nrDays+1,9);
            tableTide(1,:) = {'Date','HW 1','Time HW 1','HW 2','Time HW 2','LW 1','Time LW 1','LW 2','Time LW 2'};
            for j=1:nrDays
                tableTide{j+1,1} = datestr(floor(tDays(j)));
                % hw
                mask = find(tHw>=tDays(j) & tHw<tDays(j+1));
                switch length(mask)
                    case 1
                        ind1 = indexHigh(mask(1));
                        tableTide{j+1,2} = [num2str(h(ind1),'%5.2f'),' m'];
                        tableTide{j+1,3} = datestr(t(ind1),'HH:MM');
                        tableTide{j+1,4} = '-';
                        tableTide{j+1,5} = '-';
                    case 2
                        ind1 = indexHigh(mask(1));
                        ind2 = indexHigh(mask(2));
                        tableTide{j+1,2} = [num2str(h(ind1),'%5.2f'),' m'];
                        tableTide{j+1,3} = datestr(t(ind1),'HH:MM');
                        tableTide{j+1,4} = [num2str(h(ind2),'%5.2f'),' m'];
                        tableTide{j+1,5} = datestr(t(ind2),'HH:MM');
                    case 0
                        tableTide{j+1,2} = '-';
                        tableTide{j+1,3} = '-';
                        tableTide{j+1,4} = '-';
                        tableTide{j+1,5} = '-';
                    otherwise
                        error('Too many high waters');
                end
                %lw
                mask = find(tLw>=tDays(j) & tLw<tDays(j+1));
                switch length(mask)
                    case 1
                        ind1 = indexLow(mask(1));
                        tableTide{j+1,6} = [num2str(h(ind1),'%5.2f'),' m'];
                        tableTide{j+1,7} = datestr(t(ind1),'HH:MM');
                        tableTide{j+1,8} = '-';
                        tableTide{j+1,9} = '-';
                    case 2
                        ind1 = indexLow(mask(1));
                        ind2 = indexLow(mask(2));                        
                        tableTide{j+1,6} = [num2str(h(ind1),'%5.2f'),' m'];
                        tableTide{j+1,7} = datestr(t(ind1),'HH:MM');
                        tableTide{j+1,8} = [num2str(h(ind2),'%5.2f'),' m'];
                        tableTide{j+1,9} = datestr(t(ind2),'HH:MM');
                    case 0
                        tableTide{j+1,6} = '-';
                        tableTide{j+1,7} = '-';
                        tableTide{j+1,8} = '-';
                        tableTide{j+1,9} = '-';
                    otherwise
                        error('Too many low waters');
                end
            end
        end
        
        function t2HwStr = t2HwString(t2Hw)
            % make a nice string of a timeto HW
            %
            % t2hwStr = t2HwString(t2hw)
            % 
            if t2Hw >0
                t2HwStr = datestr(t2Hw,'HH:MM');
            else
                t2HwStr = ['-',datestr(-t2Hw,'HH:MM')];
            end
        end
        
        function t = timeToHighWater(indexLow,indexHigh,time,method)
            % calculates the time (in days) with respect to the moment of high water.
            % INPUT:
            % depending of the method (= string):
            %   1. method 'time' (default)
            %       * indexLow = time vector with low water (matlab time)
            %       * indexHigh = time vector with high water (matlab time)
            %       * time = time vector that you want to convert
            %   2. method 'index'
            %       * indexLow: Vector index denoting occurrance of low water (from calcHwLw)
            %       * indexHigh: Vector index denoting occurrance of high water (from calcHwLw)
            %       * time: a vector with the time (corresponding to index)
            % OUTPUT:
            %       * t: time to highwater
            if nargin == 3
                method = 'time';
            end
            % preallocate
            nrPeriods = length(indexLow)-1;
            nrTime    = length(time);
            
            t     = nan(nrTime,1);
            if regexpi(method,'index')
               index = 1:nrTime;
            else
               index = time; 
            end
            
            % loop over all period
            for i=1:nrPeriods
                mask    = indexLow(i)<=index &  indexLow(i+1)>index;
                IndHigh = (indexHigh>indexLow(i)) & (indexHigh<indexLow(i+1));
                IndHigh = indexHigh(IndHigh);
                if regexpi(method,'index')
                   THW     = time(IndHigh);
                else
                     THW = IndHigh;
                end
                if ~isempty(THW)
                    t(mask) = time(mask)-THW(1);
                end
            end
        end
        
        function h = waterLevelAmp(indexLow,indexHigh,watLev)
            % calculates the water level amplitude
            % h = waterLevelAmp(indexLow,indexHigh,watLev)
            % INPUT:
            % indexLow: vector index denoting occurrance of low water (from
            % calcHwLw)
            % indexHigh: vector index denoting occurrance of low water (from
            % calcHwLw)
            %watLev: : vector (timeseries) with water levels (regular time
            %stamp)
            % OUTPUT
            % h:  water level amplitude
            
            nrPeriods = length(indexLow)-1;
            % preallocate
            h = nan(nrPeriods,1);
            % loop over all period
            for i=1:nrPeriods
                hMin    = min(watLev(indexLow(i)),watLev(indexLow(i+1)));
                indHigh = (indexHigh>indexLow(i)) & (indexHigh<indexLow(i+1));
                mask    = indexHigh(indHigh);
                if ~isempty(mask)
                    h(i) = watLev(mask(1))-hMin;
                end
            end
        end
        
    end
end

