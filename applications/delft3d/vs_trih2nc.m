function varargout = vs_trih2nc(vsfile,varargin)
%vs_trih2nc  Convert part of a Delft3D trih file to netCDF-CF
%
%   vs_trih2nc(NEFISfile,<'keyword',value>)
%   vs_trih2nc(NEFISfile,<netCDFfile>,<'keyword',value>)
%
% converts Delft3D trih file (NEFIS file) to a netCDF file which has
% default name <RUNID>_his.nc to conform with default dflowfm history output.
% Do specify timezone and epsg code, to conform to CF standard and facilitate reuse.
%
% Example:
%
%   vs_trih2nc('P:\aproject\trih-n15.dat','epsg',28992,'timezone',timezone_code2iso('GMT'))
%
% nc looks same as history nc of dflowfm, so be used in dflowfm.analyseHis, and
% loads well into Quickplot. 
%
% Example how to use this netCDF file: read all
%   H = nc2struct(ncfile)
%
% Example how to use this netCDF file: select one platform
%   dflowfm.indexHis(ncfile,<platform_name>);
%   ind = 48;
%   D.platform_name = nc_varget (ncfile,'platform_name',[  ind-1 0],[ 1 -1   ]);
%   D.eta           = nc_varget (ncfile,'waterlevel'   ,[0 ind-1  ],[-1  1   ]);
%   D.u             = nc_varget (ncfile,'u_x'          ,[0 ind-1 0],[-1  1 -1]);
%   D.v             = nc_varget (ncfile,'u_y'          ,[0 ind-1 0],[-1  1 -1]);
%   D.dep           = nc_varget (ncfile,'depth'        ,[  ind-1  ],[1]);
%   D.datenum       = nc_cf_time(ncfile)
%
% Note:  you can make an nc_dump cdl ascii file a char for keyword dump:
%        vs_trih2nc('tst.dat','dump','tst.cdl');
% Note:  you can save only a subset of stations, or reorder them, to netCDF file with keyword 'ind'
%
%See also: vs_trim2nc for trim-*.dat delft3d-flow map file,
%          netcdf, snctools, vs_use, dflowfm, delft3d_io_obs, dflowfm.indexHis, dflowfm.analyseHis

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
      OPT.timezone       = ''; %timezone_code2iso('GMT');
      OPT.debug          = 0;
      OPT.time           = 0; % subset of time indices in NEFIS file, 1-based
      OPT.epsg           = [];
      OPT.type           = 'float'; %'double'; % the nefis file is by default single precision
      OPT.quiet          = 'quiet';
      OPT.mode           = 'clobber'; %'64bit_offset' creates a netcdf-3 file with 64-bit offset that cannot be used with Ncbrowse 
      OPT.stride         = 1; % write chunks per layer in case of large 3D matrices
      OPT.dump           = 1;

      OPT.ind            = 0; % index of stations to include in netCDF file, 0=all
      OPT.trajectory     = 0; % consider 'Stations' dimension as spatial trajectory dimension

      % TO DO: allow to transform sub-period too.
      % TO DO: implement WI and PI from griddata_near2, and add rename dimension 'Station' to 'distance'
      % TO DO: make QP fit for trajectory plotting
      
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
      
      T.datenum = vs_time(F,OPT.time,'quiet');
      if OPT.time==0
      OPT.time = 1:length(T.datenum);
      end
      I = vs_get_constituent_index(F);
      M.datestr     = datestr(datenum(vs_get(F,'his-version','FLOW-SIMDAT',OPT.quiet),'yyyymmdd  HHMMSS'),31);
      M.version     = ['Delft3D-FLOW version : ',strtrim(vs_get(F,'his-version','FLOW-SYSTXT',OPT.quiet)),', file version: ',strtrim(vs_get(F,'his-version','FILE-VERSION',OPT.quiet))];
      M.description = vs_get(F,'his-version','FLOW-RUNTXT',OPT.quiet);

