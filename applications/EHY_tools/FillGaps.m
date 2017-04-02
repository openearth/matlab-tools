function[times_new,values_new] = FillGaps(times,values,varargin)

% Fill gaps between measurements with NaN's

%% Initialize
OPT.interval = 2./24;
OPT = setproperty(OPT,varargin);
eps = 1e-6;

times_new  = times;
values_new = values;
max_diff   = 365;

%% As long as there are time differences larger than interval
time_diff = times(2:end) - times(1:end-1);
max_diff  = max(time_diff);
while max_diff > OPT.interval + eps
    index     = find(time_diff > OPT.interval + eps,1,'first')
    if ~isempty(index)
        %% add NaN in between
        times_new  = vertcat(times (1:index), times(index) + OPT.interval, times (index + 1:end));
        values_new = vertcat(values(1:index), NaN                        , values(index + 1:end));
        times      = times_new;
        values     = values_new;
    end
    time_diff = times(2:end) - times(1:end-1);
    max_diff = max(time_diff);
end

disp(max_diff)
    


