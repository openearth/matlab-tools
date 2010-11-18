function test_nc_getdiminfo()



fprintf('Testing NC_GETDIMINFO ...\n' );

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

%run_http_tests;
%run_grib2_tests;

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
fprintf('\t\tRunning local netcdf-3 tests...  ');
testroot = fileparts(mfilename('fullpath'));
empty_ncfile = fullfile(testroot, 'testdata/empty.nc');
full_ncfile  = fullfile(testroot, 'testdata/full.nc' );
test_local(empty_ncfile, full_ncfile);
fprintf('OK\n');
return


%--------------------------------------------------------------------------
function run_nc4_tests()

fprintf('\t\tRunning local netcdf-4 tests...  ');
testroot = fileparts(mfilename('fullpath'));
empty_ncfile = fullfile(testroot, 'testdata/empty-4.nc');
full_ncfile  = fullfile(testroot, 'testdata/full-4.nc' );
test_local(empty_ncfile, full_ncfile);
fprintf('OK\n');
return










%--------------------------------------------------------------------------
function test_local (empty_ncfile, full_ncfile )

test_unlimited ( full_ncfile );
test_limited ( full_ncfile );

test_neg_noArgs                                  ;
test_neg_onlyOneArg              ( empty_ncfile );
test_neg_tooManyInputs           ( empty_ncfile );
test_neg_1stArgNotNetcdfFile;
test_neg_2ndArgNotVarName   ;

if getpref('SNCTOOLS','TEST_JAVA_READ_ONLY',false)
    return
end

                     ;
test_neg_numericArgs1stNotNcid                   ;
test_neg_numericArgs2ndNotDimid  ( full_ncfile );
test_neg_argOneCharArgTwoNumeric ( full_ncfile );
test_neg_ncidViaPackageDimDoesNotExist ( full_ncfile );
test_neg_ncidViaMexncDimDoesNotExist ( full_ncfile );

return






%--------------------------------------------------------------------------
function test_neg_noArgs ()
try
    nb = nc_getdiminfo; %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_onlyOneArg ( ncfile )
try
    nb = nc_getdiminfo ( ncfile ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_tooManyInputs ( ncfile )
try
    diminfo = nc_getdiminfo ( ncfile, 'x', 'y' ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end








%--------------------------------------------------------------------------
function test_neg_1stArgNotNetcdfFile ( )

try
    diminfo = nc_getdiminfo ( 'does_not_exist.nc', 'x' ); %#ok<NASGU>
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end






%--------------------------------------------------------------------------
function test_neg_2ndArgNotVarName ( ncfile )

try
    nc_getdiminfo ( ncfile, 'var_does_not_exist' );
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end





%--------------------------------------------------------------------------
function test_neg_numericArgs1stNotNcid ( )
try
    nc_getdiminfo ( 1, 1 );
    error('succeeded when it should have failed.');
catch %#ok<CTCH>
    return
end




%--------------------------------------------------------------------------
function test_neg_numericArgs2ndNotDimid ( ncfile )



if snctools_use_tmw(ncfile)
	test_nc_getdiminfo_007_tmw(ncfile);

elseif snctools_use_mexnc
    [ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
    if ( status ~= 0 )
        error ( 'mexnc:open failed' );
    end
	try
    	nc_getdiminfo ( ncid, 25000 );
	catch %#ok<CTCH>
    	mexnc ( 'close', ncid );
		return
	end
	error('succeeded when it should have failed');
end

return



%--------------------------------------------------------------------------
function test_neg_argOneCharArgTwoNumeric ( ncfile )
try
    nc_getdiminfo ( ncfile, 25 );
catch %#ok<CTCH>
    return
end
error('succeeded when it should have failed.');








%--------------------------------------------------------------------------
function test_neg_ncidViaPackageDimDoesNotExist ( ncfile )

if snctools_use_tmw(ncfile)
    ncid = netcdf.open(ncfile,'NOWRITE');

    try
        nc_getdiminfo ( ncid, 'ocean_time' );
    catch %#ok<CTCH>
        netcdf.close(ncid);
        return
    end
    error('succeeded when it should have failed.');

end
return




%--------------------------------------------------------------------------
function test_neg_ncidViaMexncDimDoesNotExist ( ncfile )

if snctools_use_mexnc
    [ncid, status] = mexnc ( 'open', ncfile, nc_nowrite_mode );
    if ( status ~= 0 )
        error('mexnc:open failed');
    end

    try
        nc_getdiminfo ( ncid, 'ocean_time' );
    catch %#ok<CTCH>
        mexnc('close',ncid);
        return
    end
    error('succeeded when it should have failed.');

end
return





%--------------------------------------------------------------------------
function test_unlimited ( ncfile )
diminfo = nc_getdiminfo ( ncfile, 't' );
if ~strcmp ( diminfo.Name, 't' )
    error('diminfo.Name was incorrect.');
end
if ( diminfo.Length ~= 0 )
    error('diminfo.Length was incorrect.');
end
if ( diminfo.Unlimited ~= 1 )
    error('diminfo.Unlimited was incorrect.');
end
return





%--------------------------------------------------------------------------
function test_limited ( ncfile )

diminfo = nc_getdiminfo ( ncfile, 's' );
if ~strcmp ( diminfo.Name, 's' )
    error('diminfo.Name was incorrect.');
end
if ( diminfo.Length ~= 1 )
    error('diminfo.Length was incorrect.');
end
if ( diminfo.Unlimited ~= 0 )
    error('diminfo.Unlimited was incorrect.');
end
return



















