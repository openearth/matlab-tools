function ncwritetutorial_timeseries
%NCWRITETUTORIAL_TIMESERIES tutorial for writing timeseries on disconnected stations to netCDF-CF file
%
% For too legacy matlab releases, plase see instead: see nc_cf_timeseries.
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a timeseries. In this special case 
%  the main dimension coincides with the time axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
%See also: nc_cf_timeseries_write_tutorial, nc_cf_timeseries,
%          netcdf, ncwriteschema, ncwrite, SNCTOOLS,

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 DeltaresNUS
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

ncfile           = 'ncwritetutorial_timeseries.nc';

%% make some dummy data

D.lon            = 103.2:.2:103.8;
D.lat            = 1.2:.1:1.5;
D.location_names = {'RLS','RLD','KUS','HTF'};
D.datenum        = datenum(2009,1:12,1);
D.TSS            = repmat(20+15*cos(2*pi*(D.datenum - D.datenum(1))./(365.25)),[length(D.lon) 1]);
D.TSS            = D.TSS + 5*rand(size(D.TSS));

OPT.institution  = 'DeltaresNUS';
OPT.refdatenum   = datenum(1970,1,1);
OPT.timezone     = '+08:00';

%% 1 Create file

   nc = struct('Name','/','Format','classic');

   nc.Attributes(    1) = struct('Name','title'              ,'Value',  'SPM data in Singapore');
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL$ $Id$');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  'http://svn.oss.deltares.nl');
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'timeSeries');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

   nc.Attributes(end+1) = struct('Name','delft3d_description','Value',  '');

%% 2 Create dimensions

   ncdimlen.time        = length(D.datenum);
   ncdimlen.location    = length(D.location_names);
   ncdimlen.string_len  = size(char(D.location_names),2);

   nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time      );
   nc.Dimensions(end+1) = struct('Name','location'        ,'Length',ncdimlen.location  );
   nc.Dimensions(end+1) = struct('Name','string_len'      ,'Length',ncdimlen.string_len);
      
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   
   nc.Variables(ifld) = struct('Name'      , 'time', ...
                               'Datatype'  , 'double', ...
                               'Dimensions', struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude of station');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lon(:)) max(D.lon(:))]);
   nc.Variables(ifld) = struct('Name'      , 'longitude', ...
                               'Datatype'  , 'double', ...
                               'Dimensions', struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude of station');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.lat(:)) max(D.lat(:))]);
   nc.Variables(ifld) = struct('Name'      , 'latitude', ...
                               'Datatype'  , 'double', ...
                               'Dimensions', struct('Name', 'location','Length',ncdimlen.location), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    
                           
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'platform_name');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'platform name');
   dims(    1)  = struct('Name', 'string_len','Length',ncdimlen.string_len);
   dims(    2)  = struct('Name', 'location'  ,'Length',ncdimlen.location);
   nc.Variables(ifld) = struct('Name'      , 'station_name', ...
                               'Datatype'  , 'char', ...
                               'Dimensions', dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);     
                              
%% 3c Create (primary) variables: data
                              
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'mass_concentration_of_suspended_matter_in_sea_water');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'TSS');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'kg m-3');
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'longitude latitude');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', nan);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(D.TSS(:)) max(D.TSS(:))]);
   dims(1) = struct('Name', 'location','Length',ncdimlen.location);
   dims(2) = struct('Name', 'time'    ,'Length',ncdimlen.time    );
   nc.Variables(ifld) = struct('Name'      , 'TSS', ...
                               'Datatype'  , 'double', ...
                               'Dimensions', dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

   try;delete(ncfile);end
   disp(['vs_trih2nc: NCWRITESCHEMA: creating netCDF file: ',ncfile])
   ncwriteschema(ncfile, nc);			        
   disp(['vs_trih2nc: NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'        , D.datenum - OPT.refdatenum);
   ncwrite   (ncfile,'longitude'   , D.lon);
   ncwrite   (ncfile,'latitude'    , D.lat);
   ncwrite   (ncfile,'station_name', char(D.location_names)');
   ncwrite   (ncfile,'TSS'         , D.TSS);
      
%% test and check

   nc_dump(ncfile,[],[mfilename('fullpath'),'.cdl'])
