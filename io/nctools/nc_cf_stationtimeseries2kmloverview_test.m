function nc_cf_stationtimeseries2kmloverview_test
%NC_CF_STATIONTIMESERIES2KMLOVERVIEW_TEST tts for nc_cf_stationtimeseries2kmloverview
%
%See also: NC_CF_STATIONTIMESERIES2KMLOVERVIEW

clear OPT

subdirs = {'concentration_of_chlorophyll_in_sea_water',...
           'concentration_of_suspended_matter_in_sea_water',...
           'sea_surface_height',...
           'sea_surface_salinity',...
           'sea_surface_temperature',...
           'sea_surface_wave_from_direction',...
           'sea_surface_wave_significant_height',...
           'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment'};

for ii=1:length(subdirs)

disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': ',subdirs{ii}])

OPT.fileName    = [subdirs{ii},'.kml'];
OPT.kmlName     =  subdirs{ii};
OPT.THREDDSbase = ['http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',subdirs{ii},'/'];
OPT.HYRAXbase   = ['http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/waterbase/',subdirs{ii},'/'];
OPT.ftpbase     = ['http://opendap.deltares.nl:8080/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdirs{ii},'/'];
OPT.description = {['parameter: ',subdirs{ii}],...
                   'source: <a href="http://www.waterbase.nl">Rijkswaterstaat</a>'};

nc_cf_stationtimeseries2kmloverview([subdirs{ii},'.xls'],OPT)

end
