function nc_cf_stationtimeseries2kmloverview_test
%NC_CF_STATIONTIMESERIES2KMLOVERVIEW_TEST tts for nc_cf_stationtimeseries2kmloverview
%
%See also: NC_CF_STATIONTIMESERIES2KMLOVERVIEW

clear OPT

OPT.fileName    = 'concentration_of_suspended_matter_in_sea_water.kml';
OPT.kmlName     = 'waterbase concentration_of_suspended_matter_in_sea_water';
OPT.THREDDSbase = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/';
OPT.HYRAXbase   = 'http://opendap.deltares.nl:8080/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/';
OPT.ftpbase     = 'http://opendap.deltares.nl:8080/thredds/fileServer/opendap/rijkswaterstaat/waterbase/concentration_of_suspended_matter_in_sea_water/';
OPT.description = 'source: <a href="http://www.waterbase.nl">Rijkswaterstaat</a>';

nc_cf_stationtimeseries2kmloverview('concentration_of_suspended_matter_in_sea_water.xls',OPT)