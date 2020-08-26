%Class to declare the most common Calculations
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Statistics < handle
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
        
        
        function [pdf2,xGrid,yGrid] = hist2d(xData,yData,gridX,gridY)
            % calculates a 2d histogram
            % [pdf2,xGrid,yGrid] = Statistics.hist2d(xData,yData,gridX,gridY)
            % INPUT: xData, yData (data to make a histogram)
            %       : grid(optional); either a scalar with the number of
            %       bins or the bin edge spacing (as vector); default is 20
            %       points
            % OUTPUT: xGrid,yGrid: matrix with the bin centers
            %            pdf2: nr of points in bin centers 
            %
            % 
            
            % process optional settings

            if nargin <3
                gridX = 20;
            end

            if nargin <4
                gridY = 20;
            end
            
            % make default grid if needed
            if numel(gridX) ==1
                gridX = linspace(min(xData),max(xData),gridX);
            end
            if numel(gridY) ==1
                gridY = linspace(min(yData),max(yData),gridY);
            end
            
            nrBinX = length(gridX)-1;
            nrBinY = length(gridY)-1;
            % make grids
            gridXcenter = 0.5.*(gridX(1:end-1)+gridX(2:end));
            gridYcenter = 0.5.*(gridY(1:end-1)+gridY(2:end));
            [xGrid,yGrid] = meshgrid(gridXcenter,gridYcenter);
            % allocate
            pdf2 = zeros(nrBinX,nrBinY);
            
            % count number of points in each bin
            % The loops are split to gain some speed (i.e. to decrease the
            % number of loops in Matlab)
            if nrBinX>nrBinY
                for iY = 1:nrBinY
                    maskY = yData>=gridY(iY) & yData<gridY(iY+1);
                    dataTmp = xData(maskY);
                    for iX = 1:nrBinX
                        mask = dataTmp>=gridX(iX) & dataTmp<gridX(iX+1);
                        pdf2(iX,iY) = sum(mask);
                    end
                end
            else
                for iX = 1:nrBinX
                    maskX = xData>=gridX(iX) & xData<gridX(iX+1);
                    dataTmp = yData(maskX);
                    for iY = 1:nrBinY
                        mask = dataTmp>=gridY(iY) & dataTmp<gridY(iY+1);
                        pdf2(iX,iY) = sum(mask);
                    end
                end                
            end
            % mirror to correspond con meshgrid
            pdf2 = pdf2';
        end
        
        function [ r2 ] = coeffdet(y,f)
            %COEFFDET Calculate coefficient of determination a
            %   [ r2 ] = coeffdet(y,f)
            %   Coefficient of determination is calculated as 1-SSE/SST, in exact same
            %   way as MATLAB's curve fit r2 does. Not: r2 only equals r squared for
            %   linear fits (see Wikipedia)
            %   Input:  y: raw values
            %           f: fitted values
            %   Output: r2:r2 coefficient of determination for fit
            %   Made by THL, October 2015
            %Reshape
            y = y(:);
            f = f(:);
            
            sst=norm(y-mean(y),2)^2;
            sse=norm(y-f,2)^2;
            r2=1-sse/sst;
            
        end
        
        function dOut = logPerc(psdData,dp,percOut)
            % calculates percentiles from a particle size distribution using a logaritmic distribution; use
            % to calculate d50 d90 etc
            %
            %  dOut = logPerc(psdData,dp,percOut)
            %
            % INPUT:
            % - psdData: [NxM] matrix with a cumulative size distribution
            % - dp: [Mx1] vector with particles sizes e.g. the center of
            %             the bins of the cumulative size distribution
            % - percOut: [Kx1] vector of percentage/fraction for which to
            %          calculate the sizes fr. e.g. [10 50 90]. BE CAREFULL! Use the
            %          same convention as in psdData (e.g. between 0 and 1 for
            %          fraction or between 0 and 100 for percentages).
            % OUTPUT:
            % -dOut: [NxK] matrix with calculated percentiles
            %
           
            nrPsd = size(psdData,1);
            nrOut = length(percOut);
            dOut = zeros(nrPsd,nrOut);
            percOut = Util.makeRowVec(percOut);
            for i=1:nrPsd
                [psdTmp,dpTmp] = Interpolate.preprocess((psdData(i,:)),log(dp));
                if (sum(isnan(psdTmp)) < length(psdTmp)) & length(psdTmp) > 2
                    dOut(i,:) = exp(interp1(psdTmp,dpTmp,percOut));
                else
                   dOut(i,:) = nan(1, length(percOut)); 
                end
            end
        end
        
        function [mean,moment] = momentPdf(bin,pdfData,momentIn)
            % calculate the mean and higher centralized moments from a
            % probability density function (pdf)
            %
            % [mean,moment] = momentPdf(bin,pdfData,momentIn)
            %
            % INPUT:
            %  - bin: [M+1x1] vector with thee bin edges of the probability
            %  density function
            %  - pdfData: [NxM] matrix with probability density data. In
            %                   the first dimension
            %  - momentIn [Kx1]: vector with the moments to calculate
            %
            % OUTPUT:
            % - mean: [Nx1] vector with the average calculated from the first order moment
            % - moment: [NxK] matrix with the  moments requiered in
            %                 momentIn

            nrData   = size(pdfData);
            nrMoment = length(momentIn);
            
            %preallocate data
            moment = zeros(nrData(1),nrMoment);
            mean   = zeros(nrData(1),1);
            
            % calc CDF row per row
            for i = 1:nrData(1)
                % get data
                pdf = pdfData(i,:);
                % apply trapezium rule to moment zero
                dx = bin(2:end)-bin(1:end-1);
                integral = 0.5.*dx.*pdf;
                normFac = sum(integral);
                % normalize to get one
                pdf = pdf./normFac;
                
                % calculate mean (first moment)
                binMid = sqrt(bin(1:end-1).*bin(2:end));
                integral = 0.5.*dx.*(binMid.*pdf);
                mean(i)  = sum(integral);
                % calculate moment
                for j = 1:nrMoment
                    binFac = binMid.^momentIn(j);
                    integral = 0.5.*dx.*(binFac.*pdf);
                    moment(i,j) = sum(integral);
                end
            end
        end
        
        function cdf = pdf2cdf(bin,data,nrDim)
            % get the cumulative density function from a probability
            % density function
            %
            % cdf = pdf2cdf(bin,data,nrDim)
            %
            % INPUT:
            % - bin: [N+1x1] matrix with the edges of the size bins that
            % are used in the pdf
            % -data: [NxM] or [MxN] matrix with the probability densities
            % per bin
            % - nrDim (optional): dimension to integrate  (default = 1)
            %
            % OUTPUT:
            % -cdf: [NxM] or [MxN] matrix with the cunmulative probability densities
            % per bin
            if nargin ==2
                nrDim = 1;
            end
            nrData = size(data);
            nrPdf  = nrData(nrDim);
            
            % preallocate
            cdf = zeros(nrData);
            
            
            if nrDim ==1
                % calc CDF row per row
                for i = 1:nrPdf
                    % get data
                    pdf = data(i,:);
                    % calculate intergral
                    dx = bin(2:end)-bin(1:end-1);
                    integral = dx.*pdf;
                    sumPdf = cumsum(integral);
                    % normalize to get one
                    cdf(i,:) = sumPdf./sumPdf(end);
                end
                
            else
                % calc CDF column per column
                % get data
                for i = 1:nrPdf
                    pdf = data(:,i);
                    %calculate intergral
                    dx = bin(2:end)-bin(end-1);
                    integral = dx.*pdf;
                    sumPdf = cumsum(integral);
                    % normalize to get one
                    cdf(:,i) = sumPdf./sumPdf(end);
                    
                end
            end
        end
        
        function [meanVal,stdVal,minVal,maxVal,xC,yC] = polyLineStat(xC,yC,xy,z, dX,dW)
            % statistics on a box moving around a line
            %
            % [meanVal,stdVal,minVal,maxVal,xC,yC] = polyLineStat(xC,yC,xy,z)
            %
            % INPUT:
            % - xC, yC: p[Nx1] vector with coordinates of the line to take
            % the statistics
            % - xy: [Mx2] vector with coordinates of the data vector z
            % - z: [Mx1] data vector 
            %
            % OUTPUT:
            %
            % - meanVal,stdVal,minVal,maxVal; statistics (mean, std, min
            % and max along the line)
            % - xC,yC: coordinates of the resampled line used for the
            % statistics calculation
            
            [xC,yC] = Resample.resamplePolyline(xC,yC,2*dX);
            lineDir = PolyLine.polyDir([xC,yC]);
            cosDir  = cos(lineDir);
            sinDir  = sin(lineDir);
            nrBin   = length(xC)-1;
            maxVal  = nan(nrBin,1);
            minVal  = nan(nrBin,1);
            meanVal = nan(nrBin,1);
            stdVal  = nan(nrBin,1);
            
            for i=1:nrBin
                % make a box over a line perpendicular to the line
                xTmp = 0.5*(xC(i+1)+xC(i));
                yTmp = 0.5*(yC(i+1)+yC(i));
                % bounding box
                bbXtmp   =  [-0.5*dX,0.5*dX,0.5*dX,-0.5*dX];
                bbYtmp   =  [-0.5*dW,-0.5*dW,0.5*dW,0.5*dW];
                % rotate and translate
                bbX      = cosDir(i).*bbXtmp- sinDir(i).*bbYtmp + xTmp;
                bbY      = sinDir(i).*bbXtmp+ cosDir(i).*bbYtmp + yTmp;
                % mask
                mask = inpoly(xy,[bbX',bbY']);
                % statistics
                if sum(mask)>0
                    maxVal(i)  = max(z(mask));
                    minVal(i)  = min(z(mask));
                    meanVal(i) = mean(z(mask));
                    stdVal(i)  = std(z(mask));
                end
            end


        end

        function [rmse,rmse0,bias,r2,si] = quickStatistics(x,y,tX,tY)
            % Root mean square deviation or root mean square error
            %
            % [rmse,rmse0,bias,r2,si] = quickStatistics(x,y,tX,tY)
            %
            % INPUT: 
            %  - x,y : input data to check
            %  - tX,tY (optional): time of x and y. If specified y is
            %  interpolated to x.
            % OUTPUT:
            %  - RMSE: root mean square error
            %  - RMSE0: corrected RMSE for the BIAS
            %  - BIAS: the avergae error netween x and y
            %  - R2: Correlation between the two parameters, COVxy/sigxSigy, the more close to 1 the better
            %  - SI: Scatter Index. Normalize the RMSE to the scale in which we are working
            
            if nargin>2
                [tX,x] = Interpolate.preprocess(tX,x);
                [tY,y] = Interpolate.preprocess(tY,y);
                y = interp1(tY,y,tX);
            end
            rmse  = sqrt(nanmean((x-y).^2));  
            bias  = nanmean(x-y);              
            rmse0 = sqrt(rmse.^2-bias.^2);
            cc=Statistics.nanCorrCoef(x,y);             
            if numel(cc)<2
                r2=cc(1,1);
            else
                r2=cc(1,2);     
            end                               
            si=rmse/nanmean(x);
        end
        
        function [rmse,rmse0,bias,si] = quickStatisticsDir(x,y,tX,tY)
            % Root mean square deviation or root mean square error
            %
            % [rmse,rmse0,bias,si] = quickStatisticsDir(x,y,tX,tY)
            %
            % INPUT: 
            %  - x,y : input directions (in degrees) to check
            %  - tX,tY (optional): time of x and y. If specified y is
            %  interpolated to x.
            % OUTPUT (in degrees):
            %  - RMSE: root mean square error
            %  - RMSE0: corrected RMSE for the BIAS
            %  - BIAS: the avergae error netween x and y
            %  - SI: Scatter Index. Normalize the RMSE to the scale in which we are working            
            if nargin>2
                % preprocessing and directional interpolation
                [tX,x] = Interpolate.preprocess(tX,x);
                [tY,y] = Interpolate.preprocess(tY,y);
                sinY = interp1(tY,sind(y),tX);
                cosY = interp1(tY,cosd(y),tX);
                y = atan2(sinY,cosY)*180/pi;
                y(y<0) = y(y<0)+360;
            end
           alpha = (x-y)/180*pi;
           % delete nans
           alpha(isnan(alpha)) = [];
           %circular statistics
           if ~isempty(alpha)
               bias = circ_mean(alpha)*180/pi;
               rmse0 = circ_std(alpha)*180/pi;
               rmse = sqrt(rmse0.^2+bias.^2);
               si=rmse/nanmean(x);
           else
               bias = nan;
               rmse = nan;
               rmse0 = nan;
               si    = nan;
           end
        end
        
        function cc = nanCorrCoef(x,y)
            mask = ~isnan(x) & ~isnan(y);
            if sum(mask) > 0
                cc = corrcoef(x(mask),y(mask));
            else
                cc = nan;
            end
        end
        
        function sctStat = statTable(sctStat,nrFiles,statName,dataH,dataU,dataPhi)
            % wrapper around statistics function to make table with
            % statistics
            %
            % sctStat = statTable(sctStat,nrFiles,statName,dataH,dataU,dataPhi)
            %
            % INPUT:
            % -dataH: structure with field tMeas, tMod, hMeas, hMod
            % -dataU: structure with field tMeas, tMod, uMeas, uMod
            % -dataPhi: structure with field tMeas, tMod, phiMeas, phiMod
            % to use tide: set sctStat.procTide = 1;
            % to use t_tide: set sctStat.tTide = 1;
            % other options that can be set: sctStat.maxDh, sctStat.maxDt,
            % sctStat.comp
            % initialize data
            if ~isfield(sctStat,'theTable')
               sctStat.theTable    = zeros(nrFiles,3);
               sctStat.tableName   = cell(nrFiles,1);
               sctStat.iX = 1;
               sctStat = Util.setDefault(sctStat,'procTide',false);
               sctStat = Util.setDefault(sctStat,'tTide',false);
               sctStat = Util.setDefault(sctStat,'maxDh',0.5);
               sctStat = Util.setDefault(sctStat,'maxDt',2/24);
               sctStat = Util.setDefault(sctStat,'comp',{'M2','S2','M4','K1','O1','N2'});
               if  sctStat.procTide 
                   sctStat.tideTable   = zeros(nrFiles,8);
               end
               if  sctStat.tTide 
                   nrComp = length(sctStat.comp);
                   sctStat.ttTable = zeros(nrFiles,2*nrComp);
                   sctStat.ttTableMod  = zeros(nrFiles,2*nrComp);
                   sctStat.ttTableMeas = zeros(nrFiles,2*nrComp);
               end
            else
                % count the line is the table
                sctStat.iX = sctStat.iX + 1;
            end
            ix = sctStat.iX;
            
            % tabel with statistics comparison.
            
            % statistics of velocity
            if nargin > 4
                sctStat = Statistics.helperStatTable(sctStat, dataU,ix,4:6,'uMod','uMeas');
            end
            % statistics for direction
            if nargin > 5
                sctStat = Statistics.helperStatTable(sctStat, dataPhi,ix,7:9,'phiMod','phiMeas');
            end
            % statistics for salinity (todo multiple depths)
            if nargin > 6
                sctStat = Statistics.helperStatTable(sctStat, dataSal,ix,10:12,'salMod','salMeas');
            end
            
            % statistic for water levels (or any other variable)
            if isfield(dataH,'hMod')
                [sctStat,t,tMod, h,hMod] = Statistics.helperStatTable(sctStat, dataH,ix,1:3,'hMod','hMeas');
                sctStat.varH = 'H';
            else
                % select variable name automatically
                theVars = fieldnames(dataH);
                for i=1:length(theVars)
                    aVar = theVars{i};
                    if aVar(1)~='t'
                        if strcmpi(aVar(end-2:end),'Mod')
                            varMod = aVar;
                        end
                        if strcmpi(aVar(end-3:end),'Meas')
                            varMeas = aVar;
                        end
                    end
                end
                sctStat.varH = varMeas(1:end-4);
                
                % statistics
                sctStat = Statistics.helperStatTable(sctStat, dataH,ix,1:3,varMod,varMeas);
                % not water level so no tidal analysis
                if sctStat.procTide 
                    error('Tidal analysis only possibel for water levels');
                end
                if sctStat.tTide 
                    error('TTide analysis only possibel for water levels');
                end
            end

            % add name
            sctStat.tableName{ix}  = statName;
            
            % tabel with tide comparison
            if sctStat.procTide
                if ~isempty(h) && ~isempty(hMod)
                    data = TidalAnalysis.tideCompare(tMod,t,hMod,h,sctStat.maxDh,sctStat.maxDt);
                    sctStat.tideTable(ix,:) = [data.biasHw,data.rmse0Hw,data.biasLw,data.rmse0Lw,24.*60.*[data.biasThw,data.rmse0Thw,data.biasTlw,data.rmse0Tlw]];
                else
                    sctStat.tideTable(ix,:) = nan;
                end
            end
            
            %table with amplitude comparison from t_tide
            if sctStat.tTide
                if ~isempty(hMod) && ~isempty(h)
                    sctTt = TidalAnalysis.ttideCompare(tMod,t,hMod,h);
                    for jComp=1:length(sctStat.comp)
                        theComp = ['comp',sctStat.comp{jComp}];
                        if isfield(sctTt,theComp)
                            sctStat.ttTable(ix,2*jComp-1)     = sctTt.(theComp).amplDiff;
                            sctStat.ttTable(ix,2*jComp)       = sctTt.(theComp).phaseDiff;
                            sctStat.ttTableMod(ix,2*jComp-1)  = sctTt.(theComp).ampl;
                            sctStat.ttTableMod(ix,2*jComp)    = sctTt.(theComp).phase;
                            sctStat.ttTableMeas(ix,2*jComp-1) = sctTt.(theComp).amplRef;
                            sctStat.ttTableMeas(ix,2*jComp)   = sctTt.(theComp).phaseRef;
                        end
                    end
                end
            end
        end
        
        function [sctStat,t,tMod,var,varMod] = helperStatTable(sctStat, data,ix,cols,varMod,varMes)
            % helper function
            % TODO: make private
                t = Util.makeColVec(data.tMeas);
                tMod = Util.makeColVec(data.tMod);
                var = Util.makeColVec(data.(varMes));
                varMod = Util.makeColVec(data.(varMod));
                if ~isempty(var) && ~isempty(varMod)
                    isDir = strncmpi('phi',varMes,3);
                    if isDir
                        [rmse,rmse0,bias] = Statistics.quickStatisticsDir(varMod,var,tMod,t);
                    else
                        [rmse,rmse0,bias] = Statistics.quickStatistics(varMod,var,tMod,t);
                    end
                    
                    sctStat.theTable(ix,cols) = [bias,rmse,rmse0];
                else
                    sctStat.theTable(ix,cols) = [nan,nan,nan];
                end
        end
        
        function statTableWrite(sctStat,outFile)
            % save statistics table (from statTable) to file
            %
            %statTableWrite(sctStat,outFile)
            %
            % INPUT:
            % -sctStat: structure with statistics
            % -outFile: file to write
            
            
            % copy variables
            tableName = sctStat.tableName;
            theTable  = sctStat.theTable;
            if  sctStat.procTide
                tideTable = sctStat.tideTable;
            end
            if sctStat.tTide
                ttTable   = sctStat.ttTable;
            end
            
            % delete empty data
            switch size(theTable,2)
                case 3
                    h = sctStat.varH;
                    header1 = ['Nt, Station, Bias ',h,', RMSE ',h,', RMSE0 ',h,''];
                    header2 = ', ,m,m,m';  
                    % TODO adapt header
                case 6
                    header1 = 'Nt, Station, Bias H, RMSE H, RMSE0 H, Bias U, RMSE U, RMSE0 U';
                    header2 = ', ,m,m,m, m/s,m/s, m/s';  
                case 9
                    header1 = 'Nt, Station, Bias H, RMSE H, RMSE0 H, Bias U, RMSE U, RMSE0 U, Bias Phi, RMSE Phi, RMSE0 Phi';
                    header2 = ', ,m,m,m, m/s,m/s, m/s, deg,deg, deg';  
                case 12
                    header1 = 'Nt, Station, Bias H, RMSE H, RMSE0 H, Bias U, RMSE U, RMSE0 U, Bias Phi, RMSE Phi, RMSE0 Phi,Bias Sal, RMSE Sal, RMSE0 Sal';
                    header2 = ', ,m,m,m, m/s,m/s, m/s, deg,deg, deg, ppt,ppt,ppt';  
                otherwise
                     error('Unknown table format');
            end
            
            nrStat = sctStat.iX;
            
            % open file for reading
            fid = fopen(outFile,'w');
            
            % print standard table
            fprintf(fid,'%s\n',header1);
            fprintf(fid,'%s\n',header2);
            for i = 1:nrStat
                tmp = tableName{i};
                tmp(20) = ' ';
                fprintf(fid,'%s\n',[num2str(i),',',tmp,',',num2str(theTable(i,:),'%8.2f,')]);
            end
            
            % table with high and low water comparison
            if  sctStat.procTide
                fprintf(fid,'%s\n','');
                fprintf(fid,'%s\n','Nt, Station, Bias Hw, RMSE0 Hw,Bias Lw, RMSE0 Lw, Bias THw, RMSE0 THw,Bias TLw, RMSE0 TLw');
                fprintf(fid,'%s\n',' , , m,m,m,m,min,min,min, min');
                for i = 1:nrStat
                    tmp = tableName{i};
                    tmp(20) = ' ';
                    fprintf(fid,'%s\n',[num2str(i),',',tmp,',',num2str(tideTable(i,:),'%8.2f,')]);
                end
            end
            
            if sctStat.tTide
                fprintf(fid,'%s\n','');
                theComp = '';
                nrComp = length(sctStat.comp);
                for i=1:nrComp
                    theComp = [theComp,', ','Ampl diff ', sctStat.comp{i},',Phase diff ',sctStat.comp{i}];
                end
                    
                fprintf(fid,'%s\n',['Nt,Station ',theComp]);
                fprintf(fid,'%s\n',[', , ',repmat('[m] ,[deg],',1,nrComp)]);
                for i = 1:nrStat
                    tmp = tableName{i};
                    tmp(20) = ' ';
                    fprintf(fid,'%s\n',[num2str(i),',',tmp,',',num2str(ttTable(i,:),'%8.3f,')]);
                end
            end
            
            fclose(fid);
        end
        
           function  [psdMean, psdStd, psdSkew, psdKurt] = psdMean(bins, freq, method, type)
            % calculates the mean of a volume particle size distribution (psd)
            %  * bins = N+1 vector with the lower and upper diameter of each bin
            %         OR the N vector with mean diameter of each bin.
            %  * freq =   N vector with the frequency values of the
            %  distribution
            %  * method = calculation method
            %      * 'D32': sauter mean or surface weighted mean
            %      * 'D43': volume weighted mean or mass moment mean
            %      * 'geometric_seq': based on http://www.sequoiasci.com/article/how-to-compute-the-mean-particle-diameter-from-a-lisst-volume-distribution-2/
            %      * [m,n] = m, n according BS2955:1993
            %      * 'geometric': see Blott and Pye GRADISTAT: A GRAIN SIZE DISTRIBUTION AND STATISTICS
                            %PACKAGE FOR THE ANALYSIS OF UNCONSOLIDATED SEDIMENTS
            %      * 'arimetric': see Blott and Pye GRADISTAT: A GRAIN SIZE DISTRIBUTION AND STATISTICS
                            %PACKAGE FOR THE ANALYSIS OF UNCONSOLIDATED SEDIMENTS
            %  * type = default volume
            %
            % OUTPUT:
            % - mean value
            % -outFile: file to write
            %
            % WRITTEN BY: JCA
            % DATE: 2019
            if nargin < 4
                type = 'volume';
            end
            
            if length(bins) == size(freq,1)+1 || length(bins) == size(freq,2)+1
                binWidth = diff(bins);
                if strcmpi(method,'arithmetic') || binWidth(end) < 1.1*binWidth(1)
                    bins = (bins(1:end-1)+bins(2:end)).*0.5; % arithmetric mean of each bin
                    bins = bins';
                else
                    bins = (bins(1:end-1).*bins(2:end)).^0.5; % geometric mean of each bin
                    bins = bins';
                end
            end
            if size(bins,1) == 1
                bins = bins';
            end
            
            if length(bins) == size(freq,2)
               binsRep = repmat(bins', size(freq,1), 1);
               dim = 2;
            else
                binsRep = repmat(bins, 1,size(freq,2));
               dim = 1;
               
            end
            
            if strcmpi(type, 'volume')
                if ischar(method)
                    switch lower(method)
                        case 'd32'
                            method = [3,2];
                        case 'd43'
                            method = [4,3];
                        case 'geometric_seq'
                            % based on sequoia, see webpage of sequia about
                            % dmean calculation
                            indBinsRep = cumsum(ones(size(binsRep)), dim);
                            dSum = nansum(indBinsRep.*freq, dim);
                            indMean = dSum./nansum(freq, dim);
                            if dim == 1
                               indBins = indBinsRep(:,1);
                               %indMeanRep = repmat(indMean,size(freq,1),1);
                            else
                                indBins = indBinsRep(1,:)';
                                %indMeanRep = repmat(indMean,1,size(freq,2));
                            end
                            %indStd = (nansum(freq.*(indBinsRep - indMeanRep).^2, dim)./nansum(freq, dim)).^0.5;
                            psdMean = interp1(indBins, bins, indMean, 'spline');
                            
                            if dim == 2
                                psdMeanRep = repmat(psdMean,1,size(freq,2));
                            else
                                psdMeanRep = repmat(psdMean,size(freq,1),1);
                            end
                            psdStd = exp((nansum(freq.*(log(binsRep) - log(psdMeanRep)).^2, dim)./nansum(freq, dim)).^0.5);
                            psdSkew = nansum(freq.*(log(binsRep) - log(psdMeanRep)).^3, dim)./(nansum(freq, dim).*log(psdStd.^3));
                            psdKurt = nansum(freq.*(log(binsRep) - log(psdMeanRep)).^4, dim)./(nansum(freq, dim).*log(psdStd.^4));
                            %psdStdmin = interp1(indBins, bins, indMean - indStd, 'spline');
                            %psdStdmax = interp1(indBins, bins, indMean + indStd, 'spline');
                            %psdStd = (psdStdmin + psdStdmax).*0.5;
                            %psdSkew = psdStd; psdKurt = psdStd; % isn't calculated;
                            
                           
                            
                        case 'geometric'
                            %based on Blott and Pye GRADISTAT: A GRAIN SIZE DISTRIBUTION AND STATISTICS
                            %PACKAGE FOR THE ANALYSIS OF UNCONSOLIDATED SEDIMENTS
                            psdMean = exp(nansum(freq.*log(binsRep), dim)./nansum(freq, dim));
                            if dim == 2
                                psdMeanRep = repmat(psdMean,1,size(freq,2));
                            else
                                psdMeanRep = repmat(psdMean,size(freq,1),1);
                            end
                            psdStd = exp((nansum(freq.*(log(binsRep) - log(psdMeanRep)).^2, dim)./nansum(freq, dim)).^0.5);
                           
                            psdSkew = nansum(freq.*(log(binsRep) - log(psdMeanRep)).^3, dim)./(nansum(freq, dim).*log(psdStd.^3));
                            psdKurt = nansum(freq.*(log(binsRep) - log(psdMeanRep)).^4, dim)./(nansum(freq, dim).*log(psdStd.^4));
                        case 'arithmetic'
                            %based on Blott and Pye GRADISTAT: A GRAIN SIZE DISTRIBUTION AND STATISTICS
                            %PACKAGE FOR THE ANALYSIS OF UNCONSOLIDATED SEDIMENTS
                            psdMean = nansum(freq.*binsRep, dim)./nansum(freq, dim);
                            if dim == 2
                                psdMeanRep = repmat(psdMean,1,size(freq,2));
                            else
                                psdMeanRep = repmat(psdMean,size(freq,1),1);
                            end
                            psdStd = (nansum(freq.*(binsRep - psdMeanRep).^2, dim)./nansum(freq, dim)).^0.5;
                            psdSkew = nansum(freq.*(binsRep - psdMeanRep).^3, dim)./(nansum(freq, dim).*psdStd.^3);
                            psdKurt = nansum(freq.*(binsRep - psdMeanRep).^4, dim)./(nansum(freq, dim).*psdStd.^4);
                    end
                end
                
                if ~ischar(method) % using the BS method BS2955:199
                    psdMean = (nansum(freq.*binsRep.^(method(1)-3), dim)./...
                        nansum(freq.*binsRep.^(method(2)-3), dim)).^(1/(method(1)-method(2)));
                    
                    psdStd = nan(size(psdMean)); psdSkew = psdStd; psdKurt = psdStd; % isn't calculated;
                end
            end
        end
        
          function  psdStat = quickStatisticsPsd(bins, freq, type, method)
            % calculates some statistsics of a particle size distribution (psd)
            %  * bins = N+1 vector with the lower and upper diameter of each bin
            %         OR the N vector with mean diameter of each bin. (mm)
            %  * freq =   MxN matrix with N equal to N of bins. M equal to number of samples  
            %  * type = string of 'volume' 
            %  * method: arithmetic, geometric (default), geometric_seq
            %     geomeric has been recommended when bins are logaritmic
            %     scaled
            % OUTPUT:
            % - structure with statistiscs
            % 
            %based on Blott and Pye GRADISTAT: A GRAIN SIZE DISTRIBUTION AND STATISTICS
            %PACKAGE FOR THE ANALYSIS OF UNCONSOLIDATED SEDIMENTS
            %
            % WRITTEN BY: JCA
            % DATE: 2019
            
            if nargin < 4
                method = 'geometric';
            end
            
            % prepare input data
            if length(bins)-1 == size(freq,2)
                dim = 2;
                freq = freq./repmat(sum(freq, dim),1,size(freq, dim)).*100; % standardisation and to percent
                
            else
                dim = 1;
                freq = freq./repmat(sum(freq, dim),size(freq, dim),1).*100; % standardisation and to percent
            end
            
            
            switch lower(type)
                case 'volume'
                    psdStat.meanD32.data = Statistics.psdMean(bins, freq, 'd32',type);
                    psdStat.meanD43.data = Statistics.psdMean(bins, freq, 'd43',type);
                    [psdStat.mean.data, psdStat.std.data, psdStat.skew.data, psdStat.kurt.data] = Statistics.psdMean(bins, freq, method,type);
                    binsPhi = Statistics.diameter2phi(bins);
                    [psdStat.meanPhi.data, psdStat.stdPhi.data, psdStat.skewPhi.data, psdStat.kurtPhi.data] = Statistics.psdMean(binsPhi, freq, 'arithmetic', type);
                     
                    freqCum= cumsum(freq, dim,'omitnan');                    
                otherwise
                    error('To be written')
            end
            if size(freqCum,dim) < length(bins)
                bins = bins(2:end); %takes the upper bin for median calculation
            end
            tempPerc = Statistics.logPerc(freqCum,...
                bins , [10,50,90,20,80,25,75]);
            psdStat.d10.data = tempPerc(:,1);
            psdStat.d50.data = tempPerc(:,2);
            psdStat.d90.data = tempPerc(:,3);
            psdStat.d20.data = tempPerc(:,4);
            psdStat.d80.data = tempPerc(:,5);
            psdStat.d25.data = tempPerc(:,6);
            psdStat.d75.data = tempPerc(:,7);
            psdStat.span.data = (psdStat.d90.data - psdStat.d10.data)./(psdStat.d50.data); 
            
             if size(freqCum,dim) < length(binsPhi)
                binsPhi = binsPhi(2:end); %takes the upper bin for median calculation
            end
            [binsPhi, ind] = sort(binsPhi);
            if dim == 1
                freqCumPhi= cumsum(freq(ind,:), dim,'omitnan');
            else
                freqCumPhi= cumsum(freq(:,ind), dim,'omitnan');
            end
            
             tempPerc = Statistics.logPerc(freqCumPhi,...
                 binsPhi, [10,50,90,20,80,25,75]);
            psdStat.d10Phi.data = tempPerc(:,1);
            psdStat.d50Phi.data = tempPerc(:,2);
            psdStat.d90Phi.data = tempPerc(:,3);
            psdStat.d20Phi.data = tempPerc(:,4);
            psdStat.d80Phi.data = tempPerc(:,5);
            psdStat.d25Phi.data = tempPerc(:,6);
            psdStat.d75Phi.data = tempPerc(:,7);
            psdStat.spanPhi.data = (psdStat.d90Phi.data - psdStat.d10Phi.data)./(psdStat.d50Phi.data); 
           

          end
          
          function  phi = diameter2phi(diameter, method)
              % coverts particle diameter in milimeters(!) to phi scale units
              %  * bins = grain diameter to convert to phi-scale
              % * method:  krumbein (default)
              %
              % OUTPUT:
              % - numeric values in phi-scale
              %
              %
              % WRITTEN BY: JCA
              % DATE: 2019
              if nargin < 2
                  method = 'krumbein';
              end
              switch lower(method)
                  case 'krumbein'
                      phi = -log2(diameter);
              end
          end
          
          function  stat = quickStatisticsTimeSerie(time, values, period, interval, options)
              % calculates some statistsics of a timeserie
              %  * time = time in matlab time
              %  * values =  timeserie values
              %  * period = monthly, yearly, ...
              %  * interval (optionally) = number of multiplier of the period (default: 1)
              %               e.g. 2 daily = 2 daily, ...
              %  * options (optionally) = start and end of the requested period (default: min and max)
              %
              % OUTPUT:
              % - structure with statistiscs
              %
              % WRITTEN BY: JCA
              % DATE: 2020
              
              if nargin < 4
                  interval = 1;
              end
              if nargin < 5
                  options.start = nanmin(time);
                  options.end = nanmax(time);
              end
              % prepare input data
              
              % create new time serie
              
              options.subsetType = period;
              stat.time = Time.timeStamp(options,interval);
              %mask = stat.time >= options.start & stat.time <= options.end;
              %stat.time(mask) = [];
              
              % resample data
              stat.max = Resample.resampleMax(time, values, stat.time);
              stat.min = Resample.resampleMin(time, values, stat.time);
              stat.mean = Resample.resampleMean(time, values, stat.time);
              stat.sum = Resample.resampleSum(time, values, stat.time);
              stat.std = Resample.resampleStd(time, values, stat.time);
              stat.median = Resample.resampleMedian(time, values, stat.time);
              stat.p20 = Resample.resamplePercentile(time, values, stat.time, 20);
              stat.p80 = Resample.resamplePercentile(time, values, stat.time, 80);
              stat.p25 = Resample.resamplePercentile(time, values, stat.time, 25);
              stat.p75 = Resample.resamplePercentile(time, values, stat.time, 75);
              stat.p10 = Resample.resamplePercentile(time, values, stat.time, 10);
              stat.p90 = Resample.resamplePercentile(time, values, stat.time, 90);
              stat.number = Resample.resampleNumber(time, values, stat.time);
              
              % preparation of the output
              stat.timeBin = stat.time;
              stat.time = (stat.timeBin(1:end-1) + stat.timeBin(2:end)).*0.5;
          end
          
        

    end
    
end