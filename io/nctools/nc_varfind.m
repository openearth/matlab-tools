function varname = nc_varfind(ncfile,varargin)
%NC_VARFIND  Lookup variable name(s) in NetCDF file using attributename and -value pair
%
%   Finds the variable name in a netCDF file where the specified attribute
%   name (e.g. 'standard_name') matches with the specified attribute value
%   (e.g. 'time'). The function returns a string with the variable name if
%   an attributename and -value match was detected or an empty variable if
%   no match was found.
%
%      varname = nc_varfind(ncfile,<keyword,value>)
%
%   where 
%       ncfile                     = name of lcoal or opendap netCDF file
%       varname                    = string variable containing the variable name
%                                    where an attribute name and value match is detected 
%                                    cell array if more then 1 variable match description
%
%   The following <keyword,value> pairs have been implemented accepted (values indicated are the current default settings):
%       'attributename' , []       = attributename to search for in netCDF file (e.g. 'standard_name')
%       'attributevalue', []       = attributevalue to search for in netCDF file
%
% Examples:
%
%    directory = 'http://dtvirt5.deltares.nl:8080/thredds/dodsC/opendap/'; % either remote
%    directory = 'P:\mcdata\opendap\'                                      % or local
%
%       varname = nc_varfind([directory,'Delflandsekust.nc'], 'attributename', 'standard_name', 'attributevalue', 'time')
%       varname = nc_varfind([directory,'KB128_1312.nc'    ], 'attributename', 'long_name'    , 'attributevalue', 'x-coordinate')
%
% See also: nc_cf_time

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
varname = [];

%% get info from ncfile
infostruct = nc_info(ncfile);
tempstruct = infostruct.Dataset;

%% find
Names = {tempstruct(:).Name};
for i = 1:length(Names)
    Attributes = tempstruct(i).Attribute;
    if any(strcmp({Attributes.Name} , OPT.attributename) & strcmp({Attributes.Value} , OPT.attributevalue))
        if isempty(varname)
            varname{1} = Names{i};
        else
            disp('NB: more than one variable fits the description')
            varname = {varname Names(i)}; %#ok<AGROW>
        end
    end
end

if length(varname)==1
   varname = char(varname);
end
