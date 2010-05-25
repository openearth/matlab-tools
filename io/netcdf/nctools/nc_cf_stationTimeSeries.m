function [D,M] = nc_cf_stationTimeSeries(ncfile,varargin)
%NC_CF_STATIONTIMESERIES   load/plot one variable from stationTimeSeries netCDF file
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile)
%  [D,M] = nc_cf_stationTimeSeries(ncfile,<varname>)
%
% plots AND loads timeseries of variable varname from netCDF 
% file ncfile and returns data D and meta-data M where
% ncfile  = name of local file / OPeNDAP address / result of ncfile = nc_info()
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
% the following assumption <MUST> be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile, station_id, lon, lat) in title and (long_name, units) as ylabel.
%
%  [D,M] = nc_cf_stationTimeSeries(ncfile,<varname>,<keyword,value>)
%
% The following <keyword,value> pairs are implemented:
% * varname (default []) % can optionally also be supplied as 2nd argument
% * plot    (default: 1 if varname = [], else 0)  % switches of the plot
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'; % either remote
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
%    fname = '/rijkswaterstaat/waterbase/sea_surface_height/id1-DENHDR-179805240000-200907100000.nc';
%    [D,M] = nc_cf_stationTimeSeries([directory,fname],'sea_surface_height');
%
%    fname = 'knmi/etmgeg/etmgeg_269.nc';
%    [D,M] = nc_cf_stationTimeSeries([directory,fname],'wind_speed_mean');
%
%See also: SNCTOOLS, NC_CF_GRID

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares for Building with Nature
%       Gerben J. de Boer
%
%       gerben.deboer@deltares.nl
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

%TO DO: handle indirect time mapping where there is no variable time(time)
%TO DO: handle multiple stations in one file: paramter(time,locations)
%TO DO: allow to get all time related parameters, and plot them on by one (with pause in between)
%TO DO: take into account differences between netCDF downloaded from HYRAX and THREDDS OPeNDAP implementation

%DOne: make 'TIME' case insensitive
%DOne: time does not need standard_name time, the dimension name time is
%       sufficient, matching a variable name

%% Keyword,values

   OPT.plot    = 1;
   OPT.varname = [];
   
   if ~odd(nargin)
   OPT.varname = varargin{1};
   nextarg     = 2;
   else
   nextarg     = 1;
   end
   
   if ~isempty(OPT.varname)
      OPT.plot = 0;
   end

   OPT = setProperty(OPT,varargin{nextarg:end});

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
   
%% Check whether is indeed time series

   index = findstrinstruct(fileinfo.Attribute,'Name','CF:featureType');
   if isempty(index)
      warning(['netCDF file might not be a proper stationTimeSeries, it lacks Attribute CF:featureType=stationTimeSeries'])
   end

%% Get datenum

  [D.datenum,M.datenum.timezone] = nc_cf_time(ncfile);
   
%% Get location info

   lonname         = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   if ~isempty(lonname)
   M.lon.units     = nc_attget(ncfile,lonname,'units');
   D.lon           = nc_varget(ncfile,lonname);
   else
   D.lon           = [];
   warning('no longitude specified')
   end

   latname         = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   if ~isempty(latname)
   M.lat.units     = nc_attget(ncfile,latname,'units');
   D.lat           = nc_varget(ncfile,latname);
   else
   D.lat           = [];
   warning('no latitude specified')
   end

   idname          = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'station_id');
   if ~isempty(idname)
    D.station_id   = nc_varget(ncfile,idname);
    if isnumeric(D.station_id)
    D.station_id   = num2str(D.station_id);
    else
    D.station_id   =         D.station_id;
    end
   else
    D.station_id = '';
    warning('no unique station id specified')
   end
   
   D.station_name = D.station_id(:)'; % default

   idname          = nc_varfind(ncfile, 'attributename', 'long_name', 'attributevalue', 'station name');
   if ~isempty(idname)
    D.station_name = nc_varget(ncfile,idname);
   else
    idname         = nc_varfind(ncfile, 'attributename', 'long_name', 'attributevalue', 'station_name');
    if ~isempty(idname)
    D.station_name = nc_varget(ncfile,idname);
    end
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

      plot    (D.datenum,D.(OPT.varname),'displayname',[mktex(M.(OPT.varname).long_name),' [',...
                                                        mktex(M.(OPT.varname).units    ),']'])
      datetick('x')
      grid     on
      title   ({mktex(fileinfo.Filename),...
               ['"',D.station_name(:)','"',...
                ' (',num2str(D.lon(1)),'\circE',...
                 ',',num2str(D.lat(1)),'\circN)']})
              
      if     isfield(M.(OPT.varname),'long_name')
         long_name = M.(OPT.varname).long_name;
      elseif isfield(M.(OPT.varname),'standard_name')
         long_name = M.(OPT.varname).standard_name;
      else
         long_name = OPT.varname;
      end
      
      if     isfield(M.(OPT.varname),'units')
         units = M.(OPT.varname).units;
      else
         units = '?';
      end
              
      ylabel  ([mktex(long_name),' [',mktex(units),']']);
   
   end
   end
   
%% Output

   if     nargout==1
      varargout = {D};
   elseif nargout==2
      varargout = {D};
   end
   
%% EOF   