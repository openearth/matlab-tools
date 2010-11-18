function test_nc_dump ( )

fprintf('Testing NC_DUMP ...\n' );

% For now we will run this test preserving the fastest varying dimension.
oldpref = getpref('SNCTOOLS','PRESERVE_FVD');
setpref('SNCTOOLS','PRESERVE_FVD',true);

run_negative_tests;

test_mexnc_backend;
test_tmw_backend;
test_java_backend;


setpref('SNCTOOLS','PRESERVE_FVD',oldpref);

return



%--------------------------------------------------------------------------
function test_mexnc_backend()

fprintf('\tTesting mexnc backend ...\n');

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        test_netcdf3_files;
        
    otherwise
        fprintf(['\t\tmexnc netcdf-3 tests filtered out where the MATLAB ' ...
            'version is greater than 2008a\n']);
end


%--------------------------------------------------------------------------
function test_tmw_backend()

fprintf('\tTesting native MATLAB backend ...\n');
run_hdf4_tests;

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        fprintf(['\ttmw netcdf-3 tests filtered out where the MATLAB ' ...
            'version is less than 2008b\n']);
        
    otherwise
        test_netcdf3_files;
end


switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a','2008b','2009a','2009b','2010a'}
        fprintf(['\ttmw netcdf-4 tests filtered out where the MATLAB ' ...
            'version is less than 2010b\n']);
        
    otherwise
        test_netcdf4_files;
end

%--------------------------------------------------------------------------
function test_netcdf3_files()
fprintf('\t\tTesting netcdf-3 files ...');
test_nc3_file_with_one_dimension;
test_nc3_empty;
test_nc3_singleton;
test_nc3_unlimited_variable;
test_nc3_variable_attributes;
test_nc3_one_fixed_size_variable;
fprintf('OK\n');


%--------------------------------------------------------------------------
function test_netcdf4_files()
fprintf('\t\tTesting netcdf-4 files ...');
nc4file();
test_nc4_compressed;
fprintf('OK\n');

%--------------------------------------------------------------------------
function run_hdf4_tests()
fprintf('\t\tTesting HDF4 files ...');
dump_hdf4_example;
dump_hdf4_tp;
fprintf('OK\n');





%--------------------------------------------------------------------------
function dump_hdf4_tp()
% dumps my temperature pressure file
testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);
hdffile = fullfile(testroot,'testdata','temppres.hdf'); %#ok<NASGU>
act_data = evalc('nc_dump(hdffile);');
i1 = strfind(act_data,'{');

v = version('-release');
switch(v)
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a', '2008b', '2009a', '2009b' }
        
        i2 = strfind(d.hdf4.lt_r2010b.temppres,'{');
        if ~strcmp(d.hdf4.lt_r2010b.temppres(i2:end), act_data(i1:end))
            error('failed');
        end
        
    otherwise
        i2 = strfind(d.hdf4.ge_r2010b.temppres,'{');
        if ~strcmp(d.hdf4.ge_r2010b.temppres(i2:end), act_data(i1:end))
            error('failed');
        end
end



%-------------------------------------------------------------------------
function test_java_backend()

fprintf('\tTesting java backend ...\n');
if ~getpref('SNCTOOLS','USE_JAVA',false) || ~getpref('SNCTOOLS','TEST_REMOTE',false)
    fprintf('Java testing filtered out where SNCTOOLS preferences ');
    fprintf('set to false.\n');
    return
end


test_http_non_dods;
test_grib2;
test_opendap_url;
return






%--------------------------------------------------------------------------
function test_grib2()

fprintf('\t\tTesting grib2 files...  ');
if ~getpref('SNCTOOLS','TEST_GRIB2',false)
    fprintf('GRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('TEST_GRIB2 is set to false.\n');
    return
end

% Test a GRIB2 file.  Requires java as far as I know.
testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);
gribfile = fullfile(testroot,'testdata',...
    'ecmf_20070122_pf_regular_ll_pt_320_pv_grid_simple.grib2'); %#ok<NASGU>
act_data = evalc('nc_dump(gribfile);'); %#ok<NASGU>

% So long as it didn't error out, I'm cool with that.
fprintf('OK\n');
return






%--------------------------------------------------------------------------
function run_negative_tests()

negative_no_arguments;

%--------------------------------------------------------------------------
function negative_no_arguments ( )
% should fail if no input arguments are given.

try
	nc_dump;
catch %#ok<CTCH>
	return
