%% Create netCDF-CF of orthogonal x-y grid
%
%  example of how to make a netCDF file with CF conventions of a 
%  variable that is defined on a grid that is orthogonal
%  in a x-y coordinate system. In this special case 
%  the dimensions coincide with the x-y coordinate axes.
%  The associated lat-lon coordinate matrices are curvi-linear.
%
%  This case is described in:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
%  as "Horizontal Coordinate Reference Systems, Grid Mappings, and Projections".
%
%  An example of an orthogonal x,y grid is for instance
%  a data product defined on an otrhogonal grid in a certain 
%  local geograhic projection by programs like arcGIS. For each
%  vertex in this grid a the lat,lon values need to be calculated
%  to project it on the globe (e.g. Google Earth).
%
%    ^ latitude (degrees_north)           ^ y(m)
%    |         x                          |
%    | ncols /   \                        |        ncols
%    |     /  /\   \              coordinate	  +------+
%    |   /   /15\    \          transformation
%    |  x  /10   \     \       <==============>	 +--------+
%    |    <5     14\     \                |      |05 10 15|  +
%    |     \   9    \      \              |      |        |  |
%    |      \4       \      |             |      |04 09 14|  |
%    |       \        \     |             |      |        |  |
%    |        )3  8  xx)    | nrows       |      |03 08 xx|  | nrows
%    |       /        /     |             |      |        |  |
%    |      /2       /      |             |      |02 07 12|  | 
%    |     /   7    /      /              |      |        |  |
%    |    <1     12/     /                |      |01 06 11|  +
%    |     \6    /     /                  |      +--------+
%    |       \11/    /                    |
%    |        \/   x                      |
%    |                                    |
%    +----------------------> longitude   +----------------------> x
%                        (degrees_east)                          (m)
%
% Note that ncBrowse does not contain plot support for 
% curvi-linear grids, so ncBrowse will display the same 
% rectangular plot as for the netCDF file created by
% NC_CF_GRID_WRITE_LAT_LON_ORTHOGONAL_TUTORIAL, albeit with
% different axes annotations (col/row instead of lat/lon).
%
%See also: SNCTOOLS, NC_CF_GRID, NC_CF_GRID_WRITE,
%          NC_CF_GRID_WRITE_LAT_LON_ORTHOGONAL_TUTORIAL, 
%          NC_CF_GRID_WRITE_LAT_LON_CURVILINEAR_TUTORIAL, 
%          NC_CF_GRID_WRITE_X_Y_CURVILINEAR_TUTORIAL,
%          nc_cf_timeseries

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a> under the <a href="http://www.gnu.org/licenses/gpl.html">GPL</a> license.

%% Define meta-info: global: x,y sticks > lat,lon matrices

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
   
