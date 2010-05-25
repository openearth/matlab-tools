function test_nc_add_recs ( ncfile )
% TEST_NC_ADD_RECS
%
% Relies upon nc_getvarino, nc_addvar
%
% Test run include
%    No inputs, should fail.
%    One inputs, should fail.
%    Two inputs, 2nd is not a structure, should fail.
%    Two inputs, 2nd is an empty structure, should fail.
%    Two inputs, 2nd is a structure with bad variable names, should fail.
%    Three inputs, 3rd is non existant unlimited dimension.
%    Two inputs, write to two variables, should succeed.
%    Two inputs, write to two variables, one of them not unlimited, should fail.
%    Try to write to a file with no unlimited dimension.
%    Do two successive writes.


fprintf ( 1, 'NC_ADD_RECS:  starting test suite...\n' );


if nargin == 0
	ncfile = 'foo.nc';
end

create_ncfile ( ncfile )

% negative tests
test_no_inputs;
test_only_one_input ( ncfile );
test_2nd_input_not_structure ( ncfile );
test_2nd_input_is_empty_structure ( ncfile );
test_2nd_input_has_bad_fieldnames ( ncfile );
test_one_field_not_unlimited ( ncfile );
test_no_unlimited_dimension ( ncfile );

create_ncfile(ncfile);
test_2_inputs_2_vars ( ncfile );
test_2_successive_writes( ncfile );

return





%--------------------------------------------------------------------------
function create_ncfile ( ncfile )

if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );

    len_t = 0;
    netcdf.defDim(ncid, 'time', len_t );

    netcdf.close(ncid);
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        error ( mexnc ( 'strerror', status ) );
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        error( mexnc ( 'strerror', status ) );
    end
    
    
    len_t = 0;
    [ydimid, status] = mexnc ( 'def_dim', ncid, 'time', len_t ); %#ok<ASGLU>
    if ( status ~= 0 )
        error( mexnc ( 'strerror', status ) );
    end
    
    
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end


%
% Add a variable along the time dimension
varstruct.Name = 'test_var';
varstruct.Nctype = 'float';
varstruct.Dimension = { 'time' };
varstruct.Attribute(1).Name = 'long_name';
varstruct.Attribute(1).Value = 'This is a test';
varstruct.Attribute(2).Name = 'short_val';
varstruct.Attribute(2).Value = int16(5);

nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'test_var2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };

nc_addvar ( ncfile, varstruct );



clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );

return





function test_no_inputs (  )

% Try no inputs
try
    nc_add_recs;
catch %#ok<CTCH>
    return
end
error ( 'succeeded on no inputs, should have failed' );








function test_only_one_input ( ncfile )
%
% Try one input, should fail
try
    nc_add_recs ( ncfile );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs succeeded on one input, should have failed');









function test_2nd_input_not_structure ( ncfile )


% Try with 2nd input that isn't a structure.
try
    nc_add_recs ( ncfile, [] );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs succeeded on one input, should have failed');












function test_2nd_input_is_empty_structure ( ncfile )

%
% Try with 2nd input that is an empty structure.
try
    nc_add_recs ( ncfile, struct([]) );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs succeeded on empty structure, should have failed');










function test_2nd_input_has_bad_fieldnames ( ncfile )

%
% Try a structure with bad names
input_data.a = [3 4];
input_data.b = [5 6];
try
    nc_add_recs ( ncfile, input_data );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs succeeded on a structure with bad names, should have failed');








function test_2_inputs_2_vars ( ncfile )



% Try a good test.
before = nc_getvarinfo ( ncfile, 'test_var2' );

input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';

nc_add_recs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'test_var2' );
if ( (after.Size - before.Size) ~= 3 )
    error ( 'nc_add_recs failed to add the right number of records.');
end


return











function test_one_field_not_unlimited ( ncfile )

% Try writing to a fixed size variable

input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';
input_buffer.test_var3 = [3 4 5]';

try
    nc_add_recs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs succeeded on writing to a fixed size variable, should have failed.');








function test_no_unlimited_dimension ( ncfile )


if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );

    netcdf.close(ncid);
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error( ncerr_msg );
    end
    
    
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end


clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


input_buffer.time = [1 2 3]';
try
    nc_add_recs ( ncfile, input_buffer );
catch %#ok<CTCH>
    return
end
error ( 'nc_add_recs passed when writing to a file with no unlimited dimension');










function test_2_successive_writes ( ncfile )

if snctools_use_tmw
    ncid = netcdf.create(ncfile, nc_clobber_mode );
    %
    % Create a fixed dimension.  
    len_x = 4;
    netcdf.defDim(ncid, 'x', len_x );

    len_t = 0;
    netcdf.defDim(ncid, 'time', len_t );

    netcdf.close(ncid);
else
    %
    % ok, first create this baby.
    [ncid, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error ( ncerr_msg );
    end
    
    
    %
    % Create a fixed dimension.  
    len_x = 4;
    [xdimid, status] = mexnc ( 'def_dim', ncid, 'x', len_x ); %#ok<ASGLU>
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error ( ncerr_msg );
    end
    
    
    len_t = 0;
    [ydimid, status] = mexnc ( 'def_dim', ncid, 'time', len_t ); %#ok<ASGLU>
    if ( status ~= 0 )
        ncerr_msg = mexnc ( 'strerror', status );
        error ( ncerr_msg );
    end
    
    
    
    
    
    %
    % CLOSE
    status = mexnc ( 'close', ncid );
    if ( status ~= 0 )
        error ( 'CLOSE failed' );
    end
end
%
% Add a variable along the time dimension
varstruct.Name = 'test_var';
varstruct.Nctype = 'float';
varstruct.Dimension = { 'time' };
varstruct.Attribute(1).Name = 'long_name';
varstruct.Attribute(1).Value = 'This is a test';
varstruct.Attribute(2).Name = 'short_val';
varstruct.Attribute(2).Value = int16(5);

nc_addvar ( ncfile, varstruct );

clear varstruct;
varstruct.Name = 'test_var2';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'time' };

nc_addvar ( ncfile, varstruct );



clear varstruct;
varstruct.Name = 'test_var3';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


before = nc_getvarinfo ( ncfile, 'test_var2' );
clear input_buffer;
input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';
nc_add_recs ( ncfile, input_buffer );
nc_add_recs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'test_var2' );
if ( (after.Size - before.Size) ~= 6 )
    error ( '%s:  nc_add_recs failed to add the right number of records.', mfilename );
end
return











