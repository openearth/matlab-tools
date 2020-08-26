%%Class to declare the most common Calculations
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Calculate < handle
    %Public properties
    properties
        Property1;
    end

    %Dependent properties
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

    %Static methods
    methods (Static)
        function [uX,uY] =calcXY(mag,dir)
            % INPUT:
            % mag: magnitude of the vector
            % dir: the direction (in degrees, between 0 and 360) in the
            % nautical convention
            % OUTPUT:
            % uX, uY: vector or matrix with respectively x and y components
            % of vector data
            dir=360-dir;
            dir=dir+90;
            dir(dir>360)=dir(dir>360)-360;
            
            uX = mag.*cosd(dir);                 
            uY = mag.*sind(dir); 
        end;
        function [dir,mag] = calcDir(uX,uY)
            % calculates the nautical direction from vector data
            % [dir,mag] = Calculate.calcDir(uX,uY)
            % INPUT:
            % - uX, uY: vector or matrix with respectively x and y components
            % of vector data
            % OUTPUT:
            % - dir: the direction (in degrees, between 0 and 360) in the
            % nautical convention
            % - mag: the magnitude of the vector
            dir = atan2(uY,uX);
            % conversion to nautical degrees
            dir = 90-(dir*180/pi);
            % rescale between 0 and 360 degrees
            mask = dir<0;
            dir(mask) = dir(mask)+360;
            mag = sqrt(uX.^2+uY.^2);
        end
        
        
        function sct = calcExchange(A,vOut,time)
            % Function to calculate the exchange discharges (tide, eddy, density,
            % remainder).
            % sct = calcExchange(A,vOut,time)
            %
            % INPUT:
            %      - A: area of the computational cells. 3D array with dimensions [T,X,Z].
            %      - vOut: velocity. 3D array with dimensions [T,X,Z]. Outflow is positive (if X is in left to right order).
            %      - time: time in days
            % OUTPUT:
            %      - sct: structure containing the exchange volumes per
            %      component split into (total, in and out)
            %           --tidalVolume: tidal related exchange volume
            %           --horVolume: eddy related exchange volume
            %           --verVolume: density related exchange volume
            %           --remVolume: remainder volume of the total bruto exchange volume
            %           --brutoVolume: total exhange volume
            
            
            % Determine exchange components of velocity vOut
            
            % netto waterexchange = tidal filling
            % integrate over space (results in time series)          
            dimU = size(vOut);
            Qnetto = nansum(nansum(-vOut.*A,3),2);
            
            %waterexchange not related to tidal filling
            mV_tide = Qnetto./nansum(nansum(A,3),2);
            V_no_tide = -vOut-repmat(mV_tide,[1 dimU(2) dimU(3)]);
            
            %vertical waterexchange (density related): average along
            %horizontal
            mV_horizontal                       = nansum(V_no_tide.*A,2)./nansum(A,2);
            V_vertical                          = repmat(mV_horizontal,[1 dimU(2) 1]);
            V_vertical_in                       = V_vertical;
            V_vertical_in(V_vertical_in<0)      = 0;
            Q_vertical_in                       = nansum(nansum(V_vertical_in.*A,3),2);
            V_vertical_out                      = V_vertical;
            V_vertical_out(V_vertical_out>0)    = 0;
            Q_vertical_out                      = nansum(nansum(V_vertical_out.*A,3),2);
            
            %horizontal waterexchange (eddy related): make depth averaged
            %first
            mV_vertical                         = nansum(V_no_tide.*A,3)./nansum(A,3);
            V_horizontal                        = repmat(mV_vertical,[1 1 dimU(3)]);
            V_horizontal_in                     = V_horizontal;
            V_horizontal_in(V_horizontal_in<0)  = 0;
            Q_horizontal_in                     = nansum(nansum(V_horizontal_in.*A,3),2);
            V_horizontal_out                    = V_horizontal;
            V_horizontal_out(V_horizontal_out>0)= 0;
            Q_horizontal_out                    = nansum(nansum(V_horizontal_out.*A,3),2);
            
            % remainder
            rem             = -vOut-repmat(mV_tide,[1 dimU(2) dimU(3)])...
                                   -repmat(mV_vertical,[1 1 dimU(3)])...
                                   -repmat(mV_horizontal,[1 dimU(2) 1]);
            rem_in          = rem;
            rem_in(rem_in<0)= 0;
            Q_rem_in        = nansum(nansum(rem_in.*A,3),2);
            rem_out         = rem;
            rem_out(rem_out>0)= 0;
            Q_rem_out       = nansum(nansum(rem_out.*A,3),2);
            
            % integrate over time
            tstep                   = (time(2) -time(1))*86400;
            sct.tidalVolume.timeseries = Qnetto;
            sct.tidalVolume.total   = nansum(abs(Qnetto))*tstep;
            sct.tidalVolume.in      = nansum(Qnetto(Qnetto>0))*tstep;
            sct.tidalVolume.out     = nansum(Qnetto(Qnetto<0))*tstep;
            sct.horVolume.timeseriesIn = Q_horizontal_in;
            sct.horVolume.timeseriesOut = Q_horizontal_out;
            sct.horVolume.total     = (nansum(Q_horizontal_in)-nansum(Q_horizontal_out))*tstep;
            sct.horVolume.in        = nansum(Q_horizontal_in)*tstep;
            sct.horVolume.out       = nansum(Q_horizontal_out)*tstep;
            sct.verVolume.timeseriesIn = Q_vertical_in;
            sct.verVolume.timeseriesOut = Q_vertical_out;
            sct.verVolume.total     = (nansum(Q_vertical_in)-nansum(Q_vertical_out))*tstep;
            sct.verVolume.in        = nansum(Q_vertical_in)*tstep;
            sct.verVolume.out       = nansum(Q_vertical_out)*tstep;
            sct.remVolume.total     = (nansum(Q_rem_in)-nansum(Q_rem_out))*tstep;
            sct.remVolume.in        = nansum(Q_rem_in)*tstep;
            sct.remVolume.out       = nansum(Q_rem_out)*tstep;
            sct.remVolume.timeseriesIn = Q_rem_in;
            sct.remVolume.timeseriesOut = Q_rem_out;
            sct.brutoVolume.total   = sct.tidalVolume.total+sct.horVolume.total+...
                                        sct.verVolume.total+sct.remVolume.total;
            sct.brutoVolume.in      = sct.tidalVolume.in+sct.horVolume.in+...
                                        sct.verVolume.in+sct.remVolume.in;
            sct.brutoVolume.out     = sct.tidalVolume.out+sct.horVolume.out+...
                                        sct.verVolume.out+sct.remVolume.out;
           
