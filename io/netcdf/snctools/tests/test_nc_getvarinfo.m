function test_nc_getvarinfo()

fprintf('Testing NC_GETVARINFO...\n' );

run_negative_tests;

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
function run_negative_tests()
test_noInputs;
test_tooFewInputs;
test_tooManyInput;
test_fileIsNotNetcdfFile;
test_varIsNotNetcdfVariable;
test_fileIsNumeric_varIsChar;
test_fileIsChar_varIsNumeric;

%--------------------------------------------------------------------------
function run_nc3_tests()

testroot = fileparts(mfilename('fullpath'));

fprintf('\t\tRunning netcdf-3 tests...  ');	 

ncfile = [testroot '/testdata/getlast.nc'];
test_limitedVariable(ncfile);
test_unlimitedVariable(ncfile);
test_unlimitedVariableWithOneAttribute(ncfile);
fprintf('OK\n');

return



%--------------------------------------------------------------------------
function run_nc4_tests()

testroot = fileparts(mfilename('fullpath'));

fprintf('\t\tRunning netcdf-4 tests...  ');	 

ncfile = [testroot '/testdata/getlast-4.nc'];
test_limitedVariable(ncfile);
test_unlimitedVariable(ncfile);
test_unlimitedVariableWithOneAttribute(ncfile);
fprintf('OK\n');

return



%--------------------------------------------------------------------------
function run_http_tests()
% These tests are regular URLs, not OPeNDAP URLs.

if ~ ( getpref ( 'SNCTOOLS', 'TEST_REMOTE', false ) )
    fprintf('\t\tjava http backend testing filtered out when SNCTOOLS ');
    fprintf('''TEST_REMOTE'' preference is false.\n');
    return
end

fprintf('\t\tRunning http tests...  ');
test_fileIsHttpUrl_varIsChar;
test_fileIsJavaNcid_varIsChar;
fprintf('OK\n');
return






%--------------------------------------------------------------------------
function test_noInputs ()


try
	nc_getvarinfo;
catch %#ok<CTCH>
    return
end
error('failed');








%--------------------------------------------------------------------------
function test_tooFewInputs()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/full.nc');

try
	nc_getvarinfo ( ncfile );
catch %#ok<CTCH>
    return
end
error('failed');







%--------------------------------------------------------------------------
function test_tooManyInput()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 't1' );
catch %#ok<CTCH>
    return
end
error('failed');









%--------------------------------------------------------------------------
function test_fileIsNotNetcdfFile ()


try
	nc_getvarinfo ( 'iamnotarealfilenoreally', 't1' );
catch %#ok<CTCH>
    return
end
error('failed');















%--------------------------------------------------------------------------
function test_varIsNotNetcdfVariable()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 't5' );
catch %#ok<CTCH>
    return
end
error('failed');










%--------------------------------------------------------------------------
function test_fileIsNumeric_varIsChar ()

try
	nc_getvarinfo ( 0, 't1' );
catch %#ok<CTCH>
    return
end
error('failed');




%--------------------------------------------------------------------------
function test_fileIsJavaNcid_varIsChar ( )

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';
jncid = NetcdfFile.open(url);

try
	nc_getvarinfo ( jncid, 'w' );
catch %#ok<CTCH>
    error('failed');
end





%--------------------------------------------------------------------------
function test_fileIsHttpUrl_varIsChar ( )

import ucar.nc2.dods.*     
import ucar.nc2.*          

url = 'http://rocky.umeoce.maine.edu/GoMPOM/cdfs/gomoos.20070723.cdf';

try
	nc_getvarinfo ( url, 'w' );
catch %#ok<CTCH>
    error('failed');
end




%--------------------------------------------------------------------------
function test_fileIsChar_varIsNumeric()

testroot = fileparts(mfilename('fullpath'));
ncfile = fullfile(testroot,'testdata/full.nc');
try
	nc_getvarinfo ( ncfile, 0 );
catch %#ok<CTCH>
    return
end
error('failed');





%--------------------------------------------------------------------------
function test_limitedVariable(ncfile)

v = nc_getvarinfo ( ncfile, 'x' );

if ~strcmp(v.Name, 'x' )
    error('failed');
end
if (v.Nctype~=6 )
    error('failed');
end
if (v.Unlimited~=0 )
    error('failed');
end
if (length(v.Dimension)~=1 )
    error('failed');
end
if ( ~strcmp(v.Dimension{1},'x') )
    error('failed');
end
if (v.Size~=2 )
    error('failed');
end
if (numel(v.Size)~=1 )
    error('failed');
end
if (~isempty(v.Attribute) )
    error('failed');
end

return





%--------------------------------------------------------------------------
function test_unlimitedVariable(ncfile)

v = nc_getvarinfo ( ncfile, 't1' );

if ~strcmp(v.Name, 't1' )
    error('failed');
end
if (v.Nctype~=6 )
    error('failed');
end
if (v.Unlimited~=1 )
    error('failed');
end
if (length(v.Dimension)~=1 )
    error('failed');
end
if (v.Size~=10 )
    error('failed');
end
if (numel(v.Size)~=1 )
    error('failed');
end
if (~isempty(v.Attribute) )
    error('failed');
end

return







%--------------------------------------------------------------------------
function test_unlimitedVariableWithOneAttribute(ncfile)

v = nc_getvarinfo ( ncfile, 't4' );

if ~strcmp(v.Name, 't4' )
	error('Name was not correct.');

end
if (v.Nctype~=6 )
	error('Nctype was not correct.');
end
if (v.Unlimited~=1 )
    error('Unlimited was not correct.');
end
if (length(v.Dimension)~=2 )
	error('Dimension was not correct.');
end
if (numel(v.Size)~=2 )
	error( 'Rank was not correct.');
end
if (length(v.Attribute)~=1 )
	error('Attribute was not correct.');
end

return