end
error ( 'nc_dump succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_nc4_compressed()
owd = pwd;
testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);

ncfile = 'deflate9.nc';
load('nc_dump.mat');
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.nc4_compressed)
    cd(owd);
    error('failed');
end

cd(owd);

return



%--------------------------------------------------------------------------
function nc4file() 

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'tst_pres_temp_4D_netcdf4.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.nc4)
    cd(owd);
    error('failed');
end
cd(owd);

return



%--------------------------------------------------------------------------
function test_nc3_empty() 

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'empty.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.empty_file)
    cd(owd);
    error('failed');
end
cd(owd);

return








%--------------------------------------------------------------------------
function test_nc3_file_with_one_dimension()

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'just_one_dimension.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.one_dimension)
    cd(owd);
    error('failed');
end
cd(owd);
return



%--------------------------------------------------------------------------
function test_nc3_singleton()

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'full.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.singleton_variable)
    cd(owd);
    error('failed');
end
cd(owd);
return





%--------------------------------------------------------------------------
function test_nc3_unlimited_variable()

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'full.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.unlimited_variable)
    cd(owd);
    error('failed');
end
cd(owd);
return




%--------------------------------------------------------------------------
function test_nc3_variable_attributes()

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'full.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.variable_attributes)
    cd(owd);
    error('failed');
end
cd(owd);
return







%--------------------------------------------------------------------------
function test_nc3_one_fixed_size_variable()

owd = pwd;

testroot = fileparts(mfilename('fullpath'));
cd([testroot '/testdata']);
load('nc_dump.mat');

ncfile = 'just_one_fixed_size_variable.nc'; 
cmd = sprintf('nc_dump(''%s'')',ncfile);

act_data = evalc(cmd);
if ~strcmp(act_data,d.netcdf.one_fixed_size_variable)
    cd(owd);
    error('failed');
end
cd(owd);
return



%--------------------------------------------------------------------------
function dump_hdf4_example()
% dumps the example file that ships with matlab


testroot = fileparts(mfilename('fullpath'));
matfile = fullfile(testroot,'testdata','nc_dump.mat');
load(matfile);

act_data = evalc('nc_dump(''example.hdf'');');
i1 = strfind(act_data,'{');

v = version('-release');
switch(v)
    case { '14', '2006a', '2006b', '2007a', '2007b', '2008a', '2008b', '2009a', '2009b', '2010a' }
        
        i2 = strfind(d.hdf4.lt_r2010b.example,'{');
        if ~strcmp(d.hdf4.lt_r2010b.example(i2:end), act_data(i1:end))
            error('failed');
        end
        
    otherwise
        i2 = strfind(d.hdf4.ge_r2010b.example,'{');
        if ~strcmp(d.hdf4.ge_r2010b.example(i2:end), act_data(i1:end))
            error('failed');
        end
end





%--------------------------------------------------------------------------
function test_http_non_dods (  )
if (getpref ( 'SNCTOOLS', 'USE_JAVA', false)  && ...
        getpref ( 'SNCTOOLS', 'TEST_REMOTE', false)  )
    
    load('testdata/nc_dump.mat');
    
    url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
    fprintf('\t\tTesting remote URL access %s...  ', url );
    
    cmd = sprintf('nc_dump(''%s'')',url);
    act_data = evalc(cmd);
    if ~strcmp(act_data,d.opendap.http_non_dods)
        error('failed');
    end
       
    fprintf('OK\n');
end






%--------------------------------------------------------------------------
function test_opendap_url (  )
if getpref('SNCTOOLS','TEST_REMOTE',false) && ...
        getpref ( 'SNCTOOLS', 'TEST_OPENDAP', false ) 
    
    load('testdata/nc_dump.mat');
    % use data of today as the server has a clean up policy
    today = datestr(floor(now),'yyyymmdd');
    url = ['http://motherlode.ucar.edu:8080/thredds/dodsC/satellite/CTP/SUPER-NATIONAL_1km/current/SUPER-NATIONAL_1km_CTP_',today,'_0000.gini'];
	fprintf('\t\tTesting remote DODS access %s...  ', url );
    
    cmd = sprintf('nc_dump(''%s'')',url);
    act_data = evalc(cmd);
    
    if ~strcmp(act_data,d.opendap.unidata_motherlode)
        error('failed');
    end
    fprintf('OK\n');
else
	fprintf('Not testing NC_DUMP on OPeNDAP URLs.  Read the README for details.\n');	
end
return




