function outputPng = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
% function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
%
% with startTime and stopTime optional time strings:
% (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
%

outputPng = generateoutputpngname;

%% Plot time series
try
    f = figure();
    startTime = datenum(startTime,'yyyymmddTHHMMSS');
    stopTime = datenum(stopTime,'yyyymmddTHHMMSS');
    nc_cf_stationTimeSeries(ncfile,'varname',ncVariable,'period',[startTime stopTime]);
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

%% Print to file
print(f,'-dpng','-r120',outputPng);
close(f);