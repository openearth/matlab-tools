function test_nc_addrecs()
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


fprintf ('Testing NC_ADDRECS... \n' );

run_negative_tests;
run_positive_tests;

return










%--------------------------------------------------------------------------
function run_positive_tests()

run_nc3_tests;

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a','2008b','2009a','2009b','2010a'}
        fprintf(['\ttmw netcdf-4 tests filtered out where the MATLAB ' ...
            'version is less than 2010b\n']);
        
    otherwise
        run_nc4_tests;
end


return

%--------------------------------------------------------------------------
function run_nc3_tests()
fprintf('\tRunning netcdf-3 tests...  ');
ncfile = 'foo.nc';
create_ncfile(ncfile);
test_2_inputs_2_vars ( ncfile );
test_2_successive_writes( ncfile );
fprintf('OK\n');

%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\tRunning netcdf-4 tests...  ');
ncfile = 'foo.nc';
create_ncfile(ncfile,true);
test_2_inputs_2_vars ( ncfile );
test_2_successive_writes( ncfile );
fprintf('OK\n');


%--------------------------------------------------------------------------
function run_negative_tests()
% Negative testing?
v = version('-release');
switch(v)
	case { '14', '2006a', '2006b'}
		fprintf('version %s, no negative testing ...',v);
	otherwise
		test_nc_addrecs_neg;
end


%--------------------------------------------------------------------------
function test_2_inputs_2_vars ( ncfile )



% Try a good test.
before = nc_getvarinfo ( ncfile, 'test_var2' );

input_buffer.test_var = single([3 4 5]');
input_buffer.test_var2 = [3 4 5]';

nc_addrecs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'test_var2' );
if ( (after.Size - before.Size) ~= 3 )
    error ( 'nc_addrecs failed to add the right number of records.');
end


return



















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
nc_addrecs ( ncfile, input_buffer );
nc_addrecs ( ncfile, input_buffer );

after = nc_getvarinfo ( ncfile, 'test_var2' );
if ( (after.Size - before.Size) ~= 6 )
    error ( '%s:  nc_addrecs failed to add the right number of records.', mfilename );
end
return











%--------------------------------------------------------------------------
function create_ncfile(ncfile,use_nc4)

if (nargin > 1) && use_nc4
    mode = bitor(netcdf.getConstant('CLASSIC_MODEL'),netcdf.getConstant('NETCDF4'));
    ncid = netcdf.create(ncfile,mode);
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





