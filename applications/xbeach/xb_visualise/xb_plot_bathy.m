function xb_plot_bathy(xb, varargin)
%XB_PLOT_BATHY  Plots bathymetry from XBeach structure
%
%   Plots one or more bathymetries from a XBeach structure that contains
%   either XBeach bathymetry input, XBeach model input or XBeach model
%   output. Plots both 1D as 2D bathymetries in 2D or 3D. Also difference
%   plots can be made.
%
%   Syntax:
%   varargout = xb_plot_bathy(xb, varargin)
%
%   Input:
%   xb        = XBeach structure array
%   varargin  = t:          array of timesteps to be plotted
%               colormap:   colormap to be used
%               diff:       boolean to plot differences
%               surf:       boolean to use durf instead of pcolor in case
%                           of 2D bathymetry
%
%   Output:
%   none
%
%   Example
%   xb_plot_bathy(xb)
%   xb_plot_bathy(xb, 'diff', true)
%   xb_plot_bathy(xb, 'surf', true)
%   xb_plot_bathy(xb, 't', [1 100], 'diff', true)
%
%   See also xb_read_bathy, xb_read_input, xb_read_output

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
    't', -1, ...
    'colormap', 'jet', ...
    'diff', false, ...
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
    
    x = xb_get(xb, 'x');
    y = xb_get(xb, 'y');
    z = xb_get(xb, 'zb');
elseif xb_exist(xb, 'xc', 'yc', 'zb')
    
    x = xb_get(xb, 'xc');
    y = xb_get(xb, 'yc');
    z = xb_get(xb, 'zb');
elseif xb_exist(xb, 'xw', 'yw', 'zb')
    
    x = xb_get(xb, 'xw');
    y = xb_get(xb, 'yw');
    z = xb_get(xb, 'zb');
else
    error('No bathymetry found in XBeach structure');
end

%% try to fix dimension order

% determine nx and ny
if ~isvector(x) || ~isvector(y)
    if mean(mean(diff(x, [], 1))) < mean(mean(diff(x, [], 2)))
        nx = size(x, 2);
        ny = size(x, 1);
    else
        nx = size(x, 1);
        ny = size(x, 2);
        
        x = x';
        y = y';
    end
else
    nx = length(x);
    ny = length(y);
end

% determine nt
nt = numel(z)/ny/nx;

% determine t-dimension
d = {':' ':' ':'};
if ndims(z) == 2
    idx = [0 0 1];
else
    idx = size(z)~=nx & size(z)~=ny;
    if ~any(idx)
        if size(z, 1) == nx && size(z, 2) == ny
            idx = [0 0 1];
        elseif size(z, 3) == nx && size(z, 2) == ny
            idx = [1 0 0];
        else
            idx = [0 1 0];
        end
    end
end
idx = logical(idx);

% convert z to t, y, x
zn = nan(nt,ny,nx);
for t = 1:size(z, find(idx))
    d{idx} = t;
    if size(z, 1) == nx && size(z, 2) == ny
        zn(t,:,:) = z(d{:})';
    else
        zn(t,:,:) = z(d{:});
    end
end
z = zn;

%% plot bathymetry

figure; hold on;

colormap(OPT.colormap);

if ny <= 3 && all(min(z(1,:,:), [], 2)==max(z(1,:,:), [], 2))
    % 1D grid
    if length(OPT.t) == 1 && isnumeric(OPT.t) && OPT.t < 1
        plot(x(1,:), squeeze(z(:,1,:)));
    else
        plot(x(1,:), squeeze(z(OPT.t,1,:)));
    end
    xlabel('x'); ylabel('z');
    set(gca, 'XLim', [min(x(1,:)) max(x(1,:))]);
else
    % 2D grid
    if length(OPT.t) == 1 && isnumeric(OPT.t) && OPT.t < 1
        if OPT.diff
            OPT.t = [1 nt];
        else
            OPT.t = 1;
        end
    end
    
    if OPT.diff
        data = diff(z(OPT.t,:,:), [], 1);
    else
        data = z(OPT.t,:,:);
    end
    
    for i = 1:size(data, 1)
        if OPT.surf
            surf(x, y, squeeze(data(i,:,:)));
            xlabel('x'); ylabel('y'); zlabel('z');
            shading flat;
            view(-60,30);
        else
            pcolor(x, y, squeeze(data(i,:,:)));
            xlabel('x'); ylabel('y'); colorbar;
            shading flat; axis equal;
        end
    end
end
