function test_nc_info ( )



fprintf('Testing NC_INFO ...\n' );

run_negative_tests;

test_mexnc_backend;
test_tmw_backend;
test_java_backend;

return


%--------------------------------------------------------------------------
function run_negative_tests()

test_noInputs;
test_tooManyInputs;
test_fileNotNetcdf;


%--------------------------------------------------------------------------
function test_java_backend()

fprintf('\tTesting java backend ...\n');

if ~getpref('SNCTOOLS','USE_JAVA',false)

    fprintf('\t\tjava backend testing filtered out on ');
    fprintf('configurations where SNCTOOLS ''USE_JAVA'' ');
    fprintf('prefererence is false.\n');
    return
end

run_http_tests;

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
        
end


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
function run_http_tests()

fprintf ('\t\tRunning http tests...  ' );
test_javaNcid;
fprintf('OK\n');


%--------------------------------------------------------------------------
function run_nc3_tests()
fprintf ('\t\trunning local netcdf-3 tests...  ' );


testroot = fileparts(mfilename('fullpath'));

ncfile = [testroot '/testdata/empty.nc'];
test_emptyNetcdfFile(ncfile);

ncfile = [testroot '/testdata/just_one_dimension.nc'];
test_dimsButNoVars(ncfile);

ncfile = [testroot '/testdata/full.nc'];
test_smorgasborg(ncfile);
fprintf('OK\n');
return

%--------------------------------------------------------------------------
function run_nc4_tests()
fprintf ('\t\trunning netcdf-4 tests...  ' );


testroot = fileparts(mfilename('fullpath'));

ncfile = [testroot '/testdata/empty-4.nc'];
test_emptyNetcdfFile(ncfile);

ncfile = [testroot '/testdata/just_one_dimension-4.nc'];
test_dimsButNoVars(ncfile);

ncfile = [testroot '/testdata/full-4.nc'];
test_smorgasborg(ncfile);
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function test_javaNcid ()
import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://coast-enviro.er.usgs.gov/models/share/balop.nc';
jncid = NetcdfFile.open(url);
nc_info ( jncid );
close(jncid);
return



%--------------------------------------------------------------------------
function test_noInputs( )
try
	nc_info;
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.\n'  );





%--------------------------------------------------------------------------
function test_tooManyInputs()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot, 'testdata/empty.nc');
try
	nc_info ( ncfile, 'blah' );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_fileNotNetcdf()
ncfile = mfilename;
try
	nc_info ( ncfile );
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.' );







%--------------------------------------------------------------------------
function test_emptyNetcdfFile(ncfile)

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( ~isempty ( nc.Dimension ) )
	error( 'Dimension was wrong.');
end
if ( ~isempty ( nc.Dataset ) )
	error( 'Dataset was wrong.');
end
if ( ~isempty ( nc.Attribute ) )
	error('Attribute was wrong.');
end
return









%--------------------------------------------------------------------------
function test_dimsButNoVars(ncfile)

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( length ( nc.Dimension ) ~= 1 )
	error( 'Dimension was wrong.');
end
if ( ~isempty ( nc.Dataset ) )
	error( 'Dataset was wrong.');
end
if ( ~isempty ( nc.Attribute ) )
	error( 'Attribute was wrong.');
end
return










%--------------------------------------------------------------------------
function test_smorgasborg(ncfile)

nc = nc_info ( ncfile );
if ~strcmp ( nc.Filename, ncfile )
	error( 'Filename was wrong.');
end
if ( length ( nc.Dimension ) ~= 5 )
	error( 'Dimension was wrong.');
end
if ( length ( nc.Dataset ) ~= 6 )
	error( 'Dataset was wrong.');
end
if ( length ( nc.Attribute ) ~= 1 )
	error( 'Attribute was wrong.');
end
return






