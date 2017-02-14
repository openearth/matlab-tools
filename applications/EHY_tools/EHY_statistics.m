function Statistics = EHY_statistics(computed,observed,varargin)

%% Check if belonging times are given       
OPT.times = [];
OPT       = setproperty(OPT,varargin);

%% Do statistics (from Firmijn's scripts)
error            = computed - observed;
nonan            = ~isnan(error);
if ~isempty(error(nonan))
    Statistics.bias             = mean( error(nonan) );
    Statistics.std              = norm( error(nonan) - Statistics.bias) / sqrt(length(error(nonan)));
    Statistics.rmse             = norm( error(nonan)                  ) / sqrt(length(error(nonan)));
    Statistics.cost             = 0.5 * sum( error(nonan).^2 );
    [Statistics.maxobs,i_obs]   = max(observed(nonan));
    [Statistics.maxprd,i_prd]   = max(computed(nonan));
    Statistics.difmax           = Statistics.maxprd - Statistics.maxobs;
    if ~isempty (OPT.times)
        % Store times and time difference
        Statistics.maxobs_time = OPT.times(i_obs);
        Statistics.maxprd_time = OPT.times(i_prd);
        Statistics.difmax_time = (Statistics.maxprd_time - Statistics.maxobs_time)*1440.;  
    end
    [Statistics.minobs,i_obs]  = min(observed(nonan));
    [Statistics.minprd,i_prd]  = min(computed(nonan));
    Statistics.difmin   = Statistics.minprd - Statistics.minobs;
    if ~isempty (OPT.times)
        % Store times and time difference
        Statistics.minobs_time = OPT.times(i_obs);
        Statistics.minprd_time = OPT.times(i_prd);
        Statistics.difmin_time = (Statistics.minprd_time - Statistics.minobs_time)*1440.;  
    end
end