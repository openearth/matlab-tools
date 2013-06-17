function ncwritetutorial_grid_lat_lon_curvilinear
%ncwritetutorial_grid_lat_lon_curvilinear tutorial for writing grids to netCDF-CF file
%
% For too legacy matlab releases, see instead nc_cf_grid_write_lat_lon_curvilinear_tutorial
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a curvi-linear grid defined in (lat,lon) space,
%  i.e. a satellite image in original swath-projection.
%
%See also: ncwritetutorial_timeseries, nc_cf_timeseries, nc_cf_grid,
%          netcdf, ncwriteschema, ncwrite, SNCTOOLS,


%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares
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

ncfile           = 'ncwritetutorial_grid_lat_lon_curvilinear.nc';

%% Define meta-info: global

   OPT.institution  = 'Deltares';
   OPT.refdatenum   = datenum(1970,1,1);
   OPT.timezone     = '+08:00';
   OPT.bounds       = 1; % add corner coordinates

%% Define dimensions/coordinates: lat,lon matrices
%  checkersboard to test plot with one nan-hole
   lon1                       = [1 3 5 7];
   lat1                       = [49.5:1:54.5];
  [lon2,lat2]                 = ndgrid(lon1,lat1);
   ang                        = [-30 -15 0 15 30 45;-30 -15 0 15 30 45;-30 -15 0 15 30 45;-30 -15 0 15 30 45];
   DAT.cor.lat                = lat2 + sind(ang).*lon2./2;
   DAT.cor.lon                = lon2 + cosd(ang).*lon2./2;
   
   DAT.lat                    = corner2center(DAT.cor.lat);
   DAT.lon                    = corner2center(DAT.cor.lon); clear lon1 lon2 lat1 lat2
   DAT.time                   = now; % []; %now;
   DAT.val                    = [  1 102   3 104   5;...
                                 106   7 108   9 110;...
                                  11 112 nan 114  15]; % use ncols as 1st array dimension to get correct plot in ncBrowse (snctools swaps for us)
%% required vatriable meta-data                              
   OPT.varname                = 'depth';       % free to choose: will appear in netCDF tree
   OPT.units                  = 'm';           % from UDunits package: http://www.unidata.ucar.edu/software/udunits/
   OPT.long_name              = 'bottom depth';% free to choose: will appear in plots
   OPT.standard_name          = 'sea_floor_depth_below_geoid'; % or 'altitude'
   OPT.val_type               = 'single';      % 'single' or 'double'
   OPT.fillvalue              = NaN;

%% 1 Create file: global meta-data

   nc = struct('Name','/','Format','classic');

   nc.Attributes(    1) = struct('Name','title'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL$ $Id$');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'grid');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions: name and length

   nc.Dimensions(1) = struct('Name','col'   ,'Length', size(DAT.lon,1)); % CF wants x last, which means 1st in Matlab
   nc.Dimensions(2) = struct('Name','row'   ,'Length', size(DAT.lon,2)); % ~ y
   nc.Dimensions(3) = struct('Name','time'  ,'Length',length(DAT.time)); % CF wants time 1ts, which means last in Matlab
   nc.Dimensions(4) = struct('Name','bounds','Length',4               ); % CF wants bounds last, which means 1st in Matlab
      
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   
   nc.Variables(ifld) = struct('Name'       , 'time', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions(3),...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'longitude latitude'); % incl itself
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(DAT.lon(:)) max(DAT.lon(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'longitude_bounds');
   end
   nc.Variables(ifld) = struct('Name'       , 'longitude', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions(1:2), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'longitude latitude'); % incl itself
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(DAT.lat(:)) max(DAT.lat(:))]);
   if OPT.bounds
   attr(end+1)  = struct('Name', 'bounds'       , 'Value', 'latitude_bounds');
   end
   nc.Variables(ifld) = struct('Name'       , 'latitude', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions(1:2), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    

   if OPT.bounds
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(DAT.lon(:)) max(DAT.lon(:))]);
   nc.Variables(ifld) = struct('Name'       , 'longitude_bounds', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1:2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(DAT.lat(:)) max(DAT.lat(:))]);
   nc.Variables(ifld) = struct('Name'       , 'latitude_bounds', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , nc.Dimensions([4 1:2]), ... % CF wants bounds last, i.e 1st in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);
   end % bounds
                           
%% 3c Create (primary) variables: data
                              
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name);
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name);
   attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units);
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'longitude latitude');
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(DAT.val(:)) max(DAT.val(:))]);
   nc.Variables(ifld) = struct('Name'       , OPT.varname, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' ,nc.Dimensions(1:3), ... % CF wants time 1st, i.e last in Matlab
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

   try;delete(ncfile);end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'            , DAT.time - OPT.refdatenum);
   ncwrite   (ncfile,'longitude'       , DAT.lon);
   ncwrite   (ncfile,'latitude'        , DAT.lat);
   ncwrite   (ncfile,OPT.varname       , DAT.val);
   if OPT.bounds
   ncwrite   (ncfile,'longitude_bounds', permute(nc_cf_cor2bounds(DAT.cor.lon),[3 1 2]));
   ncwrite   (ncfile,'latitude_bounds' , permute(nc_cf_cor2bounds(DAT.cor.lat),[3 1 2]));
   end
      
%% test and check

   nc_dump(ncfile,[],[mfilename('fullpath'),'.cdl'])