%% Define dimensions/coordinates

   OPT.x                      = [400 500 600].*1e3;
   OPT.y                      = [5500:100:5900].*1e3;

  [x,y]                       = ndgrid(OPT.x,OPT.y);

   OPT.ncols                  = length(OPT.x);
   OPT.nrows                  = length(OPT.y);
   OPT.lat_type               = 'single'; % 'single', 'double' for high-resolution data (eps 1m)
   OPT.lon_type               = 'single'; % 'single', 'double' for high-resolution data (eps 1m)

   OPT.epsg.code              = 32631; % epsg code of local projection
   OPT.wgs84.code             = 4326;  % epsg code of global grid
   % http://www.epsg-registry.org/
   % in the case of a grid defined in a local x-y 
   % projection, the properties of the grid in a WGS84
   % lat,lon system do not have to be specified here, but 
   % can be retrieved from the log of the coordinate 
   % transformation carried out by convertCoordinates.
   % get (lat,lon) associated with each vertex (x,y), note order [OPT.lon,OPT.lat ...

  [OPT.lon,OPT.lat,log]       = convertCoordinates(x,y,'CS1.code',OPT.epsg.code,'CS2.code',OPT.wgs84.code);

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
      
%% 2.a Create matrix span dimensions
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#dimensions   
   
   nc_add_dimension(ncfile, 'x', OPT.ncols); % use this as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
   nc_add_dimension(ncfile, 'y', OPT.nrows); % use this as 2nd array dimension to get correct plot in ncBrowse (snctools swaps for us)

   % You might insert a vector 'col' that runs max(x):-dx:min(x) to have
   % the arcGIS ASCII file approach of having upper-left corner of 
   % the data matrix at index (1,1) rather than the default of having the 
   % lower-left corner of the data matrix  at index (1,1).

   if ~isempty(OPT.time)
   nc_add_dimension(ncfile, 'time', 1); % if you would like to include more instances of the same grid, 
                                        % you can optionally use 'time' as a 3rd dimension. see 
                                        % nc_cf_timeseries_write_tutorial for info on time.          
   end

%% 3.a Create coordinate vectors: x and y

   clear nc;ifld = 1;
   nc(ifld).Name             = 'x'; % dimension 'x' is here filled with variable 'x'
   nc(ifld).Nctype           = nc_type(OPT.lon_type);
   nc(ifld).Dimension        = {'x'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'x Rijksdriehoek');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.x(:)) max(OPT.x(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');

   ifld = ifld + 1;
   nc(ifld).Name             = 'y'; % dimension 'y' is here filled with variable 'y'
   nc(ifld).Nctype           = nc_type(OPT.lat_type);
   nc(ifld).Dimension        = {'y'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'y Rijksdriehoek');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.y(:)) max(OPT.y(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');

%% 3.b Create coordinate variables: coordinate system: epsg
%      http://www.epsg-registry.org/
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'epsg';
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.epsg.code);

%% 3.c Create coordinate variables: longitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

   ifld = ifld + 1;
   nc(ifld).Name             = 'lon';
   nc(ifld).Nctype           = nc_type(OPT.lon_type);
   nc(ifld).Dimension        = {'x','y'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.d Create coordinate variables: latitude
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
   ifld = ifld + 1;
   nc(ifld).Name             = 'lat';
   nc(ifld).Nctype           = nc_type(OPT.lat_type);
   nc(ifld).Dimension        = {'x','y'};
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude');
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]); % TO DO add half grid cell offset
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

%% 3.e Create coordinate variables: coordinate system: WGS84 default
%      global ellispes: WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
%      http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   
   ifld = ifld + 1;
   nc(ifld).Name         = 'wgs84'; % preferred
   nc(ifld).Nctype       = nc_int;
   nc(ifld).Dimension    = {};
   nc(ifld).Attribute    = nc_cf_grid_mapping(OPT.wgs84.code); % includes ADAGUC attributes

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
   nc(ifld).Dimension        = {'time','x','y'};
   else
   nc(ifld).Dimension        = {'x','y'};
   end
   nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
   nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
   nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
   nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
   nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
   nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg'); % and 'wgs84' too, but the code for the orthogonal one is more suited, the other can be retrieved via the coordinates att.
   if ~isempty(OPT.standard_name)
   nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
   end
      
%% 5.a Create all variables with attributes
   
   for ifld=1:length(nc)
      nc_addvar(ncfile, nc(ifld));   
   end
      
%% 5.b Fill all variables

   nc_varput(ncfile, 'x'            , OPT.x         );
   nc_varput(ncfile, 'y'            , OPT.y         );
   nc_varput(ncfile, 'epsg'         , OPT.epsg.code );
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
   Da.lon   = nc_varget(ncfile,'lat')

%% 7.b Load the data: using standard_names and coordinate attribute

   depname  = nc_varfind(ncfile,'attributename', 'standard_name', 'attributevalue', 'sea_floor_depth_below_geoid')
   Db.z     = nc_varget(ncfile,depname);

   coords   = nc_attget(ncfile,depname,'coordinates');
  [ax1,coords] = strtok(coords); ax2 = strtok(coords);
   if strcmpi(nc_attget(ncfile,ax1,'standard_name'),'latitude');
   Db.lat   = nc_varget(ncfile,ax1);
   Db.lon   = nc_varget(ncfile,ax2);
   else
   Db.lat   = nc_varget(ncfile,ax2);
   Db.lon   = nc_varget(ncfile,ax1);
   end

%% 7.c Load the data: using a dedicated function developed for grids

   [Dc,Mc] = nc_cf_grid(ncfile,OPT.varname)
