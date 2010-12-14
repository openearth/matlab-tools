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
    'dx', 5 ...
);

OPT = setproperty(OPT, varargin{:});

%% prepare grid

x = OPT.x;
y = OPT.y;
z = OPT.z;

if OPT.posdwn
    z = -OPT.z;
end

% determine origin
xori = min(min(x));
yori = min(min(y));

x = x - xori;
y = y - yori;

%% rotate grid

alpha = 0;

xr = x;
yr = y;

if OPT.rotate && ~isvector(z)
    alpha = xb_grid_rotation(x, y, z);
    
    if alpha ~= 0
        [xr yr] = xb_grid_rotate(x, y, -alpha);
    end
end

%% determine representative cross-section

xt = xr;
yt = yr;
zt = z;

if ~isvector(z)
    if (size(x,1)>1 && ~any(diff(x,[],1))) || (size(x,2)>1 && ~any(diff(x,[],2)))
        % orthogonal grid
        xt = xt(1,:);
        yt = yt(:,1);
        zt = max(zt, [], 1);
    else
        % rotated grid (TODO: coudld be better ?!)
        xt = min(min(xr)):OPT.dx:max(max(xr));
        yt = min(min(yr)):max(max(yr));
        zt = size(xt);

        for i = 1:length(xt)
            zt(i) = max(z(xr>=xt(i)-OPT.dx/2&xr<xt(i)+OPT.dx/2));
        end

        xt = xt(~isnan(zt));
        zt = zt(~isnan(zt));
    end
end

%% generate grid

[xg zg] = xb_generate_xgrid(xt, zt);
[yg] = xb_generate_ygrid(yt);

[xgrid ygrid] = meshgrid(xg, yg);

% interpolate bathymetry on grid, if necessary
if isvector(z)
    
    % 1D grid
    zgrid = repmat(zg, length(yg), 1);
else
    
    % 2D grid
    zgrid = griddata(xr, yr, z, xgrid, ygrid);
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
