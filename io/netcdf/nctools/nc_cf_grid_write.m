function varargout = nc_cf_grid_write(varargin)
%nc_cf_grid_write  save orthogonal/curvi-linear grid as netCDF-CF compliant file
%
%   nc_cf_grid_write(ncfilename,<keyword,value>)
%   nc_cf_grid_write(ncfilename,<keyword,value>)
%
% To get a list of all keywords, call NC_CF_GRID_WRITE without arguments.
%
%   OPT = nc_cf_grid_write()
%
% The following keywords are required:
%
% * x           x vector of length ncols, required
% * y           y vector of lenght nrows, required
% * val         matrix   of size [nrows,ncols], required
% * units       units of val
% * long_name   description of val as to appear in plots
%
% The following keywords are optional:
%
% * ncols       length of x vector (calculated from x)
% * nrows       length of y vector (calculated from y)
% * epsg        when supplied, the full latitude and longitude
%               matrixes are written to the netCDF file too, calculated
%               from the x and y, unless you specified them already:
% * lat
% * lon
%
%See also: ARCGISREAD, ARC_INFO_BINARY, ARCGRIDREAD (in $ mapping toolbox)
%          SNCTOOLS, NC_CF_GRID

% TO DO: add corner matrices too ?
% TO DO: allow lat and lon to be the dimension vectors

%%  --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%
%       Gerben de Boer
%
%       gerben.deboer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% TO DO: add latitude-longitude based on EPSG code with convertcoordinates.m

%% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
%  OpenEarthTools is an online collaboration to share and manage data and 
%  programming tools in an open source, version controlled environment.
%  Sign up to recieve regular updates of this function, and to contribute 
%  your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
%  $Id$
%  $Date$
%  $Author$
%  $Revision$
%  $HeadURL$
%  $Keywords: $

%% User defined keywords

   OPT.dump           = 1;
   OPT.disp           = 10; % stride in progres display
   OPT.convertperline = 25;  % when memory limitations are present, number of line to convert at once
   
%% User defined meta-info

   %% global

      OPT.title          = '';
      OPT.institution    = '';
      OPT.source         = '';
      OPT.history        = ['tranformation to netCDF: $HeadURL$'];
      OPT.references     = '';
      OPT.email          = '';
      OPT.comment        = '';
      OPT.version        = '';
      OPT.acknowledge    =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
      OPT.disclaimer     = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   
   %% dimensions/coordinates

      OPT.x              = [];
      OPT.y              = [];
      OPT.lon            = [];
      OPT.lat            = [];
      OPT.ncols          = [];
      OPT.nrows          = [];
      OPT.epsg           = []; % if specified, (lat,lon) are added
      OPT.wgs84          = 4326;
      OPT.latitude_type  = 'double'; % 'double' % 'single'
      OPT.longitude_type = 'double'; % 'double' % 'single'
      
   %% variables

      OPT.varname        = ''; % 'val' would be consistent with default ArcGisRead
      OPT.val            = []; % 'val' would be consistent with default ArcGisRead
      OPT.units          = '';
      OPT.long_name      = '';
      OPT.standard_name  = '';
      OPT.type           = []; % [] = auto, single or double

   %% handle meta-info

      if nargin==0;varargout = {OPT};return;end; % make function act as object

      OPT      = setProperty(OPT,varargin{2:end});
      
 %% errors

      if isempty(OPT.varname      );  error('For a netCDF file is required   : varname'      );end
      if isempty(OPT.units        );  error('For a netCDF file is required   : units'        );end
      if isempty(OPT.epsg         );warning('For a netCDF file is recommended: epsg'         );end

      if isempty(OPT.x        ) & isempty(OPT.lon          )
         error('For a netCDF file is required: x and/or lon');end
      if isempty(OPT.y        ) & isempty(OPT.lat          )
         error('For a netCDF file is required: y and/or lat');end
      if isempty(OPT.long_name) & isempty(OPT.standard_name);
         error('For a netCDF file is required: standard_name and/or long_name');end

      if ~isempty(OPT.val)
      OPT.ncols =   size(OPT.val,1);
      else
      OPT.ncols = length(OPT.x);
      end
      
      if ~isempty(OPT.val)
      OPT.nrows =   size(OPT.val,2);
      else
      OPT.nrows = length(OPT.y);
      end
      
%% Type

      if isempty(OPT.type)
      OPT.type          = class(OPT.val); % single or double
      end
      OPT.fillvalue     = nan(OPT.type); % as to appear in netCDF file, not as appeared in arcgrid file
      
