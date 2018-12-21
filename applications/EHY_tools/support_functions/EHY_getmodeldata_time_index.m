function [Data,time_index,select, varargout]=EHY_getmodeldata_time_index(Data,OPT)

varargout{1} = {};
select       = [];
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
    if isfield(OPT,'tint') & ~isempty(OPT.tint)
        times_requested = [OPT.t0:OPT.tint:OPT.tend];
        no_times        = length(times_requested);
        index_requested = [];
        
        for i_time = 1: no_times
            [~,nr_time] = min(abs(Data.times - times_requested(i_time))); % Find nearest value
            index_requested  = [index_requested nr_time];
        end
        index_requested = unique(index_requested);
        varargout{1} = index_requested;
    end
else
    select=true(length(Data.times),1);
    time_index=0;
end

end
