function nc_cf_grid_test
%NC_CF_GRID_TEST  test for nc_cf_grid
%
%See also: nc_cf_grid

%% read grid (local)

% figure('name','grid local')
% f  = 'f:\opendap\thredds\rijkswaterstaat\vaklodingen\vaklodingenKB122_2120.nc';

   figure('name','grid OPeNDAP')
   f  = 'http://opendap.deltares.nl/thredds/dodsC/opendap/rijkswaterstaat/vaklodingen/vaklodingenKB122_2120.nc';

%% test for new version of snctools in OpenEarthTools branch

%    disp('=====================================')
%    setpref('SNCTOOLS','PRESERVE_FVD',0) 
%    disp(' transpose: consistent with ncBrowse')
%    nc_dump(f,'z')
%    disp('-------------------------------------')
%    disp(' <> ncBrowse (time,y,x)')
%    
%    disp('=====================================')
%    setpref('SNCTOOLS','PRESERVE_FVD',1)
%    disp(' do not transpose: consistent with Matlab native netcdf')
%    nc_dump(f,'z')
%    disp('-------------------------------------')
%    disp(' <> Matlab native netcdf')
%    ncid = netcdf.open(f,'NOWRITE');
%    varid = netcdf.inqVarID(ncid,'z');
%    [varname,xtype,dimids,natts] = netcdf.inqVar(ncid,varid);
%    
%    for i=dimids
%       [dimname, dimlen] = netcdf.inqDim(ncid,i);
%       disp(['  ',dimname,' : ',num2str(i),'[',num2str(dimlen),']']);
%    end
%    netcdf.close(ncid)
%    disp('=====================================')

   [G,GM] =nc_cf_grid(f,'z');

%% write grid

   ncfile = fullfile(fileparts(mfilename('fullpath')),['nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'.nc']);
   
   if getpref('SNCTOOLS','PRESERVE_FVD')==0
      nc_cf_grid_write(ncfile,...
               'lon',permute(G.lon(:,:),  [2 1]),...
               'lat',permute(G.lat(:,:),  [2 1]),...
               'val',permute(G.z(1,:,:),[3 2 1]),...
             'units',GM.z.units,...
           'varname','z',...
         'long_name','z');
   else
      nc_cf_grid_write(ncfile,...
               'lon',permute(G.lon(:,:),  [1 2]),...
               'lat',permute(G.lat(:,:),  [1 2]),...
               'val',permute(G.z(:,:,1),[1 2 3]),...
             'units',GM.z.units,...
           'varname','z',...
         'long_name','z');
   end

%% read grid (local)

   figure('name','grid (local, just written)');
   [G2,GM2] = nc_cf_grid(ncfile,'z');
   fid = fopen(fullfile(fileparts(mfilename('fullpath')),['nc_cf_grid_write_test_',num2str(getpref('SNCTOOLS','PRESERVE_FVD')),'.cdl']),'w');
   nc_dump(ncfile,fid)
   fclose(fid);