%% 1a Create file (add all NEFIS 'his-version' group info)
      nc_create_empty (ncfile,OPT.mode)

      %% Add overall meta info
      %  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents
   
      nc_attput(ncfile, nc_global, 'title'         , '');
      nc_attput(ncfile, nc_global, 'institution'   , OPT.institution);
      nc_attput(ncfile, nc_global, 'source'        , 'Delft3D trih file');
      nc_attput(ncfile, nc_global, 'history'       ,['Original filename: ',filenameext(vsfile),...
                                                     ', version: ' ,M.version,...
                                                     ', file date:',M.datestr,...
                                                     ', tranformation to netCDF: $HeadURL$']);
      nc_attput(ncfile, nc_global, 'references'    , '');
      nc_attput(ncfile, nc_global, 'email'         , '');
   
      nc_attput(ncfile, nc_global, 'comment'       , '');
      nc_attput(ncfile, nc_global, 'version'       , ['$Id$ $HeadURL$ ', M.version]);
   						   
      nc_attput(ncfile, nc_global, 'Conventions'   , 'CF-1.6');
      nc_attput(ncfile, nc_global, 'CF:featureType', 'Grid');  % https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
   
      nc_attput(ncfile, nc_global, 'terms_for_use' ,['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
      nc_attput(ncfile, nc_global, 'disclaimer'    , 'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');
   
      nc_attput(ncfile, nc_global, 'description'   , str2line(M.description));

%% Coordinate system

      G.kmax        =                 vs_let(F,'his-const','KMAX'       ,'quiet');
      G.coordinates = strtrim(permute(vs_let(F,'his-const','COORDINATES','quiet'),[1 3 2]));

      G.m           = squeeze(vs_let(F,'his-const','MNSTAT',{1,OPT.ind},'quiet'));
      G.n           = squeeze(vs_let(F,'his-const','MNSTAT',{2,OPT.ind},'quiet'));
      
      G.angle       = squeeze(vs_let(F,'his-const','ALFAS' ,{  OPT.ind},'quiet'));
      G.kmax        = squeeze(vs_let(F,'his-const','KMAX'  ,            'quiet'));
      G.name        = permute(vs_let(F,'his-const','NAMST' ,{  OPT.ind},'quiet'),[2 3 1]);

   %% real and transform world coordinates,
   %  define coordinate attribute

   if any(strfind(G.coordinates,'CART')) % CARTESIAN, CARTHESIAN (old bug)
      
      G.x           = squeeze(vs_let(F,'his-const','XYSTAT',{1,OPT.ind},'quiet'));
      G.y           = squeeze(vs_let(F,'his-const','XYSTAT',{2,OPT.ind},'quiet'));
      coordinates   = 'x y';
      if ~(isempty(OPT.epsg)||isnan(OPT.epsg))
        [G.lon,G.lat] = convertCoordinates(G.x,G.y,'CS1.code',OPT.epsg,'CS2.code',4326);
        [G.lon,G.lat] = convertCoordinates(G.x,G.y,'CS1.code',OPT.epsg,'CS2.code',4326);
      else
         fprintf(2,'> No EPSG code specified for CARTESIAN grid, your grid is not CF compliant:\n')
         fprintf(2,'> (latitude,longitude) cannot be calculated from (x,y)!\n')
      end
      
   else
   
      G.lon         = squeeze(vs_let(F,'his-const','XYSTAT',{1,OPT.ind},'quiet'));
      G.lat         = squeeze(vs_let(F,'his-const','XYSTAT',{2,OPT.ind},'quiet'));
      coordinates   = 'latitude longitude';
      if ~(isempty(OPT.epsg)||isnan(OPT.epsg))
        [G.x  ,G.y  ] = convertCoordinates(G.lon,G.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
        [G.x  ,G.y  ] = convertCoordinates(G.lon,G.lat,'CS1.code',4326,'CS2.code',OPT.epsg);
      end

   end
   
   %% vertical: z/sigma

      G.layer_model = strtrim(permute(vs_let(F,'his-const','LAYER_MODEL','quiet'),[1 3 2]));

      if strmatch('SIGMA-MODEL', G.layer_model)
      G.sigma_dz      =  vs_let(F,'his-const','THICK','quiet');   
     [G.sigma_cent,...
      G.sigma_intf]   = d3d_sigma(G.sigma_dz);
      coordinatesLayer        = [coordinates]; % implicit via formula_terms att
      coordinatesLayerInterf  = [coordinates]; % implicit via formula_terms att
      elseif strmatch('Z-MODEL', G.layer_model)
      fprintf(2,'> Z-MODEL has not yet been tested.\n')
      G.ZK          =  vs_let(F,'his-const'     ,'ZK'               ,'quiet');
      coordinatesLayer        = [coordinates]; % ' Layer'
      coordinatesLayerInterf  = [coordinates]; % ' LayerInterf'
      end

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'time'             , length(T.datenum));
      if OPT.trajectory
      dimname = 'Trajectory';
      G.trajectory = distance(G.x,G.y);
      else
      dimname = 'Station';
      nc_add_dimension(ncfile, 'station_name_len' , size(G.name,2));
      end
      nc_add_dimension(ncfile, dimname            , size(G.name,1))
      nc_add_dimension(ncfile, 'Layer'            , G.kmax  );
      nc_add_dimension(ncfile, 'LayerInterf'      , G.kmax+1);


%% time

      if isempty(OPT.timezone)
         fprintf(2,'> No model timezone supplied, timezone could NOT be added to netCDF file. This will be interpreted as GMT! \n')
      end

      ifld     = 1;clear attr dims
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
      nc(ifld) = struct('Name', 'time', ...
          'Nctype'   , 'double', ... % !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
          'Dimension', {{'time'}}, ...
          'Attribute', attr);

%% platforms/stations/observation points or trajectory

   if OPT.trajectory

      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'trajectory');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.trajectory(:)) max(G.trajectory(:))]);
      nc(ifld) = struct('Name', 'Trajectory', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);

   else

      ifld     = ifld + 1;clear attr;d3d_name = 'NAMST';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'platform_name');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'station_name', ...
          'Nctype'   , 'char', ...
          'Dimension', {{dimname,'station_name_len'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.m(:)) max(G.m(:))]);
      nc(ifld) = struct('Name', 'station_m_index', ...
          'Nctype'   , OPT.type, ...	
          'Dimension', {{dimname}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'MNSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.n(:)) max(G.n(:))]);
      nc(ifld) = struct('Name', 'station_n_index', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr;d3d_name = 'ALFAS';
      attr(    1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'station_angle', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);

   end

%% horizontal coordinates: (x,y) and (lon,lat), on centres and corners

   if any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
   
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'x of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.x(:)) max(G.x(:))]);
      nc(ifld) = struct('Name', 'x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'y of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.y(:)) max(G.y(:))]);
      nc(ifld) = struct('Name', 'y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);
   end

   if (~isempty(OPT.epsg)) || (~any(strfind(G.coordinates,'CARTESIAN')))

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lon(:)) max(G.lon(:))]);
      nc(ifld) = struct('Name', 'longitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude of station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'XYSTAT');
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(G.lat(:)) max(G.lat(:))]);
      nc(ifld) = struct('Name', 'latitude', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);

   end

