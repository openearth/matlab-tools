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
%See also: snctools, vs_use, delft3d2nc

% TO DO check consistency with delft3d_to_netcdf.exe of Bert Jagers
% TO DO add sediment, turbulence etc
% TO DO add cell methods to xcor = mean(x)

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

      OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
      OPT.refdatenum     = datenum(1970,1,1); % lunix  datenumber convention
      OPT.institution    = '';
      OPT.timezone       = timezone_code2iso('GMT');
      OPT.time           = 0;
      OPT.epsg           = [];
      OPT.type           = 'float'; %'double'; % the nefis file is by default singl precision
      OPT.debug          = 0;
      
      if ~odd(nargin)
         ncfile   = varargin{1};
         varargin = {varargin{2:end}};
      else
         ncfile   = fullfile(fileparts(vsfile),[filename(vsfile) '.nc']);
      end

      OPT      = setproperty(OPT,varargin{:});
      
      if nargin==0
         varargout = {OPT};
         return
      end

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
     [G.cen.lon,G.cen.lat] = convertcoordinates(G.cen.x,G.cen.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     [G.cor.lon,G.cor.lat] = convertcoordinates(G.cor.x,G.cor.y,'CS1.code',OPT.epsg,'CS2.code',4326);

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
      nc_add_dimension(ncfile, 'm'                , G.mmax-2);
      nc_add_dimension(ncfile, 'n'                , G.nmax-2);
      nc_add_dimension(ncfile, 'm_cor'            , G.mmax-1);
      nc_add_dimension(ncfile, 'n_cor'            , G.nmax-1);
      nc_add_dimension(ncfile, 'Layer'            , G.kmax  );
      nc_add_dimension(ncfile, 'LayerInterf'      , G.kmax+1);

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
      nc(ifld) = struct('Name', 'm', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 and n = nmax removed.');
      nc(ifld) = struct('Name', 'n', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 removed.');
      nc(ifld) = struct('Name', 'm_cor', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'m_cor'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 removed.');
      nc(ifld) = struct('Name', 'n_cor', ...
          'Nctype'   , 'int', ...
          'Dimension', {{'n_cor'}}, ...
          'Attribute', attr);

%% horizontal coordinates

   if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old error)
   
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and m/n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.x(:)) max(G.cen.x(:))]);
      nc(ifld) = struct('Name', 'x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centres, y-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and m/n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.y(:)) max(G.cen.y(:))]);
      nc(ifld) = struct('Name', 'y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, x-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.x(:)) max(G.cor.x(:))]);
      nc(ifld) = struct('Name', 'grid_x', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell corners, y-coordinate');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.y(:)) max(G.cor.y(:))]);
      nc(ifld) = struct('Name', 'grid_y', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, longitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lon(:)) max(G.cen.lon(:))]);
      nc(ifld) = struct('Name', 'longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, latitude-coordinate');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 and n = m/nmax removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cen.lat(:)) max(G.cen.lat(:))]);
      nc(ifld) = struct('Name', 'latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lon(:)) max(G.cor.lon(:))]);
      nc(ifld) = struct('Name', 'grid_longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell corners');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m/n = 1 removed.');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.cor.lat(:)) max(G.cor.lat(:))]);
      nc(ifld) = struct('Name', 'grid_latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

%% vertical coordinates

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
          
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'grid cell centers, depth');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'DP DP0 DPS');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'sea_floor_depth');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'grid_x grid_y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'grid_latitude grid_longitude');
      end
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc(ifld) = struct('Name', 'grid_depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
          
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

%% 3 Create variables

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
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'S1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'eta', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'n', 'm'}}, ...
          'Attribute', attr);
      
      if isfield(I,'salinity')
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'salinity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'salinity');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1e-3');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'R1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'salinity', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end

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
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'R1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'temperature', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      end

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'horizontal velocity component in x-direction');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'U1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'u', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'horizontal velocity component in y-direction');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'V1');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'v', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);
      
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
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'WPHY');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', NaN);
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'w', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Layer', 'n', 'm'}}, ...
          'Attribute', attr);

