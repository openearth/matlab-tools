function [D,M] = nc_cf_stationTimeSeries(ncfile,varname)
%NC_CF_STATIONTIMESERIES   load/plot stationTimeSeries netCDF file
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile,varname)
%
% where ncfile is the netCDF file name (or OPeNDAP adress)
%       varname is the variable name to be extracted (must have dimension time)
%       D contains the data struct
%       M contains the metadata struct (attributes)
%
% A stationTimeSeries netCDF file as defined in
%    https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions
% must have global attributes
%   Conventions   : CF-1.4
%   CF:featureType: stationTimeSeries
%
%See also: snctools

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl	
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

   OPT.substance_code = 'id1';
   OPT.station_code   = 'DENHDR';
   ncfile  = ['http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/rijkswaterstaat/waterbase.nl/sea_surface_height/',OPT.substance_code,'-',OPT.station_code,'-196101010000-200801010000_time_direct.nc'];
   varname = 'sea_surface_height'

   nc_dump(ncfile);

%% Load time series
%------------------

   M.info=nc_info(ncfile);
   
%% Chek whether is time series
%------------------
   index = findstrinstruct(M.info.Attribute,'Name','CF:featureType');
   if isempty(index)
      error(['netCDF file is not stationTimeSeries: needs Attribute Name=CF:featureType'])
   end
   
%% get datenum
%------------------

   timename        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'time');
   M.datenum.units = nc_attget(ncfile,timename,'units');
   D.datenum       = nc_varget(ncfile,timename);

%% get location
%------------------

   lonname        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   M.lon.units    = nc_attget(ncfile,lonname,'units');
   D.lon          = nc_varget(ncfile,lonname);

   latname        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   M.lat.units    = nc_attget(ncfile,latname,'units');
   D.lat          = nc_varget(ncfile,latname);

  %idname         = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'station_id')
  %M.id.units     = nc_attget(ncfile,idname,'units');
  %D.id           = nc_varget(ncfile,idname);

%% convert units to datenum
%------------------

  %D.datenum = time2datenum(D.datenum,M.datenum.units); % TO DO
   
%% find all parameters that have time as dimension
%------------------

   if ~isempty(varname)
   
      D.(varname) = nc_varget(ncfile,varname);
     %M.(varname) = nc_attget(ncfile,varname); % get all

   else
   
      timevar = [];
      for ivar=1:length(M.info.Dataset)
         index = strcmpi(M.info.Dataset(ivar).Dimension,'time')
         if index==1
            timevar = [timevar ivar];
         end
      end
   
      for ivar=timevar
         D.(varname) = nc_varget(ncfile,F.info.Dataset(ivar).Name);
         M.(varname) = nc_attget(ncfile,F.info.Dataset(ivar).Name); % all
      end

   end

%% Plot
%------------------
   
   if ~isempty(varname)

      plot    (D.datenum,D.(varname))
      datetick('x')
      grid     on
      title   (mktex(M.info.Filename))
      ylabel  (varname);
     %ylabel  ([M.(varname).Attribute(1).Value,' [',...
     %          M.(varname).Attribute(2).Value,']']);
   
   end
   