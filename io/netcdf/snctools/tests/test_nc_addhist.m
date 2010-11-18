function test_nc_addhist()

fprintf('Testing NC_ADDHIST... \n' );
run_negative_tests;
run_positive_tests;



%--------------------------------------------------------------------------
function run_positive_tests()

run_nc3_tests;

v = version('-release');
switch(v)
    case { '14','2006a','2006b','2007a','2007b','2008a','2008b','2009a','2009b','2010a'}
        % do nothing
    otherwise
        run_nc4_tests;
end


return


%--------------------------------------------------------------------------
function run_nc3_tests()

fprintf('\tTesting netcdf-3 ...  ');
ncfile = 'foo.nc';
test_add_global_history ( ncfile );          
test_add_global_history_twice ( ncfile ); 

fprintf('OK\n');

%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\tTesting netcdf-4 ...  ');
ncfile = 'foo4.nc';

test_add_global_history_nc4 ( ncfile );        
test_add_global_history_twice_nc4 ( ncfile ); 

fprintf('OK\n');


return



%--------------------------------------------------------------------------
function test_add_global_history ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
histblurb = 'blah';
nc_addhist ( ncfile, histblurb );

hista = nc_attget ( ncfile, nc_global, 'history' );
s = strfind(hista, histblurb );
if isempty(s)
	error('history attribute did not contain first attribution.');
end
return




%--------------------------------------------------------------------------
function test_add_global_history_nc4 ( ncfile )

nc_create_empty(ncfile,nc_netcdf4_classic);
histblurb = 'blah';
nc_addhist ( ncfile, histblurb );

hista = nc_attget ( ncfile, nc_global, 'history' );
s = strfind(hista, histblurb );
if isempty(s)
	error('history attribute did not contain first attribution.');
end

verify_netcdf4(ncfile);
return




%--------------------------------------------------------------------------
function test_add_global_history_twice ( ncfile )

create_empty_file ( ncfile, nc_clobber_mode );
histblurb = 'blah a';
nc_addhist ( ncfile, histblurb );
histblurb2 = 'blah b';
nc_addhist ( ncfile, histblurb2 );
histatt = nc_attget ( ncfile, nc_global, 'history' );
s = strfind(histatt, histblurb2 );
if isempty(s)
	error('history attribute did not contain second attribution');
end
return

%--------------------------------------------------------------------------
function test_add_global_history_twice_nc4 ( ncfile )

nc_create_empty(ncfile,nc_netcdf4_classic);
histblurb = 'blah a';
nc_addhist ( ncfile, histblurb );
histblurb2 = 'blah b';
nc_addhist ( ncfile, histblurb2 );
histatt = nc_attget ( ncfile, nc_global, 'history' );
s = strfind(histatt, histblurb2 );
if isempty(s)
	error('history attribute did not contain second attribution');
end
verify_netcdf4(ncfile);
return

%--------------------------------------------------------------------------
function run_negative_tests()

v = version('-release');
switch(v)
	case{'14','2006a','2006b'}
	    fprintf('\tSome negative tests filtered out on version %s.\n', v);
    otherwise
		test_nc_addhist_neg;
end
