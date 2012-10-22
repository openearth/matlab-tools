function varargout = vs_trih2nc(vsfile,varargin)
%vs_trih2nc  Convert part of a Delft3D trih file to netCDF (BETA)
%
%   vs_trih2nc(NEFISfile,<'keyword',value>)
%   vs_trih2nc(NEFISfile,<netCDFfile>,<'keyword',value>)
%
% converts Delft3D trih file (NEFIS file) to a netCDF file in 
% the same directory with extension replaced by nc.
%
% Example:
%
%   vs_trih2nc('P:\aproject\trih-n15.dat','epsg',28992)
%
% nc looks same as nc of dflowfm, so it loads well into Quickplot.
%
% Example how to use this netCDF file: read all
%   H = nc2struct(ncfile)
%
% Example how to use this netCDF file: select one station
%   dflowfm.indexHis(ncfile,<station_name>);
%   ind = 48;
%   D.station_name = nc_varget (ncfile,'station_name',[  ind-1 0],[ 1 -1   ]);
%   D.eta          = nc_varget (ncfile,'waterlevel'  ,[0 ind-1  ],[-1  1   ]);
%   D.u            = nc_varget (ncfile,'u_x'         ,[0 ind-1 0],[-1  1 -1]);
%   D.v            = nc_varget (ncfile,'u_y'         ,[0 ind-1 0],[-1  1 -1]);
%   D.dep          = nc_varget (ncfile,'depth'       ,[  ind-1  ],[1]);
%   D.datenum      = nc_cf_time(ncfile)
%
%See also: snctools, vs_use, dflowfm, delft3d_io_obs, dflowfm.indexHis

% TO DO add morphological! depth
% TO DO check consistency with delft3d_to_netcdf.exe of Bert Jagers
% TO DO add sediment, turbulence etc
% TO DO add cell methods to xcor = mean(x)
% to do merge with OpenEarthTools\matlab\applications\cosmos\code\OMSRunner\fileio\trih2nc

%%  --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
      OPT.debug          = 0;
      OPT.time           = 0; % subset of time indices in NEFIS file, 1-based
      OPT.epsg           = 28992;
      OPT.type           = 'float'; %'double'; % the nefis file is by default single precision
      OPT.quiet          = 'quiet';
      OPT.mode           = 'clobber'; %'64bit_offset' creates a netcdf-3 file with 64-bit offset that cannot be used with Ncbrowse 
      OPT.stride         = 1; % write chunks per layer in case of large 3D matrices
      
      if nargin==0
         varargout = {OPT};
         return
      end
      
      if ~odd(nargin)
         ncfile   = varargin{1};
         varargin = {varargin{2:end}};
      else
         runid  = filename(vsfile); runid = runid(6:end); % remove 'trih-'
         ncfile = fullfile(fileparts(vsfile),[runid,'_his.nc']); % '_his' is same same as Delft3D-FM
      end

      OPT      = setproperty(OPT,varargin{:});

%% 0 Read raw data

      F = vs_use(vsfile,OPT.quiet);
      
      G = vs_trih_station(F);
      
      T.datenum = vs_time(F,OPT.time,'quiet');
      if OPT.time==0
      OPT.time = 1:length(T.datenum);
      end
      I = vs_get_constituent_index(F);
      M.datestr     = datestr(datenum(vs_get(F,'his-version','FLOW-SIMDAT',OPT.quiet),'yyyymmdd  HHMMSS'),31);
      M.version     = ['Delft3D-FLOW version : ',strtrim(vs_get(F,'his-version','FLOW-SYSTXT',OPT.quiet)),', file version: ',strtrim(vs_get(F,'his-version','FILE-VERSION',OPT.quiet))];
      M.description = vs_get(F,'his-version','FLOW-RUNTXT',OPT.quiet);

