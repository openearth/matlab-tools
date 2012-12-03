function delft3d_io_meteo_write_example
%DELFT3D_IO_METEO_WRITE_EXAMPLE
%
% Example how to convert a set of netCDF meteo files to
% meteo files for Delft3D. It also creates an mdf
% file that can readily be used to check the meteo
% files with Delf3D itself.
%
%See also: netcdf, delft3d_io_meteo_write

%%  --------------------------------------------------------------------
%   Copyright (C) 2012 Deltares
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

   if nargin==0
      return
   end

   OPT.ncfiles        = {'meteo\CFSR.NS.2003.nc','meteo\CFSR.NS.2004.nc'};
   OPT.refdatenum     = datenum(2003,1,1); % for mdf test file
   OPT.period         = datenum(2003,11,[1 8]);
   
%% map parameters from netcf file to delft3d parameters

   OPT.lon           = 'lon';
   OPT.lat           = 'lat';
   OPT.varnames      = {'slp'         ,'u10'   ,'v10'   ,'sh'               ,'t2'             ,'tcc'};
  %CONVERT_UNITS does not work on 'degree Celsius' so we specify conversion factors
  %OPT.varunits      = {'Pascal'      ,'m/s'   ,'m/s'   ,'kg/kg'            ,'degree Celsius' ,'1'};
   OPT.amfac         = [1              1         1       100                 1                 100  ];

   OPT.amnames       = {'air_pressure','x_wind','y_wind','relative_humidity','air_temperature','cloudiness'};
   OPT.amext         = {'amp'         ,'amu'   ,'amv'   ,'amr'              ,'amt'            ,'amc'};
   OPT.amunits       = {'Pa'          ,'m s-1' ,'m s-1' ,'%'                ,'Celsius'        ,'%'};
   OPT.amkeyword     = {'fwndgp'      ,'fwndgu','fwndgv','fwndgr'           ,'fwndgt'         ,'fwndgc'};

%% load space dimensions

   D.lon  =         ncread(OPT.ncfiles{  1},OPT.lon);
   D.lat  =         ncread(OPT.ncfiles{  1},OPT.lat);
   
%% load time dimensions

   files2proces  = [];
   for ifile=1:length(OPT.ncfiles)
      T(ifile).count   = nc_getdiminfo(OPT.ncfiles{ifile},'time','Length')-1;
      T(ifile).datenum =    nc_cf_time(OPT.ncfiles{ifile},'time');
      T(ifile).dt      =    unique(diff(T(ifile).datenum (ifile)));
      index = find(T(ifile).datenum >= OPT.period(1) & ...
                   T(ifile).datenum <= OPT.period(2));
      if ~isempty(index)
      T(ifile).start   = index(  1);
      T(ifile).stop    = index(end);
      T(ifile).t0      = datestr(T(ifile).datenum(T(ifile).start));
      T(ifile).t1      = datestr(T(ifile).datenum(T(ifile).stop));
      files2proces = [files2proces ifile];
      end
   end

%% create delft3d ascii file headers (and add 1st timestep)

   MDF = delft3d_io_mdf('new');

   ifile = files2proces(1);
   for ivar=1:length(OPT.varnames)
   data = ncread(OPT.ncfiles{1},OPT.varnames{ivar},[1 1 1],[Inf Inf 1]);
   amfilename = [filename(OPT.ncfiles{ifile}),'.',OPT.amext{ivar}];
   grdfile    = [filename(OPT.ncfiles{ifile}),'.grd'];
   encfile    = [filename(OPT.ncfiles{ifile}),'.enc'];
   fid(ivar) = delft3d_io_meteo_write([filename(OPT.ncfiles{ifile}),'.',OPT.amext{ivar}],...
       T(ifile).datenum(T(ifile).start),data.*OPT.amfac(ivar),D.lon,D.lat,...
       'CoordinateSystem','Spherical',...
              'grid_file',grdfile,...
               'quantity',OPT.amnames{ivar},...
                   'unit',OPT.amunits{ivar},...
               'writegrd',ivar==1,... % only needed once
                 'header',['source: ',OPT.ncfiles{1}]);
             
   MDF.keywords.(OPT.amkeyword{ivar}) = amfilename;
   end
   
   T(1).start          = min(T(1).start + 1,T(1).stop); % do not add 1st timestep again
   MDF.keywords.filcco = grdfile;
   MDF.keywords.filgrd = encfile;
   MDF.keywords.mnkmax = [size(data)+1 1];
   MDF.keywords.sub1   = '  W '; % activate wind
   MDF.keywords.Wnsvwp = 'Y';    % spatially varying meteo input
   MDF.keywords.airout = 'yes';  % save p,u,v  to trim file
   MDF.keywords.heaout = 'yes';  % save rh,c,t to trim file
   MDF.keywords.itdate = datestr(OPT.refdatenum,'yyyy-mm-dd');
   ifile = files2proces(1);
   MDF.keywords.tstart = (T(ifile).datenum(T(ifile).start) - OPT.refdatenum)*24*60;
   MDF.keywords.dt     = (T(ifile).dt)*24*60;
   MDF.keywords.depuni = 1e3;
   ifile = files2proces(end);
   MDF.keywords.tstop  = (T(ifile).datenum(T(ifile).stop) - OPT.refdatenum)*24*60;
   MDF.keywords.flmap  = round([MDF.keywords.tstart MDF.keywords.dt MDF.keywords.tstop]);
  %MDF.keywords.Cstbnd = #Y#
  %MDF.keywords.PavBnd = 

%% pump rest of times teps from netcdf to delft3d ascii file

   for ifile=files2proces
      for it=T(ifile).start:T(ifile).stop
          
          disp(['file: ',num2str(ifile),' progress: ',num2str(100*it/T(ifile).count,'%07.3f'),' %'])
          
          D.time = T(ifile).datenum(it); %nc_cf_time(OPT.ncfiles{ifile},'time',it);
          
          for ivar=1:length(OPT.varnames)
          data = ncread(OPT.ncfiles{ifile},OPT.varnames{ivar},[1 1 it],[Inf Inf 1]);
          delft3d_io_meteo_write(fid(ivar),D.time,data.*OPT.amfac(ivar));
          end   
      end
   end

%% close delft3d ascii files for further writing

   for ivar=1:length(OPT.varnames)
       fclose(fid(ivar));
   end

%% save mdf for test simulation

   delft3d_io_mdf('write',[filename(OPT.ncfiles{1}),'.mdf'],MDF.keywords);
   