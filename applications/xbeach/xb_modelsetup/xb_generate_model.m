function xb = xb_generate_model(varargin)
%XB_GENERATE_MODEL  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_generate_model(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_generate_model
%
%   See also 

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
    'bathy_x', [], ...
    'bathy_y', [], ...
    'bathy_z', [] ...
);

OPT = setproperty(OPT, varargin{:});

% create xbeach structure
xb = xb_new();

%% create grid

% generate grid
[x z] = xb_generate_xgrid(OPT.bathy_x, OPT.bath_z);
[y] = xb_generate_ygrid(OPT.bathy_y);

[xgrid ygrid] = meshgrid(y, x);

% interpolate bathymetry on grid, if necessary
if isvector(OPT.bathy_z)
    
    % 1D grid
    zgrid = repmat(z, length(z), length(y));
else
    
    % 2D grid
    zgrid = interp2(OPT.bathy_x, OPT.bathy_y, OPT.bath_z, xgrid, ygrid);
end

%% create model

xb = xb_set(xb, ...
    'nx', size(zgrid, 1), ...
    'ny', size(zgrid, 2), ...
    'vardx', 1, ...
    'xfile', xb_set([], 'xfile', xgrid), ...
    'yfile', xb_set([], 'yfile', ygrid), ...
    'depfile', xb_set([], 'depfile', zgrid) ...
);

xb = xb_meta(xb, mfilename, 'input');

