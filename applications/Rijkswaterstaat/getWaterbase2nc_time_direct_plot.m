   clear all
   close all

   % load file from web via OpenDAP
   OPT.substance_code = 'id1';
   OPT.station_code   = 'DENHDR';
   outputfile         = ['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase.nl/sea_surface_height/',OPT.substance_code,'-',OPT.station_code,'-196101010000-200801010000_time_direct.nc'];
   
   [D,M]=nc_cf_stationTimeSeries(outputfile,'sea_surface_height')