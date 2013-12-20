function ncwritetutorial_profile(ncfile0,varargin)
%NCWRITETUTORIAL_PROFILE tutorial for writing timeSeriesProfile to netCDF-CF file
%
%  Tutorial of how to make a netCDF file with CF conventions of a 
%  variable that is a timeSeriesProfile. In this special case 
%  the main dimensions coincides with the time axis and the z axis.
%
%  This case is described in CF: http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.6/ch09.html
%
% An example of a 3D trajectory is repeated CTD data.
%
%See also: netcdf, ncwriteschema, ncwrite, SNCTOOLS,
%          ncwritetutorial_grid
%          ncwritetutorial_timeseries
%          ncwritetutorial_trajectory

%%  --------------------------------------------------------------------
%   Copyright (C) 2013 Deltares 4 Rijkswaterstaat (SPA Eurotracks)
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

% contant z (binned) or varying z (ragged arrays)

   if nargin==0
      ncfile0         = [mfilename('fullpath'),'.nc'];
   end
   
%% Required spatio-temporal fields

   OPT.title          = '';
   OPT.institution    = '';
   OPT.version        = '';
   OPT.references     = '';
   OPT.email          = '';
   
   OPT.datenum1       = datenum(2009,0,1:365); % nominal times per profile, e.g. beginning or mean
   OPT.lon0           =  3; % 0D nominal/target location
   OPT.lat0           = 52; % 0D nominal/target location
   OPT.lon1           =  3 + .02*cos(2*pi*OPT.datenum1./365); % 1D we allow for some discrepnacy between target location and realized lcoation
   OPT.lat1           = 52 + .01*cos(4*pi*OPT.datenum1./365+pi/2); % 1D
   OPT.z1             = 0:.1:25; % 1D
   
   % we make a time-stack, using full time and z matrices
   % in reality, the data also have full time and z variablesa
   % z differs per cast, and is therefor every often a ragged-array
   % time can include the time of the cast itself. usually this time is neglected,
   % but when a CTD frame is used as a scanfish or glider, the full tiem matrix needs to be stored as well
   % In this tutorial we assign nominal times per cast, the beginning.
   
   [OPT.datenum2,OPT.z2  ] = meshgrid(OPT.datenum1,OPT.z1);
   [OPT.lon2,~]            = meshgrid(OPT.lon1    ,OPT.z1);
   [OPT.lat2,~]            = meshgrid(OPT.lat1    ,OPT.z1);
   OPT.var = exp(-OPT.z2./5).*2.*cos(2.*pi.*OPT.datenum2./365);

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

for dz = [0 1]; % amplitude of z undulation: 0=2D, otherwise=3D

   nc = struct('Name','/','Format','classic');

   nc.Attributes(    1) = struct('Name','title'              ,'Value',  OPT.title);
   nc.Attributes(end+1) = struct('Name','institution'        ,'Value',  OPT.institution);
   nc.Attributes(end+1) = struct('Name','source'             ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','history'            ,'Value',  '$HeadURL: https://svn.oss.deltares.nl/repos/openearthtools/trunk/matlab/io/netcdf/nctools/ncwritetutorial_timeseries.m $ $Id: ncwritetutorial_timeseries.m 8921 2013-07-19 06:13:40Z boer_g $');
   nc.Attributes(end+1) = struct('Name','references'         ,'Value',  OPT.version);
   nc.Attributes(end+1) = struct('Name','email'              ,'Value',  OPT.email);
   nc.Attributes(end+1) = struct('Name','featureType'        ,'Value',  'timeSeriesProfile');

   nc.Attributes(end+1) = struct('Name','comment'            ,'Value',  '');
   nc.Attributes(end+1) = struct('Name','version'            ,'Value',  '');

   nc.Attributes(end+1) = struct('Name','Conventions'        ,'Value',  'CF-1.6');

   nc.Attributes(end+1) = struct('Name','terms_for_use'      ,'Value', ['These data can be used freely for research purposes provided that the following source is acknowledged: ',OPT.institution]);
   nc.Attributes(end+1) = struct('Name','disclaimer'         ,'Value',  'This data is made available in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.');

%% 2 Create dimensions

   ncdimlen.time        = length(OPT.datenum1);
   ncdimlen.z           = length(OPT.z1);
   nc.Dimensions(1)     = struct('Name','time'  ,'Length', ncdimlen.time);
   nc.Dimensions(2)     = struct('Name','z'     ,'Length', ncdimlen.z);
   
   variable.dims(1)     = nc.Dimensions(2); % show correct by default in ncBrowse
   variable.dims(2)     = nc.Dimensions(1);
   
   
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
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'nominal longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon0(:)) max(OPT.lon0(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lon', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'nominal latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat0(:)) max(OPT.lat0(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lat', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , {[]}, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'actual longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon1(:)) max(OPT.lon1(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lon1', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'actual latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat1(:)) max(OPT.lat1(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lat1', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'time','Length',ncdimlen.time), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    

