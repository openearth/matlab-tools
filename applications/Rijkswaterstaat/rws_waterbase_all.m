function rws_waterbase_all
%RWS_WATERBASE_ALL    download waterbase.nl parameters from web, transform to netCDF, make kml,  make catalog.
%
%See also: KNMI_ALL,                   , RWS_WATERBASE_*
%          NC_CF_STATIONTIMESERIES2META, NC_CF_DIRECTORY2CATALOG, NC_CF_STATIONTIMESERIES2KMLOVERVIEW

%% Initialize

  %urlbase = 'p:\mcdata\opendap\';              % @ deltares internally
  %urlbase = 'http://dtvirt5.deltares.nl:8080'; % test server
   urlbase = 'http://opendap.deltares.nl:8080'; % production server
   locbase = 'P:\mcdata';                       % @ deltares internally
   
%% define parameters over which to loop
%  make sure this list correspnds with the definition inside rws_waterbase_get_url_loop    
%  make sure this list correspnds with the definition inside rws_waterbase2nc    

subdirs = {'concentration_of_chlorophyll_in_sea_water',...
           'concentration_of_suspended_matter_in_sea_water',...
           'sea_surface_height',...
           'sea_surface_salinity',...
           'sea_surface_temperature',...
           'sea_surface_wave_from_direction',...
           'sea_surface_wave_significant_height',...
           'sea_surface_wind_wave_mean_period_from_variance_spectral_density_second_frequency_moment',...
           'water_volume_transport_into_sea_water_from_rivers'};

for ii= 1:length(subdirs)   
       
      subdir            = subdirs{ii};
      OPT.directory_nc  = [locbase,         '\opendap\rijkswaterstaat\waterbase\'      ,filesep,subdir];
      OPT.directory_raw = [locbase,'\OpenEarthRawData\rijkswaterstaat\waterbase\cache\',filesep,subdir];
      
   
   %% Download from waterbase.nl
   %  make sure list above is synchronized with definition inside rws_waterbase_get_url_loop    
      rws_waterbase_get_url_loop('parameter'    ,ii,...
                                 'directory_raw',OPT.directory_raw);
   
   %% Make netCDF
   %  make sure list above is synchronized with definition inside rws_waterbase2nc    
   
      rws_waterbase2nc('parameter'    ,ii,...
                       'directory_nc' ,OPT.directory_nc,...
                       'directory_raw',OPT.directory_raw);

   %% Make overview png and xls
          
      nc_cf_stationtimeseries2meta('directory_nc'  ,[OPT.directory_nc],...
                                   'standard_names',{subdir});
   
   %% Make catalog.nc
   
      nc_cf_directory2catalog                      ([OPT.directory_nc])
   
   %% Make KML overview with links to netCDF on opendap.deltares.nl
      
      disp(['Processing ',num2str(ii),' / ',num2str(length(subdirs)),': ',subdirs{ii}])
      
      OPT2.fileName           = [OPT.directory_nc,'.kml'];
      OPT2.kmlName            =  ['rijkswaterstaat/waterbase/' subdir];
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
   