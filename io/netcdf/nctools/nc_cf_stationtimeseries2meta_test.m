%NC_CF_STATIONTIMESERIES2META_TEST  test for nc_cf_stationtimeseries2meta
%
%
% See also: nc_cf_stationtimeseries2meta


%% Note: generates error after about 450 files:
%     java.lang.OutOfMemoryError: Java heap space
%
% Note that that opendap acces does not work then (landboundary)

OPT.USE_JAVA = getpref ('SNCTOOLS', 'USE_JAVA');
setpref ('SNCTOOLS', 'USE_JAVA', 0)

%% ------------------------

%  OPT.subdirs = {'concentration_of_chlorophyll_in_sea_water',...
%                 'concentration_of_suspended_matter_in_sea_water',...
%                 'sea_surface_height',...
%                 'sea_surface_salinity',...
%                 'sea_surface_temperature',...
%                 'sea_surface_wave_from_direction',...
%                 'sea_surface_wave_significant_height',...
%                 'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};
%                 
%  for ii=1:length(OPT.subdirs)            
%  
%  [M,units] = nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\rijkswaterstaat\waterbase\',OPT.subdirs{ii}],...
%                                          'standard_name',OPT.subdirs{ii});
%  
%  end

%% ------------------------

  OPT.subdirs = {'etmgeg'%,...
                 };%'potwind'};
                 
  for ii=1:length(OPT.subdirs)            
  
  nc_cf_stationtimeseries2meta('directory_nc',['P:\mcdata\opendap\knmi\',OPT.subdirs{ii}],...
                              'standard_names',{'wind_speed','wind_from_direction'});
  
  end


%% ------------------------
               
setpref ('SNCTOOLS', 'USE_JAVA', OPT.USE_JAVA)

%% EOF
