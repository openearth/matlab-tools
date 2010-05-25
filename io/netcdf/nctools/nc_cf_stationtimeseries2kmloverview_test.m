function nc_cf_stationtimeseries2kmloverview_test
%NC_CF_STATIONTIMESERIES2KMLOVERVIEW_TEST tts for nc_cf_stationtimeseries2kmloverview
%
%See also: NC_CF_STATIONTIMESERIES2KMLOVERVIEW, KNMI_ALL, RWS_WATERBASE_ALL

% TO DO: allow for multiple parameters in one kml file instead of one per kml

clear OPT

%% Initialize

  %urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
  %urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server

   urlbase = 'http://opendap.deltares.nl:8080'; % production server
   locbase = 'P:\mcdata';                       % @ deltares internally

%% KNMI, see KNMI_all

%% Rijkswaterstaat, see RWS_WATERBASE_ALL

subdirs = {'concentration_of_chlorophyll_in_sea_water',...
           'concentration_of_suspended_matter_in_sea_water',...
           'sea_surface_height',...
           'sea_surface_salinity',...
           'sea_surface_temperature',...
           'sea_surface_wave_from_direction',...
           'sea_surface_wave_significant_height',...
           'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
           'water_volume_transport_into_sea_water_from_rivers'};

for ii= [1:7 9] % 1:length(subdirs)   
   
      subdir            = subdirs{ii};
      OPT.directory_nc  = [locbase,         '\opendap\rijkswaterstaat\waterbase\'      ,filesep,subdir];

   %% Make KML overview with links to netCDF on opendap.deltares.nl

   disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': ',subdirs{ii}])
   
      OPT2.fileName           = [OPT.directory_nc,'.kml'];
      OPT2.kmlName            =  subdir;
      OPT2.THREDDSbase        = [urlbase,'/thredds/dodsC/opendap/rijkswaterstaat/waterbase/',     subdirs{ii},'/'];
      OPT2.HYRAXbase          = [urlbase,'/opendap/rijkswaterstaat/waterbase/',                   subdirs{ii},'/'];
      OPT2.ftpbase            = [urlbase,'/thredds/fileServer/opendap/rijkswaterstaat/waterbase/',subdirs{ii},'/'];
      OPT2.description        = {['parameter: ',subdir],...

                                 'source: <a href="http://www.waterbase.nl">Rijkswaterstaat</a>'};
      
      OPT2.standard_name      = subdirs{ii};
      
      OPT2.iconnormalState    = 'http://maps.google.com/mapfiles/kml/shapes/placemark_square.png';
      OPT2.iconhighlightState = 'http://www.rijkswaterstaat.nl/images/favicon.ico';
      
      % camera
      
      OPT2.lon = 1;
      OPT2.lat = 54;
      OPT2.z   = 100e4;
      
      nc_cf_stationtimeseries2kmloverview([OPT.directory_nc,'.xls'],OPT2);
   
end

%% EOF