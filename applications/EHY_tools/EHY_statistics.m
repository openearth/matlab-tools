function Statistics = EHY_statistics(computed,observed)

%% Do statistics (from Firmijn's scripts)
error            = computed - observed;
nonan            = ~isnan(error);
if ~isempty(error(nonan))
    Statistics.bias     = mean( error(nonan) );
    Statistics.std      = norm( error(nonan) - Statistics.bias) / sqrt(length(error(nonan)));
    Statistics.rmse     = norm( error(nonan)                  ) / sqrt(length(error(nonan)));
    Statistics.cost     = 0.5 * sum( error(nonan).^2 );
    Statistics.maxobs   = max(observed(nonan));
    Statistics.maxprd   = max(computed(nonan));
    Statistics.difmax   = Statistics.maxprd - Statistics.maxobs;
    Statistics.minobs   = min(observed(nonan));
    Statistics.minprd   = min(computed(nonan));
    Statistics.difmin   = Statistics.minprd - Statistics.minobs;
end