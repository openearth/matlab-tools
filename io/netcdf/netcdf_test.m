function OK =  netcdf_test
%NETCDF_TEST   integration tst for snctools + netcdf dependencies (java, mex, mathworks native netcdf library)
%
%See also: netcdf_settings, netcdf

disp('please be patient: testing 1000 times')

test_local_system % load opendap vars, save as local netcdf3, load it again & compare

test_opendap_local_system