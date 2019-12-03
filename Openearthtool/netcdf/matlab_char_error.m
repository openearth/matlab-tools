%ncread in Matlab chops characters at length 64 for all nc modes
%
% netcdf matlab-ncread-error-classic-65 {
% dimensions:
% 	dimension_length_1 = 1 ;
% 	dimension_length_65 = 65 ;
% variables:
% 	char str(dimension_length_1, dimension_length_65) ;
% data:
% 
%  str =
%   "01234567890123456789012345678901234567890123456789012345678901234" ;
% }

D.str= '01234567890123456789012345678901234567890123456789012345678901234';

f1 ='matlab-ncread-error-classic-65.nc'        ;
f2 ='matlab-ncread-error-64bit-offset-65.nc'   ;
f3 ='matlab-ncread-error-netcdf4-classic-65.nc';
f4 ='matlab-ncread-error-netcdf4-65.nc'        ;

struct2nc(D,f1,'mode','clobber')
struct2nc(D,f2,'mode','64bit_offset')
struct2nc(D,f3,'mode','netcdf4-classic')
struct2nc(D,f4,'mode','netcdf4' )

%%
setpref('SNCTOOLS','USE_NETCDF_JAVA',0)
ncread   ([f1],'str')'
ncread   (['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f1],'str')'
ncread   (['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f2],'str')'
ncread   (['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f3],'str')'
ncread   (['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f4],'str')'
setpref('SNCTOOLS','USE_NETCDF_JAVA',1)
nc_varget(['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f1],'str')
nc_varget(['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f2],'str')
nc_varget(['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f3],'str')
nc_varget(['http://opendap.deltares.nl/thredds/dodsC/opendap/test/',f4],'str')

%%
setpref('SNCTOOLS','USE_NETCDF_JAVA',0)
ncread   (['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f1],'str')'
ncread   (['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f2],'str')'
ncread   (['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f3],'str')'
ncread   (['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f4],'str')'
setpref('SNCTOOLS','USE_NETCDF_JAVA',1)
nc_varget(['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f1],'str')
nc_varget(['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f2],'str')
nc_varget(['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f3],'str')
nc_varget(['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/test/',f4],'str')
