function [D,M] = nc_cf_stationTimeSeries(ncfile,varargin)
%NC_CF_STATIONTIMESERIES   load/plot one variable from stationTimeSeries netCDF file
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile)
%  [D,M] = nc_cf_stationTimeSeries(ncfile,varname)
%
% plots/loads timeseries of variable varname from netCDF 
% file ncfile and returns data and meta-data where
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% D       = contains the data struct
% M       = the metadata struct (attributes)
% varname = the variable name to be extracted (must have dimension time)
%           When varname is not supplied, a dialog box is offered.
%
% A stationTimeSeries netCDF file is defined in
%   <a href="https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions">https://cf-pcmdi.llnl.gov/trac/wiki/PointObservationConventions</a>
% and must have global attributes:
%  *  Conventions   : CF-1.4
%  *  CF:featureType: stationTimeSeries
% the following assumption must be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile, station_id, lon, lat) in title and (long_name, units) as ylabel.
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile,varname,<keyword,value>)
%
% The following <keyword,value> are implemented
% * plot   (default 1)
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'; % either remote
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
% [D,M]=nc_cf_stationTimeSeries([directory,'/rijkswaterstaat/waterbase/sea_surface_height/id1-DENHDR-179805240000-200907100000.nc'],...
%                               'sea_surface_height')
%
% [D,M]=nc_cf_stationTimeSeries([directory,'knmi/etmgeg/etmgeg_269.nc'],...
%                               'wind_speed_mean')
%
%See also: SNCTOOLS, NC_CF_GRID

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
%TO DO: take into account differences between netCDF downloaded from HYRAX and THREDDS OPeNDAP implementation

%DOne: make 'TIME' case insensitive
%DOne: time does not need standard_name time, the dimension name time is
%       sufficient, matching a variable name

%% Keyword,values

   OPT.plot    = 1;
   OPT.varname = [];
   
   if nargin > 1
   OPT.varname = varargin{1};
   end
   
   OPT = setProperty(OPT,varargin{2:end});

%% Load file info

   %% get info from ncfile
   if isstruct(ncfile)
      fileinfo = ncfile;
   else
      fileinfo = nc_info(ncfile);
   end
   
   %% deal with name change in scntools: DataSet > Dataset
   if     isfield(fileinfo,'Dataset'); % new
     fileinfo.DataSet = fileinfo.Dataset;
   elseif isfield(fileinfo,'DataSet'); % old
     fileinfo.Dataset = fileinfo.DataSet;
     disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
   else
      error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
   end
   
%% Check whether is time series
   index = findstrinstruct(fileinfo.Attribute,'Name','CF:featureType');
   if isempty(index)
      warning(['netCDF file might not be a proper stationTimeSeries, it lacks Attribute CF:featureType=stationTimeSeries'])
   end

%% Get datenum
   D.datenum      = nc_cf_time(ncfile);
   
%% Get location info

   lonname        = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   if ~isempty(lonname)
   M.lon.units    = nc_attget(ncfile,lonname,'units');
   D.lon          = nc_varget(ncfile,lonname);
   else
   D.lon          = [];
   warning('no longitude specified')
   end

   latname        = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   if ~isempty(latname)
   M.lat.units    = nc_attget(ncfile,latname,'units');
   D.lat          = nc_varget(ncfile,latname);
   else
   D.lat          = [];
   warning('no latitude specified')
   end

   idname         = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'station_id');
   if ~isempty(idname)
   D.station_id   = nc_varget(ncfile,idname);
   if isnumeric(D.station_id)
   D.station_name = num2str(D.station_id);
   else
   D.station_name =         D.station_id;
   end
   else
   D.station_name = '';
   warning('no unique station id specified')
   end

%% Find specified (or all parameters) that have time as dimension
%  and select one.

   if isempty(OPT.varname)
   
      timevar = [];
      for ivar=1:length(fileinfo.Dataset)
         index = any(strcmpi(fileinfo.Dataset(ivar).Dimension,'time')); % use any if for case like {'locations','time'}
         if index==1
            timevar = [timevar ivar];
         end
      end
      
      timevarlist = cellstr(char(fileinfo.Dataset(timevar).Name));


      [ii, ok] = listdlg('ListString', timevarlist, .....
                      'SelectionMode', 'single', ...
                       'PromptString', 'Select one variable', ....
                               'Name', 'Selection of variable',...
                           'ListSize', [500, 300]); 
                               
      
      varindex    = timevar(ii);
      OPT.varname = timevarlist{ii};
      
   else
   
      % get index
      nvar = length(fileinfo.Dataset);
      
      for ivar=1:nvar
         if strcmp(fileinfo.Dataset(ivar).Name,OPT.varname)
         varindex = ivar;
         break
         end
      end
   end
   
%% get data

      D.(OPT.varname) = nc_varget(ncfile,OPT.varname);
      
%% get Attributes

      nAttr = length(fileinfo.Dataset(varindex).Attribute);
      for iAttr = 1:nAttr
      Name  = mkvar(fileinfo.Dataset(varindex).Attribute(iAttr).Name);
      Value =       fileinfo.Dataset(varindex).Attribute(iAttr).Value;
      M.(OPT.varname).(Name) = Value; % get all  % TO DO
      end

%% Plot
   
   if OPT.plot
   if ~isempty(OPT.varname)

      plot    (D.datenum,D.(OPT.varname))
      datetick('x')
      grid     on
      title   ({mktex(fileinfo.Filename),...
               ['"',D.station_name,'"',...
                ' (',num2str(D.lon),'\circE',...
                 ',',num2str(D.lat),'\circN',...
                ')']})
      ylabel  ([mktex(M.(OPT.varname).long_name),' [',...
                mktex(M.(OPT.varname).units    ),']']);
   
   end
   end
   
%% Output

   if     nargout==1
      varargout = {D};
   elseif nargout==2
      varargout = {D};
   end
   
%% EOF   