%% lat,lon

   if ~isempty(OPT.epsg) & (isempty(OPT.lat & OPT.lon))
      
      % calculate per row because of memory issues for large matrices
      
     [x    ,y    ] = meshgrid(OPT.x,OPT.y);
      OPT.lon      = repmat(nan,size(OPT.val));
      OPT.lat      = repmat(nan,size(OPT.val));
      
      % compromise: consider 2D matrix as 1D vector and do section by section
      
      if (OPT.convertperline > 0) & ~isinf(OPT.convertperline)
      dline = OPT.convertperline;
      for ii=1:dline:size(OPT.lat,1)
      iii = ii+(1:dline)-1;
      iii = iii(iii < size(OPT.lat,1));
      disp(['converting coordinates to (lat,lon): ',num2str(min(iii)),'-',num2str(max(iii)),'/',num2str(size(OPT.lat,1))])
     [OPT.lon(iii,:),OPT.lat(iii,:),log] = convertcoordinates(x(iii,:),y(iii,:),'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      else % 0 or Inf
     [OPT.lon       ,OPT.lat       ,log] = convertcoordinates(x       ,y       ,'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      
      clear x y

   end

%% 1a Create file

      outputfile = varargin{1};
   
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
      
%% 2 Create x and y dimensions
   
      nc_add_dimension(outputfile, 'x_cen', OPT.ncols); % use this as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
      nc_add_dimension(outputfile, 'y_cen', OPT.nrows); % use this as 2nd array dimension to get correct plot in ncBrowse (snctools swaps for us)

%% 3a Create coordinate variables
   
      clear nc
      ifld = 0;
   
   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   %  TO DO, based on OPT.epsg
   %  Local Cartesian coordinates
   if ~isempty(OPT.x) & ~isempty(OPT.y)

        ifld = ifld + 1;
      nc(ifld).Name             = 'x_cen';
      nc(ifld).Nctype           = 'int';
      nc(ifld).Dimension        = {'x_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.x(:)) max(OPT.x(:))]);
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end
   
        ifld = ifld + 1;
      nc(ifld).Name             = 'y_cen';
      nc(ifld).Nctype           = 'int';
      nc(ifld).Dimension        = {'y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate in Cartesian system');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.y(:)) max(OPT.y(:))]);
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end
   end

   %% Latitude-longitude
   if ~isempty(OPT.lon) & ~isempty(OPT.lat)

   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name             = 'longitude_cen';
      nc(ifld).Nctype           = nc_type(OPT.longitude_type);
      nc(ifld).Dimension        = {'x_cen','y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lon(:)) max(OPT.lon(:))]); % 
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

   %% Latitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
        ifld = ifld + 1;
      nc(ifld).Name             = 'latitude_cen';
      nc(ifld).Nctype           = nc_type(OPT.latitude_type);
      nc(ifld).Dimension        = {'x_cen','y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.lat(:)) max(OPT.lat(:))]); % 
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');
   end

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
   if ~isempty(OPT.epsg)

        ifld = ifld + 1;
      nc(ifld).Name         = 'epsg';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute = struct('Name', ...
       {'name',...
        'grid_mapping_name', ...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'latitude_of_projection_origin', ...
        'longitude_of_projection_origin', ...
        'false_easting', ...
        'false_northing', ...
        'scale_factor_at_projection_origin', ...
        'comment'}, ...
        'Value', ...
        {log.CS1.name,...
         log.proj_conv1.method.name,     ...
         log.CS1.ellips.semi_major_axis, ...
         log.CS1.ellips.semi_minor_axis, ...
         log.CS1.ellips.inv_flattening,  ...
         log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Latitude of natural origin'    )),...
         log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Longitude of natural origin'   )),...
         log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'False easting'                 )),...
         log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'False northing'                )),...
         log.proj_conv1.param.value(strcmp(log.proj_conv1.param.name,'Scale factor at natural origin')),...
        'value is equal to EPSG code'});

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name         = 'wgs84';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute = struct('Name', ...
       {'name',...
        'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'comment'}, ...
        'Value', ...
        {log.CS2.name,...
         log.CS2.ellips.semi_major_axis, ...
         log.CS2.ellips.semi_minor_axis, ...
         log.CS2.ellips.inv_flattening,  ...
        'value is equal to EPSG code'});

   end

%% 3b Create depdendent variable

   %% Parameters with standard names
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
      %% Define dimensions in this order:
      %  time,z,y,x (note: snctools swaps, see getpref('SNCTOOLS')

        ifld = ifld + 1;
      nc(ifld).Name             = OPT.varname;
      nc(ifld).Nctype           = nc_type(OPT.type);
      nc(ifld).Dimension        = {'x_cen','y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
      nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(OPT.val(:)) max(OPT.val(:))]);
      if ~isempty(OPT.standard_name)
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      end
      if ~isempty(OPT.lon) & ~isempty(OPT.lat)
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      end
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
      end
      
%% 4 Create all variables with attibutes
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill all variables

      if ~isempty(OPT.x) & ~isempty(OPT.y)
      nc_varput(outputfile, 'x_cen'        , OPT.x');
      nc_varput(outputfile, 'y_cen'        , OPT.y');
      end

      nc_varput(outputfile, OPT.varname    , OPT.val); % save x as first dimension so ensure correct plotting in ncBrowse
      
      if ~isempty(OPT.epsg)
      nc_varput(outputfile, 'wgs84'        , OPT.wgs84);
      nc_varput(outputfile, 'epsg'         , OPT.epsg);
      end
      if ~isempty(OPT.lon) & ~isempty(OPT.lat)
         % nc_dump(outputfile,'longitude_cen')
         % size(OPT.lon)
      nc_varput(outputfile, 'longitude_cen', OPT.lon);
      nc_varput(outputfile, 'latitude_cen' , OPT.lat);
      end
      
%% 6 Check
   
      if OPT.dump
      nc_dump(outputfile);
      end

      if nargout==1
         varargout = {D};
      end

%% EOF