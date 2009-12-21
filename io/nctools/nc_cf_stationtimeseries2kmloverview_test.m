function nc_cf_stationtimeseries2kmloverview_test
%NC_CF_STATIONTIMESERIES2KMLOVERVIEW_TEST tts for nc_cf_stationtimeseries2kmloverview
%
%See also: NC_CF_STATIONTIMESERIES2KMLOVERVIEW, KNMI_ALL

% TO DO: allow for multiple parameters in one kml file instead of one per kml

clear OPT

%% urlbase

 % urlbase = 'p:\mcdata\opendap\'; % @ deltares internally
 % urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
   urlbase = 'http://opendap.deltares.nl:8080'; % production server

%% KNMI, see KNMI_all.m

%% Rijkswaterstaat

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
   
       directory          = 'P:\mcdata\opendap\rijkswaterstaat\waterbase\';
   OPT.fileName           = [directory,filesep,subdirs{ii},'.kml'];
   OPT.kmlName            =  subdirs{ii};
   OPT.THREDDSbase        = [urlbase,'/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',     subdirs{ii},'/'];
   OPT.HYRAXbase          = [urlbase,'/opendap/rijkswaterstaat/waterbase/',                   subdirs{ii},'/'];
   OPT.ftpbase            = [urlbase,'/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdirs{ii},'/'];
   OPT.description        = {['parameter: ',subdirs{ii}],...
                              'source: <a href="http://www.waterbase.nl">Rijkswaterstaat</a>'};
   
   OPT.standard_name      = subdirs{ii};
   
   OPT.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
   OPT.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
   
   nc_cf_stationtimeseries2kmloverview([directory,filesep,subdirs{ii},'.xls'],OPT);
   
   end

%% EOF