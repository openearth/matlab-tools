function xb = xb_generate_grid(varargin)
%XB_GENERATE_GRID  Creates a model grid based on a given bathymetry
%
%   Creates a model grid in either one or two dimensions based on a given
%   bathymetry. The result is a XBeach input structure containing three
%   matrices of equal size containing a rectilinear grid in x, y and z
%   coordinates.
%
%   Syntax:
%   xb = xb_generate_grid(varargin)
%
%   Input:
%   varargin  = x:          x-coordinates of bathymetry
%               y:          y-coordinates of bathymetry
%               z:          z-coordinates of bathymetry
%               rotate:     boolean flag that determines whether the
%                           coastline is located in line with y-axis
%               posdwn:     boolean flag that determines whether positive
%                           z-direction is down
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_grid('x', x, 'y', y, 'z', z)
%
%   See also xb_generate_xgrid, xb_generate_ygrid, xb_generate_model

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
% Created: 01 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'x', [0 2550 2724.9 2775 2805 3030.6], ...
    'y', [], ...
    'z', [-20 -3 0 3 15 15], ...
    'rotate', true, ...
    'posdwn', false, ...
    'dd', 5 ...
);

OPT = setproperty(OPT, varargin{:});

%% prepare grid

x_w = OPT.x;
y_w = OPT.y;
z_w = OPT.z;

% make sure coordinates are matrices
if isvector(x_w) && isvector(y_w)
    [x_w y_w] = meshgrid(x_w, y_w);
end

% set vertical positive direction
if OPT.posdwn
    z_w = -z_w;
end

%% convert from world to xbeach coordinates

% determine origin
xori = min(min(x_w));
yori = min(min(y_w));

alpha = 0;
x_r = x_w - xori;
y_r = y_w - yori;
z_r = z_w;

% rotate grid and determine alpha
if OPT.rotate && ~isvector(z_w)
    alpha = xb_grid_rotation(x_r, y_r, z_w);
    
    if alpha ~= 0
        [x_r y_r] = xb_grid_rotate(x_r, y_r, -alpha);
    end
end

%% create dummy grid

x_d = min(min(x_r)):OPT.dd:max(max(x_r));
y_d = min(min(y_r)):OPT.dd:max(max(y_r));

% rotate dummy grid to world coordinates
[x_d_w y_d_w] = xb_grid_rotate(x_d, y_d, alpha);
x_d_w = xori + x_d_w; y_d_w = yori + y_d_w;

% interpolate elevation data to dummy grid
z_d = interp2(x_w, y_w, z_w, x_d_w, y_d_w);

%% determine representative cross-section

z_d_cs = max(z_d, [], 1);

% remove nan's
notnan = ~isnan(z_d_cs);
x_d = x_d(notnan);
z_d_cs = z_d_cs(notnan);

%% create xbeach grid

[x_xb z_xb] = xb_generate_xgrid(x_d, z_d_cs);
[y_xb] = xb_generate_ygrid(y_d);

[xgrid ygrid] = meshgrid(x_xb, y_xb);

% interpolate bathymetry on grid, if necessary
if isvector(z_w)
    % 1D grid
    zgrid = repmat(z_xb, length(y_xb), 1);
else
    % 2D grid
    
    % rotate xbeach grid to world coordinates
    [x_xb_w y_xb_w] = xb_grid_rotate(x_xb, y_xb, alpha);
    x_xb_w = xori + x_xb_w; y_xb_w = yori + y_xb_w;
    
    % interpolate elevation data to xbeach grid
    zgrid = interp2(x_w, y_w, z_w, x_xb_w, y_xb_w);
end

% determine size
nx = size(zgrid, 2)-1;
ny = size(zgrid, 1)-1;

if OPT.posdwn
    zgrid = -zgrid;
end

%% create xbeach structures

bathy = xb_empty();
bathy = xb_set(bathy, 'xfile', xgrid, 'yfile', ygrid, 'depfile', zgrid);
bathy = xb_meta(bathy, mfilename, 'bathymetry');

xb = xb_empty();
xb = xb_set(xb, 'nx', nx, 'ny', ny, 'xori', xori, 'yori', yori, ...
    'alpha', alpha, 'vardx', 1, 'posdwn', OPT.posdwn);

xb = xb_join(xb, xb_bathy2input(bathy));
xb = xb_meta(xb, mfilename, 'input');
