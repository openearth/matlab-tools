
%Class to declare the most common data calculation/transformation
%
% TODO: move the constants to the configuration file.
% TODO: add some try/catch
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Filter < handle
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
        function [xout,maskValid] = applyFlags(x,flags,method)
            %applies outlier flags
            %
            %[xout,maskValid] = applyFlags(x,flags,method)
            %
            % check the data validation and apply the selected option : 
            % delete, nan or interpolate
            % Constant flag definition
            
            NOT_VALIDATED = 0;
            VALIDATED     = 1;
            SUSPICIOUS    = 2;
            CALCULATED    = 3;
            MANUAL_EDIT   = 4;
            
            if any(flags==NOT_VALIDATED)
                warning('There are non-validated data');
            end
            
            mask = (flags==SUSPICIOUS);
            
            xout = x;
            switch method
                case 'delete'
                    % deletes suspocious data. Note that this must then also be done in the coordinates  (i.e. the time stamp changes and becomes irregular)
                    % note that for matrixes, the whole row is deleted
                    % (i.e. column matrixes are expected)
                    
                    mask = any(mask,2);
                    xout(mask,:) = [];
                case 'nan'
                    % sets suspicious data to nan
                    xout(mask) = nan;
                case 'interpolate'
                    % interpolates suspicious data
                    sizeX = size(x);
                    for i = 1:sizeX(2)
                        xout(mask,i) = interpNan(x(:,i));
                    end
            end
            maskValid = ~mask;
        end
        
        function [w] = hamming(N)
            % Hamming window
            % 
            % [w] = hamming(N);

            n = 0:N-1;
            w = 0.54 - 0.46 * cos(2*pi*n/(N-1));
        
        end
        
        function [yNew,yMin,yMax] = lowess(x, y, xNew, options)
            % Compute local linear regression
            %
            % Computation with LOESS method
            % Inspired by: K:\PROJECTS\11\11284 - Composietbuien-klimaatwijzigingen\07-Uitv\
            %       overzicht reeksen c nieuw.xls, sheet hypo (VBA)
            %
            %[yNew,yMin,yMax] = lowess(x, y, xNew, options)
            %
            % INPUTS:
            % - x:       input x data
            % - y:       input y data
            % - xNew:    location of output points
            % - options.dx: sampling interval
            % - options.nAlfa: confidence interval
            % - options.method ('loess' or 'lowess')
            % - option.function: function to be used for weighting (lowess only)
            % - options.order: order of the fitted polynomial (default = 1)
            % 
            % OUTPUTS:
            % - yNew: fitted values at xNew
            % - yMin: minimum values (according to confidence interval) at
            %   xNew
            % - yMax: maximum values (according to confidence interval) at
            %   xNew
            %
            % Written by: sdo,
            % Last modified by : thl
            % Date: 27/02/2015
            
            % remove NaN
            [x,y] = Util.deleteNans(x,y);

            % set default options
            if nargin==3
                options = struct;
            end
            options = Util.setDefault(options,'method','lowess');
            options = Util.setDefault(options,'function',@Calculate.thirdOrder);
            options = Util.setDefault(options,'nAlfa',0.95);
            options = Util.setDefault(options,'nrBootstrap',500);
            options = Util.setDefault(options,'nrSamples',1000);
            options = Util.setDefault(options,'order',1);
            options = Util.setDefault(options,'dx', mean(diff(xNew)));
            
            dx = options.dx;
            
            % Difference from average
            yMean = nanmean(y);
            yAcc  = y - yMean;
            
            sizeXNew = numel(xNew);
            yNew = zeros(sizeXNew,1);
            yMin = zeros(sizeXNew,1);
            yMax = zeros(sizeXNew,1);

                        
            if nargout >1
                yMin = zeros(sizeXNew,1);
                yMax = zeros(sizeXNew,1);
            end
            
            % lokale regressie
            for i = 1:numel(xNew)
                % determine mask
                mask = (xNew(i)-dx <=x) &  (xNew(i)+dx >x);
                
                if sum(mask) ==0
                    yNew(i,:) = NaN;
                    continue,
                end
                % find data in mask
                x0 = mean(x(mask));
                xInt = x(mask)-x0;
                yInt = yAcc(mask);
                meanXInt = xNew(i)-x0;
                
                % apply weightimg for lowess method
                if strcmpi(options.method,'lowess')
                    dist   = abs(xInt-meanXInt)/dx;
                    weight = options.function(dist);
                else
                    weight = ones(size(xInt));
                end
                weight = weight./sum(weight);
                
                
                % fit line to weighted points and apply
                A = [];
                for j = 0:options.order
                    A = [A xInt.^j];
                end
                mask = weight>0;
                try
                coef = flipud(lscov(A(mask,:),yInt(mask,:),weight(mask,:)));
                catch
                    coef = nan(1,options.order+1);
                end
                
                yNew(i) = polyval(coef,xNew(i)-x0)+ yMean;
                yFit = polyval(coef,xInt)+yMean;
                
                % Determinarion of error
                if nargout >1
                    bias = sort(yInt+ yMean - yFit);
                    % for small datasets, perform a bootstrap
                    nrBias = numel(bias);
                    if nrBias<options.nrBootstrap
                        
                        iMax = ceil(options.nAlfa*nrBias);
                        iMin = ceil((1-options.nAlfa)*nrBias);
                        % preallocate
                        tempMax = zeros(1,options.nrSamples);
                        tempMin = zeros(1,options.nrSamples);
                        % perform bootstrap
                        for ii=1:options.nrSamples
                            ind         = ceil(rand(nrBias,1)*nrBias);
                            temp        = sort(bias(ind));
                            tempMax(ii) = temp(iMax);
                            tempMin(ii) = temp(iMin);
                        end
                        % take an average
                        yMax(i) = mean(tempMax);
                        yMin(i) = mean(tempMin);
                    else
                        %for large datasets, take the confidence interval from the sorted data
                        ind     = ceil(options.nAlfa*numel(bias));
                        yMax(i) = bias(ind);
                        ind     = ceil((1-options.nAlfa)*numel(bias));
                        yMin(i) = bias(ind);
                    end
                end
            end
            yMax = yNew + yMax;
            yMin = yNew + yMin;
        end
        
        function y = lowpassFilter(x,filterPeriod,type)
            % performs a moving average low pass filter
            %
            % y = lowpassFilter(x,filterPeriod,type)
            %
            % This function performs a moving average low pass filter on the data in the row vector vIn and outputs it as y.
            % The filter period (in nr of datapoints) is given in nPeriod. It is assumed that the spacing between the different datapoints is constant. It first filters
            % forward, than backwards, in order to prevent phase lag errors. Note that
            % nan values are first interpolated.
            % If noption is specified, use 1 for double moving average, use 2 for
            % central double average (and use odd nPeriod)
            % INPUTS:
            % - x: row vector with input data
            % - filterPeriod: nr of datapoint over which the filtering should be
            %        taken.
            % - type (optional): if set to 1 (default), a double moving avg is used, if set to 2 a
            %        central average is used (no phase lag, but slower)
            %
            % OUTPUTS:
            % - y:  vector with (filtered version of the input data)
            %
            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            %
            %% Written by: Alexander Breugem
            %
            % Date: July 2009
            % Modified by:
            % Date:
            
            if nargin<= 2
                type = 1;
            end
            
            if type ==2
                if mod(filterPeriod,2)==0
                    error('nPeriod must be odd when using central filtering');
                end
            end
            %mbv moving average

            %interpoleren data
            maskNan = isnan(x) ;
            x = Interpolate.interpNan(x);

            %make row vector if necessary
            if (size(x,1))>1
                x=x';
                doFlip = 1;
            else
                doFlip = 0;
            end            
            
            filterPeriod = floor(filterPeriod);
            data = zeros(1,length(x)+filterPeriod-1);
            number = zeros(1,length(x)+filterPeriod-1);
            if ~isempty(x)
                switch type
                    case 1     %use two moving averages
                        a = ones(filterPeriod,1)./filterPeriod;
                        b = 1;
                        
                        %filter forward
                        tempData = filter(a,b,x);
                        %fileter backward
                        tempData = filter(a,b,fliplr(tempData));
                        %terug omkeren data
                        y = fliplr(tempData);
                    case 2 %calculate central average
                        indCut = ceil((filterPeriod-1)/2);
                        for i =1:filterPeriod
                            tempData = [nan(1,i-1),x(1:end),nan(1,filterPeriod-i)];
                            data = data + tempData;
                            number   = number + ~isnan(tempData);
                        end
                        y = data./number;
                        y = y(indCut+1:end-indCut);
                end
                
                y(maskNan) = nan;
                if doFlip
                    y=y';
                end
            else
                y = [];
            end
        end
        
        function y = hammingLowpass(x,sf,fCutoff,M)
            % Advanced low-pass filtering using Hamming window
            %
            % y = hammingLowpass(x,sf,fCutoff,M);
            %
            % INPUT: 
            % - x: Input time series
            % - sf: Sampling frequency
            % - fCutoff: Cutoff frequency (in same units as sampling
            % frequency);
            % - M: Number of points in filter
            %
            % See https://tomroelandts.com/articles/how-to-create-a-simple-low-pass-filter
            
            if rem(M,2)~=1
                error('M should be odd');
            end
            
            fc = fCutoff./sf; %Normalized cutoff frequency
            n = 0:M-1;
            %Ideal filter
            hc =  Filter.sinc(2*fc*(n-(M-1)/2));
            %Hamming window
            w = Filter.hamming(M);
            %Window the filter
            hc = hc.*w;
            %Normalize
            hc = hc./sum(hc);
            
            %Convolution
            y = conv(x,hc,'same');
        end
            
            
        
        function mask = removeOutlierGlobal(data,option)
            % robust detection of outliers
            %
            % mask = removeOutlierGlobal(data,option)
            %
            % outliers are flagged if they are more then a threshold
            % times median absolute deviation away from the median
            % the
            % 
            % INPUTS:
            % - data: [MxN] matrix with data
            % - option.thresholdGlobal: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurous data
            %
            % OUTPUTS:
            % - mask: [MxN] boolean matrix. True if a value is an
            % outlier
            
            med  = nanmedian(data(:));
            perc = prctile(data(:),[25 75]);
            
            minVal = med - option.thresholdGlobal.*(med-perc(1));
            maxVal = med + option.thresholdGlobal.*(perc(2)-med);
            
            mask = (data < minVal) | (data > maxVal);
        end
        
        function mask = removeOutlierGlobalDir(data,option)
            % robust detection of outliers in directions
            %
            % mask = removeOutlierGlobalDir(data,option)
            %
            % outliers are flagged if they are more then a threshold
            % times standard deviation away from the median
            %
            % INPUT:
            % - data: [MxN] matrix with data
            % - option.thresholdGlobalDir: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurous data
            %
            % OUTPUT:
            % - mask: [MxN] boolean matrix. True if a value is an
            % outlier
            %
            % NOTE: Uses the directional statistics toolbox
            
            data    = mod(data,2*pi);
            dataVec = data(:);
            
            dataVec(isnan(dataVec)) = [];
            
            med    = circ_median(dataVec);
            diff   = mod(dataVec-med,2*pi);
            stdVal = circ_std(diff);
            minVal = mod(med - option.thresholdGlobalDir.*stdVal,2*pi);
            maxVal = mod(med + option.thresholdGlobalDir.*stdVal,2*pi);
            
            if (maxVal>minVal)
                mask = (data < minVal) | (data > maxVal);
            else
                mask = (data > minVal) & (data < maxVal);
            end
        end
        
        function mask = removeOutliersMedian1d(data,option)
            % find outlier using median filter
            %
            % mask = removeOutliersMedian1d(data,option)
            %
            % INPUT:
            % - data: [Mx1] vector with data
            % - option.medianWindow: size of the window for applying the
            % filter.
            % - option.thresholdMedian: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurous data
            %
            % OUTPUT:
            % - mask: [Mx1] boolean vector. True if a value is an
            % outlier
            
            data = data(:);
            
            % preallocate
            mask = false(size(data));
            
            % input parameter checking
            if size(option.medianWindow)~=1
                error('The size of option.medianWindow must be 2');
            end
            if any(mod(option.medianWindow,2)==0)
                error('Only odd window sizes are allowed');
            end
            
            %calculation of 1D median filter for a column vectors
            window = (option.medianWindow(1)-1)/2;
            for i = window+1:size(data,1)-window
                tempData = data(i-window(1):i+window(1));
                %Median
                med = nanmedian(tempData(:));
                dataVec = abs(tempData(:)-med);
                %median absolute deviation
                mad = nanmedian(dataVec);
                %Robust elimination
                mask(i) = abs(med-data(i))>option.thresholdMedian.*mad;
            end
        end
        
        function mask = removeOutliersMedian2d(data,option)
            % find outlier using median filter
            %
            % mask = removeOutliersMedian2d(data,option)
            %
            % INPUT:
            % - data: [MxN] matrix with data
            % - option.medianWindow: [2x1] size of the window for applying the
            % filter (in x and y direction).
            % - option.thresholdMedian: a threshold value (normalised by the median absolute deviation)) to use in
            % order to eliminate spurious data
            %
            % OUTPUT:
            % - mask: [MxN] boolean matrix. True if a value is an outlier
            
            % preallocate
            mask = false(size(data));
            
            if size(option.medianWindow)~=2
                error('The size of option.medianWindow must be 2');
            end
            if any(mod(option.medianWindow,2)==0)
                error('Only odd window sizes are allowed');
            end
            
            %calculation of 2D median filter
            window = [(option.medianWindow(1)-1)/2,(option.medianWindow(2)-1)/2];
            for i = window(1)+1:size(data,1)-window(1)
                for j = 1+window(2):size(data,2)-window(2)
                    dataMat = data(i-window(1):i+window(1),j-window(2):j+window(2));
                    %Median
                    med = nanmedian(dataMat(:));
                    dataVec = abs(dataMat(:)-med);
                    %median absolute deviation
                    mad = nanmedian(dataVec);
                    %Robust elimination
                    mask(i,j) = abs(med-data(i,j))>option.thresholdMedian.*mad;
                end
            end
        end
        
        function [y] = sinc(x)
            % Sinc function
            %
            % [y] = sinc(x);
            
            y = sin(pi*x)./(pi*x);
            y(x==0)=1;
        end
        
    end
end