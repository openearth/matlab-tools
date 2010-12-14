function [x y z] = xb_grid_merge(varargin)
%XB_GRID_MERGE  Merges one or more 2D grids together
%
%   Merges one or more 2D grids together
%
%   Syntax:
%   varargout = xb_grid_merge(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_grid_merge
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
% Created: 14 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'x', {{}}, ...
    'y', {{}}, ...
    'z', {{}}, ...
    'dd', 5, ...
    'precision', 1e5 ...
);

OPT = setproperty(OPT, varargin{:});

if ~iscell(OPT.x) || ~iscell(OPT.y) || ~iscell(OPT.z)
    error('Nothing to merge!');
end

%% read grids

% determine number of full grids
n = min([length(OPT.x) length(OPT.y) length(OPT.z)]);

% determine grid extend
xmin = Inf; xmax = -Inf;
ymin = Inf; ymax = -Inf;

for i = 1:n
    if isvector(OPT.x{i}) && isvector(OPT.y{i})
        [OPT.x{i} OPT.y{i}] = meshgrid(OPT.x{i}, OPT.y{i});
    end
    
    xmin = min(xmin, min(min(OPT.x{i})));
    xmax = max(xmax, max(max(OPT.x{i})));
    ymin = min(ymin, min(min(OPT.y{i})));
    ymax = max(ymax, max(max(OPT.y{i})));
end

% create output grid
[x y] = meshgrid(xmin:OPT.dd:xmax, ymin:OPT.dd:ymax);
z = nan(size(x));

%% interpolate grids to output grid

for i = 1:n
    angle = atan(diff(OPT.y{i}([1 end],1))/diff(OPT.x{i}([1 end],1)))/pi*180-90;
    
    if angle == 0
        % orthogonal grid
        zi = interp2(OPT.x{i}, OPT.y{i}, OPT.z{i}, x, y);
        z(~isnan(zi)) = zi(~isnan(zi));
    else
        % rotated grid
        [xr1 yr1] = xb_grid_world2xb(OPT.x{i}, OPT.y{i}, xmin, ymin, -angle);
        [xr2 yr2] = xb_grid_world2xb(x, y, xmin, ymin, -angle);
        
        % round off
        xr1 = round(xr1*OPT.precision)/OPT.precision;
        yr1 = round(yr1*OPT.precision)/OPT.precision;
        xr2 = round(xr2*OPT.precision)/OPT.precision;
        yr2 = round(yr2*OPT.precision)/OPT.precision;
        
        % interpolate
        zi = interp2(xr1, yr1, OPT.z{i}, xr2, yr2);
        z(~isnan(zi)) = zi(~isnan(zi));
    end
end