%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables

      nc_varput(ncfile, 'time'          , T.datenum - OPT.refdatenum);

      nc_varput(ncfile, 'm'             , [2:G.mmax-1  ]');
      nc_varput(ncfile, 'n'             , [2:G.nmax-1  ]');
      nc_varput(ncfile, 'm_cor'         , [1:G.mmax-1  ]');
      nc_varput(ncfile, 'n_cor'         , [1:G.nmax-1  ]');

      nc_varput(ncfile, 'x'             ,    G.cen.x);
      nc_varput(ncfile, 'y'             ,    G.cen.y);
      
      nc_attput(ncfile, 'x'             ,'actual_range',[min(G.cen.x(:)) max(G.cen.x(:))]);
      nc_attput(ncfile, 'y'             ,'actual_range',[min(G.cen.y(:)) max(G.cen.y(:))]);

      nc_varput(ncfile, 'grid_x'        ,    G.cor.x);
      nc_varput(ncfile, 'grid_y'        ,    G.cor.y);
      nc_attput(ncfile, 'grid_x'        ,'actual_range',[min(G.cor.x(:)) max(G.cor.x(:))]);
      nc_attput(ncfile, 'grid_y'        ,'actual_range',[min(G.cor.y(:)) max(G.cor.y(:))]);

      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))
      nc_varput(ncfile, 'longitude'     ,G.cen.lon);
      nc_varput(ncfile, 'latitude'      ,G.cen.lat);
      nc_attput(ncfile, 'longitude'     ,'actual_range',[min(G.cen.lon(:)) max(G.cen.lon(:))]);
      nc_attput(ncfile, 'latitude'      ,'actual_range',[min(G.cen.lat(:)) max(G.cen.lat(:))]);

      nc_varput(ncfile, 'grid_longitude',G.cor.lon);
      nc_varput(ncfile, 'grid_latitude' ,G.cor.lat);
      nc_attput(ncfile, 'grid_longitude','actual_range',[min(G.cor.lon(:)) max(G.cor.lon(:))]);
      nc_attput(ncfile, 'grid_latitude' ,'actual_range',[min(G.cor.lat(:)) max(G.cor.lat(:))]);
      end      

      data = vs_let(F,'map-const','THICK','quiet');
     [sigma,sigmaInterf] = d3d_sigma(data); % [0 .. 1]

      nc_varput(ncfile, 'k'             ,1:G.kmax);
      nc_varput(ncfile, 'Layer'         ,sigma-1);
      nc_attput(ncfile, 'Layer'         ,'actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);
				        
      nc_varput(ncfile, 'LayerInterf'   ,sigmaInterf-1);
      nc_attput(ncfile, 'LayerInterf'   ,'actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 0]

      nc_varput(ncfile, 'depth'         ,-G.cen.dep); % positive down !
      nc_varput(ncfile, 'grid_depth'    ,-G.cor.dep); % positive down !
      nc_attput(ncfile, 'depth'         ,'actual_range',[min(-G.cen.dep(:)) max(-G.cen.dep(:))]);
      nc_attput(ncfile, 'grid_depth'    ,'actual_range',[min(-G.cor.dep(:)) max(-G.cor.dep(:))]);
      
      nc_varput(ncfile, 'zactive'       ,G.cen.mask);
      nc_attput(ncfile, 'zactive'       ,'actual_range',[0 1]);
      
      i = 0;
      
      R.eta = [Inf -Inf];
      R.u   = [Inf -Inf];
      R.v   = [Inf -Inf];
      R.w   = [Inf -Inf];

      for it = OPT.time
      
      i = i + 1;
      
      disp(['processing timestep ',num2str(i),' of ',num2str(length(OPT.time)),' (# ',num2str(it),')'])
          
          %% update grid, incl waterlevel which determines z grid spacing
          
          G = vs_meshgrid3dcorcen(F, it, G);
          
          if isfield(I,'salinity')
          D.salinity    = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.salinity.index   },'quiet');
          nc_varput(ncfile,'salinity'   , shiftdim(D.salinity  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.salinity,2))       ]); % go from y, x, z to z, y, x
          end
          if isfield(I,'temperature')
          D.temperature = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.temperature.index},'quiet');
          nc_varput(ncfile,'temperature', shiftdim(D.temperature  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.temperature,2))       ]); % go from y, x, z to z, y, x
          end
          
         [D.u,D.v] = vs_let_vector_cen(F, 'map-series',{it},{'U1','V1'}, {0,0,0},'quiet');
          D.w      = vs_let_scalar    (F, 'map-series',{it},'WPHY'     , {0,0,0},'quiet');
          D.u      = permute(D.u,[4 2 3 1]); % z y x
          D.v      = permute(D.v,[4 2 3 1]); % z y x
          D.w      = permute(D.w,[3 1 2]);   % z y x
          
          %% apply masks
          
          G.cen.zwl = G.cen.zwl.*G.cen.mask;
          for k=1:size(D.u,1)
              D.u(k,:,:) = D.u(k,:,:).*permute(G.cen.mask,[3 1 2]);
              D.v(k,:,:) = D.v(k,:,:).*permute(G.cen.mask,[3 1 2]);
              %           D.w(k,:,:) = D.w(k,:,:).*permute(G.cen.mask,[3 1 2]);
          end
          
          %% write matrices

          nc_varput(ncfile,'eta'     , G.cen.zwl,[i-1, 0, 0   ],[1, size(G.cen.zwl   )]);
          nc_varput(ncfile,'u'       , D.u      ,[i-1, 0, 0, 0],[1, size(D.u         )]);
          nc_varput(ncfile,'v'       , D.v      ,[i-1, 0, 0, 0],[1, size(D.v         )]);
          nc_varput(ncfile,'w'       , D.w      ,[i-1, 0, 0, 0],[1, size(D.w         )]);
          
          R.eta = [min(R.eta(1),min(G.cen.zwl(:))) max(R.eta(2),max(G.cen.zwl(:)))];
          R.u   = [min(R.u  (1),min(D.u      (:))) max(R.u  (2),max(D.u      (:)))];  
          R.v   = [min(R.v  (1),min(D.v      (:))) max(R.v  (2),max(D.v      (:)))];  
          R.w   = [min(R.w  (1),min(D.w      (:))) max(R.w  (2),max(D.w      (:)))];
          
      end
      
      nc_attput(ncfile,'eta','actual_range',R.eta)
      nc_attput(ncfile,'u'  ,'actual_range',R.u  );
      nc_attput(ncfile,'v'  ,'actual_range',R.v  );
      nc_attput(ncfile,'w'  ,'actual_range',R.w  );
      
%% EOF      
