%% Create netCDF-CF of orthogonal lat-lon grid
%
%  example of how to make a netCDF file with CF conventions of a 
%  variable that is defined on a grid that is orthogonal
%  in a lat-lon coordinate system. In this special case 
%  the dimensions coincide with the coordinate axes.
%
%  This case is described in:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984551
%  as "Independent Latitude, Longitude Axes".
%
%    ^ latitude (degrees_north)
%    |
%    |       ncols
%    |      +------+
%    |
%    |     +--------+
%    |     |05 10 15|  +
%    |     |        |  |
%    |     |04 09 14|  |
%    |     |        |  |
%    |     |03 08 xx|  | nrows
%    |     |        |  |
%    |     |02 07 12|  | 
%    |     |        |  |
%    |     |01 06 11|  +
%    |     +--------+
%    |
%    +--------------------------> longitude
%                            (degrees_east)
%
%See also: SNCTOOLS, NC_CF_GRID, NC_CF_GRID_WRITE,
%          NC_CF_GRID_WRITE_LAT_LON_CURVILINEAR_TUTORIAL, 
%          NC_CF_GRID_WRITE_X_Y_ORTHOGONAL_TUTORIAL,
%          NC_CF_GRID_WRITE_X_Y_CURVILINEAR_TUTORIAL,
%          nc_cf_timeseries
%          http://opendap.deltares.nl/thredds/catalog/opendap/test/catalog.html

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a> under the <a href="http://www.gnu.org/licenses/gpl.html">GPL</a> license.

%% Define meta-info: global

   OPT.title                  = '';
   OPT.institution            = '';
   OPT.source                 = '';
   OPT.history                = ['tranformation to netCDF: $HeadURL$'];
   OPT.references             = '';
   OPT.email                  = '';
   OPT.comment                = '';
   OPT.version                = '';
   OPT.acknowledge            =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
   OPT.disclaimer             = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   
%% Define dimensions/coordinates: lat,lon sticks

   OPT.lat_type               = 'single'; % 'single', 'double' for high-resolution data (eps 1m)
   OPT.lon_type               = 'single'; % 'single', 'double' for high-resolution data (eps 1m)

   OPT.cor.lon                = [1 3 5 7];      % pixel corners
   OPT.cor.lat                = [49.5:1:54.5];
   OPT.lon                    = [2 4 6];        % pixel centers
   OPT.lat                    = [50 51 52 53 54];
   OPT.ncols                  = length(OPT.lon);
   OPT.nrows                  = length(OPT.lat);

   OPT.wgs84.code             = 4326; % % epsg code of global grid: http://www.epsg-registry.org/
   OPT.wgs84.name             = 'WGS 84';
   OPT.wgs84.semi_major_axis  = 6378137.0;
   OPT.wgs84.semi_minor_axis  = 6356752.314247833;
   OPT.wgs84.inv_flattening   = 298.2572236;

%% Define variable (define some data)
%  checkersboard to test plot with one nan-hole
   OPT.val                    = [  1 102   3 104   5;...
                                 106   7 108   9 110;...
                                  11 112 nan 114  15]; % use ncols as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
   OPT.varname                = 'depth';       % free to choose: will appear in netCDF tree
   OPT.units                  = 'm';           % from UDunits package: http://www.unidata.ucar.edu/software/udunits/
   OPT.long_name              = 'bottom depth';% free to choose: will appear in plots
   OPT.standard_name          = 'sea_floor_depth_below_geoid'; % or 'altitude'
   OPT.val_type               = 'single';      % 'single' or 'double'
   OPT.fillvalue              = nan;
   OPT.time                   = now; % []; %now;
   OPT.timezone               = '+00:00';
   
%% 1.a Create netCDF file

   ncfile = fullfile(fileparts(mfilename('fullpath')),[mfilename,'.nc']);

   nc_create_empty (ncfile)