%% 1a Create file (add all NEFIS 'map-version' group info)

      nc_create_empty (ncfile,OPT.mode)

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(ncfile, nc_global, 'title'         , '');
      nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(ncfile, nc_global, 'source'        , 'Delft3D trih file');
      nc_attput(ncfile, nc_global, 'history'       ,['Original filename: ',vsfile,...
                                                     ', version: ' ,M.version,...
                                                     ', file date:',M.datestr,...
                                                     ', tranformation to netCDF: $HeadURL$']);
      nc_attput(ncfile, nc_global, 'references'    , '');
      nc_attput(ncfile, nc_global, 'email'         , '');
   
      nc_attput(ncfile, nc_global, 'comment'       , '');
      nc_attput(ncfile, nc_global, 'version'       , ['$Id$ $HeadURL$ ', M.version]);
   						   
      nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.4');
      nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(ncfile, nc_global, 'terms_for_use' ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc_attput(ncfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
      nc_attput(ncfile, nc_global, 'description'   , str2line(M.description));

%% Add discovery information (test):

      %  http://www.unidata.ucar.edu/projects/THREDDS/tech/catalog/InvCatalogSpec.html
   
      if ~isempty(OPT.epsg)
     [G.lon,G.lat] = convertCoordinates(G.x,G.y,'CS1.code',OPT.epsg,'CS2.code',4326);
     [G.lon,G.lat] = convertCoordinates(G.x,G.y,'CS1.code',OPT.epsg,'CS2.code',4326);

      nc_attput(ncfile, nc_global, 'geospatial_lat_min'  , min(G.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_max'  , max(G.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_min'  , min(G.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_max'  , max(G.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_units', 'degrees_north');
      nc_attput(ncfile, nc_global, 'geospatial_lon_units', 'degrees_east' );
      end

      nc_attput(ncfile, nc_global, 'time_coverage_start' , datestr(T.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(ncfile, nc_global, 'time_coverage_end'   , datestr(T.datenum(end),'yyyy-mm-ddPHH:MM:SS'));

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'time'             , length(T.datenum));
      nc_add_dimension(ncfile, 'Station'          , size(G.name,1))
      nc_add_dimension(ncfile, 'station_name_len' , size(G.name,2));
      nc_add_dimension(ncfile, 'Layer'            , G.kmax  );
      nc_add_dimension(ncfile, 'LayerInterf'      , G.kmax+1);

      ifld = 0;
      ifld     = ifld + 1;clear attr;d3d_name = 'NAMST';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'station_name');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'station_name', ...
          'Nctype'   , 'char', ...
          'Dimension', {{'Station','station_name_len'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.m(:)) max(G.m(:))]);
      nc(ifld) = struct('Name', 'station_m_index', ...
          'Nctype'   , OPT.type, ...	
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.n(:)) max(G.n(:))]);
      nc(ifld) = struct('Name', 'station_n_index', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr;d3d_name = 'ALFAS';
      attr(    1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'station_angle', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);

   if any(strfind(G.coordinates,'CARTESIAN'))
   
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.x(:)) max(G.x(:))]);
      nc(ifld) = struct('Name', 'station_x_coordinate', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.y(:)) max(G.y(:))]);
      nc(ifld) = struct('Name', 'station_y_coordinate', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);

   end

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lon(:)) max(G.lon(:))]);
      nc(ifld) = struct('Name', 'station_longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell centers');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lat(:)) max(G.lat(:))]);
      nc(ifld) = struct('Name', 'station_latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);

   end

      ifld     = ifld + 1;clear attr; d3d_name = 'DPS';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(    1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc(ifld) = struct('Name', 'depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Station'}}, ...
          'Attribute', attr);

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
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma thickness at layer midpoints');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '%');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      nc(ifld) = struct('Name', 'THICK', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: sigma eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      nc(ifld) = struct('Name', 'sigma', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);
          
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer interfaces');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: sigmaInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      nc(ifld) = struct('Name', 'sigmaInterf', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'LayerInterf'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      nc(ifld) = struct('Name', 'time', ...
          'Nctype'   , 'double', ... % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
          'Dimension', {{'time'}}, ...
          'Attribute', attr);

