function test_nc_attget()

fprintf ('Testing NC_ATTGET...\n' );

run_negative_tests;

test_mexnc_backend;
test_tmw_backend;
test_java_backend;



%--------------------------------------------------------------------------
function test_java_backend()
fprintf('\tTesting java backend ...\n');

if ~getpref('SNCTOOLS','USE_JAVA',false)
    fprintf('\t\tjava backend testing filtered out on ');
    fprintf('configurations where SNCTOOLS ''USE_JAVA'' ');
    fprintf('prefererence is false.\n');
    return
end

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        % Only test if on win64
        c = computer;
        if strcmp(c,'PCWIN64')
            run_nc3_tests;
            run_nc4_tests;
        end
        
    case { '2008b', '2009a', '2009b', '2010a' }
        run_nc4_tests;
        
    otherwise
        fprintf('\t\tjava backend testing with local files filtered out on release %s\n', v);
end

run_http_tests;
run_grib2_tests;

%--------------------------------------------------------------------------
function test_mexnc_backend()

fprintf('\tTesting mexnc backend ...\n');
v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        run_nc3_tests;
        
    otherwise
        fprintf('\t\tmexnc testing filtered out on release %s.\n', v);
        return
end


return
%--------------------------------------------------------------------------
function test_tmw_backend()

fprintf('\tTesting tmw backend ...\n');

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        fprintf('\t\ttmw testing filtered out on release %s... ', v);
        return;
        
    case { '2008b','2009a','2009b','2010a'}
        run_nc3_tests;
        
    otherwise
        run_nc3_tests;
        run_nc4_tests;
end


