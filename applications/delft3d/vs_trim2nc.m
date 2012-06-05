function varargout = vs_trim2nc(vsfile,varargin)
%VS_TRIM2NC  Convert part of a Delft3D trim file to netCDF (BETA)
%
%   vs_trim2nc(NEFISfile,<'keyword',value>)
%   vs_trim2nc(NEFISfile,<netCDFfile>,<'keyword',value>)
%
% converts Delft3D trim file (NEFIS file) to a netCDF file in 
% the same directory with extension replaced by nc.
%
% Example:
%
%   vs_trim2nc('P:\aproject\trim-n15.dat','epsg',28992,'time',5)
%
% By default is converts all native delft3d output variables, 
% but you can also select a subset with keyword 'var'.Call 
% VS_TRIM2NC() without argument to find out which ones are 
% available in 'var_cf', 'var_primary' and 'var_derived'.
%
%See also: snctools, vs_use, delft3d2nc

% TO DO better check consistency with delft3d_to_netcdf.exe of Bert Jagers
% TO DO add sediment etc

%%  --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%
%       Gerben de Boer / Fedor Baart / Kees den Heijer
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

%% keywords

      OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wrong dates in ncbrowse due to different calendars. Must use doubles here.
      OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
      OPT.institution    = '';
      OPT.timezone       = timezone_code2iso('GMT');
      OPT.time           = 0;
      OPT.epsg           = [];
      OPT.type           = 'float'; %'double'; % the nefis file is by default single precision
      OPT.debug          = 0;
      OPT.var_cf         = {'time','m','n','Layer','LayerInterf','longitude','latitude'};
      OPT.var_primary    = {'grid_m','grid_n','x','y','grid_x','grid_y','grid_longitude','grid_latitude','k','grid_depth','depth','zactive','waterlevel','salinity','temperature','u','v','w','density','tke','eps'};
      OPT.var_derived    = {'pea','area'};
      OPT.var            = {OPT.var_cf{:},OPT.var_primary{:}};
      OPT.var_all        = {OPT.var_cf{:},OPT.var_primary{:},OPT.var_derived{:}};

      if nargin==0
         varargout = {OPT};
         return
      end
      
      if ~odd(nargin)
         ncfile   = varargin{1};
         varargin = {varargin{2:end}};
      else
         ncfile   = fullfile(fileparts(vsfile),[filename(vsfile) '.nc']);
      end

      OPT      = setproperty(OPT,varargin{:});

%% 0 Read raw data

      F = vs_use(vsfile);
      G = vs_meshgrid2dcorcen(F);
      
      T = vs_time(F,OPT.time);
      if OPT.time==0
      OPT.time = 1:length(T.datenum);
      end
      I = vs_get_constituent_index(F);
      M.datestr     = datestr(datenum(vs_get(F,'map-version','FLOW-SIMDAT' ),'yyyymmdd  HHMMSS'),31);
      M.version     = ['Delft3D-FLOW version : ',strtrim(vs_get(F,'map-version','FLOW-SYSTXT' )),', file version: ',strtrim(vs_get(F,'map-version','FILE-VERSION'))];
      M.description = vs_get(F,'map-version','FLOW-RUNTXT');
      
