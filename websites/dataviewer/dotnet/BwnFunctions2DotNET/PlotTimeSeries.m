function outputPng = PlotTimeSeries(ncfile,ncVariable, varargin)
% function [output] = PlotTimeSeries(ncfile,ncVariable, startTime, stopTime)
%
% with startTime and stopTime optional time strings:
% (ISO 8601)  'yyyymmddTHHMMSS'        20000301T154517
%

outputPng = generateoutputpngname(varargin{:});

%% Plot time series
try
    f = figure();
    if nargin == 4
        startTime = datenum(varargin{1},'yyyymmddTHHMMSS');
        stopTime = datenum(varargin{2},'yyyymmddTHHMMSS');
        nc_cf_stationTimeSeries(ncfile,'varname',ncVariable,'period',[startTime stopTime]);
    else
        nc_cf_stationTimeSeries(ncfile,'varname',ncVariable);
    end
catch me
    error(['Could not read opendap file: ', me.getReport]);
end

%% Print to file
print(f,'-dpng','-r120',outputPng);
close(f);