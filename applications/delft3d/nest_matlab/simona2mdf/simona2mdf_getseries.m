function [times,values] = simona2mdf_getseries(series)

% simona2mdf_getseries : extract time series uit of a siminp file

if strcmpi(series.SERIES,'regular')
    times  = series.FRAME(1):series.FRAME(2):series.FRAME(3);
    values = series.VALUES(1:length(times));
else
    simona2mdf_warning('TIME_AND_VALUE for time series not implemeted yet');
end