%% 1a Create file (add all NEFIS 'map-version' group info)

      nc_create_empty (ncfile)

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(ncfile, nc_global, 'title'         , '');
      nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(ncfile, nc_global, 'source'        , 'Delft3D trim file');
      nc_attput(ncfile, nc_global, 'history'       ,['Original filename: ',vsfile,...
                                                     ', version: ' ,M.version,...
                                                     ', file date:',M.datestr,...
                                                     ', tranformation to netCDF: $HeadURL$']);
      nc_attput(ncfile, nc_global, 'references'    , '');
      nc_attput(ncfile, nc_global, 'email'         , '');
   
      nc_attput(ncfile, nc_global, 'comment'       , '');
      nc_attput(ncfile, nc_global, 'version'       , M.version);
   						   
      nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
      nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(ncfile, nc_global, 'terms_for_use' ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc_attput(ncfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
      nc_attput(ncfile, nc_global, 'description'   , str2line(M.description));

%% Add discovery information (test):

      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
      if ~isempty(OPT.epsg)
     [G.cen.lon,G.cen.lat] = convertCoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     [G.cor.lon,G.cor.lat] = convertCoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);

      nc_attput(ncfile, nc_global, 'geospatial_lat_min'  , min(G.cor.lat(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_max'  , max(G.cor.lat(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_min'  , min(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_max'  , max(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_units', 'degrees_north');
      nc_attput(ncfile, nc_global, 'geospatial_lon_units', 'degrees_east' );
      end

      nc_attput(ncfile, nc_global, 'time_coverage_start' , datestr(T.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(ncfile, nc_global, 'time_coverage_end'   , datestr(T.datenum(end),'yyyy-mm-ddPHH:MM:SS'));

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'time'             , length(T.datenum));
      nc_add_dimension(ncfile, 'm'                , G.mmax-2); % we remove dummy rows/cols
      nc_add_dimension(ncfile, 'n'                , G.nmax-2);
      nc_add_dimension(ncfile, 'Layer'            , G.kmax  );
      nc_add_dimension(ncfile, 'LayerInterf'      , G.kmax+1);
      nc_add_dimension(ncfile, 'bounds2'          , 2); % for corner (grid_*) indices
      nc_add_dimension(ncfile, 'bounds4'          , 4); % for corner (grid_*) coordinates

      if any(strcmp('grid_depth',OPT.var))
      nc_add_dimension(ncfile, 'grid_m'           , G.mmax-1);
      nc_add_dimension(ncfile, 'grid_n'           , G.nmax-1);
      end

      ifld = 0;

%% time
     
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      nc(ifld) = struct('Name', 'time', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time'}}, ...
          'Attribute', attr);

%% add values of dimensions

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 and m = mmax removed.');
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_m');
      nc(ifld) = struct('Name', 'm', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 and n = nmax removed.');
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_n');
      nc(ifld) = struct('Name', 'n', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 removed.');
      nc(ifld) = struct('Name', 'grid_m', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m','bounds2'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 removed.');
      nc(ifld) = struct('Name', 'grid_n', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n','bounds2'}}, ...
          'Attribute', attr);

%% horizontal coordinates: (x,y) and (lon,lat), on centres and corners

   if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old bug)
   
      if any(strcmp('x',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XZ map-const:XWAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and m/n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.x(:)) max(G.cen.x(:))]);
      if any(strcmp('grid_x',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_x');
      end
      nc(ifld) = struct('Name', 'x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('y',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, y-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YZ map-const:YWAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and m/n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.y(:)) max(G.cen.y(:))]);
      if any(strcmp('grid_y',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_y');
      end
      nc(ifld) = struct('Name', 'y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end

      if any(strcmp('grid_x',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.x(:)) max(G.cor.x(:))]);
      nc(ifld) = struct('Name', 'grid_x', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n', 'm','bounds4'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('grid_y',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, y-coordinate');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.y(:)) max(G.cor.y(:))]);
      nc(ifld) = struct('Name', 'grid_y', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n', 'm','bounds4'}}, ...
          'Attribute', attr);
      end

   end

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)

      if any(strcmp('longitude',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, longitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XZ map-const:XWAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lon(:)) max(G.cen.lon(:))]);
      if any(strcmp('grid_longitude',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_longitude');
      end
      nc(ifld) = struct('Name', 'longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('latitude',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, latitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YZ map-const:YWAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lat(:)) max(G.cen.lat(:))]);
      if any(strcmp('grid_latitude',OPT.var))
      attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'grid_latitude');
      end
      nc(ifld) = struct('Name', 'latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end

      if any(strcmp('grid_longitude',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lon(:)) max(G.cor.lon(:))]);
      nc(ifld) = struct('Name', 'grid_longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm','bounds4'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('grid_latitude',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lat(:)) max(G.cor.lat(:))]);
      nc(ifld) = struct('Name', 'grid_latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm','bounds4'}}, ...
          'Attribute', attr);
      end
   end

%% vertical coordinates

      if any(strcmp('k',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'layer index');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1, the bottom layer has index kmax.');
      nc(ifld) = struct('Name', 'k', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);
      end

      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: sigma eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      nc(ifld) = struct('Name', 'Layer', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);
          
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer interfaces');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: sigmaInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      nc(ifld) = struct('Name', 'LayerInterf', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'LayerInterf'}}, ...
          'Attribute', attr);
          
%% bathymetry

      if any(strcmp('grid_depth',OPT.var))
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, depth');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-const:DP map-const:DP0 map-const:DPS map-const:DRYFLP');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'sea_floor_depth');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      % NB for values at corners there is no bounds matrix
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc(ifld) = struct('Name', 'grid_depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'grid_n', 'grid_m'}}, ...
          'Attribute', attr);
      end
          
      if any(strcmp('depth',OPT.var))
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'depth of cell corners');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'DPS0');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'sea_floor_depth');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc(ifld) = struct('Name', 'depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end

      if any(strcmp('zactive',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'KCS');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Non-active/active in cell centre');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'KCS');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'zactive', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('area',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'area of grid cells');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The exact area spanned geometrically by the 4 corner points is not identical to area GSQS used internally in Delft3D for mass-conservation!');
      nc(ifld) = struct('Name', 'area', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      end

%% 3 Create variables: momentum and mass conservation

      if any(strcmp('waterlevel',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_elevation');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'water level');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:S1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'waterlevel', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'n', 'm'}}, ...
          'Attribute', attr);
      end

      if any(strcmp('u',OPT.var)) | any(strcmp('v',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, x-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:U1 map-series:V1 map-const:ALFAS');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'u', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, y-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:U1 map-series:V1 map-const:ALFAS');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'v', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('w',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'upward_sea_water_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'vertical velocity');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:WPHY');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'w', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      
%% 3 Create variables: scalars

      if any(strcmp('density',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_density');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'density');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m3');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RHO');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'density', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      
      if any(strcmp('pea',OPT.var))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Potential Energy Anomaly (PEA)');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'J/m3');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'references'   , 'Value', 'de Boer et al, Ocean Modelling 2008. http://dx.doi.org/10.1016/j.ocemod.2007.12.003');
      nc(ifld) = struct('Name', 'pea', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'n', 'm'}}, ...
          'Attribute', attr);
      end

      if any(strcmp('salinity',OPT.var))
      if isfield(I,'salinity')
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'salinity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'salinity');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'ppt');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'salinity', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      end

      if any(strcmp('temperature',OPT.var))
      if isfield(I,'temperature')
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'temperature');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'temperature');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degree_Celsius');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:R1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'temperature', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      end

      if any(strcmp('tke',OPT.var))
      if isfield(I,'turbulent_energy')
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'turbulent kinetic energy');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s2');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RTUR1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'tke', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'LayerInterf', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      end

      if any(strcmp('eps',OPT.var))
      if isfield(I,'energy_dissipation')
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'turbulent energy dissipation');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s3');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'map-series:RTUR1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'eps', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'LayerInterf', 'n', 'm'}}, ...
          'Attribute', attr);
      end
      end