%% 3 Create variables

      ifld     = ifld + 1;clear attr; d3d_name = 'ZWL';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_elevation');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'waterlevel', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Station'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr;d3d_name = 'ZCURU';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'eastward_sea_water_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'u_x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time','Station','Layer'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr;d3d_name = 'ZCURV';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'northward_sea_water_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      else 
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'u_y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time','Station','Layer'}}, ...
          'Attribute', attr);
      
% (a) bottom shear stresses

      ifld     = ifld + 1;clear attr; d3d_name = 'ZTAUKS';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_northward_stress');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_x_stress');
      end      
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'N m-2');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
      nc(ifld) = struct('Name', 'tau_x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Station'}}, ...
          'Attribute', attr);      
    
      ifld     = ifld + 1;clear attr; d3d_name = 'ZTAUET';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_eastward_stress');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_y_stress');
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'N m-2');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
      nc(ifld) = struct('Name', 'tau_y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', 'Station'}}, ...
          'Attribute', attr); 
      
 % (b) salinity
 
      d3d_name = 'GRO';
      if ~isempty(vs_get_elm_def(F,d3d_name))
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_salinity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'psu');
      if isempty(OPT.epsg)
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'salinity', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time','Station','Layer'}}, ...
          'Attribute', attr);
      end
   
% to do
%       ifld     = ifld + 1;clear attr
%       attr(    1)  = struct('Name', 'standard_name', 'Value', 'specific_kinetic_energy_of_sea_water');
%       attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'k');       % not in NEFIS file
%       attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2 s-2');  % not in NEFIS file 
%       if isempty(OPT.epsg)
%       attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
%       else
%       attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
%       end
%       attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'ZTUR');
%       attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
%       attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
%       nc(ifld) = struct('Name', 'TKE', ...
%           'Nctype'   , OPT.type, ...
%           'Dimension', {{'time','Station','LayerInterf'}}, ...
%           'Attribute', attr);
%       
%       ifld     = ifld + 1;clear attr
%       attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_kinetic_energy_dissipation_per_unit_area_due_to_vertical_friction');
%       attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'eps');    % not in NEFIS file
%       attr(end+1)  = struct('Name', 'units'        , 'Value', 'W m-2');  % not in NEFIS file
%       if isempty(OPT.epsg)
%       attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'x y');
%       else
%       attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
%       end
%       attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'ZTUR');
%       attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
%       attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
%       nc(ifld) = struct('Name', 'eps', ...
%           'Nctype'   , OPT.type, ...
%           'Dimension', {{'time','Station','LayerInterf'}}, ...
%           'Attribute', attr);
      
