function varargout = vs_trim2netcdf(vsfile,varargin)
%VS_TRIM2NETCDF  Convert part of a Delft3D trim file to netCDF (BETA)
%
%   vs_trim2netcdf(NEFISfile,<'keyword',value>)
%
% converts Delft3D trim file (NEFIS file) to a netCDF file in 
% the same directory with extension replaced by nc.
%
% Example:
%
%   vs_trim2netcdf('P:\aproject\trim-n15.dat','epsg',28992,'time',5)
%
%See also: snctools, vs_use

% TO DO add depth
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
      OPT.debug          = 0;
      OPT.time           = 0;
      OPT.epsg           = [];

      OPT      = setProperty(OPT,varargin{:});
      
      if nargin==0
         varargout = {OPT};
         return
      end

      ncfile = [fileparts(vsfile) filesep filename(vsfile) '.nc'];

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
      %------------------
   
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

      nc_attput(ncfile, nc_global, 'geospatial_lat_min'  , min(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_max'  , max(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_min'  , min(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lon_max'  , max(G.cor.lon(:)));
      nc_attput(ncfile, nc_global, 'geospatial_lat_units', 'degrees_north');
      nc_attput(ncfile, nc_global, 'geospatial_lon_units', 'degrees_east' );
      end

      nc_attput(ncfile, nc_global, 'time_coverage_start' , datestr(T.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(ncfile, nc_global, 'time_coverage_end'   , datestr(T.datenum(end),'yyyy-mm-ddPHH:MM:SS'));

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'time' , length(T.datenum));
      nc_add_dimension(ncfile, 'm'    , G.mmax-2);
      nc_add_dimension(ncfile, 'n'    , G.nmax-2);
      nc_add_dimension(ncfile, 'm_cor', G.mmax-1);
      nc_add_dimension(ncfile, 'n_cor', G.nmax-1);
      nc_add_dimension(ncfile, 'sigma', G.kmax  );

      ifld = 0;
      
   %% dimensions

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell centers');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 and m = mmax removed.');
      nc(ifld) = struct('Name', 'm', ...
          'Nctype', 'int', ...
          'Dimension', {{'m'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell centers');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 and n = nmax removed.');
      nc(ifld) = struct('Name', 'n', ...
          'Nctype', 'int', ...
          'Dimension', {{'n'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW m index of cell corners');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 removed.');
      nc(ifld) = struct('Name', 'm_cor', ...
          'Nctype', 'int', ...
          'Dimension', {{'m_cor'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW n index of cell corners');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 removed.');
      nc(ifld) = struct('Name', 'n_cor', ...
          'Nctype', 'int', ...
          'Dimension', {{'n_cor'}}, ...
          'Attribute', attr);

   %% coordinates

   if any(strfind(G.coordinates,'CARTESIAN'))
   
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'x of cell centers');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      nc(ifld) = struct('Name', 'x', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'y of cell centers');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      nc(ifld) = struct('Name', 'y', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'x of cell corners');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      nc(ifld) = struct('Name', 'x_cor', ...
          'Nctype', 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'y of cell corners');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      nc(ifld) = struct('Name', 'y_cor', ...
          'Nctype', 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

   if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell centers');
      attr(3)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT,XZ');
      nc(ifld) = struct('Name', 'longitude', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell centers');
      attr(3)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT,YZ');
      nc(ifld) = struct('Name', 'latitude', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'longitude');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'longitude of cell corners');
      attr(3)  = struct('Name', 'units'        , 'Value', 'degrees_east');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'XCOR');
      nc(ifld) = struct('Name', 'longitude_cor', ...
          'Nctype', 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'latitude');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'latitude of cell corners');
      attr(3)  = struct('Name', 'units'        , 'Value', 'degrees_north');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'YCOR');
      nc(ifld) = struct('Name', 'latitude_cor', ...
          'Nctype', 'double', ...
          'Dimension', {{'n_cor', 'm_cor'}}, ...
          'Attribute', attr);
   end

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'sigma');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'axis'         , 'Value', 'Z');
      attr(4)  = struct('Name', 'positive'     , 'Value', 'down');
      attr(5)  = struct('Name', 'comment'      , 'Value', 'The surface layer has index k=1, the bottom layer has index kmax.');
      nc(ifld) = struct('Name', 'sigma', ...
          'Nctype', 'double', ...
          'Dimension', {{'sigma'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'time');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'time');
      attr(3)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd'),' 00:00:00 ',OPT.timezone]);
      attr(4)  = struct('Name', 'axis'         , 'Value', 'T');
      nc(ifld) = struct('Name', 'time', ...
          'Nctype', 'double', ...
          'Dimension', {{'time'}}, ...
          'Attribute', attr);

%% 3 Create variables

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'sea_surface_elevation');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'water level');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'positive'     , 'Value', 'up');
      if isempty(OPT.epsg)
      attr(5)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(5)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(6)  = struct('Name', 'delft3d_name' , 'Value', 'S1');
      nc(ifld) = struct('Name', 'eta', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'n', 'm'}}, ...
          'Attribute', attr);
      
      if isfield(I,'salinity')
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'salinity');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'salinity');
      attr(3)  = struct('Name', 'units'        , 'Value', '1e-3');
      if isempty(OPT.epsg)
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'R1');
      nc(ifld) = struct('Name', 'salinity', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      end

      if isfield(I,'temperature')
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'temperature');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'temperature');
      attr(3)  = struct('Name', 'units'        , 'Value', 'degree_Celsius');
      if isempty(OPT.epsg)
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'R1');
      nc(ifld) = struct('Name', 'temperature', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      end

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'u');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'horizontal velocity component in x-direction');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'U1');
      nc(ifld) = struct('Name', 'u', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'v');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'horizontal velocity component in y-direction');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'V1');
      nc(ifld) = struct('Name', 'v', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'w');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'vertical velocity');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm/s');
      if isempty(OPT.epsg)
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      else
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'latitude longitude');
      end
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'WPHY');
      nc(ifld) = struct('Name', 'w', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);