%% vertical coordinates

      if strmatch('SIGMA-MODEL', G.layer_model)

      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: Layer eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:THICK');
      nc(ifld) = struct('Name', 'Layer', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);
          
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'sigma at layer interfaces');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'ocean_sigma_coordinate');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: LayerInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1 and is sigma=0, the bottom layer has index kmax and is sigma=-1.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:THICK');
      nc(ifld) = struct('Name', 'LayerInterf', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'LayerInterf'}}, ...
          'Attribute', attr);
      
      elseif strmatch('Z-MODEL', G.layer_model)

      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer midpoints');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: Layer eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:ZK');
      nc(ifld) = struct('Name', 'Layer', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'Layer'}}, ...
          'Attribute', attr);
          
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'long_name'    , 'Value', 'z at layer interfaces');
      attr(end+1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'formula_terms', 'Value', 'sigma: LayerInterf eta: waterlevel depth: depth'); % requires depth to be positive !!
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bottom layer has index k=1 and is the bottom depth, the surface layer has index kmax and is z=free water surface.');
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', 'his-const:KMAX his-const:LAYER_MODEL his-const:ZK');
      nc(ifld) = struct('Name', 'LayerInterf', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'LayerInterf'}}, ...
          'Attribute', attr);
      
      end % z/sigma