%% 4 Create variables with attributes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables

      nc_varput(ncfile, 'station_name'        , G.name);
      nc_varput(ncfile, 'station_angle'       , G.angle);
      nc_varput(ncfile, 'station_m_index'     , G.m);
      nc_varput(ncfile, 'station_n_index'     , G.n);
      nc_varput(ncfile, 'station_x_coordinate', G.x);
      nc_varput(ncfile, 'station_y_coordinate', G.y);
      nc_varput(ncfile, 'time'         , T.datenum - OPT.refdatenum);
      nc_varput(ncfile, 'k'            , [1:G.kmax   ]');
      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))
      nc_varput(ncfile, 'station_longitude'    ,G.lon);
      nc_varput(ncfile, 'station_latitude'     ,G.lat);
      end      
      
      THICK = vs_let(F,'his-const','THICK',OPT.quiet);
     [sigma,sigmaInterf] = d3d_sigma(THICK); % [0 .. 1]
      
      nc_varput(ncfile,'THICK',THICK);
      nc_attput(ncfile,'THICK','actual_range',[min(THICK) max(THICK)]);

      nc_varput(ncfile,'sigma',sigma-1);
      nc_attput(ncfile,'sigma','actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);

      nc_varput(ncfile,'sigmaInterf',sigmaInterf-1);
      nc_attput(ncfile,'sigmaInterf','actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 1]
      
      data = vs_let(F,'his-const','DPS',OPT.quiet);
      nc_varput(ncfile,'depth',data);
      nc_attput(ncfile,'depth','actual_range',[min(data(:)) max(data(:))]);

      data = vs_let(F,'his-series','ZWL',OPT.quiet);
      nc_varput(ncfile,'waterlevel',data);
      nc_attput(ncfile,'waterlevel','actual_range',[min(data(:)) max(data(:))]);

      if OPT.stride
          for k=1:G.kmax
              data = vs_let(F,'his-series','ZCURU',{0 k},OPT.quiet);
              nc_varput(ncfile,'u_x',data,[0 0 k-1],[size(data) 1]);
              data = vs_let(F,'his-series','ZCURV',{0 k},OPT.quiet);
              nc_varput(ncfile,'u_y',data,[0 0 k-1],[size(data) 1]);
          end
% to do       
%           for k=1:G.kmax+1
%               data = vs_let(F,'his-series','ZTUR',{0 k 1},OPT.quiet);
%               nc_varput(ncfile,'TKE',data,[0 0 k-1],[size(data) 1]);
%               data = vs_let(F,'his-series','ZTUR',{0 k 2},OPT.quiet);
%               nc_varput(ncfile,'eps',data,[0 0 k-1],[size(data) 1]);
%           end
      else
          data = vs_let(F,'his-series','ZCURU',OPT.quiet);
          nc_varput(ncfile,'u_x',data);
          nc_attput(ncfile,'u_x','actual_range',[min(data(:)) max(data(:))]);

          data = vs_let(F,'his-series','ZCURV',OPT.quiet);
          nc_varput(ncfile,'u_y',data);
          nc_attput(ncfile,'u_y','actual_range',[min(data(:)) max(data(:))]);
% to do
%           data = vs_let(F,'his-series','ZTUR',{0 0 1},OPT.quiet);
%           nc_varput(ncfile,'TKE',data);
%           nc_attput(ncfile,'TKE','actual_range',[min(data(:)) max(data(:))]);
% 
%           data = vs_let(F,'his-series','ZTUR',{0 0 2},OPT.quiet);
%           nc_varput(ncfile,'eps',data);
%           nc_attput(ncfile,'eps','actual_range',[min(data(:)) max(data(:))]);
      end

     data = vs_let(F,'his-series','ZTAUKS',OPT.quiet);
     nc_varput(ncfile,'tau_x',data);
     nc_attput(ncfile,'tau_x','actual_range',[min(data(:)) max(data(:))]);

     data = vs_let(F,'his-series','ZTAUET',OPT.quiet);
     nc_varput(ncfile,'tau_y',data);
     nc_attput(ncfile,'tau_y','actual_range',[min(data(:)) max(data(:))]);

     %data = vs_let(F,'his-series','FLTR',OPT.quiet);)
     %nc_varput(ncfile,'cumQ',data);
     %nc_attput(ncfile,'cumQ','actual_range',data)

     %data = vs_let(F,'his-series','CTR',OPT.quiet);
     %nc_varput(ncfile,'Q',data);
     %nc_attput(ncfile,'Q','actual_range',data)

      if isfield(I,'salinity')  
      if OPT.stride
          for k=1:G.kmax
              data = vs_let(F,'his-series','GRO',{0,[ k ],[ 1 ]},OPT.quiet);
              nc_varput(ncfile,'salinity',data,[0 0 k-1],[size(data) 1]);
          end
      else
          data = vs_let(F,I.salinity.groupname,I.salinity.elementname,{0,0,[ I.salinity.index ]},OPT.quiet);
          nc_varput(ncfile,'salinity',data);
          nc_attput(ncfile,'salinity','actual_range',[min(data(:)) max(data(:))]);
      end   
      end
      if isfield(I,'temperature')
      end
      
%% EOF      
