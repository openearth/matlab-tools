function xb_plot_bathy(xb, varargin)
%XB_PLOT_BATHY  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_plot_bathy(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_plot_bathy
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
% Created: 02 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    't', 1, ...
    'colormap', 'jet', ...
    'surf', false ...
);

OPT = setproperty(OPT, varargin{:});

%% check, convert and read bathymetry

if xb_exist(xb, 'xfile', 'yfile', 'depfile')
    
    % input bathymetry
    bathy = xb_input2bathy(xb);

    % check if conversion was necessary
    if isempty(bathy)
        bathy = xb;
    end

    x = xb_get(bathy, 'xfile');
    y = xb_get(bathy, 'yfile');
    z = xb_get(bathy, 'depfile');
elseif xb_exist(xb, 'x', 'y', 'zb')
    
    x = xb_get(bathy, 'x');
    y = xb_get(bathy, 'y');
    z = xb_get(bathy, 'zb');
elseif xb_exist(xb, 'xw', 'yw', 'zb')
    
    x = xb_get(bathy, 'xw');
    y = xb_get(bathy, 'yw');
    z = xb_get(bathy, 'zb');
else
    error('No bathymetry found in XBeach structure');
end

%% plot bathymetry

figure;

colormap(OPT.colormap);

if size(z, 1) <= 3 && all(min(z, [], 1)==max(z, [], 1))

    % 1D grid
    plot(x(1,:), z(1,:,:));
    xlabel('x'); ylabel('z');
else

    % 2D grid
    if OPT.surf
        surf(x, y, z(:,:,OPT.t));
        xlabel('x'); ylabel('y'); zlabel('z');
        shading flat;
    else
        pcolor(x, y, z(:,:,OPT.t));
        xlabel('x'); ylabel('y'); colorbar;
        shading flat; axis equal;
    end
end
