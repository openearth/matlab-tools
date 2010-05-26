function varargout = arcgis2nc(ncfile,D,varargin)
%ARCGIS2NC  save arcGRID file, with optional meta-info, as netCDF file
%
%   arcgis2nc(ncfilename,D             ,<keyword,value>)
%   arcgis2nc(ncfilename,arcgisfilename,<keyword,value>)
%
% saves struct D as read by ARCGISREAD as netCDF-CF file (*.nc).
% When keyword 'epsg' is supplied, the full latitude and longitude
% matrixes are written to the netCDF file too. To get a list 
% of all keywords, call ARCGIS2NC without arguments.
%
%   OPT = arcgis2nc()
%
% The following keywords are required:
% * units       units of arcgis variable
% * long_name   description of arcgis variable as to appear in plots
%
%See also: ARCGISREAD, SNCTOOLS, NC_CF_GRID, ARCGRIDREAD (in $ mapping toolbox)

% TO DO: add corner matrices

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

 if ischar(D); 
   fname = D;
 else
   fname = D.filename;
end

%% User defined keywords

   OPT.dump           = 1;
   OPT.disp           = 10; % stride in progres display
   OPT.convertperline = 1;  % when memory limitations are present

%% User defined meta-info

   %% global

      OPT.title          = '';
      OPT.institution    = '';
      OPT.source         = '';
      OPT.history        = ['Original filename: ',fname,...
                            ', tranformation to NetCDF: $HeadURL$'];
      OPT.references     = '';
      OPT.email          = '';
      OPT.comment        = '';
      OPT.version        = '';
      OPT.acknowledge    =['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution];
      OPT.disclaimer     = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';
   
   %% dimensions/coordinates

      OPT.epsg           = []; % if specified, (lat,lon) are added
      OPT.latitude_type  = 'double'; % 'double' % 'single'
      OPT.longitude_type = 'double'; % 'double' % 'single'
      
   %% variables

      OPT.units          = '';
      OPT.varname        = 'val'; % consistent with default ArcGisRead
      OPT.long_name      = '';
      OPT.standard_name  = '';
      OPT.type           = []; % [] = auto, single or double
      OPT.wgs84          = 4326;

   %% handle meta-info

      if nargin==0;D = OPT;return;end; % make function act as object
   
      OPT      = setproperty(OPT,varargin{:});
      
   %% errors

   if isempty(OPT.units    );error  ('For a netCDF file is required   : units'        );end
   if isempty(OPT.long_name);error  ('For a netCDF file is required   : long_name'    );end
   if isempty(OPT.long_name);warning('For a netCDF file is recommended: standard_name');end
   if isempty(OPT.epsg     );warning('For a netCDF file is recommended: epsg'         );end
      
%% Data

   if ischar(D)
      D = arcgisread(D,'units',OPT.units,...
                     'varname',OPT.varname,...
                   'long_name',OPT.long_name,...
               'standard_name',OPT.standard_name);
   end

%% Type

      if isempty(OPT.type)
      OPT.type          = class(D.(OPT.varname)); % single or double
      end
      OPT.fillvalue     = nan(OPT.type); % as to appear in netCDF file, not as appeared in arcgrid file

%% 1a Create file

      outputfile = ncfile;
   
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
      
%% 2 Create dimensions
   
      nc_add_dimension(outputfile, 'x_cen', D.ncols); % use this as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
      nc_add_dimension(outputfile, 'y_cen', D.nrows); % use this as 2nd array dimension to get correct plot in ncBrowse (snctools swaps for us)

%% 3 Create variables
   
      clear nc
      ifld = 0;
   
   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#appendix-grid-mappings
   %  TO DO, based on OPT.epsg
   %  Local Cartesian coordinates

        ifld = ifld + 1;
      nc(ifld).Name             = 'x_cen';
      nc(ifld).Nctype           = 'int';
      nc(ifld).Dimension        = {'x_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.x(:)) max(D.x(:))]);
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
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.y(:)) max(D.y(:))]);
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end

   %% Latitude-longitude
      
   if ~isempty(OPT.epsg)
      
      % calculate per row because of memory issues for large matrices
      
     [x    ,y    ] = meshgrid(D.x,D.y);
      D.lon        = repmat(nan,size(D.(OPT.varname)));
      D.lat        = repmat(nan,size(D.(OPT.varname)));
      
      % compromise: consider 2D matrix as 1D vector and do section by section
      
      if    OPT.convertperline
      d = 2;
      for ii=1:d:size(D.lat,1)
      iii = ii+(1:d)-1;
      iii = iii(iii < size(D.lat,1));
      disp(['converting coordinates to (lat,lon): ',num2str(min(iii)),'-',num2str(max(iii)),'/',num2str(size(D.lat,1))])
     [D.lon(iii,:),D.lat(iii,:),log] = convertcoordinates(x(iii,:),y(iii,:),'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      else
     [D.lon       ,D.lat       ,log] = convertcoordinates(x      ,y      ,'CS1.code',OPT.epsg,'CS2.code',OPT.wgs84);
      end
      
      clear x y
      
   %% Longitude
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name             = 'longitude_cen';
      nc(ifld).Nctype           = nc_type(OPT.longitude_type);
      nc(ifld).Dimension        = {'x_cen','y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.lon(:)) max(D.lon(:))]); % 
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
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.lat(:)) max(D.lat(:))]); % 
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'wgs84');

   %% Coordinate system
   %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate

        ifld = ifld + 1;
      nc(ifld).Name         = 'epsg';
      nc(ifld).Nctype       = nc_int;
      nc(ifld).Dimension    = {};
      nc(ifld).Attribute = struct('Name', ...
       {'grid_mapping_name', ...
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
        {log.proj_conv1.method.name,     ...
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
       {'semi_major_axis', ...
        'semi_minor_axis', ...
        'inverse_flattening', ...
        'comment'}, ...
        'Value', ...
        {log.CS2.ellips.semi_major_axis, ...
         log.CS2.ellips.semi_minor_axis, ...
         log.CS2.ellips.inv_flattening,  ...
        'value is equal to EPSG code'});

   end

   %% Parameters with standard names
   %  http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
   
      %% Define dimensions in this order:
      %  time,z,y,x (note: snctools swaps)

        ifld = ifld + 1;
      nc(ifld).Name             = OPT.varname;
      nc(ifld).Nctype           = nc_type(OPT.type);
      nc(ifld).Dimension        = {'x_cen','y_cen'};
      nc(ifld).Attribute(    1) = struct('Name', 'long_name'      ,'Value', OPT.long_name    );
      nc(ifld).Attribute(end+1) = struct('Name', 'units'          ,'Value', OPT.units        );
      nc(ifld).Attribute(end+1) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue    );
      nc(ifld).Attribute(end+1) = struct('Name', 'actual_range'   ,'Value', [min(D.(OPT.varname)(:)) max(D.(OPT.varname)(:))]);
      if ~isempty(OPT.standard_name)
      nc(ifld).Attribute(end+1) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      end
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(end+1) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      nc(ifld).Attribute(end+1) = struct('Name', 'grid_mapping'   ,'Value', 'epsg');
      end
      
%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill variables
   
      nc_varput(outputfile, 'x_cen'        , D.x');
      nc_varput(outputfile, 'y_cen'        , D.y');
      nc_varput(outputfile, OPT.varname    , D.(OPT.varname)'); % save x as first dimension so ensure correct plotting in ncBrowse
      nc_varput(outputfile, 'wgs84'        , OPT.wgs84);
      
      if ~isempty(OPT.epsg)
      nc_varput(outputfile, 'epsg'         , OPT.epsg);
      nc_varput(outputfile, 'longitude_cen', D.lon');
      nc_varput(outputfile, 'latitude_cen' , D.lat');
      end
      
%% 6 Check
   
      if OPT.dump
      nc_dump(outputfile);
      end

      if nargout==1
         varargout = {D};
      end

%% EOF