%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables (always)

      nc_varput(ncfile, 'time'          , T.datenum - OPT.refdatenum);
      nc_varput(ncfile, 'm'             , [2:G.mmax-1  ]');
      nc_varput(ncfile, 'n'             , [2:G.nmax-1  ]');
      nc_varput(ncfile, 'grid_m'        , nc_cf_cor2bounds([1:G.mmax-1  ]'));
      nc_varput(ncfile, 'grid_n'        , nc_cf_cor2bounds([1:G.nmax-1  ]'));

      data = vs_let(F,'map-const','THICK','quiet');
     [sigma,sigmaInterf] = d3d_sigma(data); % [0 .. 1]

      nc_varput(ncfile, 'Layer'         ,sigma-1);
      nc_attput(ncfile, 'Layer'         ,'actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);
      nc_varput(ncfile, 'LayerInterf'   ,sigmaInterf-1);
      nc_attput(ncfile, 'LayerInterf'   ,'actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 0]

%% 5 Fill variables (optional)

      if     any(strcmp('x',OPT.var))
      nc_varput(ncfile, 'x'             ,    G.cen.x);
      nc_attput(ncfile, 'x'             ,'actual_range',[min(G.cen.x(:)) max(G.cen.x(:))]);
      end
      
      if     any(strcmp('y',OPT.var))
      nc_varput(ncfile, 'y'             ,    G.cen.y);
      nc_attput(ncfile, 'y'             ,'actual_range',[min(G.cen.y(:)) max(G.cen.y(:))]);
      end

      if     any(strcmp('grid_x',OPT.var))
      nc_varput(ncfile, 'grid_x'        ,    nc_cf_cor2bounds(G.cor.x));
      nc_attput(ncfile, 'grid_x'        ,'actual_range',[min(G.cor.x(:)) max(G.cor.x(:))]);
      end

      if     any(strcmp('grid_y',OPT.var))
      nc_varput(ncfile, 'grid_y'        ,    nc_cf_cor2bounds(G.cor.y));
      nc_attput(ncfile, 'grid_y'        ,'actual_range',[min(G.cor.y(:)) max(G.cor.y(:))]);
      end

      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      if     any(strcmp('longitude',OPT.var))
      nc_varput(ncfile, 'longitude'     ,G.cen.lon);
      nc_attput(ncfile, 'longitude'     ,'actual_range',[min(G.cen.lon(:)) max(G.cen.lon(:))]);
      end
      if     any(strcmp('latitude',OPT.var))
      nc_varput(ncfile, 'latitude'      ,G.cen.lat);
      nc_attput(ncfile, 'latitude'      ,'actual_range',[min(G.cen.lat(:)) max(G.cen.lat(:))]);
      end

      if     any(strcmp('grid_longitude',OPT.var))
      nc_varput(ncfile, 'grid_longitude',nc_cf_cor2bounds(G.cor.lon));
      nc_attput(ncfile, 'grid_longitude','actual_range',[min(G.cor.lon(:)) max(G.cor.lon(:))]);
      end      

      if     any(strcmp('grid_latitude',OPT.var))
      nc_varput(ncfile, 'grid_latitude' ,nc_cf_cor2bounds(G.cor.lat));
      nc_attput(ncfile, 'grid_latitude' ,'actual_range',[min(G.cor.lat(:)) max(G.cor.lat(:))]);
      end      
      end

      if     any(strcmp('k',OPT.var))
      nc_varput(ncfile, 'k'          ,1:G.kmax);
      end

      if     any(strcmp('grid_depth',OPT.var))
      nc_varput(ncfile, 'grid_depth',-G.cor.dep); % positive down !
      nc_attput(ncfile, 'grid_depth','actual_range',[min(-G.cor.dep(:)) max(-G.cor.dep(:))]);
      end      

      if     any(strcmp('depth'     ,OPT.var))
      nc_varput(ncfile, 'depth'     ,-G.cen.dep); % positive down !
      nc_attput(ncfile, 'depth'     ,'actual_range',[min(-G.cen.dep(:)) max(-G.cen.dep(:))]);
      end      

      if     any(strcmp('zactive'   ,OPT.var))
      nc_varput(ncfile, 'zactive'   ,G.cen.mask);
      nc_attput(ncfile, 'zactive'   ,'actual_range',[0 1]);
      end      

      if     any(strcmp('area'      ,OPT.var))
      nc_varput(ncfile, 'area'      ,G.cen.area);
      nc_attput(ncfile, 'area'      ,'actual_range',[0 1]);
      end      

      i = 0;
      
      if any(strcmp('waterlevel' ,OPT.var));R.waterlevel  = [Inf -Inf];end
      if any(strcmp('u'          ,OPT.var));R.u           = [Inf -Inf];end
      if any(strcmp('v'          ,OPT.var));R.v           = [Inf -Inf];end
      if any(strcmp('w'          ,OPT.var));R.w           = [Inf -Inf];end
      if any(strcmp('density'    ,OPT.var));R.density     = [Inf -Inf];end
      if any(strcmp('pea'        ,OPT.var));R.pea         = [Inf -Inf];end
      if any(strcmp('salinity'   ,OPT.var));R.salinity    = [Inf -Inf];end
      if any(strcmp('temperature',OPT.var));R.temperature = [Inf -Inf];end

      for it = OPT.time
      
      i = i + 1;
      
      disp(['processing timestep ',num2str(i),' of ',num2str(length(OPT.time)),' (# ',num2str(it),')'])
          
          %% update grid, incl waterlevel which determines z grid spacing
          %  apply masks
          %  write matrices
          
          G = vs_meshgrid3dcorcen(F, it, G);
          
          if any(strcmp('waterlevel',OPT.var))
          G.cen.zwl = G.cen.zwl.*G.cen.mask;
          nc_varput(ncfile,'waterlevel'     , G.cen.zwl,[i-1, 0, 0   ],[1, size(G.cen.zwl   )]);
          R.waterlevel = [min(R.waterlevel(1),min(G.cen.zwl(:))) max(R.waterlevel(2),max(G.cen.zwl(:)))];
          end
          
          if any(strcmp('u',OPT.var)) | any(strcmp('v',OPT.var))
         [D.u,D.v] = vs_let_vector_cen(F, 'map-series',{it},{'U1','V1'}, {0,0,0},'quiet');
          D.u      = permute(D.u,[4 2 3 1]); % z y x
          D.v      = permute(D.v,[4 2 3 1]); % z y x
          for k=1:size(D.u,1)
              D.u(k,:,:) = D.u(k,:,:).*permute(G.cen.mask,[3 1 2]);
              D.v(k,:,:) = D.v(k,:,:).*permute(G.cen.mask,[3 1 2]);
              %           D.w(k,:,:) = D.w(k,:,:).*permute(G.cen.mask,[3 1 2]);
          end
          nc_varput(ncfile,'u'       , D.u      ,[i-1, 0, 0, 0],[1, size(D.u         )]);
          nc_varput(ncfile,'v'       , D.v      ,[i-1, 0, 0, 0],[1, size(D.v         )]);
          R.u   = [min(R.u  (1),min(D.u      (:))) max(R.u  (2),max(D.u      (:)))];  
          R.v   = [min(R.v  (1),min(D.v      (:))) max(R.v  (2),max(D.v      (:)))];  
          end
         
          if any(strcmp('w',OPT.var))
          D.w      = vs_let_scalar    (F, 'map-series',{it},'WPHY'     , {0,0,0},'quiet');
          D.w      = permute(D.w,[3 1 2]);   % z y x
          nc_varput(ncfile,'w'       , D.w      ,[i-1, 0, 0, 0],[1, size(D.w         )]);
          R.w   = [min(R.w  (1),min(D.w      (:))) max(R.w  (2),max(D.w      (:)))];
          end
          
          if any(strcmp('density',OPT.var)) | any(strcmp('pea',OPT.var))
          data3d = vs_let_scalar    (F,'map-series' ,{it},'RHO'      , {0 0 0},'quiet');
          if any(strcmp('density',OPT.var))
          nc_varput(ncfile,'density', shiftdim(data3d,2),[i-1, 0  0  0], [1, size(shiftdim(data3d,2))]); % go from y, x, z to z, y, x
          R.density = [min(R.density(1),min(data3d(:))) max(R.density(2),max(data3d(:)))];
          end
          if any(strcmp('pea',OPT.var))
          data2d = pea_simpson_et_al_1990(G.cen.intf.z,data3d,3,'weights',G.sigma_dz);
          nc_varput(ncfile,'pea'     , data2d,[i-1, 0, 0   ],[1, size(data2d   )]);
          R.pea = [min(R.pea(1),min(data2d(:))) max(R.pea(2),max(data2d(:)))];
          end
          end
          
          if any(strcmp('salinity',OPT.var))
          if isfield(I,'salinity')
          data3d    = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.salinity.index   },'quiet');
          nc_varput(ncfile,'salinity'   , shiftdim(data3d  ,2),[i-1, 0  0  0], [1, size(shiftdim(data3d,2))]); % go from y, x, z to z, y, x
          R.salinity = [min(R.salinity(1),min(data3d(:))) max(R.salinity(2),max(data3d(:)))];
          end
          end
          
          if any(strcmp('temperature',OPT.var))
          if isfield(I,'temperature')
          data3d = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.temperature.index},'quiet');
          nc_varput(ncfile,'temperature', shiftdim(data3d  ,2),[i-1, 0  0  0], [1, size(shiftdim(data3d,2))]); % go from y, x, z to z, y, x
          R.temperature = [min(R.temperature(1),min(data3d(:))) max(R.temperature(2),max(data3d(:)))];
          end
          end

      end
      
%% add actual ranges

      varnames = fieldnames(R);

      for ivar=1:length(varnames)
      varname = varnames{ivar};
      nc_attput(ncfile,varname  ,'actual_range',R.(varname));
      end
      
      if OPT.debug
      nc_dump(ncfile)
      end

%% EOF      
