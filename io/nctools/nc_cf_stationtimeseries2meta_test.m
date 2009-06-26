%NC_CF_STATIONTIMESERIES2META_TEST  test for nc_cf_stationtimeseries2meta
%
% See also: nc_cf_stationtimeseries2meta

% ------------------------
%
% OPT.subdirs = {'concentration_of_chlorophyll_in_sea_water',...
%                'concentration_of_suspended_matter_in_sea_water',...
%                'sea_surface_height',...
%                'sea_surface_salinity',...
%                'sea_surface_temperature',...
%                'sea_surface_wave_from_direction',...
%                'sea_surface_wave_significant_height',...
%                'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};
%                
% for ii=1:length(OPT.subdirs)            
% 
% nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\rijkswaterstaat\waterbase\',OPT.subdirs{ii}])
% 
% end
%
% ------------------------
%
  OPT.subdirs = {'etmgeg',...
                 'potwind'};
                 
  for ii=1:length(OPT.subdirs)            
  
  nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\knmi\',OPT.subdirs{ii}])
  
  end
%
% ------------------------

%% EOF
