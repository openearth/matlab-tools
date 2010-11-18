function test_nc_adddim()

fprintf('Testing NC_ADDDIM ...\n' );

run_negative_tests;

test_mexnc_backend;
test_tmw_backend;



%--------------------------------------------------------------------------
function test_mexnc_backend()

fprintf('\tTesting mexnc backend ...\n');

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        run_nc3_tests;
        
    otherwise
        fprintf(['\t\tmexnc netcdf-3 tests filtered out where the MATLAB ' ...
            'version is greater than 2008a\n']);
end


%--------------------------------------------------------------------------
function test_tmw_backend()

fprintf('\tTesting native MATLAB backend ...\n');

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a'}
        fprintf(['\ttmw netcdf-3 tests filtered out where the MATLAB ' ...
            'version is less than 2008b\n']);
        
    otherwise
        run_nc3_tests
end


switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a','2008b','2009a','2009b','2010a'}
        fprintf(['\ttmw netcdf-4 tests filtered out where the MATLAB ' ...
            'version is less than 2010b\n']);
        
    otherwise
        run_nc4_tests;
end

%--------------------------------------------------------------------------
function run_nc3_tests()
fprintf('\t\tTesting netcdf3 ... ');

ncfile = 'foo.nc';
test_add_regular_dimension ( ncfile );                 
test_add_unlimited ( ncfile );                         
test_dimension_already_exists ( ncfile );  

fprintf('OK\n');

return




%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\t\tTesting netcdf4 ... ');
ncfile = 'foo4.nc';

test_add_unlimited_nc4_classic ( ncfile );             
test_dimension_already_exists_nc4_classic ( ncfile );  

fprintf('OK\n');

return






%--------------------------------------------------------------------------
function test_add_regular_dimension ( ncfile )

% test 7:  add a normal dimension
create_empty_file ( ncfile, nc_clobber_mode );
nc_adddim ( ncfile, 't', 5 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 5 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 0  )
	error ( '%s:  nc_adddim incorrectly classified the dimension', mfilename  );
end

return


















%--------------------------------------------------------------------------
function test_add_unlimited ( ncfile )
% test 8:  add an unlimited dimension
create_empty_file ( ncfile, nc_clobber_mode );
nc_adddim ( ncfile, 't', 0 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 0 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 1  )
	error ( '%s:  nc_adddim incorrectly classified the dimension', mfilename  );
end

return











%--------------------------------------------------------------------------
function test_add_unlimited_nc4_classic ( ncfile )
% Add a dimension to a netcdf-4 classic file

nc_create_empty ( ncfile, nc_netcdf4_classic );
nc_adddim ( ncfile, 't', 0 );

%
% Now check that the new dimension are there.
d = nc_getdiminfo ( ncfile, 't' );
if ( ~strcmp(d.Name,'t') )
	error ( '%s:  nc_adddim failed on fixed dimension add name', mfilename  );
end
if ( d.Length ~= 0 )
	error ( '%s:  nc_adddim failed on fixed dimension add length', mfilename  );
end
if ( d.Unlimited ~= 1  )
	error ( '%s:  nc_adddim incorrectly classified the dimension', mfilename  );
end

% make sure it is hdf5
fid = fopen(ncfile,'r');
x = fread(fid,4,'uint8=>char');
fclose(fid);

if ~strcmp(x(2:4)','HDF')
	error('Did not create a netcdf-4 file');
end
return










%--------------------------------------------------------------------------
function test_dimension_already_exists ( ncfile )

% test 9:  try to add a dimension that is already there
create_empty_file ( ncfile, nc_clobber_mode );
nc_adddim ( ncfile, 't', 0 );
try
	nc_adddim ( ncfile, 't', 0 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');







%--------------------------------------------------------------------------
function test_dimension_already_exists_nc4_classic ( ncfile )

nc_create_empty ( ncfile, nc_netcdf4_classic );
nc_adddim ( ncfile, 't', 0 );
try
	nc_adddim ( ncfile, 't', 0 );
catch %#ok<CTCH>
    return
end
error ( 'succeeded when it should have failed.');






%--------------------------------------------------------------------------
function run_negative_tests()
v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_adddim_neg;
end

