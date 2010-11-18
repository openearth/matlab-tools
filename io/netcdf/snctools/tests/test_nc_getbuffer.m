function test_nc_getbuffer ( )
% TEST_NC_GETBUFFER
%
% Relies upon nc_addvar, nc_addnewrecs, nc_add_dimension
%
% test 1:  no input arguments, should fail
% test 2:  2 inputs, 2nd is not a cell array, should fail
% test 3:  3 inputs, 2nd and 3rd are not numbers, should fail
% test 4:  4 inputs, 2nd is not a cell array, should fail
% test 5:  4 inputs, 3rd and 4th are not numbers, should fail
% test 6:  1 input, 1st is not a file, should fail.
% test 7:  5 inputs, should fail
% test 8:  1 input, an empty netcdf with no variables, should fail
%          because no record variable was found
%
% test 9:  1 input, 5 record variables. Should succeed.
% test 10:  2 inputs, same netcdf file as 9.  Restrict output to two
%           of the variables.  Should succeed.
% test 11:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range, which is given as valid.
% test 12:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  Start is negative number.  Result 
%           should be the last few "count" records.
% test 13:  3 inputs, same netcdf file as 9.  Restrict output to given
%           start:start+count range.  count is negative number.  Result 
%           should be everything from start to "end - count"
% test 14:  4 inputs.  Otherwise the same as test 11.

fprintf('Testing NC_GETBUFFER ...\n');

run_netcdf3_tests;
run_netcdf4_tests;

%--------------------------------------------------------------------------
function run_netcdf3_tests()

fprintf('\tTesting netcdf-3 ...  ');
testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot, 'testdata/empty.nc'   );
run_negative_tests(ncfile);

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot, 'testdata/getlast.nc' );
run_positive_tests(ncfile);

fprintf('OK\n');


%--------------------------------------------------------------------------
function run_netcdf4_tests()

fprintf('\tTesting netcdf-4 ...  ');
v = version('-release');
switch(v)
    case {'14','2006a','2006b','2007a','2007b','2008a','2008b','2009a','2009b','2010a'}
        if ~getpref('SNCTOOLS','USE_JAVA',false)
            fprintf(['\n\t\tFiltering out netcdf-4 testing on release %s '...
                'when SNCTOOLS preference USE_JAVA is set to false.'], v);
            return;
        end
end

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot, 'testdata/empty-4.nc'   );
run_negative_tests(ncfile);

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot, 'testdata/getlast-4.nc' );
run_positive_tests(ncfile);

fprintf('OK\n');

%--------------------------------------------------------------------------
function run_negative_tests(ncfile)

test_no_inputs;
test_2nd_input_not_cell_array(ncfile);
test_3_inputs_2nd_and_3rd_not_numeric(ncfile);
test_4_inputs_2nd_not_cell_array(ncfile);

test_4_inputs_3rd_and_4th_not_numeric(ncfile);
test_1_input_not_a_file;
test_too_many_inputs(ncfile);
test_1_input_no_record_variable(ncfile);

return;

%--------------------------------------------------------------------------
function run_positive_tests(ncfile)



test_5_record_variables  (ncfile);
test_restrict_to_2_vars  (ncfile);
test_start_and_count     (ncfile);
test_negative_start_count(ncfile);
test_start_negative_count(ncfile);
test_varlist_start_neg_count (ncfile);

return







%--------------------------------------------------------------------------
function test_no_inputs (  )
try
    nc_getbuffer;
catch %#ok<CTCH>
    return
end
error('failed');






%--------------------------------------------------------------------------
function test_2nd_input_not_cell_array ( ncfile )
try
    nc_getbuffer ( ncfile, 1 );
catch %#ok<CTCH>
    return
end
error('failed');






%--------------------------------------------------------------------------
function test_3_inputs_2nd_and_3rd_not_numeric ( ncfile )
try
    nc_getbuffer ( ncfile, 'a', 'b' );
catch %#ok<CTCH>
    return
end
error('failed');







%--------------------------------------------------------------------------
function test_4_inputs_2nd_not_cell_array ( ncfile )
try
    nc_getbuffer ( ncfile, 1, 1, 2 );
catch %#ok<CTCH>
    return
end
error('failed');

  





