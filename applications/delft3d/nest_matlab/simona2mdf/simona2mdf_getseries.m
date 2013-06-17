function [times,values] = simona2mdf_getseries(series)

% simona2mdf_getseries : extract time series uit of a siminp file

if strcmpi(series.SERIES,'regular')
    times  = series.FRAME(1):series.FRAME(2):series.FRAME(3);
    values = series.VALUES(1:length(times));
else
    for itime = 1: size(series.TIME_AND_VALUE,1)
        times(itim)  = series.TIME_AND_VALUE(itim,1)*1440 + ...
                       series.TIME_AND_VALUE(itim,2)*60   + ...
                       series.TIME_AND_VALUE(itim,3)      ;
        values(itim) = series.TIME_AND_VALUE(itim,4);
    end
end

