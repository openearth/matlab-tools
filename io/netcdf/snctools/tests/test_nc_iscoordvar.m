function test_nc_iscoordvar()

fprintf('Testing NC_ISCOORDVAR...\n');

run_negative_tests;

test_mexnc_backend;
test_tmw_backend;
test_java_backend;



%--------------------------------------------------------------------------
function test_coordvar_java ()

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

bool = nc_iscoordvar(url,'xpos');
if ~bool
	error ( 'failed' );
end
return
%--------------------------------------------------------------------------
function run_negative_tests()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/empty.nc');

test_no_inputs;
test_only_one_input (ncfile);
test_too_many_inputs(ncfile);
test_not_netcdf_file;
test_empty_ncfile (ncfile);

ncfile = fullfile(testroot,'testdata/iscoordvar.nc');
test_variable_not_present (ncfile);
test_not_a_coordvar (ncfile);
test_var_has_2_dims (ncfile);
test_singleton_variable (ncfile);

%--------------------------------------------------------------------------
function test_java_backend()

fprintf('\tTesting java backend ...  ');

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
        
end

test_coordvar_java;
fprintf('OK\n');

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
function run_nc3_tests()

fprintf('\t\tRunning local netcdf-3 tests...');
testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/iscoordvar.nc');
test_coordvar(ncfile);
fprintf('OK\n');

return




%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\t\tRunning local netcdf-3 tests...');
testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/iscoordvar-4.nc');
test_coordvar(ncfile);
fprintf('OK\n');

return












%--------------------------------------------------------------------------
function test_no_inputs()
try
	nc_iscoordvar;
catch %#ok<CTCH>
    return
end
error('failed');





%--------------------------------------------------------------------------
function test_only_one_input ( ncfile )

try
	nc_iscoordvar ( ncfile );
catch %#ok<CTCH>
    return
end
error('failed');







%--------------------------------------------------------------------------
function test_too_many_inputs( ncfile )

try
	nc_iscoordvar ( ncfile, 'blah', 'blah2' );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_not_netcdf_file (  )

try
	nc_iscoordvar ( 'test_iscoordvar.m', 't' );
catch %#ok<CTCH>
    return
end
error('failed');








%--------------------------------------------------------------------------
function test_empty_ncfile ( ncfile )

try
	nc_iscoordvar ( ncfile, 't' );
catch %#ok<CTCH>
    return
end
error('failed');












%--------------------------------------------------------------------------
function test_variable_not_present( ncfile )

try
	nc_iscoordvar ( ncfile, 'y' );
catch %#ok<CTCH>
    return
end
error('failed');










%--------------------------------------------------------------------------
function test_not_a_coordvar ( ncfile )

% 2nd set of tests should succeed
% test 9:  given variable's dimension is not of the same name

b = nc_iscoordvar ( ncfile, 'u' );
if ( b ~= 0 )
	error('incorrect result.');
end
return






%--------------------------------------------------------------------------
function test_var_has_2_dims ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ( ~b )
	error ( 'incorrect result.\n' );
end
return







%--------------------------------------------------------------------------
function test_singleton_variable ( ncfile )

yn = nc_iscoordvar ( ncfile, 't' );
if ( yn )
	error ( 'incorrect result.\n'  );
end

return






%--------------------------------------------------------------------------
function test_coordvar ( ncfile )

b = nc_iscoordvar ( ncfile, 's' );
if ~b
	error ( 'incorrect result.\n'  );
end

return









