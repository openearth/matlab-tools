function test_nc_create_empty()
% Test:  No mode given
% Test:  64-bit mode
% Test:  create a netcdf-4 file
% test_char_mode:  the mode is a string instead of numeric

fprintf('Testing NC_CREATE_EMPTY...  ' );

negative_testing;

test_mexnc_backend;
test_tmw_backend;

return


%--------------------------------------------------------------------------
function run_nc3_tests()
fprintf('\t\tTesting netcdf-3 ...  ');

ncfile = 'foo.nc';
test_no_mode_given(ncfile);
test_64bit_mode(ncfile);
test_char_mode(ncfile);

fprintf('OK\n');

%--------------------------------------------------------------------------
function run_nc4_tests()
fprintf('\t\tTesting netcdf-4 ...  ');

ncfile = 'foo4.nc';
test_netcdf4_classic(ncfile);

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
function negative_testing()

test_no_args;


%--------------------------------------------------------------------------
function test_netcdf4_classic ( ncfile )

if ~netcdf4_capable
	fprintf('\tmexnc (netcdf-4) backend testing filtered out on configurations where the library version < 4.\n');
	return
end


delete(ncfile);
nc_create_empty(ncfile,nc_netcdf4_classic);
fid = fopen(ncfile,'r');
x = fread(fid,4,'uint8=>char');
fclose(fid);

if ~strcmp(x(2:4)','HDF')
	error('Did not create a netcdf-4 file');
end
return








%--------------------------------------------------------------------------
function test_no_args ( )

try
	nc_create_empty;
	error( 'succeeded when it should have failed');
catch %#ok<CTCH>
    return
end

return







%--------------------------------------------------------------------------
function test_no_mode_given ( ncfile )

nc_create_empty ( ncfile );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return






%--------------------------------------------------------------------------
function test_64bit_mode ( ncfile )

mode = bitor ( nc_clobber_mode, nc_64bit_offset_mode );

nc_create_empty ( ncfile, mode );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return



%--------------------------------------------------------------------------
function test_char_mode ( ncfile )

mode = 'clobber';

nc_create_empty ( ncfile, mode );
md = nc_info ( ncfile );

if ~isempty(md.Dataset)
	error('number of variables was not zero');
end

if ~isempty(md.Attribute)
	error('number of global attributes was not zero');
end

if ~isempty(md.Dimension)
	error('number of dimensions was not zero');
end

return