%% 4 Create variables with attibutes
   
      for ifld=1:length(nc)
         if OPT.debug
            disp(var2evalstr(nc(ifld)))
         end
         nc_addvar(ncfile, nc(ifld));   
      end

%% 5 Fill variables

      nc_varput(ncfile, 'm'    , 2:G.mmax-1);
      nc_varput(ncfile, 'n'    , 2:G.nmax-1);
      nc_varput(ncfile, 'm_cor', 1:G.mmax-1);
      nc_varput(ncfile, 'n_cor', 1:G.nmax-1);
      nc_varput(ncfile, 'x'    ,   G.cen.x );
      nc_varput(ncfile, 'y'    ,   G.cen.y );
      nc_varput(ncfile, 'x_cor',   G.cor.x );
      nc_varput(ncfile, 'y_cor',   G.cor.y );
      nc_varput(ncfile, 'time' , T.datenum - OPT.refdatenum);
      nc_varput(ncfile, 'sigma', 1:G.kmax  );
      if (~isempty(OPT.epsg)) | (~any(strfind(G.coordinates,'CARTESIAN')))
      nc_varput(ncfile, 'longitude'    ,G.cen.lon);
      nc_varput(ncfile, 'latitude'     ,G.cen.lat);
      nc_varput(ncfile, 'longitude_cor',G.cor.lon);
      nc_varput(ncfile, 'latitude_cor' ,G.cor.lat);
      end      

      i = 0;

      for it = OPT.time
      
      i = i + 1;
      
      disp(['processing timestep ',num2str(i),' of ',num2str(length(OPT.time)),' (# ',num2str(it),')'])
          
          %% update grid, incl waterlevel which determines z grid spacing
          
          G = vs_meshgrid3dcorcen(F, it, G);
          
          if isfield(I,'salinity')
          D.salinity    = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.salinity.index   });
          nc_varput(ncfile,'salinity', shiftdim(salinity  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.sal,2))       ]); % go from y, x, z to z, y, x
          end
          if isfield(I,'temperature')
          D.temperature = vs_let_scalar    (F,'map-series' ,{it},'R1'       , {0 0 0 I.temperature.index});
          nc_varput(ncfile,'temperature', shiftdim(temperature  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.sal,2))       ]); % go from y, x, z to z, y, x
          end
          
         [D.u,D.v] = vs_let_vector_cen(F, 'map-series',{it},{'U1','V1'}, {0,0,0},'quiet');
          D.w      = vs_let_scalar    (F, 'map-series',{it},'WPHY'     , {0,0,0});
          D.u      = permute(D.u,[4 2 3 1]); % z y x
          D.v      = permute(D.v,[4 2 3 1]); % z y x
          D.w      = permute(D.w,[3 1 2]);   % z y x
      
          nc_varput(ncfile,'eta'     , G.cen.zwl   ,[i-1, 0, 0   ],[1, size(G.cen.zwl   )]);
          nc_varput(ncfile,'u'       , D.u         ,[i-1, 0, 0, 0],[1, size(D.u         )]);
          nc_varput(ncfile,'v'       , D.v         ,[i-1, 0, 0, 0],[1, size(D.v         )]);
          nc_varput(ncfile,'w'       , D.w         ,[i-1, 0, 0, 0],[1, size(D.w         )]);
          
      end
      
%% EOF      