%% 1.b Add overall meta info
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
   nc_attput(ncfile, nc_global, 'title'         , OPT.title);
   nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
   nc_attput(ncfile, nc_global, 'source'        , OPT.source);
   nc_attput(ncfile, nc_global, 'history'       , OPT.history);
   nc_attput(ncfile, nc_global, 'references'    , OPT.references);
   nc_attput(ncfile, nc_global, 'email'         , OPT.email);

   nc_attput(ncfile, nc_global, 'comment'       , OPT.comment);
   nc_attput(ncfile, nc_global, 'version'       , OPT.version);

   nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.5');
   nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions

   nc_attput(ncfile, nc_global, 'terms_for_use' , OPT.acknowledge);
   nc_attput(ncfile, nc_global, 'disclaimer'    , OPT.disclaimer);
      
%% 2   Create matrix span dimensions
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#dimensions   
   
   nc_add_dimension(ncfile, 'lon', OPT.ncols); % !!! use this as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
   nc_add_dimension(ncfile, 'lat', OPT.nrows); % !!! use this as 2nd array dimension to get correct plot in ncBrowse (snctools swaps for us)
   nc_add_dimension(ncfile, 'vertices', 2); % For each coordinate tick we need two endpoints

   % You might insert a vector 'col' that runs [OPT.ncols:-1:1] to have
   % the arcGIS ASCII file approach of having upper-left corner of 
   % the data matrix at index (1,1) rather than the default of having the 
   % lower-left corner of the data matrix  at index (1,1).

   if ~isempty(OPT.time)
   nc_add_dimension(ncfile, 'time', 1); % if you would like to include more instances of the same grid, 
                                        % you can optionally use 'time' as a 3rd dimension. see 
                                        % nc_cf_timeseries_write_tutorial for info on time.          
   end

%% 3.a Create coordinate vector: longitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

   clear nc;ifld = 1;
   nc(ifld).Name             = 'lon'; % dimension 'lon' is here filled with variable 'lon'
   nc(ifld).Nctype           = nc_type(OPT.lon_type);
   nc(ifld).Dimension        = {'lon'}; % !!!
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'         ,'Value', 'lonbounds');

   ifld = ifld + 1;
   nc(ifld).Name             = 'lonbounds'; % dimension 'lon' is here filled with variable 'lon'
   nc(ifld).Nctype           = nc_type(OPT.lon_type);
   nc(ifld).Dimension        = {'lon','vertices'}; % !!!
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude vertices');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.cor.lon(:)) max(OPT.cor.lon(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.b Create coordinate vector: latitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name             = 'lat'; % dimension 'lat' is here filled with variable 'lat'
   nc(ifld).Nctype           = nc_type(OPT.lat_type);
   nc(ifld).Dimension        = {'lat'}; % !!!
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   nc(ifld).Attribute(end+1) = struct('Name', 'bounds'         ,'Value', 'latbounds');

   ifld = ifld + 1;
   nc(ifld).Name             = 'latbounds'; % dimension 'lat' is here filled with variable 'lat'
   nc(ifld).Nctype           = nc_type(OPT.lat_type);
   nc(ifld).Dimension        = {'lat','vertices'}; % !!!
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude vertices');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.cor.lat(:)) max(OPT.cor.lat(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.c Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'wgs84'; % preferred
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84.code); % is same as 
   nc(ifld).Attribute    = struct('Name', ...
    {'name',...
     'epsg',...
     'grid_mapping_name',...
     'semi_major_axis', ...
     'semi_minor_axis', ...
     'inverse_flattening', ...
     'comment'}, ...
     'Value', ...
     {OPT.wgs84.name,...
      OPT.wgs84.code,...
     'latitude_longitude',...
      OPT.wgs84.semi_major_axis, ...
      OPT.wgs84.semi_minor_axis, ...
      OPT.wgs84.inv_flattening,  ...
     'value is equal to EPSG code'});

   % add ADAGUC projection parameters optionally
   
      nc(ifld).Attribute(end+1) = struct('Name', 'proj4_params'   ,'Value', '+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs');
      nc(ifld).Attribute(end+1) = struct('Name', 'projection_name','Value', 'Latitude Longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'EPSG_code'      ,'Value', ['EPSG:',num2str(OPT.wgs84.code)]);

%% 3z   Optionally create time dimension

   if ~isempty(OPT.time)
   OPT.refdatenum            = datenum(1970,1,1); 
   OPT.timezone              = '+00:00';
   ifld = ifld + 1;
   nc(ifld).Name             = 'time';   % dimension 'time' is here filled with variable 'time'
   nc(ifld).Nctype           = 'double'; % time should always be in doubles
   nc(ifld).Dimension        = {'time'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'time');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.time(:)) max(OPT.time(:))]-OPT.refdatenum);
   end

