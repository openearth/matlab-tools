function varname = lookupVarnameInNetCDF(varargin)
%LOOKUPVARNAMEINNETCDF  Looks up variable name(s) in a NetCDF file associated with an attributename and -value pair.
%
%   Finds the variable name in a NetCDF file where the specified attribute
%   name (e.g. 'standard_name') matches with the specified attribute value
%   (e.g. 'time'). The function returns a string with the variable name if
%   an attributename and -value match was detected or an empty variable if
%   no match was found.
%
%   Syntax:
%   varargout = getVarnameFromNetCDFfile(varargin)
%
%   Input:
%   For the following keywords, values are accepted (values indicated are the current default settings):
%       'ncfile', []               = filename of nc file to use
%       'attributename', []        = attributename to search for in NetCDF file
%       'attributevalue', []       = attributevalue to search for in NetCDF file
%
%   Output:
%       varname                    = string variable containing the variable name where an attribute name and value match is detected 
%
%   Example
%{
    ncfile  = 'Delflandsekust.nc'; nc_dump(ncfile)
    ncfile  = 'KB128_1312.nc';     nc_dump(ncfile)
    varname = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'standard_name', 'attributevalue', 'time')
    varname = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'long_name', 'attributevalue', 'x-coordinate')
    varname = lookupVarnameInNetCDF('ncfile', ncfile, 'attributename', 'long_name', 'attributevalue', 'y-coordinate')
%}
%   See also getDataFromNetCDFGrid

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% settings
% defaults
OPT = struct(...
    'ncfile', [], ...                                   % filename of nc file to use
    'attributename', [], ...                            % this is a datenum of the starting time to search
    'attributevalue', [] ...                            % this indicates the search window (nr of days, '-': backward in time, '+': forward in time)
    );

% overrule default settings by property pairs, given in varargin
OPT = setProperty(OPT, varargin{:});

% initialise output
varname = [];

%% get info from ncfile
infostruct = nc_info(OPT.ncfile);
tempstruct = infostruct.Dataset;

%% fine
Names = {tempstruct(:).Name};
for i = 1:length(Names)
    Attributes = tempstruct(i).Attribute;
    if any(strcmp({Attributes.Name} , OPT.attributename) & strcmp({Attributes.Value} , OPT.attributevalue))
        if isempty(varname)
            varname = Names{i};
        else
            disp('NB: more than one variable fits the description')
            varname = {varname Names(i)}; %#ok<AGROW>
        end
    end
end


