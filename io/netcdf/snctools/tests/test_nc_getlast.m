function test_nc_getlast()

fprintf('Testing NC_GETLAST...\n');

test_mexnc_backend;
test_tmw_backend;
test_java_backend;

return


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
fprintf('\t\tRunning netcdf-3 tests...  ');
testroot = fileparts(mfilename('fullpath'));
emptyfile = fullfile(testroot,'testdata/empty.nc');
regfile = fullfile(testroot,'testdata/getlast.nc');
run_all_tests(emptyfile,regfile);
fprintf('OK\n');
return

%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\t\tRunning netcdf-4 tests...  ');
testroot = fileparts(mfilename('fullpath'));
emptyfile = fullfile(testroot,'testdata/empty-4.nc');
regfile = fullfile(testroot,'testdata/getlast-4.nc');
run_all_tests(emptyfile,regfile);
fprintf('OK\n');
return



%--------------------------------------------------------------------------
function run_all_tests(emptyfile,regfile)
% This first set of tests should all fail.
% Test:  No inputs.
% Test:  Too few inputs (one).
% Test:  Too many inputs (4).
% Test:  1st input is not character.
% Test:  2nd input is not character.
% Test:  3rd input is not numeric.
% Test:  1st input is not a netcdf file.
% Test:  2nd input is not a netcdf variable.
% Test:  2nd input is a netcdf variable, but not unlimited.
% Test:  Non-positive "num_records"
% Test:  Time series variables have data, but fewer than what was 
%           requested.
%
% This second set of tests should all succeed.
% Test:  Two inputs, should return the last record.
% Test:  Three valid inputs.
% Test:  Get everything

test_no_inputs;
test_too_few_inputs(emptyfile);
test_too_many_inputs(emptyfile);
test_first_input_not_char;
test_2nd_input_not_char(emptyfile);
test_3rd_input_not_numeric(emptyfile);
test_1st_input_not_netcdf;
test_2nd_input_not_netcdf_variable(emptyfile);
test_var_not_unlimited(regfile);
test_nonpositive_records(regfile);
test_too_few_records(regfile);

test_last_record(regfile);
test_last_few_records(regfile);
test_get_everything(regfile);

return




%--------------------------------------------------------------------------
function test_no_inputs (  )

try
	nc_getlast;
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');








%--------------------------------------------------------------------------
function test_too_few_inputs ( ncfile )

try
	nc_getlast ( ncfile );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_too_many_inputs ( ncfile )

try
	nc_getlast ( ncfile, 't1', 3, 4 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_first_input_not_char (  )

try
	nc_getlast ( 0, 't1' );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.\n');





%--------------------------------------------------------------------------
function test_2nd_input_not_char ( ncfile )

try
	nc_getlast ( ncfile, 0 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_3rd_input_not_numeric ( ncfile )

try
	nc_getlast ( ncfile, 't1', 'a' );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_1st_input_not_netcdf ( )

try
	nc_getlast ( 'test_nc_getlast.m', 't1', 1 );
catch %#ok<CTCH>
    return
end

error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_2nd_input_not_netcdf_variable ( ncfile )

try
	nc_getlast ( ncfile, 't4', 1 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');





%--------------------------------------------------------------------------
function test_var_not_unlimited ( ncfile )

try
	nc_getlast ( ncfile, 'x', 1 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_nonpositive_records( ncfile )

try
	nc_getlast ( ncfile, 't1', 0 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_too_few_records ( ncfile )


try
	nc_getlast ( ncfile, 't1', 12 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');








%--------------------------------------------------------------------------
function test_last_record ( ncfile )

v = nc_getlast ( ncfile, 't1' );
if ( length(v) ~= 1 )
	error ( 'return value length was wrong' );
end
return




%--------------------------------------------------------------------------
function test_last_few_records ( ncfile )
v = nc_getlast ( ncfile, 't1', 7 );
if ( length(v) ~= 7 )
	error('return value length was wrong.');
end
return



%--------------------------------------------------------------------------
function test_get_everything ( ncfile )

v = nc_getlast ( ncfile, 't1', 10 );
if ( length(v) ~= 10 )
	error('return value length was wrong.');
end
return


