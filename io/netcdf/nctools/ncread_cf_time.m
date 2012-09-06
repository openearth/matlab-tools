function [datenumbers,zone] = ncread_cf_time(ncFile, varName, varargin)
%NCREAD_CF_TIME  Returns time data from a specified cf compliant time variable in matlab date numbers 
%
%   Syntax is exactly like ncread.
%
%   See also NCREAD

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 05 Sep 2012
% Created with Matlab version: 8.0.0.755 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% check if file is a cf comliant time variable
info          = ncinfo(ncFile,varName);
unitAttribute = strcmpi({info.Attributes.Name},'units');

assert(any(unitAttribute),'Variable must have attribute units')

%% get time data and vonvert from udunits to matlab datenum
vardata            = ncread(ncFile,varName,varargin{:});
time_units         = info.Attributes(unitAttribute).Value;
[datenumbers,zone] = udunits2datenum(vardata,time_units);