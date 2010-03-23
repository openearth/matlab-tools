function vs_trim2netcdf(vsfile)
%VS_TRIM2NETCDF  convert part of a Delft3D trim file to netCDF (BETA)
%
%   vs_trim2netcdf(NEFISfile)
%
% converts Delft3D trim file (NEFIS file) to a netCDF file in 
% the same directory with extension replaced by nc.
%
% Example:
%
%   vs_trim2netcdf('P:\aproject\trim-n15.dat')
%
%See also: snctools, vs_use

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

      ncfile = [fileparts(vsfile) filesep filename(vsfile) '.nc'];

%% 0 Read raw data

      F = vs_use(vsfile);
      G = vs_meshgrid2dcorcen(F);
      T = vs_time(F);
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
   
     %nc_attput(ncfile, nc_global, 'geospatial_lat_min'         , min(D.latcor(:)));
     %nc_attput(ncfile, nc_global, 'geospatial_lat_max'         , max(D.latcor(:)));
     %nc_attput(ncfile, nc_global, 'geospatial_lon_min'         , min(D.loncor(:)));
     %nc_attput(ncfile, nc_global, 'geospatial_lon_max'         , max(D.loncor(:)));
      nc_attput(ncfile, nc_global, 'time_coverage_start'        , datestr(T.datenum(  1),'yyyy-mm-ddPHH:MM:SS'));
      nc_attput(ncfile, nc_global, 'time_coverage_end'          , datestr(T.datenum(end),'yyyy-mm-ddPHH:MM:SS'));
     %nc_attput(ncfile, nc_global, 'geospatial_lat_units'       , 'degrees_north');
     %nc_attput(ncfile, nc_global, 'geospatial_lon_units'       , 'degrees_east' );

%% 2 Create dimensions

      nc_add_dimension(ncfile, 'time' , length(T.datenum));
      nc_add_dimension(ncfile, 'm'    , G.mmax-2);
      nc_add_dimension(ncfile, 'n'    , G.nmax-2);
      nc_add_dimension(ncfile, 'sigma', G.kmax  );

      ifld = 0;

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW  m grid index');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ m = 1 and m = mmax removed.');
      nc(ifld) = struct('Name', 'm', ...
          'Nctype', 'int', ...
          'Dimension', {{'m'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'Delft3D-FLOW  n grid index');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'comment'      , 'Value', 'dummy matrix space @ n = 1 andn = nmax removed.');
      nc(ifld) = struct('Name', 'n', ...
          'Nctype', 'int', ...
          'Dimension', {{'n'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_x_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'x');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'X');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'XWAT');
      nc(ifld) = struct('Name', 'x', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'projection_y_coordinate');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'y');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm');
      attr(4)  = struct('Name', 'axis'         , 'Value', 'Y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'YWAT');
      nc(ifld) = struct('Name', 'y', ...
          'Nctype', 'double', ...
          'Dimension', {{'n', 'm'}}, ...
          'Attribute', attr);

      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'long_name'    , 'Value', 'sigma');
      attr(2)  = struct('Name', 'units'        , 'Value', '1');
      attr(3)  = struct('Name', 'axis'         , 'Value', 'Z');
      attr(4)  = struct('Name', 'positive'     , 'Value', 'down');
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
      attr(5)  = struct('Name', 'coordinates'  , 'Value', 'x y');
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
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
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
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
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
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'U1');
      nc(ifld) = struct('Name', 'u', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'v');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'horizontal velocity component in y-direction');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
      attr(5)  = struct('Name', 'delft3d_name' , 'Value', 'V1');
      nc(ifld) = struct('Name', 'v', ...
          'Nctype'   , 'double', ...
          'Dimension', {{'time', 'sigma', 'n', 'm'}}, ...
          'Attribute', attr);
      
      ifld     = ifld + 1;clear attr
      attr(1)  = struct('Name', 'standard_name', 'Value', 'w');
      attr(2)  = struct('Name', 'long_name'    , 'Value', 'vertical velocity');
      attr(3)  = struct('Name', 'units'        , 'Value', 'm/s');
      attr(4)  = struct('Name', 'coordinates'  , 'Value', 'x y');
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
      nc_varput(ncfile, 'x'    , G.cen.x);
      nc_varput(ncfile, 'y'    , G.cen.y);
      nc_varput(ncfile, 'time' , T.datenum - OPT.refdatenum);
      nc_varput(ncfile, 'sigma', 1:G.kmax);

      for i = 1:length(T.datenum)
      
      disp(['processing timestep ',num2str(i),' of ',num2str(length(T.datenum))])
          
          %% update grid, incl waterlevel which determines z grid spacing
          
          G = vs_meshgrid3dcorcen(F, i, G);
          
          if isfield(I,'salinity')
          D.salinity    = vs_let_scalar    (F,'map-series' ,{i},'R1'       , {0 0 0 I.salinity.index   });
          nc_varput(ncfile,'salinity', shiftdim(salinity  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.sal,2))       ]); % go from y, x, z to z, y, x
          end
          if isfield(I,'temperature')
          D.temperature = vs_let_scalar    (F,'map-series' ,{i},'R1'       , {0 0 0 I.temperature.index});
          nc_varput(ncfile,'temperature', shiftdim(temperature  ,2),[i-1, 0  0  0], [1, size(shiftdim(D.sal,2))       ]); % go from y, x, z to z, y, x
          end
          
         [D.u,D.v] = vs_let_vector_cen(F, 'map-series',{i},{'U1','V1'}, {0,0,0},'quiet');
          D.w      = vs_let_scalar    (F, 'map-series',{i},'WPHY'     , {0,0,0});
          D.u      = permute(D.u,[4 2 3 1]); % z y x
          D.v      = permute(D.v,[4 2 3 1]); % z y x
          D.w      = permute(D.w,[3 1 2]);   % z y x
      
          nc_varput(ncfile,'eta'     , G.cen.zwl   ,[i-1, 0, 0   ],[1, size(G.cen.zwl   )]);
          nc_varput(ncfile,'u'       , D.u         ,[i-1, 0, 0, 0],[1, size(D.u         )]);
          nc_varput(ncfile,'v'       , D.v         ,[i-1, 0, 0, 0],[1, size(D.v         )]);
          nc_varput(ncfile,'w'       , D.w         ,[i-1, 0, 0, 0],[1, size(D.w         )]);
          
      end
      
%% EOF      
