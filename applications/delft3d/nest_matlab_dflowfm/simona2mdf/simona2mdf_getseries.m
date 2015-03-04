function [times,values] = simona2mdf_getseries(series)

% simona2mdf_getseries : extract time series uit of a siminp file

if strcmpi(series.SERIES,'regular')
    times  = series.FRAME(1):series.FRAME(2):series.FRAME(3);
    values = series.VALUES(1:length(times));
else
    for itim = 1: size(series.TIME_AND_VAL,1)
        times(itim)  = series.TIME_AND_VAL(itim,1)*1440 + ...
                       series.TIME_AND_VAL(itim,2)*60   + ...
                       series.TIME_AND_VAL(itim,3)      ;
        values(itim) = series.TIME_AND_VAL(itim,4);
    end
end

if times(1) > 0 && simona2mdf_fieldandvalue(series,'TID')
    times (2:end+1)  = times (1:end);
    values(2:end+1)  = values(1:end);
    times (1      )  = 0.;
    values(1      )  = series.TID;
end

