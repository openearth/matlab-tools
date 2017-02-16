function Statistics = EHY_statistics(computed,observed,varargin)

%% Check if belonging times are given and if it is tidal simulation or not
OPT.times = [];
OPT.tide  = false;
OPT       = setproperty(OPT,varargin);

%% Do statistics (from Firmijn's scripts)
error            = computed - observed;
nonan            = ~isnan(error);
if ~isempty(error(nonan))
    Statistics.bias             = mean( error(nonan) );
    Statistics.std              = norm( error(nonan) - Statistics.bias) / sqrt(length(error(nonan)));
    Statistics.rmse             = norm( error(nonan)                  ) / sqrt(length(error(nonan)));
    Statistics.cost             = 0.5 * sum( error(nonan).^2 );
    
    %% Statistics for high (1) and low (2) waters
    for i_hwlw = 1: 2
        % Highwaters
        sign = 1.;
        func_maxmin = 'max';
        if i_hwlw == 2;
            sign = -1.;
            func_maxmin = 'min';
        end
        
        % Maximum or minimum water levels over the entire period (can be nonsense)
        [Statistics.hwlw(i_hwlw).cmp,i_cmp]   = feval(func_maxmin,computed(nonan));
        [Statistics.hwlw(i_hwlw).obs,i_obs]   = feval(func_maxmin,observed(nonan));
        Statistics.hwlw(i_hwlw).diff          = feval(func_maxmin,computed(nonan)) - feval(func_maxmin,observed(nonan));
        if ~isempty (OPT.times)
            % Store times and time difference
            Statistics.hwlw(i_hwlw).time_cmp  = datestr(OPT.times(i_cmp));
            Statistics.hwlw(i_hwlw).time_obs  = datestr(OPT.times(i_obs));
            Statistics.hwlw(i_hwlw).time_diff = (OPT.times(i_cmp) - OPT.times(i_obs))*1440.;
            if OPT.tide
                % Same analysis this time over SERIES of High waters
                Statistics_tide                          = det_stat_tide(OPT.times,computed,observed,sign);
                Statistics.hwlw(i_hwlw).series_bias      = Statistics_tide.serieshwlw_bias;
                Statistics.hwlw(i_hwlw).series_rmse      = Statistics_tide.serieshwlw_rmse;
                Statistics.hwlw(i_hwlw).time_series_bias = Statistics_tide.serieshwlw_time_bias;
                Statistics.hwlw(i_hwlw).time_series_rmse = Statistics_tide.serieshwlw_time_rmse;
            end
        end
    end
end

function Statistics_tide = det_stat_tide(times,computed,observed,sign)

%% Determine high or low water statistics of a tidal signal, sign = 1 hw, sign = -1 lw
period = (12.*60 + 25.)/1440.; %period M2

%% Get high or low waters
[hwlw_cmp,time_hwlw_cmp]             = gethighwater   (times,sign.*computed,period);
[hwlw_obs,time_hwlw_obs]             = gethighwater   (times,sign.*observed,period);

%% Make sure the first hw or lw are corresponding
if time_hwlw_cmp(1) - time_hwlw_obs(1) > period/2
    hwlw_cmp(1:end-1)      = hwlw_cmp(2:end);
    time_hwlw_cmp(1:end-1) = time_hwlw_cmp(2:end);
end

if time_hwlw_cmp(1) - time_hwlw_obs(1) < -1.*period/2
    hwlw_obs(1:end-1)      = hwlw_obs(2:end);
    time_hwlw_obs(1:end-1) = time_hwlw_obs(2:end);
end

%% Statistics on values
tmp                                  = EHY_statistics (sign.*hwlw_cmp,sign.*hwlw_obs);
Statistics_tide.serieshwlw_bias      = tmp.bias;
Statistics_tide.serieshwlw_rmse      = tmp.rmse;

%% Statistics on times
tmp                                  = EHY_statistics(time_hwlw_cmp,time_hwlw_obs);
Statistics_tide.serieshwlw_time_bias = tmp.bias*1440.; % from days to minutes
Statistics_tide.serieshwlw_time_rmse = tmp.rmse*1440.; % from days to minutes