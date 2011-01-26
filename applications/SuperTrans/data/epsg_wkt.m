function wkt = epsg_wkt(epsg_code)
%EPSG_WKT  gets the well known text representation of an epsg code
%
%   Uses webservice. If you recieve a proxy error, adjust the settings in
%   File > Preferences > Web
%
%   Syntax:
%   varargout = epsg_wkt(varargin)
%
%   Input:
%   epsg_code  = EPSG code
%
%   Output:
%   wkt = wellk known text representation of epsg code
%
%   Example
%   wkt = epsg_wkt(4326)
%
%   See also: convertCoordinates, nc_cf_grid_mapping

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       tda
%
%       <EMAIL>	
%
%       <ADDRESS>
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 06 Aug 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

wkt = urlread(sprintf('http://spatialreference.org/ref/epsg/%d/prettywkt/',epsg_code));