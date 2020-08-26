% Class with resampling scripts
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Resample < handle
    %Public properties
    properties
        
    end
    
    %Dependand properties
    properties (Dependent = true, SetAccess = private)
        
    end
    
    %Private properties
    properties(SetAccess = private)
        
    end
    
    %Public methods
    methods
        
    end
    
    %Private methods
    methods (Access = 'private')
        
    end
    
    %Stactic methods
    methods (Static)
        function ynew = resampleInt(x,y,xnew)
            % resamples data (by tacking the average)
            %
            % ynew = resampleInt(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % integral (caluclated with the trapezium rule) of all values in a bin
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine average for every resampled interval
            for i = 1:nrLength
                mask = (x>=xnew(i)) & (x<xnew(i+1));
                % Todo (inlining for beter speed?)
                % TODO: interpolate values at the edges of the interval
                ynew(i) = Calculate.trapeziumRule(x(mask),y(mask));
            end
        end
        
        function ynew = resampleMax(x,y,xnew)
            % resamples data (by tacking the maximum)
            %
            % ynew = resampleMax(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % maximum of all values in a bin
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine maximum for every resampled interval
            for i = 1:nrLength
                mask    = (x>=xnew(i)) & (x<xnew(i+1));
                ynew(i) =  nanmax(y(mask));
            end
        end
        
        function ynew = resampleMean(x,y,xnew)
            % resamples data (by tacking the average)
            %
            % ynew = resampleMean(x,y,xnew)
            %
            % INPUT:
            % - x: [Nx1] vector of original x values of input points
            % - y: original y values of input points to resample;  can be
            % [NxM] matrix ordered by columnwise
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % averages of all values in a bin
            
            %allocating output variable
            if size(x,1)~=size(y,1)
                error(Wr);
            end
            nrLength = length(xnew)-1;
            nrCol    = size(y,2);
            ynew     = nan(nrLength,nrCol);
            % determine average for every resampled interval
            for i = 1:nrLength
                mask    = (x>=xnew(i)) & (x<xnew(i+1));
                ynew(i,:) =  nanmean(y(mask,:));
            end
            
        end
        
        function ynew = resampleMin(x,y,xnew)
            % resamples data (by tacking the minimum)
            %
            % ynew = resampleMin(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % minimum of all values in a bin
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine minimum for every resampled interval
            for i = 1:nrLength
                mask    = (x>=xnew(i)) & (x<xnew(i+1));
                ynew(i) =  nanmin(y(mask));
            end
        end
               
         function ynew = resamplePercentile(x,y,xnew,percentile)
            % resamples data (by tacking the sum)
            %
            % ynew = resampleSum(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % - percentile = value of the percentile between 0 and 100.
            
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % sum of all values in a bin
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine sum for every resampled interval
            for i = 1:nrLength
                mask    = (x>=xnew(i)) & (x<xnew(i+1));
                ynew(i) =  prctile(y(mask),percentile);
            end
         end
         function ynew = resampleMedian(x,y,xnew)
             % resamples data (by tacking the sum)
             %
             % ynew = resampleSum(x,y,xnew)
             %
             % INPUT:
             % - x: vector of original x values of input points
             % - y: original y values of input points to resample
             % - xnew: vector [Nx1] of  edges of the bins to resample
             
             % OUTPUT
             % - ynew: the resampled values (size [N-1x1]), which are the
             % sum of all values in a bin
             
             %allocating output variable
             nrLength = length(xnew)-1;
             ynew     = nan(nrLength,1);
             % determine sum for every resampled interval
             for i = 1:nrLength
                 mask    = (x>=xnew(i)) & (x<xnew(i+1));
                 ynew(i) =  nanmedian(y(mask));
             end
         end
         function ynew = resampleStd(x,y,xnew)
             % resamples data (by tacking the sum)
             %
             % ynew = resampleSum(x,y,xnew)
             %
             % INPUT:
             % - x: vector of original x values of input points
             % - y: original y values of input points to resample
             % - xnew: vector [Nx1] of  edges of the bins to resample
             
             % OUTPUT
             % - ynew: the resampled values (size [N-1x1]), which are the
             % sum of all values in a bin
             
             %allocating output variable
             nrLength = length(xnew)-1;
             ynew     = nan(nrLength,1);
             % determine sum for every resampled interval
             for i = 1:nrLength
                 mask    = (x>=xnew(i)) & (x<xnew(i+1));
                 ynew(i) =  nanstd(y(mask));
             end
         end
        
        function ynew = resampleSum(x,y,xnew)
            % resamples data (by tacking the sum)
            %
            % ynew = resampleSum(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % sum of all values in a bin
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine sum for every resampled interval
            for i = 1:nrLength
                mask    = (x>=xnew(i)) & (x<xnew(i+1));
                ynew(i) =  nansum(y(mask));
            end
        end
        function ynew = resampleNumber(x,y,xnew)
            % resamples data (by tacking the sum)
            %
            % ynew = resampleSum(x,y,xnew)
            %
            % INPUT:
            % - x: vector of original x values of input points
            % - y: original y values of input points to resample
            % - xnew: vector [Nx1] of  edges of the bins to resample
            % OUTPUT
            % - ynew: the resampled values (size [N-1x1]), which are the
            % total number of values between in the bin excluding
            % NaN-values.
            
            %allocating output variable
            nrLength = length(xnew)-1;
            ynew     = nan(nrLength,1);
            % determine sum for every resampled interval
            for i = 1:nrLength
                mask    = ((x>=xnew(i)) & (x<xnew(i+1))) & ~isnan(y);
                ynew(i) =  nansum(mask);
            end
        end
        function [xRes,yRes,sRes] = resamplePolyline(x,y,dxRes)
            % resamples a polyline using a given distance
            %
            % [xRes,yRes,sRes] = resamplePolyline(x,y,dxRes)
            %
            % INPUT: 
            % - x,y   : [Nx1] vector of coordinates of the polyline
            % - dxRes : [scalar] distance used to resample the polyline
            % OUTPUT: 
            % - xRes, yRes: [Nx1]: x and y coordinates of the
            % resampled polyline
            % - sRes: distance along the resampled polyline
            % get data
            SMALL_VAR = 0.01;
            xRes = [];
            yRes = [];
            for i = 1:length(x)-1
                % determine the distance between the coordinates
                distX = x(i+1)-x(i);
                distY = y(i+1)-y(i);
                dist = sqrt(distX.^2 + distY.^2);
                % determine the needed distances
                dx = dxRes*distX/dist;
                dy = dxRes*distY/dist;
                % make a vector
                xTmp = x(i):dx:x(i+1);
                yTmp = y(i):dy:y(i+1);
                % add to the complete vector
                if isempty(xTmp)
                    xTmp  = x(i).*ones(size(yTmp));
                end
                if isempty(yTmp)
                    yTmp  = y(i).*ones(size(xTmp));
                end
                if i>1
                    dist = sqrt( (xRes(end)-xTmp(1)).^2 + (yRes(end)-yTmp(1)).^2);
                    if dist > SMALL_VAR
                        xRes =[xRes;xTmp'];
                        yRes =[yRes;yTmp'];
                    else
                        xRes =[xRes;xTmp(2:end)'];
                        yRes =[yRes;yTmp(2:end)'];
                    end
                else
                    xRes =[xRes;xTmp'];
                    yRes =[yRes;yTmp'];
                end
                
            end
            sRes = sqrt((xRes-xRes(1)).^2+(yRes-yRes(1)).^2);
        end
        
        function[xRes,yRes] = resamplePolylineEqual(x,y,dxRes)
            % resamples a polyline using a given distance
            %
            % [xRes,yRes] = resamplePolylineEqual(x,y,dxRes)
            %
            % INPUT: 
            % - x,y   : [Nx1] vector of coordinates of the polyline
            % - dxRes : [scalar] distance used to resample the polyline
            % OUTPUT: 
            % - xRes, yRes: [Nx1]: x and y coordinates of the
            % resampled polyline
            
            % calculate distance
            dx = diff(x);
            dy = diff(y);
            dist = cumsum([0; sqrt(dx.^2 +dy.^2)]);
            
            % adjusted size
            maxDist = max(dist);
            nP = ceil(maxDist./dxRes);
            di = linspace(0,maxDist,nP)';
            
            ind = (1:length(x))';
            [dist,ind] = Interpolate.preprocess(dist,ind);
            x = x(ind);
            y = y(ind);
            % interpolate
            xRes = interp1(dist,x,di);
            yRes = interp1(dist,y,di);
            
        end
    end
end