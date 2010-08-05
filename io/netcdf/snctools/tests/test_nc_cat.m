function test_nc_cat (  )
% TEST_NC_CAT:
%

% For now we will run this test preserving the fastest varying dimension.
oldpref = getpref('SNCTOOLS','PRESERVE_FVD');
setpref('SNCTOOLS','PRESERVE_FVD',true);

global ignore_eids;
fprintf ( 1, 'Testing NC_CAT...\n' );

ignore_eids = getpref('SNCTOOLS','IGNOREEIDS',true);

test_netcdf3;
test_hdf4;

setpref('SNCTOOLS','PRESERVE_FVD',oldpref);
return



%--------------------------------------------------------------------------
function test_netcdf3()
fprintf('\tRunning netcdf-3 tests...\n' );

test_normal_usage;
test_recvar_not_time;



%--------------------------------------------------------------------------
function test_normal_usage(mode)

if nargin == 0
    mode = nc_clobber_mode;
end

ncfile1 = 'ts1.nc';
ncfile2 = 'ts2.nc';
create_test_file(ncfile1,mode);
create_test_file(ncfile2,mode);
populate(ncfile1,ncfile2);

nc_cat(ncfile1,ncfile2);
expdata = [1 2 3 4 5 6]';
t = nc_varget(ncfile1,'time');
ddiff = abs(expdata - t);
if any(ddiff)
    error('failed');
end


return

%--------------------------------------------------------------------------
function test_recvar_not_time(mode)

if nargin == 0
    mode = nc_clobber_mode;
end

ncfile1 = 'ts1.nc';
ncfile2 = 'ts2.nc';
create_test_file_not_time(ncfile1,mode);
create_test_file_not_time(ncfile2,mode);
populate_not_time(ncfile1,ncfile2);

nc_cat(ncfile1,ncfile2);
expdata = [1 2 3 4 5 6]';
t = nc_varget(ncfile1,'time2');
ddiff = abs(expdata - t);
if any(ddiff)
    error('failed');
end


return
%--------------------------------------------------------------------------
function populate(file1,file2)
v.time = ones(3,1);
v.heat = ones(180,360,3);
for j = 1:3
    v.time(j) = j;
    v.heat(:,:,j) = v.heat(:,:,j) * j;
end

nc_addnewrecs(file1,v);

clear v;
v.time = ones(3,1);
v.heat = ones(180,360,3);
for j = 1:3
    v.time(j) = j + 3;
    v.heat(:,:,j) = v.heat(:,:,j) * j + 3;
end

nc_addnewrecs(file2,v);

%--------------------------------------------------------------------------
function populate_not_time(file1,file2)
v.time2 = ones(3,1);
v.heat = ones(180,360,3);
for j = 1:3
    v.time2(j) = j;
    v.heat(:,:,j) = v.heat(:,:,j) * j;
end

nc_addnewrecs(file1,v);

clear v;
v.time2 = ones(3,1);
v.heat = ones(180,360,3);
for j = 1:3
    v.time2(j) = j + 3;
    v.heat(:,:,j) = v.heat(:,:,j) * j + 3;
end

nc_addnewrecs(file2,v);

%--------------------------------------------------------------------------
function test_hdf4()
fprintf('\tRunning hdf4 tests... \n ' );

test_normal_usage('hdf4');
test_recvar_not_time('hdf4');


return

%--------------------------------------------------------------------------
function create_test_file_not_time(filename,mode)
if isnumeric(mode)
    nc_create_empty(filename,mode);
    nc_adddim(filename,'time2',0);
    nc_adddim(filename,'lon',360);
    nc_adddim(filename,'lat',180);
    v.Name = 'time2';
    v.Dimension = {'time2'};
    nc_addvar(filename,v);
else
    nc_create_empty(filename,mode);
    nc_adddim(filename,'time2',0);
    nc_adddim(filename,'lon',360);
    nc_adddim(filename,'lat',180);   
end

v.Dimension = {'lat','lon','time2'};
v.Name = 'heat';
nc_addvar(filename,v);


nc_attput(filename,nc_global,'creation_date',datestr(now));

%--------------------------------------------------------------------------
function create_test_file(filename,mode)
if isnumeric(mode)
    nc_create_empty(filename,mode);
    nc_adddim(filename,'time',0);
    nc_adddim(filename,'lon',360);
    nc_adddim(filename,'lat',180);
    v.Name = 'time';
    v.Dimension = {'time'};
    nc_addvar(filename,v);
else
    nc_create_empty(filename,mode);
    nc_adddim(filename,'time',0);
    nc_adddim(filename,'lon',360);
    nc_adddim(filename,'lat',180);   
end

v.Dimension = {'lat','lon','time'};
v.Name = 'heat';
nc_addvar(filename,v);


nc_attput(filename,nc_global,'creation_date',datestr(now));
