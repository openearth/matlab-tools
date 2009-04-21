function [D,M] = nc_cf_stationTimeSeries(ncfile,varargin)
%NC_CF_STATIONTIMESERIES   load/plot one variable from stationTimeSeries netCDF file
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile)
%  [D,M] = nc_cf_stationTimeSeries(ncfile,varname)
%
% plots/loads timeseries of variable varname from netCDF 
% file ncfile and returns data and meta-data
% where * ncfile is the netCDF file name (or OPeNDAP adress)
%       * D contains the data struct
%       * M contains the metadata struct (attributes)
%       * varname is the variable name to be extracted (must have dimension time)
%         When varname is not supplied, a dialog box is offered.
%
% A stationTimeSeries netCDF file is defined in
%   <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a>
% and must have global attributes:
%  *  Conventions   : CF-1.4
%  *  CF:featureType: stationTimeSeries
% the following assumption must be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile, station_id, lon, lat in title) and (long_name, units) on as ylabel.
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile,varname,<keyword,value>)
%
% The following <keyword,value> are implemented
% * plot   (default 1)
%
% Examples:
%
% directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'
%
% nc_cf_stationTimeSeries([directory,'/rijkswaterstaat/waterbase.nl/sea_surface_height/id1-DENHDR-196101010000-200801010000_time_direct.nc'],...
%                         'sea_surface_height')
%
% nc_cf_stationTimeSeries([directory,''knmi/etmgeg/etmgeg_269_time_direct.nc'],...
%                         'wind_speed_mean')
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

%TO DO: handle indirect time mapping where there is no variable time(time)
%TO DO: handle multiple stations in one file 
%TO DO: allow to get all time related parameters, and plot them on by one (with pause in between)
%TO DO: document <keyword,value> pairs
%TO DO: move to scntools

%% Keyword,values
%------------------

   OPT.plot    = 1;
   OPT.varname = [];
   
   if nargin > 1
   OPT.varname = varargin{1};
   end
   
   OPT = setProperty(OPT,varargin{2:end});

%% Load file info
%------------------

   INF = nc_info(ncfile);
   
%% Check whether is time series
%------------------
   index = findstrinstruct(INF.Attribute,'Name','CF:featureType');
   if isempty(index)
      error(['netCDF file is not stationTimeSeries: needs Attribute Name=CF:featureType'])
   end

%% Get datenum
%------------------

   timename        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'time');
   M.datenum.units = nc_attget(ncfile,timename,'units');
   D.datenum       = nc_varget(ncfile,timename);
   D.datenum       = udunits2datenum(D.datenum,M.datenum.units); % convert units to datenum
   
%% Get location info
%------------------

   lonname        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   M.lon.units    = nc_attget(ncfile,lonname,'units');
   D.lon          = nc_varget(ncfile,lonname);

   latname        = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   M.lat.units    = nc_attget(ncfile,latname,'units');
   D.lat          = nc_varget(ncfile,latname);

   idname         = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'station_id');
   D.station_id   = nc_varget(ncfile,idname);

   if isnumeric(D.station_id)
   D.station_name = num2str(D.station_id);
   else
   D.station_name =         D.station_id;
   end

%% Find specified (or all parameters) that have time as dimension
%  and select one.
%------------------

   if isempty(OPT.varname)
   
      timevar = [];
      for ivar=1:length(INF.Dataset)
         index = any(strcmpi(INF.Dataset(ivar).Dimension,'time')); % use any if for case like {'locations','time}
         if index==1
            timevar = [timevar ivar];
         end
      end
      
      timevarlist = cellstr(char(INF.Dataset(timevar).Name));


      [ii, ok] = listdlg('ListString', timevarlist, .....
                      'SelectionMode', 'single', ...
                       'PromptString', 'Select one variable', ....
                               'Name', 'Selection of variable',...
                           'ListSize', [500, 300]); 
                               
      
      varindex    = timevar(ii);
      OPT.varname = timevarlist{ii};
      
   else
   
   %% get index
   %------------------
   
      nvar = length(INF.Dataset);
      
      for ivar=1:nvar
         if strcmp(INF.Dataset(ivar).Name,OPT.varname)
         varindex = ivar;
         break
         end
      end
   end
   
%% get data
%------------------

      D.(OPT.varname) = nc_varget(ncfile,OPT.varname);
      
%% get Attributes
%------------------

      nAttr = length(INF.Dataset(varindex).Attribute);
      for iAttr = 1:nAttr
      Name  = mkvar(INF.Dataset(varindex).Attribute(iAttr).Name);
      Value =       INF.Dataset(varindex).Attribute(iAttr).Value;
      M.(OPT.varname).(Name) = Value; % get all  % TO DO
      end

%% Plot
%------------------
   
   if OPT.plot
   if ~isempty(OPT.varname)

      plot    (D.datenum,D.(OPT.varname))
      datetick('x')
      grid     on
      title   ({mktex(INF.Filename),...
               ['"',D.station_name,'"',...
                ' (',num2str(D.lon),'\circE',...
                ',',num2str(D.lat),'\circN',...
                ')']})
      ylabel  ([M.(OPT.varname).long_name,' [',...
                M.(OPT.varname).units    ,']']);
   
   end
   end
   
%% Output
%------------------

   if     nargout==1
      varargout = {D};
   elseif nargout==2
      varargout = {D};
   end
   
%% EOF   