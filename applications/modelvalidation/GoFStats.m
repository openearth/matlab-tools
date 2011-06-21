function STATS = GoFStats(D3DTimePoints, D3DValues, ...
    NetCDFTime, NetCDFValues, varargin)
%GoFStats computes 'Goodness of Fit' scores and plots target diagram 
%as explained in Jolliff et al., 2009 [Summary diagrams for coupled
%hydrodynamic-ecosystem model skill assessment, Jason K. Jolliff et al., 
%Journal of Marine Systems 76 (2009) 64-82].
%The statistics are computed for modeled timeseries MODEL assuming that 
%the reference is provided by the in-situ measurements OBS.
%
% STATS = GoFStats(model_times, model_values, obs_times, obs_values, varargin);
%
% If option subset is deactivated, computes statistics on the whole model 
% timeseries (default is option subset activated).
%
% Example:
% STATS = GoFStats(model_times, model_values, obs_times, obs_values);
%
%  Timeseries data definition:
%   * <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a> (full definition)
%   * <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984788</a> (simple)
%
%See also: GOFTIMESERIES

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%

OPT.station = '';
OPT.subset = 1;
OPT = setProperty(OPT, varargin{:});

%% combine timeseries:
%   - missing observations are replaced by NaNs
%   - missing model values are interpolated in time
tmpTime = cat(1, squeeze(D3DTimePoints), squeeze(NetCDFTime));
[STATS.datenum, idx] = sort(tmpTime);
newData.model = interp1(squeeze(D3DTimePoints), ...
    squeeze(D3DValues), squeeze(NetCDFTime));
newData.obs = NaN + zeros(size(squeeze(D3DTimePoints)));
tmpData.model = cat(1, squeeze(D3DValues), squeeze(newData.model));
tmpData.obs = cat(1, squeeze(newData.obs), squeeze(NetCDFValues));
combined_all.D3DTimePoints = tmpTime(idx);
combined_all.NetCDFTime = tmpTime(idx);
combined_all.D3DValues = tmpData.model(idx);
combined_all.NetCDFValues = tmpData.obs(idx);

%% Keep only (model) points that have an equivalent in the observations
%% and compute the statistics on this subset
if (OPT.subset)
    msk = find(~isnan(combined_all.NetCDFValues));
    combined.D3DTimePoints = combined_all.D3DTimePoints(msk);
    combined.NetCDFTime = combined_all.NetCDFTime(msk);
    combined.D3DValues = combined_all.D3DValues(msk);
    combined.NetCDFValues = combined_all.NetCDFValues(msk);
else
    combined.D3DTimePoints = combined_all.D3DTimePoints;
    combined.NetCDFTime = combined_all.NetCDFTime;
    combined.D3DValues = combined_all.D3DValues;
    combined.NetCDFValues = combined_all.NetCDFValues;
end

STATS.model_comb = combined.D3DValues;
STATS.obs_comb = combined.NetCDFValues;

%% compute means and stddev of normal distributions
STATS.model_mean = nanmean(combined.D3DValues);
STATS.obs_mean = nanmean(combined.NetCDFValues);
STATS.model_stddev = nanstd(combined.D3DValues);
STATS.obs_stddev = nanstd(combined.NetCDFValues);
%% compute residus of normal distributions
STATS.model_res = combined.D3DValues - STATS.model_mean;
STATS.obs_res = combined.NetCDFValues - STATS.obs_mean;
%% compute various statistics
% number of records
STATS.n = length(combined.D3DValues); 
% correlation coefficient
STATS.R = nanmean(STATS.model_res.*STATS.obs_res)/ ...
    (STATS.model_stddev.*STATS.obs_stddev);
% normalized standard deviation
STATS.normalized_stddev = STATS.model_stddev/STATS.obs_stddev; 
% total RMS difference
%STATS.RMSD = sqrt(nanmean((combined.D3DValues - combined.NetCDFValues).^2));
STATS.RMSD = sqrt(nanmean((STATS.model_comb-STATS.obs_comb).^2));
% bias
STATS.bias = STATS.model_mean - STATS.obs_mean;
% unbiased RMS difference
%STATS.unbiased_RMSD = sqrt(STATS.RMSD^2 - STATS.bias^2);
STATS.unbiased_RMSD = sqrt(nanmean((STATS.model_res-STATS.obs_res).^2));
% normalized bias
STATS.normalized_bias = (STATS.model_mean - STATS.obs_mean)/ ...
    STATS.obs_stddev;
% normalized unbiased RMS difference
%STATS.normalized_unbiased_RMSD = sqrt(1. + ...
%    STATS.normalized_stddev^2 - 2.*STATS.normalized_stddev*STATS.R);
STATS.normalized_unbiased_RMSD = STATS.unbiased_RMSD/STATS.normalized_stddev;
% model efficiency
STATS.model_efficiency = 1.0 - ...
    nansum((combined.D3DValues-combined.NetCDFValues).^2)/ ...
    nansum(STATS.model_res.^2);
% skill score
STATS.skill_score = 1.0 - ((1.0+STATS.R)/2.)* ...
    exp(-(STATS.normalized_stddev-1)^2/0.18);

STATS.CF = nanmean(abs(combined.D3DValues - combined.NetCDFValues))./ ...
    STATS.model_stddev;

%% Compute coordinates for the target diagrams
% STATS.model.GoF = [STATS.RMScp]*sign([STATS.model.stddev] - ...
%     [STATS.obs.stddev])./[STATS.obs.stddev];
STATS.xTarget = sign(STATS.model_stddev-STATS.obs_stddev)*...
    STATS.normalized_unbiased_RMSD;
STATS.yTarget = STATS.normalized_bias;

%%STATS.model_name = model.name;
STATS.obs_name = OPT.station;

return;
end
