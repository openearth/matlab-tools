function varargout = arcgis2nc(ncfile,D,varargin)
%ARCGIS2NC  save arcGRID file, with optional meta-info, as netCDF file
%
%   arcgis2nc(ncfilename,D,<keyword,value>)
%
% saves struct D as read by ARCGISREAD as netCDF-CF file.
% When keyword 'epsg' is supplied, full latitude and longitude
% matrixes are written to the netCDF file too. To get a list 
% of all keywords, call ARCGIS2NC without arguments.
%
%   OPT = arcgis2nc()
%
%See also: ARCGISREAD, SNCTOOLS, NC_CF_GRID, ARCGRIDREAD (in $ mapping toolbox)

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
   OPT.convertperline = 1;  % when memory limitations are present

%% User defined meta-info

   OPT.varname        = 'val';
   OPT.long_name      = '';
   OPT.standard_name  = '';
   OPT.units          = '';
   OPT.epsg           = [];  % if specified, (lat,lon) are added
   OPT.type           = []; % [] = auto, single or double
   OPT.latitude_type  = 'double'; % 'double' % 'single'
   OPT.longitude_type = 'double'; % 'double' % 'single'
   
   OPT.title          = '';
   OPT.institution    = '';
   OPT.source         = '';
   OPT.history        = ['Original filename: ',filename(D.filename),...
                         ', tranformation to NetCDF: $HeadURL$'];
   OPT.references     = '';
   OPT.email          = '';
   OPT.comment        = '';
   OPT.version        = '';
   OPT.acknowledge    = 'These data can be used freely for research purposes provided that the following source is acknowledged: ?';
   OPT.disclaimer     = 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.';

   if nargin==0;D = OPT;return;end; % make function act as object
   
   OPT      = setProperty(OPT,varargin{:})

   if isempty(OPT.type)
   OPT.type          = class(D.(OPT.varname)); % single or double
   end
   OPT.fillvalue     = nan(OPT.type); % as to appear in netCDF file, not as appeared in arcgrid file

%% 1a Create file

      outputfile = ncfile;
   
      nc_create_empty (outputfile)
   
      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
      %------------------
   
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
      %------------------
      
      % TO DO, based on OPT.epsg
   
      %% Local Cartesian coordinates
      %------------------

        ifld = ifld + 1;
      nc(ifld).Name         = 'x_cen';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'x_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'x-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_x_coordinate'); % standard name
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(4) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end
   
        ifld = ifld + 1;
      nc(ifld).Name         = 'y_cen';
      nc(ifld).Nctype       = 'int';
      nc(ifld).Dimension    = {'y_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'y-coordinate in Cartesian system');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'm');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'projection_y_coordinate'); % standard name
      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(4) = struct('Name', 'epsg'           ,'Value', OPT.epsg);
      end

      %% Latitude-longitude
      %------------------
      
      if ~isempty(OPT.epsg)
      
      %c calculate per row because of memeroy issues for large matrices
     [x    ,y    ] = meshgrid(D.x,D.y);
      D.lon        = repmat(nan,size(D.(OPT.varname)));
      D.lat        = repmat(nan,size(D.(OPT.varname)));
      
       %consider as 1D matrix and do section bys ection
      
      if    OPT.convertperline
      for ii=1:size(D.lat,1)
      disp([num2str(ii),'/',num2str(size(D.lat,1))])
     [D.lon(ii,:),D.lat(ii,:)] = convertcoordinates(x(ii,:),y(ii,:),'CS1.code',OPT.epsg,'CS2.code',4326);
      end
      else
     [D.lon      ,D.lat      ] = convertcoordinates(x      ,y      ,'CS1.code',OPT.epsg,'CS2.code',4326);
      end
      
      clear x y
      
      %% Longitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#longitude-coordinate
      %------------------

        ifld = ifld + 1;
      nc(ifld).Name         = 'longitude_cen';
      nc(ifld).Nctype       = nc_type(OPT.longitude_type);
      nc(ifld).Dimension    = {'x_cen','y_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'longitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_east');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'longitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'actual_range'   ,'Value', [min(D.lon(:)) max(D.lon(:))]); % 

      %% Latitude
      % http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#latitude-coordinate
      %------------------

        ifld = ifld + 1;
      nc(ifld).Name         = 'latitude_cen';
      nc(ifld).Nctype       = nc_type(OPT.latitude_type);
      nc(ifld).Dimension    = {'x_cen','y_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', 'latitude');
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', 'degrees_north');
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', 'latitude'); % standard name
      nc(ifld).Attribute(4) = struct('Name', 'actual_range'   ,'Value', [min(D.lat(:)) max(D.lat(:))]); % 

       end

      %% Parameters with standard names
      % * http://cf-pcmdi.llnl.gov/documents/cf-standard-names/standard-name-table/current/
      %------------------
   
      %% Define dimensions in this order:
      %  time,z,y,x

        ifld = ifld + 1;
      nc(ifld).Name         = OPT.varname;
      nc(ifld).Nctype       = nc_type(OPT.type);
      nc(ifld).Dimension    = {'x_cen','y_cen'};
      nc(ifld).Attribute(1) = struct('Name', 'long_name'      ,'Value', OPT.long_name);
      nc(ifld).Attribute(2) = struct('Name', 'units'          ,'Value', OPT.units);
      nc(ifld).Attribute(3) = struct('Name', 'standard_name'  ,'Value', OPT.standard_name);
      nc(ifld).Attribute(4) = struct('Name', '_FillValue'     ,'Value', OPT.fillvalue);
      nc(ifld).Attribute(5) = struct('Name', 'actual_range'   ,'Value', [min(D.(OPT.varname)(:)) max(D.(OPT.varname)(:))]);

      if ~isempty(OPT.epsg)
      nc(ifld).Attribute(6) = struct('Name', 'coordinates'    ,'Value', 'latitude_cen longitude_cen');
      end
      
%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         nc_addvar(outputfile, nc(ifld));   
      end
      
%% 5 Fill variables
   
      nc_varput(outputfile, 'x_cen'        , D.x);
      nc_varput(outputfile, 'y_cen'        , D.y);
      nc_varput(outputfile, OPT.varname    , D.(OPT.varname)'); % save x as first dimension so ensure correct plotting in ncBrowse
      
      if ~isempty(OPT.epsg)
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