%--------------------------------------------------------------------------
function test_4_inputs_3rd_and_4th_not_numeric ( ncfile )
try
    nc_getbuffer ( ncfile, cell(1), 'a', 'b' );
catch %#ok<CTCH>
    return
end
error('failed');






%--------------------------------------------------------------------------
function test_1_input_not_a_file (  )
try
    nc_getbuffer ( 5 );
catch %#ok<CTCH>
    return
end
error('fail');






%--------------------------------------------------------------------------
function test_too_many_inputs ( ncfile )
try
    nc_getbuffer ( ncfile, cell(1), 3, 4, 5 );
catch %#ok<CTCH>
    return
end
error('fail');






%--------------------------------------------------------------------------
function test_1_input_no_record_variable ( ncfile )
try
    nc_getbuffer ( ncfile );
catch %#ok<CTCH>
    return
end
error('fail');





%--------------------------------------------------------------------------
function test_5_record_variables ( ncfile )

nb = nc_getbuffer ( ncfile );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    error('failed');
end
for j = 1:4
    fname = f{j};
    d = nb.(fname);
    if ( size(d,1) ~= 10 )
        error ( 'length of field %s in the output buffer was not 10.');
    end
end
return




%--------------------------------------------------------------------------
function test_restrict_to_2_vars ( ncfile )

nb = nc_getbuffer ( ncfile, {'t1', 't2'} );

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
    error('output buffer did not have 2 fields.');
end
for j = 1:2
    fname = f{j};
    d = nb.(fname);
    if ( length(d) ~= 10 )
        error('length of field %s in the output buffer was not 10.');
    end
end
return






%--------------------------------------------------------------------------
function test_start_and_count ( ncfile )


nb = nc_getbuffer ( ncfile, 5, 3 );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    error('output buffer did not have 5 fields.');
end


for j = 1:n
    fname = f{j};
    d = nb.(fname);
    if getpref('SNCTOOLS','PRESERVE_FVD',false) ...
            && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 3 )
        error('length of field %s in the output buffer was not 10.',fname);
    end
end

%
% t1 should be [5 6 7]
if any ( nb.t1 - [5 6 7]' )
    error( 't1 was not what we thought it should be.');
end
return







%--------------------------------------------------------------------------
function test_negative_start_count ( ncfile )

nb = nc_getbuffer ( ncfile, -1, 3 );

%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    error('output buffer did not have 4 fields.');
end
for j = 1:n
    fname = f{j};
    d = nb.(fname);
    if getpref('SNCTOOLS','PRESERVE_FVD',false) ...
            && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 3 )
        error('length of field %s in the output buffer was not 10.',fname);
    end
end

%
% t1 should be [7 8 9]
if any ( nb.t1 - [7 8 9]' )
    error('t1 was not what we thought it should be.');
end
return







%--------------------------------------------------------------------------
function test_start_negative_count ( ncfile )

nb = nc_getbuffer ( ncfile, 5, -1 );
%
% should have 5 fields
f = fieldnames(nb);
n = length(f);
if n ~= 5
    error('output buffer did not have 4 fields.');
end
for j = 1:n
    fname = f{j};
    d = nb.(fname);
    if getpref('SNCTOOLS','PRESERVE_FVD',false) ...
            && (ndims(d) > 1) && (size(d,ndims(d)) > 1)
        sz = size(d,ndims(d));
    else
        sz = size(d,1);
    end
    if ( sz ~= 5 )
        error('length of field %s in the output buffer was not 5.',fname);
    end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
    error('t1 was not what we thought it should be' );
end
return







%--------------------------------------------------------------------------
function test_varlist_start_neg_count( ncfile )

nb = nc_getbuffer ( ncfile, {'t1', 't2' }, 5, -1 );

%
% should have 2 fields
f = fieldnames(nb);
n = length(f);
if n ~= 2
    error('output buffer did not have 2 fields.');
end
for j = 1:n
    fname = f{j};
    d = nb.(fname);
    if ( size(d,1) ~= 5 )
        error('length of field %s in the output buffer was not 10', fname);
    end
end

%
% t1 should be [5 6 7 8 9]
if any ( nb.t1 - [5 6 7 8 9]' )
    error('t1 was not what we thought it should be.');
end
return




