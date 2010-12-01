function [xgrid ygrid zgrid] = xb_generate_grid(xin, yin, zin, varargin)
%XB_GENERATE_GRID  Creates a model grid based on a given bathymetry
%
%   Creates a model grid in either one or two dimensions based on a given
%   bathymetry. The result is three matrices of equal size containing a
%   rectilinear grid in x, y and z coordinated.
%
%   Syntax:
%   [xgrid ygrid zgrid] = xb_generate_grid(xin, yin, zin, varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   [xgrid ygrid zgrid] = xb_generate_grid(xin, yin, zin)
%
%   See also xb_generate_xgrid, xb_generate_ygrid

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
);

OPT = setproperty(OPT, varargin{:});

%% generate grid

[x z] = xb_generate_xgrid(xin, zin);
[y] = xb_generate_ygrid(yin);

[xgrid ygrid] = meshgrid(x, y);

% interpolate bathymetry on grid, if necessary
if isvector(zin)
    
    % 1D grid
    zgrid = repmat(z, length(y), 1);
else
    
    % 2D grid
    zgrid = interp2(xin, yin, zin, xgrid, ygrid);
end
