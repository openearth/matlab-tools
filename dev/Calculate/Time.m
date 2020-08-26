%Class to declare the most common Time
%
% @author ABR
% @author SEO
% @version 0.8, 10/02/2014
%

classdef Time < handle
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
        function dateTime = dateTime2Num(date, time,refDate)
            % convert IMDC time to matlab time
            %
            %   dateTime = dateTime2Num(date, time,refDate)
            %
            %   Converts the 1 column integer
            %   matrices date and time into a single column matrix of serial date
            %   number. Date numbers are serial days where 1 corresponds to 1-Jan-0000.
            %   Values in 1 column intger matrices date and time must have the format
            %   YYYYMMDD and hhmmss respectively.
            %   dateTime is 1 column serial date number matrix representing the values of
            %   date and time.
            %
            %   refDate: is an
            %   integer value representing date and time inmatlab format.
            %   Returned matrix dateTime will contain serial date values representing the time
            %   passed between values of mDate and mTime and nRefDate.

            if nargin <3
                refDate = 0.0;
            end;

            year   = floor(date./10000);
            month  = floor((date-(year.*10000))./100);
            day    = date - (year.*10000)-(month.*100);
            hour   = floor(time./10000);
            minute = floor((time-(hour.*10000))./100);
            second = time - (hour.*10000)-(minute.*100);

            dateTime = datenum([year,month,day,hour,minute,second])-refDate;
        end;

        function strParts = getDateParts(str, tokens)
            %get all the parts of the string separated by special token
            %Input: - exampleDate - 01/Jun/2013
            %       - dateSeparator: '/'
            remain = str;
            cont   = 1;
            while(~isempty(remain))
                [text, remain] = strtok(remain, tokens);
                strParts{cont} = text;
                cont = cont + 1;
            end;
        end;

        function data = getExtractedTimeData(dataset, newTime)
            % extract a selected time for an entire dataset
            dataIndex = [];
            for i=1:size(newTime,1)
                indexes = find(fix(dataset.Time(:))== newTime(i));
                dataIndex = [dataIndex;indexes];
            end;

            data      = dataset;
            data.Time = dataset.Time(dataIndex);
        end;

        function [date, time] = num2DateTime(dateTime)
            % converts matlab time to IMDC style date time matrix
            %
            % [date, time]= num2DateTime(dateTime) transforms time tags in
            % serial time [days since 0 Jan 0000 00:00:00] to Date [YYYMMDD] and Time [hhmmss]
            %
            % INPUT: -dateTime: [Mx1] vector of serial time to transform
            %
            % OUTPUT: -date,Time: [Mx1]  vector of date [YYYYMMDD] and time [hhmmss]

            % International Marine and Dredging Consultants, IMDC
            % Antwerp Belgium
            %
            % Written by: Pierre Bayart
            % Date: June 2006
            % Modified by: Alexander Breugem
            % Date: February 2008

            dateVecs = datevec(dateTime);

            %checking rounding of of the dates
            mask = (dateVecs(:,6)>59.99);
            dateVecs(mask,5) = dateVecs(mask,5)+1;
            dateVecs(mask,6) = dateVecs(mask,6)-60;

            dateVecs(dateVecs(:,5)>59.99,4) = dateVecs(dateVecs(:,5)>59.99,4)+1;
            dateVecs(dateVecs(:,5)>59.99,5) = dateVecs(dateVecs(:,5)>59.99,5)-60;

            dateVecs(dateVecs(:,4)>23,3) = dateVecs(dateVecs(:,4)>23,3)+1;
            dateVecs(dateVecs(:,4)>23,4) = dateVecs(dateVecs(:,4)>23,4)-24;

            outDate = 1e4*dateVecs(:,1)+1e2*dateVecs(:,2)+dateVecs(:,3);
            outTime = 1e4*dateVecs(:,4)+1e2*dateVecs(:,5)+dateVecs(:,6);

            date = round(outDate);
            time = round(outTime);
        end;

        function timeStamp = timeStamp(options,interval)
            % makes time stamps
            %INPUT: options: structure with fields
            % -start
            % -end
            % -subsetType
            % interval: the interval value
            % OUTPUT: timestamps: a vector with time stamps
            options.interval = interval;

            switch options.subsetType
                case 'minutely'
                    timeStamp = Time.timeStampMinutes(options);
                case 'hourly'
                    timeStamp = Time.timeStampHour(options);
                case 'daily'
                    timeStamp = Time.timeStampDay(options);
                case 'weekly'
                    % options.firstDayOfWeek
                    timeStamp = Time.timeStampWeeks(options);
                case 'monthly'
                    timeStamp = Time.timeStampMonth(options);
                case 'yearly'
                    options.start = floor(options.start);
                    options.end   = ceil(options.end);
                    timeStamp     = Time.timeStampYears(options);
                otherwise
                    timeStamp = Time.timeStampDay(options);
            end
        end

        function x = timeStampDay(options)
            % make daily series starting at zero hours
            % INPUT:
            %options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in days (default is 1)
            % OUTPUT: x a row vector with the timestamps
            options   = Util.setDefault(options,'interval',1);
            startdate = floor(options.start);
            enddate   = ceil(options.end);
            x         = startdate:options.interval:enddate;

            % check if the right enddate is reached
            if x(end) < enddate
                x = [x,x(end)+options.interval];
            end;
        end;

        function x = timeStampHour(options)
            % make hourly series starting at complete hours
            % INPUT:
            %options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in days (default is 1)
            % OUTPUT: x a row vector with the timestamps
            options = Util.setDefault(options,'interval',1);
            startVec = datevec(options.start);
            startVec(5:6) = 0;
            startdate = datenum(startVec);
            endVec = datevec(options.end);
            if any(endVec(5:6))>    0
                endVec(4) = endVec(4) + 1;
            end;
            endVec(5:6) = 0;
            enddate = datenum(endVec);

            % convert to days
            options.interval = options.interval/24;


            x = startdate:options.interval:enddate;
            % check if the right enddate is reached
            if x(end) < enddate
                x = [x,x(end)+options.interval];
            end;
        end;

        function x = timeStampMinutes(options)
            % make minutely series starting at zero hours
            % INPUT:
            %options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in days (default is 1)
            % OUTPUT: x a row vector with the timestamps
            options = Util.setDefault(options,'interval',1);
            % convert to days
            options.interval = options.interval/60/24;
            startDate =  Calculate.roundToVal(options.start,options.interval,'floor');
            endDate   =  Calculate.roundToVal(options.end,options.interval,'ceil');
            x = startDate:options.interval:endDate;
            % check if the right enddate is reached
            if x(end) < endDate
                x = [x,x(end)+options.interval];
            end;
        end;

        function x = timeStampMonth(options)
            % make monthly time stamps starting at a prescirbed data
            % INPUT:
            % -options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in months (default is 1)
            % OUTPUT: x a row vector with the timestamps

            options = Util.setDefault(options,'interval',1);

            % make monthly series starting at the first day of the month
            startVec = datevec(options.start);

            % ending on the first day of the next month
            endVec = datevec(options.end);

            %    endVec(2) = mod(endVec(2),12)+1;
            %calculate time span
            nrMonths = (endVec(1)-startVec(1))*12 + (endVec(2)+1-startVec(2));

            % correcting for an integer multiple of intervals
            nrMonths = options.interval*ceil(nrMonths/options.interval);

            months = startVec(2) + (0:options.interval:nrMonths);

            %generating years and months
            years  = startVec(1) + floor((months-1)/12);
            months = 1+mod(months-1,12);

            nrTicks = length(months);
            % converting to matlab time
            monthVec = [years', months', ones(nrTicks,1),zeros(nrTicks,3)];
            x = datenum(monthVec);
        end;

        function x = timeStampQuarter(options)
            % make monthly series starting at the first day of the quarter (january, april etc)
            % INPUT:
            % options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % OUTPUT: x a row vector with the timestamps

            startVec    = datevec(options.start);
            startVec(2) = 1+floor((startVec(2)-1)/3)*3;

            % ending on the first day of the next month
            endVec    = datevec(options.end);
            endVec(2) = 1+ceil((endVec(2)-1)/3)*3;

            %    endVec(2) = mod(endVec(2),12)+1;
            %calculate time span
            nrMonths = (endVec(1)-startVec(1))*12 + (endVec(2)-startVec(2));

            % step every 3 months
            months = startVec(2) + (0:3:nrMonths);

            %generating years and months
            years   = startVec(1) + floor(months/12);
            months  = 1+mod(months-1,12);
            nrQuart = length(years);

            % converting to matlab time
            monthVec = [years', months', ones(nrQuart,1),zeros(nrQuart,3)];
            x = datenum(monthVec);

        end;

        function x = timeStampWeeks(options)
            % make weekly time series starting at a prescribed data
            % INPUT:
            % options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in weeks (default is 1)
            % -firstdayofweek (optional): the day to start the weeks  1 = sunday, 7 is saturday; default = 2(monday)
            % OUTPUT: x a row vector with the timestamps

            options = Util.setDefault(options,'firstDayOfWeek',2);
            options = Util.setDefault(options,'interval',1);

            % determining startday at prescribed date
            weekDayStart = weekday(options.start);
            dt           = weekDayStart - options.firstDayOfWeek;
            dt(dt<0)     = dt+7;
            startDate    = floor(options.start)-dt;

            % also for the enddate (in whole weeks)
            endDate    = ceil(options.end);
            weekDayEnd = weekday(endDate);
            dt         = options.firstDayOfWeek - weekDayEnd;
            dt(dt<0)   = dt+7;
            endDate    = endDate + dt;

            % generating timestamps
            x = startDate:7*options.interval:endDate;

            % checking if the end date is reached
            if x(end) < endDate
                x = [x,x(end)+7*options.interval];
            end;

        end;

        function x = timeStampYears(options)
            % make yearly time stamps starting at a prescirbed data
            % INPUT:
            % options: a structure with the fields
            % -start: the first date
            % -end: the last date
            % -interval (optional): the time step interval in years (default is 1)
            % OUTPUT: x a row vector with the timestamps

            options  = Util.setDefault(options,'interval',1);
            startVec = datevec(options.start);

            % ending on the first day of the next month
            endVec    = datevec(options.end);
            endVec(1) = endVec(1)+1;
            years     = startVec(1):options.interval:endVec(1);

            % checking if the end date is reached
            if years(end) < endVec(1)
                years = [years,years(end)+options.interval];
            end;

            nrYears = length(years);
            % converting to matlab time
            yearVec = [years', ones(nrYears,2),zeros(nrYears,3)];
            x = datenum(yearVec);

        end;

    end
end