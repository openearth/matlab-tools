function [alpha a b] = xb_grid_rotation(x, y, z, varargin)
%XB_GRID_ROTATION  Determines rotation of a 2D grid based on the coastline
%
%   Determines the location of a 2D grid based on the coastline by
%   detecting the coastline and determining the angle of the coastline.
%
%   Syntax:
%   [alpha a b] = xb_grid_rotation(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of bathymetric grid
%   y           = y-coordinates of bathymetric grid
%   z           = elevations in bathymetric grid
%   varargin    = units:    output units (degrees/radians)
%
%   Output:
%   alpha       = rotation of grid
%   a           = linear regression parameter of coastline (y=a+b*x)
%   b           = linear regression parameter of coastline (y=a+b*x)
%
%   Example
%   alpha = xb_grid_rotation(x, y, z)
%
%   See also xb_grid_rotate

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
% Created: 14 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ndims(z) ~= 2; error(['Dimensions of elevation matrix incorrect [' num2str(ndims(z)) ']']); end;

OPT = struct( ...
    'units', 'degrees' ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(y); y = 0; end;

%% determine coastline
[xc yc] = xb_get_coastline(x, y, z);

% get linear regression line from coastline
[a b] = xb_linreg(xc, yc);

%% determine rotation

alpha = 0;
if ~isnan(b)
    alpha = pi/2-atan(b);

    [xr yr] = xb_grid_rotate(x, y, -alpha, 'units', 'radians');
    [dim dir] = xb_grid_orientation(xr, yr, z);
    if dir < 1; alpha = alpha+pi; end;

    % convert units
    if strcmpi(OPT.units, 'degrees')
        alpha = alpha/pi*180;
    end
end