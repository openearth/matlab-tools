function varargout = nc_varfind(ncfile,varargin)
%NC_VARFIND  Lookup variable name(s) in NetCDF file using attributename and -value pair
%
%      varname = nc_varfind(ncfile  ,<keyword,value>)
%
%   Finds the variable name in a netCDF file where the specified attribute
%   name (e.g. 'standard_name') matches with the specified attribute value
%   (e.g. 'time'). The function returns a string with the variable name if
%   an attributename and -value match was detected, an empty variable if
%   no match was found, and a cell array when more then 1 variable match description.
%
%   ncfile  = name of local file, OPeNDAP address, or result of ncfile = nc_info()
%   varname = string variable containing 
%             the variable name where an attribute name and value match should be detected.
%
%   The following <keyword,value> pairs have been implemented accepted (values indicated are the current default settings):
%       'attributename' , []       = attributename to search for in netCDF file (e.g. 'standard_name')
%       'attributevalue', []       = attributevalue to search for in netCDF file
%
%      [varname,index] = nc_varfind(fileinfo,...) 
%
%    also returns the incides into the fileinfo = nc_info(ncfile)
%                                   
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'; % either remote
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
%       varname = nc_varfind([directory,'knmi\NOAA\mom\1990_mom\5\N19900508T132200_SST.nc'],...
%                 'attributename', 'standard_name', 'attributevalue', 'time')
%
% See also: nc_cf_time, nc_cf_grid

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Mark van Koningsveld
%
%       m.vankoningsveld@tudelft.nl	
%
%       Hydraulic Engineering Section
%       Faculty of Civil Engineering and Geosciences
%       Stevinweg 1
%       2628CN Delft
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

% Created: 02 Apr 2009
% Created with Matlab version: 7.7.0.471 (R2008b)
% renamed from lookupVarnameInNetCDF

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
% defaults

OPT.attributename  = [];  % this is a datenum of the starting time to search
OPT.attributevalue = [];  % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{1:end});

% initialise output
varname  = '';
varindex = [];

%% get info from ncfile
if isstruct(ncfile)
   fileinfo = ncfile;
else
   fileinfo = nc_info(ncfile);
end

%% deal with name change in scntools
if     isfield(fileinfo,'Dataset'); % new
  tempstruct = fileinfo.Dataset;
elseif isfield(fileinfo,'DataSet'); % old
  tempstruct = fileinfo.DataSet;
  disp(['warning: please use newer version of snctools (e.g. ',which('matlab\io\snctools\nc_info'),') instead of (',which('nc_info'),')'])
else
   error('neither field ''Dataset'' nor ''DataSet'' returned by nc_info')
end

%% find
Names = {tempstruct(:).Name};
for i = 1:length(Names)
    Attributes = tempstruct(i).Attribute;
    if ~isempty(Attributes)
    if any(strcmp({Attributes.Name} , OPT.attributename) & strcmp({Attributes.Value} , OPT.attributevalue))
        if isempty(varname)
            varname {1} = Names{i};
            varindex    = i;
        else
            disp('NB: more than one variable fits the description')
            varname  = {varname  Names(i)};
            varindex = [varindex i];
        end
    end
    end
end

if length(varname)==1
   varname = char(varname);
end


if nargout==1
   varargout= {varname};
elseif nargout==2
   varargout= {varname,varindex};
end