%% 3c Create (primary) variables: vertical

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'altitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'z');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'm');
   attr(end+1)  = struct('Name', 'positive'     , 'Value', 'down');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Z');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   
if dz==0 % same z per profile: dimension(z)=variable(z)
   ncfile = strrep(ncfile0,'.nc','_zlayers.nc');
   attr(end+1)  = struct('Name', 'actual_range'  ,'Value' , [min(OPT.z1(:)) max(OPT.z1(:))]);
   nc.Variables(ifld) = struct('Name'       , 'z', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , struct('Name', 'z','Length',ncdimlen.z), ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   variable.coordinates = '';
   
else % unique z per profile: ragged-array: dimension(z)=just an index
   ncfile = strrep(ncfile0,'.nc','_ragged.nc');
   attr(end+1)  = struct('Name', 'actual_range'  ,'Value' , [min(OPT.z2(:)) max(OPT.z2(:))]);
   nc.Variables(ifld) = struct('Name'       , 'z2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);   
   variable.coordinates = 'time z2';

   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'highres longitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Longitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_east');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'X');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lon2(:)) max(OPT.lon2(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lon2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);
   
   ifld     = ifld + 1;clear attr
   attr(    1)  = struct('Name', 'standard_name', 'Value', 'highres latitude');
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', 'Latitude');
   attr(end+1)  = struct('Name', 'units'        , 'Value', 'degrees_north');
   attr(end+1)  = struct('Name', 'axis'         , 'Value', 'Y');
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.lat2(:)) max(OPT.lat2(:))]);
   nc.Variables(ifld) = struct('Name'       , 'lat2', ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);    
end
                           
%% 3c Create (primary) variables: data

   ifld     = ifld + 1;clear attr;
   attr(    1)  = struct('Name', 'standard_name', 'Value', OPT.standard_name);
   attr(end+1)  = struct('Name', 'long_name'    , 'Value', OPT.long_name);
   attr(end+1)  = struct('Name', 'units'        , 'Value', OPT.units);
   attr(end+1)  = struct('Name', 'coordinates'  , 'Value', variable.coordinates);
   attr(end+1)  = struct('Name', '_FillValue'   , 'Value', OPT.fillvalue);
   attr(end+1)  = struct('Name', 'actual_range' , 'Value', [min(OPT.var(:)) max(OPT.var(:))]);
      
   for iatt=1:2:length(OPT.Attributes)
   attr(end+1)  = struct('Name', OPT.Attributes{iatt}, 'Value', OPT.Attributes{iatt+1});
   end
   
   nc.Variables(ifld) = struct('Name'       , OPT.Name, ...
                               'Datatype'   , 'double', ...
                               'Dimensions' , variable.dims, ...
                               'Attributes' , attr,...
                               'FillValue'  , []);                              
                              
%% 4 Create netCDF file

   try;delete(ncfile);end
   disp([mfilename,': NCWRITESCHEMA: creating netCDF file: ',ncfile])
   %var2evalstr(nc)
   ncwriteschema(ncfile, nc);			        
   disp([mfilename,': NCWRITE      : filling  netCDF file: ',ncfile])
      
%% 5 Fill variables

   ncwrite   (ncfile,'time'         , OPT.datenum1 - OPT.refdatenum);
   ncwrite   (ncfile,'lon'          , OPT.lon0(:));
   ncwrite   (ncfile,'lat'          , OPT.lat0(:));
   ncwrite   (ncfile,'lon1'         , OPT.lon1(:));
   ncwrite   (ncfile,'lat1'         , OPT.lat1(:));
   if dz==0
   ncwrite   (ncfile,'z'            , OPT.z1(:));
   else
   ncwrite   (ncfile,'z2'           , OPT.z2  );
   ncwrite   (ncfile,'lon2'         , OPT.lon2);
   ncwrite   (ncfile,'lat2'         , OPT.lat2);
   end
   ncwrite   (ncfile,OPT.Name       , OPT.var);
      
%% test and check

   nc_dump(ncfile,[],strrep(ncfile,'.nc','.cdl'))
   clear variable ncdimlen nc

end % z