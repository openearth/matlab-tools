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
%   varargin  = x: x-coordinates of bathymetry
%               y: y-coordinates of bathymetry
%               z: z-coordinates of bathymetry
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
    'z', [-20 -3 0 3 15 15] ...
);

OPT = setproperty(OPT, varargin{:});

%% generate grid

[x z] = xb_generate_xgrid(OPT.x, min(OPT.z, [], 1));
[y] = xb_generate_ygrid(OPT.y);

[xgrid ygrid] = meshgrid(x, y);

% interpolate bathymetry on grid, if necessary
if isvector(OPT.z)
    
    % 1D grid
    zgrid = repmat(z, length(y), 1);
else
    
    % 2D grid
    zgrid = interp2(OPT.x, OPT.y, OPT.z, xgrid, ygrid);
end

nx = size(zgrid, 2)-1;
ny = size(zgrid, 1)-1;

%% derive posdwn value
% generally ussume posdwn to be -1
posdwn = -1;
if z(1) > mean(z(:))
    % when the z at the seaward boundary is larger then the mean z of the
    % profile, the posdwn is assumed to be 1
    posdwn = 1;
end

%% create xbeach structures

bathy = xb_empty();
bathy = xb_set(bathy, 'xfile', xgrid, 'yfile', ygrid, 'depfile', zgrid);
bathy = xb_meta(bathy, mfilename, 'bathymetry');

xb = xb_empty();
xb = xb_set(xb, 'nx', nx, 'ny', ny, 'vardx', 1, 'posdwn', posdwn);
xb = xb_join(xb, xb_bathy2input(bathy));