%             figure; hold on; 
%             plot(time,Qnetto,'-b'); 
%             plot(time,Q_horizontal_in,'-k'); 
%             plot(time,Q_horizontal_out,'--k');
%             plot(time,Q_vertical_in,'-r'); 
%             plot(time,Q_vertical_out,'--r');
%             plot(time,Q_rem_in,'-g'); 
%             plot(time,Q_rem_out,'--g');
%             grid on; dynamicDateTicks
%             legend('Tidal','Hor in','Hor out','Ver in','Ver out','Rem in','Rem out','location','best')
                    
        end

        function [xProj,yProj,dist] = projectOnRef(x,y,xRef,yRef)
            %Projects data on a reference line

            % INPUT
            %
            %x: X coordinates for data to project(matrix or vector)
            %y: Y coordinates for data to project(matrix or vector)
            %xref: [2x1] vector with start and end x coordinate of the
            %reference line
            %yref: [2x1] vector with start and end x coordinate of the
            %reference line
            %
            % xProj: the projected X coordinates (vector or matrix with the
            % same size as x)
            % yProj: the projected Y coordinates (vector or matrix with the
            % same size as x)
            % dist: the distance along the projected line (starting at x0)
            % (i.e. the S coordinate)

            try
                % these are the start (x0,y0) and end coordinates of the line on
                % which the data is projected
                x0 = xRef(1);
                y0 = yRef(1);
                x1 = xRef(2);
                y1 = yRef(2);

                % calculate the direction of the reference line
                a1 = x1-x0;
                a2 = y1-y0;

                % solving the parametric equation
                t = (a2.* (x-x0) - a1.* (y-y0))./(a2.^2 + a1.^2);

                % calculing the projected coordinates
                xProj = x - a2.*t;
                yProj = y + a1.*t;

                % calculate the distance
                dist = sqrt((xProj-x0).^2 + (yProj-y0).^2);

                % determine on which side of a line parallel to x0 the line is
                % put points not between x0 and infinity in the direction of x1
                % negative
                val = -a1.*x +a2.*y;
                dist(val>0) = -dist(val>0);
            catch
                sct = lasterror;
                errordlg([sct.message ' The projection could not be done.']);
                return;
            end
        end

        function [uCross,uAlong] = projectVector(uOld,vOld,xRef,yRef)
            % determines the components of a vector parallel and perpendicular to a transect
            %
            % [uCross,uAlong] = projectVector(uOld,vOld,xRef,yRef)
            %
            % INPUT: uOld, vOld [MxN], x and y components of a vector
            %       xref, yref  [M+1x1] or [Mx1] or [2x1], coordinates of a line on which uOld
            %      and vOld must be projected
            %
            % OUTPUT:uCross and uLong; components of uOld, vOld 
            % perpendicular and parallel to the transect given by xref,yref
            
            % determine the direction of the line segments in xref, yref
            dx = diff(xRef);
            dy = diff(yRef);
            % add an extra point at the end
            if length(xRef)==size(uOld,1)
                dx  = [dx;dx(end)];
                dy  = [dy;dy(end)];
            end
            % calculate the length of each segment
            dd = sqrt(dx.^2+dy.^2);
            % make a coordinate system alonng the transect
            nx = dx./dd; % cos theta
            ny = dy./dd; % sin theta
            % preallocate
            uCross = zeros(size(uOld));
            uAlong = zeros(size(uOld));
            % inner product
            nrY = size(uOld,2);
            for i = 1:nrY
                uAlong(:,i) =  uOld(:,i).*nx + vOld(:,i).*ny;
                uCross(:,i) = -uOld(:,i).*ny + vOld(:,i).*nx;
            end
        end
        
        function [uNew,vNew] = rotateVector(uOld,vOld, dir,mode)
            % rotates vector data
            %
            % [uNew,vNew] = Calculate.rotateVector(uOld,vOld, dir,mode)
            %
            % INPUT:
            %       - uOld: original data in X direction (scalar, matrix or vector)
            %       - vOld: original data in Y direction (scalar, matrix or vector)
            %       - dir: the direction (scalar or size of uOld) (in degrees, positive in counterclockwise direction)
            %              to rotate the data
            %       - mode: string with 'degrees' (default) or 'radians'
            % OUTPUT:
            %       - uNew: rotated data in X direction (scalar, matrix or vector)
            %       - vNew: rotated data in Y direction (scalar, matrix or vector)
            %

            % conversion from degrees to radians
            if nargin ==3
                mode ='degrees';
            end
            if strcmpi(mode,'degrees')
                dir(dir < 0) = dir(dir < 0) + 360; 
                dir = pi./180.*dir;
            end
            if numel(dir)==1
                dir = dir.*ones(size(uOld));
            end

            % apply rotation matrix
            if length(dir(:))>1
                uNew = cos(dir).*uOld - sin(dir).*vOld;
                vNew = sin(dir).*uOld + cos(dir).*vOld;
            end
            
            
        end

        function [vOut,vRemain] = round2integer(vData,nInt)
            % general script for rounding integers
            vOut    = nInt.*floor(vData./nInt);
            vRemain = vData - vOut;
        end

        function y = roundToVal(x,val,type)
            % round to mulitiples of value
            % INPUT: x: a scalar, vector or matrix with data to round
            % val: a scalar with the value use to round. This may be a any
            % number (also fractions). As an example, rouding to multiples
            % of 50 is done by using val = 50.
            % type: a string with the possible types: 'round','floor', 'ceil'
            % OUTPUT:  y: the rounded version of x (with the same size)
            if nargin ==2
                type = 'round';
            end
            switch (type)
                case 'round'
                    y  = val.*round(x./val);
                case 'floor'
                    y  = val.*floor(x./val);
                case 'ceil'
                    y  = val.*ceil(x./val);
            end
        end

        function y = thirdOrder(x)
            %Calculate y = (1-x.^3).^3
            y = (1-x.^3).^3;
        end

        function int = trapeziumRule(x,y)
            % integrate data using trapezium rule
            dx = diff(x);
            int = 0.5.*sum(dx.*(y(2:end)+y(1:end-1)));
        end
        
        function dist = circle_distance(lat1,lon1,lat2,lon2)
            % This uses the ‘haversine’ formula to calculate the great-circle 
            % distance between two points – that is, the shortest distance 
            % over the earth’s surface – giving an ‘as-the-crow-flies’ 
            % distance between the points (ignoring any hills they fly 
            % over, of course!).
            %
            % INPUT: -lat1,lon1,lat2,lon2 vectors with the geographical
            %        coordinates of the points.
            % OUTPUT: -dist: distance in meters for every (lat1, lon1)
            %        combination (lat2, lon2), same dimension as the input
            %        vectors.
            if ( sum(abs(lat1)>90)+sum(abs(lat2)>90) )>0
                error('error in latitudes. All latitudes should be defined between -90° and +90°');
            end
            R = 6371*1000; % earths radius in meter
            lat1 = deg2rad(lat1);
            lat2 = deg2rad(lat2);
            dLat = lat2-lat1;
            dLon = mod(lon2-lon1,360);
            dLon(dLon>180) = 360-dLon(dLon>180);
            dLon = deg2rad(dLon);
            a = sin(dLat/2).^2 + cos(lat1).*cos(lat2).*(sin(dLon/2).^2);
            c = 2*atan2(sqrt(a),sqrt(1-a));
            dist = R*c;
        end

    end
end