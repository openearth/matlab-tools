function [D,M] = nc_cf_grid(ncfile,varargin)
%NC_CF_GRID   load/plot one variable from netCDF grid file
%
%  [D,M] = nc_cf_grid(ncfile)
%  [D,M] = nc_cf_grid(ncfile,varname)
%
% plots/loads timeseries of variable varname from netCDF 
% file ncfile and returns data and meta-data where 
% ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
% D       = contains the data struct
% M       = the metadata struct (attributes)
% varname = the variable name to be extracted (must have dimension time)
%           When varname is not supplied, a dialog box is offered.
%
% A netCDF (curvi-linear) grid file is defined in
%   <a href="http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04.html">http://cf-pcmdi.llnl.gov/documents/cf-conventions/1.4/ch04.html</a>
% and must have global attributes:
%  *  Conventions   : CF-1.4
% the following assumption must be valid:
%  * lat, lon and time coordinates must always exist as defined in the CF convenctions.
%
% The plot contains (ncfile) in title and (long_name, units) on colorbar.
%
%  [D,M] = nc_cf_grid(ncfile,varname,<keyword,value>)
%
% The following <keyword,value> are implemented
% * plot   (default 1)
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'  % either remote [OpenEarth OPeNDAP THREDDS server test]
%    directory = 'http://opendap.deltares.nl:8080/thredds/dodsC/opendap/'  %               [OpenEarth OPeNDAP THREDDS server production]
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
%    [D,M]=nc_cf_grid([directory,'knmi/NOAA/mom/1990_mom/5/N19900501T025900_SST.nc'],'SST')
%
%See also: SNCTOOLS, NC_CF_STATIONTIMESERIES

% HYRAX does not work, nor does it show tree in ncBrowse, but does plot in ncBrowse.
%    directory = 'http://opendap.deltares.nl:8080/opendap/'                %               [OpenEarth OPeNDAP HYRAX production server]
%    directory = 'http://opendap.deltares.nl:8080/opendap/dodsC/opendap/'  %               [OpenEarth OPeNDAP HYRAX production server]

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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords$

%TO DO: handle indirect time mapping where there is no variable time(time)
%TO DO: allow to get all time related parameters, and plot them on by one (with pause in between)
%TO DO: document <keyword,value> pairs
%TO DO: test also simple case where dimensions are have standard_name latitude, longitude

%% Keyword,values

   OPT.plot    = 1;
   OPT.oned    = 0;
   OPT.varname = []; % one if dimensions are (latitude,longitude), 0 if variables are (latitude,longitude)
   
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

   index = findstrinstruct(fileinfo.Attribute,'Name','Conventions');
   fileinfo.Attribute(index).Value;
   if isempty(index)
      error(['netCDF file is not a grid: needs Attribute Conventions=CF-1.4'])
   end

%% Get datenum

   timename        = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'time');
   if ~isempty(timename)
      M.datenum.units = nc_attget(ncfile,timename,'units');
      D.datenum       = nc_varget(ncfile,timename);
      D.datenum       = udunits2datenum(D.datenum,M.datenum.units); % convert units to datenum
   end
   
%% Get location info

   lonname        = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'longitude');
   if ~isempty(lonname)
      M.lon.units    = nc_attget(ncfile,lonname,'units');
      D.lon          = nc_varget(ncfile,lonname);
   else
      disp('no longitude present')
   end

   latname        = nc_varfind(ncfile, 'attributename', 'standard_name', 'attributevalue', 'latitude');
   if ~isempty(latname)
      M.lat.units    = nc_attget(ncfile,latname,'units');
      D.lat          = nc_varget(ncfile,latname);
   else
      disp('no latitude present')      
   end

%% Find specified (or all parameters) that have latitude AND longitude as either
%  * dimension
%  * coordinates attribute
%  and select one.

   if isempty(OPT.varname)
   
      coordvar = [];
      for ivar=1:length(fileinfo.Dataset)
      
         lat = false;
         lon = false;
         
         %%   direct mapping: find dimension latitude, longitude OR
         
         for idim=1:length(fileinfo.Dataset(ivar).Dimension)

            if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),'latitude'))))
               lat = true;
            end
	    
            if any(cell2mat((strfind(fileinfo.Dataset(ivar).Dimension(idim),'longitude'))))
               lon = true;
            end
            
         end
         
         %% indirect mapping: find index of coordinates attribute
         if (lat && lon)

            coordvar = [coordvar ivar];
            D.lon    = D.lon(:)';
            D.lat    = D.lat(:)';
            OPT.oned = 1;
         
         else

            atrindex = nc_atrname2index(fileinfo.Dataset(ivar),'coordinates');
            
            if ~isempty(atrindex)
            
               % check whether coordinates attribute refers to variables that have standard_name latitude & longitude
               coordvarnames = strtokens2cell(fileinfo.Dataset(ivar).Attribute(atrindex).Value);
               
               lat = false;
               lon = false;
               
               for ii=1:length(coordvarnames)
               
                  varindex = nc_varname2index(fileinfo,coordvarnames{ii});
               
                  % find index of standard_name attribute
                  atrindex = nc_atrname2index(fileinfo.Dataset(varindex),'standard_name');
               
                  if ~isempty(atrindex)
                     if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'latitude')
                     lat=true;
                     end
                     if strcmpi(fileinfo.Dataset(varindex).Attribute(atrindex).Value,'longitude')
                     lon=true;
                     end
                  end
	       
               end
            
               if lat && lon 
                  coordvar = [coordvar ivar];
               end
            
            end % if ~isempty(atrindex)
            
         end % if ~(lat && lon)
         
      end
      
      coordvarlist = cellstr(char(fileinfo.Dataset(coordvar).Name));


      [ii, ok] = listdlg('ListString', coordvarlist, .....
                      'SelectionMode', 'single', ...
                       'PromptString', 'Select one variable', ....
                               'Name', 'Selection of variable',...
                           'ListSize', [500, 300]); 
                               
      
      varindex    = coordvar(ii);
      OPT.varname = coordvarlist{ii};
      
   else
   
   %% get index
   
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

      if OPT.oned
      pcolorcorcen(D.lon,D.lat,D.(OPT.varname)')
      else
      pcolorcorcen(D.lon,D.lat,D.(OPT.varname))
      end
      tickmap ('ll')
      grid     on
      title   ({mktex(fileinfo.Filename),...
                datestr(D.datenum)})
      colorbarwithvtext([mktex(M.(OPT.varname).long_name),' [',...
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