function outputPng = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime,varargin)
% function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime, outputDir)
%
% with startTime and stopTime optional time strings:
% (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
%

outputPng = generateoutputpngname(varargin{:});

%% Plot time series
try
    f = figure();
    startTime = datenum(startTime,'yyyymmddTHHMMSS');
    stopTime = datenum(stopTime,'yyyymmddTHHMMSS');
    %% OPTION 1: 
         profile on
        nc_cf_stationTimeSeries(ncfile,'varname',ncVariable,'period',[startTime stopTime]);
         profile report
    
    %% OPTION 2 (because OPTION 1 is much slower!)
%     [D.datenum,start0,count0,M.datenum.timezone] = nc_cf_time_range(ncfile,'time',[startTime stopTime]);
%     I         = nc_getvarinfo(ncfile,ncVariable);
%     start     = zeros(1,length(I.Dimension));
%     count     = ones (1,length(I.Dimension));
%     i         = strmatch('time',I.Dimension);
%     count(i)  = count0;
%     start(i)  = start0;
%     D.var = nc_varget(ncfile,ncVariable,start,count);
%     plot(D.datenum,D.var);
%     ylabel([I.Attribute(1).Value ' [' I.Attribute(2).Value ']']);
%     datetick('x',24,'keeplimits');
%     grid on;
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

%% Print to file
print(f,'-dpng','-r120',outputPng);
close(f);