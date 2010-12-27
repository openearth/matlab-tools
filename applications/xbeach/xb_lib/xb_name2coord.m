function [x y] = xb_name2coord(name, varargin)
%XB_NAME2COORD  Converts a location name to a coordinate using Google Maps
%
%   Converts a location name to a coordinate using Google Maps. By default,
%   RD locations are returned. Another option is to return WGS84
%   coordinates.
%
%   Syntax:
%   [x y] = xb_name2coord(name, varargin)
%
%   Input:
%   name      = Name of the location
%   varargin  = type:   Type of coordinates to return
%
%   Output:
%   x         = x-coordinate of location
%   y         = y-coordinate of location
%
%   Example
%   [x y] = xb_name2coord('Delft')
%   [x y] = xb_name2coord('Bijenkorf Amsterdam')
%
%   See also xb_bc_normstorm

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl	
%
%       Rotterdamseweg 185
%       2629HD Delft
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
% Created: 27 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'type', 'RD' ...
);

OPT = setproperty(OPT, varargin{:});

%% retrieve latlon coordinate data from google maps

xml = xmlread(['http://maps.google.com/maps/geo?q=' name '&output=xml&oe=utf8']);

xml = xml.getElementsByTagName('kml').item(0);
xml = xml.getElementsByTagName('Response').item(0);
xml = xml.getElementsByTagName('Placemark').item(0);
xml = xml.getElementsByTagName('Point').item(0);

coords = xml.getElementsByTagName('coordinates').item(0);
coords = char(coords.item(0).getData);
coords = str2double(regexp(coords, ',' , 'split'));

x = coords(1);
y = coords(2);

%% convert coordinates

switch OPT.type
    case 'RD'
        [x y] = convertCoordinates(x,y,'CS1.code',4326,'CS2.code',28992);
    case 'WGS84'
        % do nothing
    otherwise
        warning(['Coordinate type unknown, using WGS84 [' OPT.type ']']);
end

if nargout <= 1
    x = [x y];
end

