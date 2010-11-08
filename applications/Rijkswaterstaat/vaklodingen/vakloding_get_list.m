function vakloding_get_list(url,varargin)
%VAKLODING_GET_LIST  list of all kaartbladen and all times from opendap server
%
%    vakloding_get_list(url,<keyword,value>)
%
% Example: for OpenEarth test and production server
%
% RWS Jarkus Grids: production
%    vakloding_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/jarkus/grids/catalog.html')
%
% RWS Vaklodingen: production and test
%    vakloding_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%    vakloding_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml')
%
% RWS Kustlidar: production and test
%    vakloding_get_list('http://dtvirt5.deltares.nl:8080/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%    vakloding_get_list('http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/kustlidar/catalog.html')
%
% A local netCDF gridset:
%    vakloding_get_list(pwd)
%
%See also: grid_2D_orthogonal, opendap_catalog, rijkswaterstaat

   url      = 'http://opendap.deltares.nl/thredds/catalog/opendap/rijkswaterstaat/vaklodingen/catalog.xml';

   url      = 'F:\opendap\thredds\rijkswaterstaat\vaklodingen\';
   xls      = 'F:\opendap\thredds\rijkswaterstaat\vaklodingen\vaklodingen.xls';

   nc_cf_gridset_get_list(url,'xlsname',xls)