%% 4   Create dependent variable
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#variables
%      Parameters with standard names:
%      http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

   ifld = ifld + 1;
   nc(ifld).Name             = OPT.varname;
   nc(ifld).Nctype           = nc_type(OPT.val_type);
   if ~isempty(OPT.time)
   nc(ifld).Dimension        = {'time','lon','lat'};
   else
   nc(ifld).Dimension        = {'lon','lat'};
   end
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
   nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon'); % not required as the coordinates are vectors
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   if ~isempty(OPT.standard_name)
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
   end
      
%% 5.a Create all variables with attributes
   
   for ifld=1:length(nc)
      nc_addvar(ncfile, nc(ifld));   
   end
      
%% 5.b Fill all variables

   nc_varput(ncfile, 'lonbounds'    , nc_cf_cor2bounds(OPT.cor.lon)');
   nc_varput(ncfile, 'latbounds'    , nc_cf_cor2bounds(OPT.cor.lat)');
   nc_varput(ncfile, 'lon'          , OPT.lon       );
   nc_varput(ncfile, 'lat'          , OPT.lat       );
   nc_varput(ncfile, 'wgs84'        , OPT.wgs84.code);
   if ~isempty(OPT.time)
   nc_varput(ncfile, 'time'         , OPT.time - OPT.refdatenum);
   nc_varput(ncfile, OPT.varname    , permute(OPT.val,[3 1 2]));
   else
   nc_varput(ncfile, OPT.varname    , OPT.val       );
   end
      
%% 6   Check file summary
   
   nc_dump(ncfile);
   fid = fopen(fullfile(fileparts(mfilename('fullpath')),[mfilename,'.cdl']),'w');
   fprintf(fid,'%s\n', '// The netCDF CF conventions for grids are defined here:');
   fprintf(fid,'%s\n', '// http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.5/ch05s06.html');
   fprintf(fid,'%s\n', '// This grid file can be loaded into matlab with nc_cf_grid.m');
   fprintf(fid,'%s\n',['// To create this netCDF file with Matlab please see ',mfilename]);
   nc_dump(ncfile,fid);
   fclose(fid);
   
%% 7.a Load the data: using the variable names from nc_dump

   Da.dep   = nc_varget(ncfile,'depth');
   Da.lat   = nc_varget(ncfile,'lon');
   Da.lon   = nc_varget(ncfile,'lat');

%% 7.b Load the data: using standard_names and coordinate attribute

   depname  = nc_varfind(ncfile,'attributename', 'standard_name', 'attributevalue', 'sea_floor_depth_below_geoid');
   Db.z     = nc_varget(ncfile,depname);

   coords   = nc_attget(ncfile,depname,'coordinates');
  [ax1,coords] = strtok(coords); ax2 = strtok(coords);
   if strcmpi(nc_attget(ncfile,ax1,'standard_name'),'latitude')
   Db.lat   = nc_varget(ncfile,ax1);
   Db.lon   = nc_varget(ncfile,ax2);
   else
   Db.lat   = nc_varget(ncfile,ax2);
   Db.lon   = nc_varget(ncfile,ax1);
   end

%% 7.c Load the data: using a dedicated function developed for grids

   [Dc,Mc] = nc_cf_grid(ncfile,OPT.varname);
