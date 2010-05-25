%_TUTORIAL_NC_CF_GRID_WRITE_LAT_LON_CURVILINEAR   example of how to create a netCDF grid file of a curvi-linear lat-lon grid
%
%  example of how to make a netCDF file of a variable
%  that is defined on a grid that is curvi-linear
%  in a lat-lon coordinate system. In this case 
%  the dimensions (m,n) do not coincide with the coordinate axes.
%
%  This case is described in:
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#id2984605
%  as "Two-Dimensional Latitude, Longitude, Coordinate Variables".
%
%    ^ latitude (degrees_north)
%    |
%    |         +
%    |  ncols/   \
%    |     /    A  \
%    |    +   /###\  \
%    |      <######\   \
%    |       \######\    \
%    |        )######)    nrows
%    |       /######/ 	  / 
%    |      /######/  	/
%    |     <######/   /
%    |      \####/  /
%    |        \/  /
%    |           +
%    |            
%    +----------------------> longitude (degrees_east)
%
%See also: SNCTOOLS, NC_CF_GRID, NC_CF_GRID_WRITE,
%          _TUTORIAL_NC_CF_GRID_WRITE_LAT_LON_CURVILINEAR, 
%          _TUTORIAL_NC_CF_GRID_WRITE_X_Y_ORTHOGONAL,
%          _TUTORIAL_NC_CF_GRID_WRITE_X_Y_CURVILINEAR,

%% User defined meta-info

   %% global

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
   
   %% dimensions/coordinates

      OPT.lon                    = 0:.5:10;
      OPT.lat                    = 49:.25:60;
      OPT.ncols                  = length(OPT.lon);
      OPT.nrows                  = length(OPT.lat);

     [lon,lat]                   = ndgrid(OPT.lon,OPT.lat);

      lon2                       = cosd(30).*(lon - mean(OPT.lon)) - sind(30).*(lat - mean(OPT.lat)) + mean(OPT.lon);
      lat2                       = sind(30).*(lat - mean(OPT.lat)) + cosd(30).*(lon - mean(OPT.lon)) + mean(OPT.lat);
      
      OPT.lon                    = lon2; clear lon2
      OPT.lat                    = lat2; clear lat2
      
      OPT.wgs84                  = 4326;
      OPT.ellips.name            = 'WGS 84';
      OPT.ellips.semi_major_axis = 6378137.0;
      OPT.ellips.semi_minor_axis = 6356752.314247833;
      OPT.ellips.inv_flattening  = 298.2572236;
      OPT.lat_type               = 'single'; % 'double' % 'single'
      OPT.lon_type               = 'single'; % 'double' % 'single'
      
   %% variable

      OPT.varname                = 'depth';
      OPT.val                    = lat + rand(size(lon)).*lon; % use ncols as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
      OPT.units                  = 'm';
      OPT.long_name              = 'sea_floor_depth_below_geoid';
      OPT.standard_name          = 'altitude';
      OPT.val_type               = 'single'; % 'double' % 'single'
      OPT.fillvalue              = nan;
      
%% 1a Create file

      outputfile = fullfile(fileparts(mfilename('fullpath')),['_tutorial_nc_cf_grid_write_lat_lon_curvilinear','.nc']);
   
      nc_create_empty (outputfile)
   
   %% Add overall meta info
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(outputfile, nc_global, 'title'         , OPT.title);
      nc_attput(outputfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(outputfile, nc_global, 'source'        , OPT.source);
      nc_attput(outputfile, nc_global, 'history'       , OPT.history);
      nc_attput(outputfile, nc_global, 'references'    , OPT.references);
      nc_attput(outputfile, nc_global, 'email'         , OPT.email);
   
      nc_attput(outputfile, nc_global, 'comment'       , OPT.comment);
      nc_attput(outputfile, nc_global, 'version'       , OPT.version);
   						   
      nc_attput(outputfile, nc_global, 'Conventions'   , 'CF-1.4');
      nc_attput(outputfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(outputfile, nc_global, 'terms_for_use' , OPT.acknowledge);
      nc_attput(outputfile, nc_global, 'disclaimer'    , OPT.disclaimer);
      
%% 2 Create matrix span dimensions
%    http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#dimensions   

      nc_add_dimension(outputfile, 'col', OPT.ncols); % use this as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
      nc_add_dimension(outputfile, 'row', OPT.nrows); % use this as 2nd array dimension to get correct plot in ncBrowse (snctools swaps for us)

%% 3a Create coordinate variables
   
      clear nc
      ifld = 0;
   
   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name             = 'lon';
      nc(ifld).Nctype           = nc_type(OPT.lon_type);
      nc(ifld).Dimension        = {'col','row'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon'); % lon matrix can be plotted as a function of lat and itself
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   
        ifld = ifld + 1;
      nc(ifld).Name             = 'lat';
      nc(ifld).Nctype           = nc_type(OPT.lat_type);
      nc(ifld).Dimension        = {'col','row'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon'); % lat matrix can be plotted as a function of lon and itself
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

   %% Coordinate system (WGS 84, ED 50, INT 1924, ETRS 89 and the upcoming ETRS update etc.)
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#grid-mappings-and-projections
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings

        ifld = ifld + 1;
      nc(ifld).Name         = 'wgs84'; % preferred
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute = struct('Name', ...
       {'name',...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'comment'}, ...
        'Value', ...
        {OPT.ellips.name,...
         OPT.ellips.semi_major_axis, ...
         OPT.ellips.semi_minor_axis, ...
         OPT.ellips.inv_flattening,  ...
        'value is equal to EPSG code'});

%% 3b Create depdendent variable
%     http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#variables

   %% Parameters with standard names
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/

        ifld = ifld + 1;
      nc(ifld).Name             = OPT.varname;
      nc(ifld).Nctype           = nc_type(OPT.val_type);
      nc(ifld).Dimension        = {'col','row'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
      nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'lat lon');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
      if ~isempty(OPT.standard_name)
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      end
      
%% 4 Create all variables with attibutes
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill all variables

      nc_varput(outputfile, 'lon'          , OPT.lon  );
      nc_varput(outputfile, 'lat'          , OPT.lat  );
      nc_varput(outputfile, 'wgs84'        , OPT.wgs84);
      nc_varput(outputfile, OPT.varname    , OPT.val  );
      
%% 6 Check
   
      nc_dump(outputfile);

%% EOF