%% bathymetry

      ifld     = ifld + 1;clear attr; d3d_name = 'DPS';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
      attr(    1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', '');
      nc(ifld) = struct('Name', 'depth', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{dimname}}, ...
          'Attribute', attr);
          
%% 3 Create (primary) variables: momentum and mass conservation

      ifld     = ifld + 1;clear attr; d3d_name = 'ZWL';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_elevation');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      nc(ifld) = struct('Name', 'waterlevel', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', dimname}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr; d3d_name = 'ZKFS';
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'active');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '1');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'flag_values'  , 'Value', [0 1]);
      attr(end+1)  = struct('Name', 'flag_meanings', 'Value', 'inactive active ');
      nc(ifld) = struct('Name', 'mask', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', dimname}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr;d3d_name = 'ZCURU';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'eastward_sea_water_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lon-component');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_x_velocity'); % surface_geostrophic_sea_water_x_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, x-component');
      end
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_x = [Inf -Inf];
      nc(ifld) = struct('Name', 'u_x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr;d3d_name = 'ZCURV';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'northward_sea_water_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, lat-component');
      else 
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_y_velocity'); % surface_geostrophic_sea_water_y_velocity_assuming_sea_level_for_geoid
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, y-component');
      end
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_y = [Inf -Inf];
      nc(ifld) = struct('Name', 'u_y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr;d3d_name = 'ZCURW';
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'upward_sea_water_velocity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'velocity, z-component');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(end+1)  = struct('Name', 'positive'     , 'Value', 'up');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.u_z = [Inf -Inf];
      nc(ifld) = struct('Name', 'u_z', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
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
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
      nc(ifld) = struct('Name', 'tau_x', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', dimname}}, ...
          'Attribute', attr);      
    
      ifld     = ifld + 1;clear attr; d3d_name = 'ZTAUET';
      if (~any(strfind(G.coordinates,'CART'))) % CARTESIAN, CARTHESIAN (old bug)
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_eastward_stress');
      else
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'surface_downward_y_stress');
      end
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', vs_get_elm_def(F,d3d_name,'Description'));
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'N m-2');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);
      attr(end+1)  = struct('Name', 'comment'      , 'Value', 'The bed shear stresses are in real world directions x and y');
      nc(ifld) = struct('Name', 'tau_y', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time', dimname}}, ...
          'Attribute', attr); 
      
 % (b) density: temperature + salinity
 
      d3d_name = 'ZRHO';
      if ~isempty(vs_get_elm_def(F,d3d_name))
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_density');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Density in station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg/m3');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.density = [Inf -Inf];
      nc(ifld) = struct('Name', 'density', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);
      end
 
      d3d_name = 'GRO';
      if ~isempty(vs_get_elm_def(F,d3d_name))
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_salinity');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Salinity in station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'psu');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.salinity = [Inf -Inf];
      nc(ifld) = struct('Name', 'salinity', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);
 
      ifld     = ifld + 1;clear attr;
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'sea_water_temperature');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Temperature in station');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'degree_Celsius');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.temperature = [Inf -Inf];
      nc(ifld) = struct('Name', 'temperature', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);
      end
   
 % (c) turbulence

      d3d_name = 'ZTUR';
      if ~isempty(vs_get_elm_def(F,d3d_name))
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'specific_kinetic_energy_of_sea_water'); %?
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Turbulent kinetic energy in station'); % not in NEFIS file
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s2'); % not in NEFIS file 
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.tke = [Inf -Inf];
      nc(ifld) = struct('Name', 'tke', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'LayerInterf'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', 'ocean_kinetic_energy_dissipation_per_unit_area_due_to_vertical_friction'); %?
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Turbulent dissipation in station');    % not in NEFIS file
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm2/s3'); % 'W m-2'); % not in NEFIS file
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN));
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.eps = [Inf -Inf];
      nc(ifld) = struct('Name', 'eps', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'LayerInterf'}}, ...
          'Attribute', attr);
      end
      
      d3d_name = 'ZVICWW';
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy viscosity-3D');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.viscosity_z = [Inf -Inf];
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'viscosity_z', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'LayerInterf'}}, ...
          'Attribute', attr);
      
      d3d_name = 'ZDICWW';
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Vertical eddy diffusivity-3D');
      attr(end+1)  = struct('Name', 'units'        , 'Value', 'm^2/s');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinatesLayerInterf);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.diffusivity_z = [Inf -Inf];
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name);
      nc(ifld) = struct('Name', 'diffusivity_z', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'LayerInterf'}}, ...
          'Attribute', attr);

      d3d_name = 'ZRICH';
      ifld     = ifld + 1;clear attr
      attr(    1)  = struct('Name', 'standard_name', 'Value', '');
      attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Richardson number');
      attr(end+1)  = struct('Name', 'units'        , 'Value', '-');
      attr(end+1)  = struct('Name', 'coordinates'  , 'Value', coordinates);
      attr(end+1)  = struct('Name', '_FillValue'   , 'Value', single(NaN)); % this initializes at NaN rather than 9.9692e36
      attr(end+1)  = struct('Name', 'actual_range' , 'Value', [nan nan]);R.Ri = [Inf -Inf];
      attr(end+1)  = struct('Name', 'delft3d_name' , 'Value', d3d_name');
      nc(ifld) = struct('Name', 'Ri', ...
          'Nctype'   , OPT.type, ...
          'Dimension', {{'time',dimname,'Layer'}}, ...
          'Attribute', attr);

%% 4 Create variables with attributes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables

   if OPT.trajectory
      nc_varput(ncfile, 'Trajectory'          , G.trajectory);
   else
      nc_varput(ncfile, 'station_name'        , G.name);
      nc_varput(ncfile, 'station_angle'       , G.angle);
      nc_varput(ncfile, 'station_m_index'     , G.m);
      nc_varput(ncfile, 'station_n_index'     , G.n);
   end
      if any(strfind(G.coordinates,'CARTESIAN')) || ~isempty(OPT.epsg)
      nc_varput(ncfile, 'x', G.x);
      nc_varput(ncfile, 'y', G.y);
      end
      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))      
      nc_varput(ncfile, 'longitude'  , G.lon);
      nc_varput(ncfile, 'latitude'   , G.lat);
      end
      nc_varput(ncfile, 'time'         , T.datenum - OPT.refdatenum);
      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))
      nc_varput(ncfile, 'longitude'    ,G.lon);
      nc_varput(ncfile, 'latitude'     ,G.lat);
      end      
      
      if strmatch('SIGMA-MODEL', G.layer_model)
      matrix = vs_let(F,'his-const','THICK','quiet');
     [sigma,sigmaInterf] = d3d_sigma(matrix); % [0 .. 1]
      nc_varput(ncfile,'Layer'         ,sigma-1);
      nc_attput(ncfile,'Layer'         ,'actual_range',[min(sigma(:)-1) max(sigma(:)-1)]);
      
      nc_varput(ncfile,'LayerInterf'   ,sigmaInterf-1);
      nc_attput(ncfile,'LayerInterf'   ,'actual_range',[min(sigmaInterf(:)-1) max(sigmaInterf(:)-1)]); % [-1 0]
      elseif strmatch('Z-MODEL', G.layer_model)

      Layer = corner2center1(G.ZK);
      nc_varput(ncfile,'Layer'         ,Layer);
      nc_attput(ncfile,'Layer'         ,'actual_range',[min(Layer(:)) max(Layer(:))]);
      
      nc_varput(ncfile,'LayerInterf'   ,G.ZK);
      nc_attput(ncfile,'LayerInterf'   ,'actual_range',[min(G.ZK(:)) max(G.ZK(:))]);
      end
      
      matrix = vs_let(F,'his-const','DPS',{OPT.ind},OPT.quiet);
      nc_varput(ncfile,'depth',matrix);
      nc_attput(ncfile,'depth','actual_range',[min(matrix(:)) max(matrix(:))]);

      matrix = vs_let(F,'his-series','ZWL',{OPT.ind},OPT.quiet);
      nc_varput(ncfile,'waterlevel',matrix);
      nc_attput(ncfile,'waterlevel','actual_range',[min(matrix(:)) max(matrix(:))]);

      matrix = vs_let(F,'his-series','ZKFS',{OPT.ind},OPT.quiet);
      nc_varput(ncfile,'mask',matrix);
      nc_attput(ncfile,'mask','actual_range',[min(matrix(:)) max(matrix(:))]);

      if OPT.stride
          for k=1:G.kmax

              matrix = vs_let(F,'his-series','ZCURU',{OPT.ind,k},OPT.quiet);
              nc_varput(ncfile,'u_x',matrix,[0 0 k-1],[size(matrix) 1]);
              R.u_x(1) = min(R.u_x(1),min(matrix(:)));
              R.u_x(2) = max(R.u_x(2),max(matrix(:)));

              matrix = vs_let(F,'his-series','ZCURV',{OPT.ind,k},OPT.quiet);
              nc_varput(ncfile,'u_y',matrix,[0 0 k-1],[size(matrix) 1]);
              R.u_y(1) = min(R.u_y(1),min(matrix(:)));
              R.u_y(2) = max(R.u_y(2),max(matrix(:)));

              matrix = vs_let(F,'his-series','ZCURW',{OPT.ind,k},OPT.quiet);
              nc_varput(ncfile,'u_z',matrix,[0 0 k-1],[size(matrix) 1]);
              R.u_z(1) = min(R.u_z(1),min(matrix(:)));
              R.u_z(2) = max(R.u_z(2),max(matrix(:)));

          end
      else
          matrix = vs_let(F,'his-series','ZCURU',{OPT.ind,0},OPT.quiet);
          nc_varput(ncfile,'u_x',matrix);
          R.u_x = [min(matrix(:)) max(matrix(:))];

          matrix = vs_let(F,'his-series','ZCURV',{OPT.ind,0},OPT.quiet);
          nc_varput(ncfile,'u_y',matrix);
          R.u_y = [min(matrix(:)) max(matrix(:))];

          matrix = vs_let(F,'his-series','ZCURW',{OPT.ind,0},OPT.quiet);
          nc_varput(ncfile,'u_z',matrix);
          R.u_z = [min(matrix(:)) max(matrix(:))];
      end
      
      matrix = vs_let(F,'his-series','ZTAUKS',{OPT.ind},OPT.quiet);
      nc_varput(ncfile,'tau_x',matrix);
      nc_attput(ncfile,'tau_x','actual_range',[min(matrix(:)) max(matrix(:))]);
      
      matrix = vs_let(F,'his-series','ZTAUET',{OPT.ind},OPT.quiet);
      nc_varput(ncfile,'tau_y',matrix);
      nc_attput(ncfile,'tau_y','actual_range',[min(matrix(:)) max(matrix(:))]);

      if OPT.stride
         for k=1:G.kmax
            matrix = vs_let(F,'his-series','ZRHO',{OPT.ind,k},OPT.quiet);
            nc_varput(ncfile,'density',matrix,[0 0 k-1],[size(matrix) 1]);
            R.density(1) = min(R.density(1),min(matrix(:)));
            R.density(2) = max(R.density(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZRHO',{OPT.ind,0},OPT.quiet);
         nc_varput(ncfile,'density',matrix);
         R.density = [min(R.density(1),min(matrix(:))) max(R.density(2),max(matrix(:)))];
      end   

 % (b) density: temperature + salinity

      if isfield(I,'salinity')  
      if OPT.stride
         for k=1:G.kmax
            matrix = vs_let(F,'his-series','GRO',{OPT.ind,k,I.salinity.index},OPT.quiet);
            nc_varput(ncfile,'salinity',matrix,[0 0 k-1],[size(matrix) 1]);
            R.salinity(1) = min(R.salinity(1),min(matrix(:)));
            R.salinity(2) = max(R.salinity(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','GRO',{OPT.ind,0,I.salinity.index},OPT.quiet);
         nc_varput(ncfile,'salinity',matrix);
         R.salinity = [min(R.salinity(1),min(matrix(:))) max(R.salinity(2),max(matrix(:)))];
      end   
      end

      if isfield(I,'temperature')
      if OPT.stride
         for k=1:G.kmax
            matrix = vs_let(F,'his-series','GRO',{OPT.ind,k,I.temperature.index},OPT.quiet);
            nc_varput(ncfile,'temperature',matrix,[0 0 k-1],[size(matrix) 1]);
            R.temperature(1) = min(R.temperature(1),min(matrix(:)));
            R.temperature(2) = max(R.temperature(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','GRO',{OPT.ind,0,I.temperature.index},OPT.quiet);
         nc_varput(ncfile,'temperature',matrix);
         R.temperature = [min(R.temperature(1),min(matrix(:))) max(R.temperature(2),max(matrix(:)))];
      end   
      end
      
 % (c) turbulence

      if isfield(I,'turbulent_energy')  
      if OPT.stride
         for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,k,I.turbulent_energy.index},OPT.quiet);
            nc_varput(ncfile,'tke',matrix,[0 0 k-1],[size(matrix) 1]);
            R.tke(1) = min(R.tke(1),min(matrix(:)));
            R.tke(2) = max(R.tke(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,0,I.turbulent_energy.index},OPT.quiet);
         nc_varput(ncfile,'tke',matrix);
         R.tke = [min(R.tke(1),min(matrix(:))) max(R.tke(2),max(matrix(:)))];
      end   
      end

      if isfield(I,'energy_dissipation')  
      if OPT.stride
         for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,k,I.energy_dissipation.index},OPT.quiet);
            nc_varput(ncfile,'eps',matrix,[0 0 k-1],[size(matrix) 1]);
            R.eps(1) = min(R.eps(1),min(matrix(:)));
            R.eps(2) = max(R.eps(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZTUR',{OPT.ind,0,I.energy_dissipation.index},OPT.quiet);
         nc_varput(ncfile,'eps',matrix);
         R.eps = [min(R.eps(1),min(matrix(:))) max(R.eps(2),max(matrix(:)))];
      end   
      end

      if OPT.stride
         for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZVICWW',{OPT.ind,k},OPT.quiet);
            nc_varput(ncfile,'viscosity_z',matrix,[0 0 k-1],[size(matrix) 1]);
            R.viscosity_z(1) = min(R.viscosity_z(1),min(matrix(:)));
            R.viscosity_z(2) = max(R.viscosity_z(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZVICWW',{OPT.ind,0},OPT.quiet);
         nc_varput(ncfile,'viscosity_z',matrix);
         R.viscosity_z = [min(R.viscosity_z(1),min(matrix(:))) max(R.viscosity_z(2),max(matrix(:)))];
      end   

      if OPT.stride
         for k=1:G.kmax+1
            matrix = vs_let(F,'his-series','ZDICWW',{OPT.ind,k},OPT.quiet);
            nc_varput(ncfile,'diffusivity_z',matrix,[0 0 k-1],[size(matrix) 1]);
            R.diffusivity_z(1) = min(R.diffusivity_z(1),min(matrix(:)));
            R.diffusivity_z(2) = max(R.diffusivity_z(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZDICWW',{OPT.ind,0},OPT.quiet);
         nc_varput(ncfile,'diffusivity_z',matrix);
         R.diffusivity_z = [min(R.diffusivity_z(1),min(matrix(:))) max(R.diffusivity_z(2),max(matrix(:)))];
      end   

      if OPT.stride
         for k=1:G.kmax
            matrix = vs_let(F,'his-series','ZRICH',{OPT.ind,k},OPT.quiet);
            nc_varput(ncfile,'Ri',matrix,[0 0 k-1],[size(matrix) 1]);
            R.Ri(1) = min(R.Ri(1),min(matrix(:)));
            R.Ri(2) = max(R.Ri(2),max(matrix(:)));
         end
      else
         matrix = vs_let(F,'his-series','ZRICH',{OPT.ind,0},OPT.quiet);
         nc_varput(ncfile,'Ri',matrix);
         R.Ri = [min(R.Ri(1),min(matrix(:))) max(R.Ri(2),max(matrix(:)))];
      end
   
%% update actual ranges

      if exist('R','var')
        varnames = fieldnames(R);
        
        for ivar=1:length(varnames)
           varname = varnames{ivar};
           ncwriteatt(ncfile,varname  ,'actual_range',R.(varname));
        end
      end

      if isnumeric(OPT.dump) && OPT.dump==1
         nc_dump(ncfile);
      else
         fid = fopen(OPT.dump,'w');
         nc_dump(ncfile,fid);
         fclose(fid);
      end
      
%% EOF      
