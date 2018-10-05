function [Data,time_index,select]=EHY_getmodeldata_time_index(Data,OPT)
if ~isempty(OPT.t0) && ~isempty(OPT.tend)
    select=(Data.times>=OPT.t0) & (Data.times<=OPT.tend);
    time_index=find(select);
    if ~isempty(time_index)
        Data.times=Data.times(time_index);
    else
        error(['These time steps are not available in the outputfile' char(10),...
            'requested data period: ' datestr(OPT.t0) ' - ' datestr(OPT.tend) char(10),...
            'available model data:  ' datestr(Data.times(1)) ' - ' datestr(Data.times(end))])
    end
else
    select=true(length(Data.times),1);
    time_index=0;
end

end