return
%--------------------------------------------------------------------------
function run_negative_tests()
v = version('-release');
switch(v)
	case{'14','2006a','2006b','2007a'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_attget_neg;
end



%--------------------------------------------------------------------------
function run_grib2_tests()

if ~getpref('SNCTOOLS','TEST_GRIB2',false)
    fprintf('\tGRIB2 testing filtered out where SNCTOOLS preference ');
    fprintf('TEST_GRIB2 is set to false.\n');
    return
end

fprintf('\t\tRunning grib2 tests...  ');
testroot = fileparts(mfilename('fullpath'));
gribfile = fullfile(testroot,'testdata',...
    'ecmf_20070122_pf_regular_ll_pt_320_pv_grid_simple.grib2');
test_grib2_char(gribfile);
fprintf('OK\n');
return

%--------------------------------------------------------------------------
function test_grib2_char(gribfile)

act_data = nc_attget(gribfile,-1,'creator_name');
exp_data = 'ECMWF, RSMC subcenter = 0';
if ~strcmp(act_data,exp_data)
    error('failed'); 
end
return

%--------------------------------------------------------------------------
function run_nc3_tests()
fprintf('\t\tRunning netcdf-3 tests...  ');

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/attget.nc');

run_local_tests(ncfile);
fprintf('OK\n');
return



%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\t\tRunning netcdf4 tests...  ');
testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/attget-4.nc');

run_local_tests(ncfile);
ncfile = fullfile(testroot,'testdata/tst_group_data.nc');
test_nc4_group_char_att(ncfile)
test_nc4_group_var_char_att(ncfile);

fprintf('OK\n');
return










%--------------------------------------------------------------------------
function run_local_tests(ncfile)

test_retrieveDoubleAttribute ( ncfile );
test_retrieveFloatAttribute ( ncfile );
test_retrieveIntAttribute ( ncfile );
test_retrieveShortAttribute ( ncfile );
test_retrieveUint8Attribute ( ncfile );
test_retrieveInt8Attribute ( ncfile );
test_retrieveTextAttribute ( ncfile );

test_retrieveGlobalAttribute_empty ( ncfile );
test_writeRetrieveGlobalAttributeMinusOne ( ncfile );
test_writeRetrieveGlobalAttributeNcGlobal ( ncfile );
test_writeRetrieveGlobalAttributeGlobalName ( ncfile );


return;


%--------------------------------------------------------------------------
function run_http_tests()
% These tests are regular URLs, not OPeNDAP URLs.
if ~ ( getpref ( 'SNCTOOLS', 'TEST_REMOTE', false ) )
    fprintf('\t\tjava http testing filtered out when SNCTOOLS ');
    fprintf('''TEST_REMOTE'' preference is false.\n');
    return
end
fprintf('\t\tRunning http tests...  ');
test_retrieveAttribute_HTTP;
test_retrieveAttribute_http_jncid;
fprintf('OK\n');
return







%--------------------------------------------------------------------------
function test_retrieveAttribute_HTTP ()

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

w = nc_attget ( url, 'w', 'valid_range' );
if ~strcmp(class(w),'single')
	error ( 'Class of retrieve attribute was not single' );
end
if (abs(double(w(2)) - 0.5) > eps)
	error ( 'valid max did not match' );
end
if (abs(double(w(1)) + 0.5) > eps)
	error ( 'valid max did not match' );
end
return


%--------------------------------------------------------------------------
function test_retrieveAttribute_http_jncid ()

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';
jncid = NetcdfFile.open(url);
                           

w = nc_attget (jncid, 'w', 'valid_range' );
if ~strcmp(class(w),'single')
	error ( 'Class of retrieve attribute was not single' );
end
if (abs(double(w(2)) - 0.5) > eps)
	error ( 'valid max did not match' );
end
if (abs(double(w(1)) + 0.5) > eps)
	error ( 'valid max did not match' );
end
close(jncid);
return


%--------------------------------------------------------------------------
function test_retrieveIntAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_int_att' );
if ( ~strcmp(class(attvalue), 'int32' ) )
	error('class of retrieved attribute was not int32.');
end
if ( attvalue ~= int32(3) )
	error('retrieved attribute differs from what was written.');
end

return










%--------------------------------------------------------------------------
function test_retrieveShortAttribute ( ncfile )


attvalue = nc_attget ( ncfile, 'x_db', 'test_short_att' );
if ( ~strcmp(class(attvalue), 'int16' ) )
	error('class of retrieved attribute was not int16.');
end
if ( length(attvalue) ~= 2 )
	error('retrieved attribute length differs from what was written.');
end
if ( any(double(attvalue) - [5 7])  )
	error('retrieved attribute differs from what was written.');
end

return








%--------------------------------------------------------------------------
function test_retrieveUint8Attribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_uchar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	error('class of retrieved attribute was not int8.');
end
if ( uint8(attvalue) ~= uint8(100) )
	error('retrieved attribute differs from what was written.');
end

return




%--------------------------------------------------------------------------
function test_retrieveInt8Attribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_schar_att' );
if ( ~strcmp(class(attvalue), 'int8' ) )
	error('class of retrieved attribute was not int8.');
end
if ( attvalue ~= int8(-100) )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveTextAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_text_att' );
if ( ~ischar(attvalue ) )
	error('class of retrieved attribute was not char.');
end

if ( ~strcmp(attvalue,'abcdefghijklmnopqrstuvwxyz') )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveGlobalAttribute_empty ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseEmptyVarname' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseGlobalVarname' );

attvalue = nc_attget ( ncfile, '', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseEmptyVarname' );
warning ( 'off', 'SNCTOOLS:nc_attget:hdf5:doNotUseGlobalVarname' );

return





%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeMinusOne ( ncfile )

attvalue = nc_attget ( ncfile, -1, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return





%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeNcGlobal ( ncfile )

varid = netcdf.getConstant('NC_GLOBAL');
attvalue = nc_attget ( ncfile, varid, 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return 






%--------------------------------------------------------------------------
function test_writeRetrieveGlobalAttributeGlobalName ( ncfile )

warning ( 'off', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );
warning ( 'off', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );

attvalue = nc_attget ( ncfile, 'GLOBAL', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

warning ( 'on', 'SNCTOOLS:nc_attget:java:doNotUseGlobalString' );
warning ( 'on', 'SNCTOOLS:nc_attget:doNotUseGlobalString' );

return
















%--------------------------------------------------------------------------
function test_retrieveDoubleAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_double_att' );
if ( ~strcmp(class(attvalue), 'double' ) )
	error('class of retrieved attribute was not double.');
end
if ( attvalue ~= 3.14159 )
	error('retrieved attribute differs from what was written.');
end

return







%--------------------------------------------------------------------------
function test_retrieveFloatAttribute ( ncfile )

attvalue = nc_attget ( ncfile, 'x_db', 'test_float_att' );
if ( ~strcmp(class(attvalue), 'single' ) )
	error('class of retrieved attribute was not single.');
end
if ( abs(double(attvalue) - 3.14159) > 1e-6 )
	error('retrieved attribute differs from what was written.');
end

return

%--------------------------------------------------------------------------
function test_nc4_group_char_att(ncfile)

expData = 'in first group';
actData = nc_attget(ncfile,'/g1','title');

if ~strcmp(expData,actData)
    error('failed');
end

%--------------------------------------------------------------------------
function test_nc4_group_var_char_att(ncfile)

expData = 'km/hour';
actData = nc_attget(ncfile,'/g1/var','units');

if ~strcmp(expData,actData)
    error('failed');
end



