function ncwritetutorial_trajectory(ncfile,varargin)
%NCWRITETUTORIAL_TRAJECTORY tutorial for writing trajectory to netCDF-CF file
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a trajectory. In this special case 
%  the main dimension coincides with the time axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
% An example of a 3D trajectory is FerryBox data (http://www.ferrybox.org/)
%
%See also: netcdf, ncwriteschema, ncwrite, SNCTOOLS,
%          ncwritetutorial_grid
%          ncwritetutorial_timeseries

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat
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
%  $Id: ncwritetutorial_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $
%  $Date: 2013-07-19 08:13:40 +0200 (Fri, 19 Jul 2013) $
%  $Author: boer_g $
%  $Revision: 8921 $
%  $HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_timeseries.m $
%  $Keywords: $

   if nargin==0
      ncfile         = [mfilename('fullpath'),'.nc'];
   end

%% Required spatio-temporal fields

   OPT.title          = '';
   OPT.institution    = '';
   OPT.version        = '';
   OPT.references     = '';
   OPT.email          = '';
   
   OPT.datenum        = datenum(2009,0,1:365);
   OPT.lon            =  3+2*cos(2*pi*OPT.datenum./365); % lissajous
   OPT.lat            = 52+1*cos(4*pi*OPT.datenum./365+pi/2);
   OPT.epsg           = 4326;

   OPT.var            = 3-2*cos(2*pi*OPT.datenum/365);

%% Required data fields
   
   OPT.Name           = 'TSS';
   OPT.standard_name  = 'mass_concentration_of_suspended_matter_in_sea_water';
   OPT.long_name      = 'TSS';
   OPT.units          = 'kg m-3';
   OPT.Attributes     = {};

%% Required settings

   OPT.Format         = 'classic'; % '64bit','classic','netcdf4','netcdf4_classic'
   OPT.refdatenum     = datenum(0000,0,0); % matlab datenumber convention: A serial date number of 1 corresponds to Jan-1-0000. Gives wring date sin ncbrowse due to different calenders. Must use doubles here.
   OPT.refdatenum     = datenum(1970,1,1); % linux  datenumber convention
   OPT.fillvalue      = typecast(uint8([0    0    0    0    0    0  158   71]),'DOUBLE'); % ncetcdf default that is also recognized by ncBrowse % DINEOF does not accept NaNs; % realmax('single'); %
   OPT.timezone       = timezone_code2iso('GMT');
   
   if verLessThan('matlab','7.12.0.635')
      error('At least Matlab release R2011a is required for writing netCDF files due tue NCWRITESCHEMA.')
   end

   OPT      = setproperty(OPT,varargin);

%% CF attributes: add overall meta info
%  http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/cf-conventions.html#description-of-file-contents

   nc = struct('Name','/','Format','classic');

   nc.Attributes(    1) = struct('Name','title'              ,'Value',  OPT.title);
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_timeseries.m $ $Id: ncwritetutorial_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  OPT.version);
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  OPT.email);
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'timeSeries');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   ncdimlen.time        = length(OPT.var(:));
   nc.Dimensions(    1) = struct('Name','time'            ,'Length',ncdimlen.time      );
      
%% 3a Create (primary) variables: time

   ifld     = 1;clear attr dims
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'time');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'time');
   attr(end+1)  = struct('Name', 'units'        , 'Value', ['days since ',datestr(OPT.refdatenum,'yyyy-mm-dd HH:MM:SS'),OPT.timezone]);
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'T');
   
   nc.Variables(ifld) = struct('Name'       , 'time', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
                           
%% 3b Create (primary) variables: space

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon(:)) max(OPT.lon(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lon', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat(:)) max(OPT.lat(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lat', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    
                           
%% 3c Create (primary) variables: data
                              
   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name);
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name);
   attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', 'lat lon'); % platform_name needed to sdhow up in QuickPlot
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.var(:)) max(OPT.var(:))]);
      
   for iatt=1:2:length(OPT.Attributes)
   attr(end+1)  = struct('Name', OPT.Attributes{iatt}, 'Value', OPT.Attributes{iatt+1});
   end

   nc.Variables(ifld) = struct('Name'       , OPT.Name, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

   try;delete(ncfile);end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE: filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'         , OPT.datenum(:) - OPT.refdatenum);
   ncwrite   (ncfile,'lon'          , OPT.lon(:));
   ncwrite   (ncfile,'lat'          , OPT.lat(:));
   ncwrite   (ncfile,OPT.Name       , OPT.var(:));
      
%% test and check

   nc_dump(ncfile,[],strrep(ncfile,'.nc','.cdl'))


    
    