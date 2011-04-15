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
%               ne:         vector or matrix of the size of z containing
%                           either booleans indicating if a cell is
%                           non-erodable or a numeric value indicating the
%                           thickness of the erodable layer on top of a
%                           non-erodable layer
%               xgrid:      options for xb_grid_xgrid
%               ygrid:      options for xb_grid_ygrid
%               rotate:     boolean flag that determines whether the
%                           coastline is located in line with y-axis
%               crop:       either a boolean indicating if grid should be
%                           cropped to obtain a rectangle or a [x y w h]
%                           array indicating how the grid should be cropped
%               finalise:   either a boolean indicating if grid should be
%                           finalised using default settings or a cell
%                           array indicating the finalisation actions to
%                           perform
%               posdwn:     boolean flag that determines whether positive
%                           z-direction is down
%               zdepth:     extent of model below mean sea level, which is
%                           used if non-erodable layers are defined
%               superfast:  boolean to enable superfast 1D mode
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_grid('x', x, 'y', y, 'z', z)
%
%   See also xb_grid_xgrid, xb_grid_ygrid, xb_generate_model

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
    'ne', [], ...
    'xgrid', {{}}, ...
    'ygrid', {{}}, ...
    'rotate', true, ...
    'crop', true, ...
    'finalise', true, ...
    'posdwn', false, ...
    'zdepth', 100, ...
    'superfast', false ...
);

OPT = setproperty(OPT, varargin{:});

if isempty(OPT.y); OPT.y = 0; end;

%% prepare grid

x_w = OPT.x;
y_w = OPT.y;
z_w = OPT.z;
ne_w = OPT.ne;

% make sure coordinates are matrices
if isvector(x_w) && isvector(y_w)
    [x_w y_w] = meshgrid(x_w, y_w);
end

% set vertical positive direction
if OPT.posdwn
    z_w = -z_w;
end

%% convert from world to xbeach coordinates

[x_r y_r] = deal(x_w, y_w);

% determine origin
xori = min(min(x_w));
yori = min(min(y_w));

alpha = 0;

% rotate grid and determine alpha
if OPT.rotate && ~isvector(z_w)
    alpha = xb_grid_rotation(x_r, y_r, z_w);
    
    if abs(alpha) > 5
        [x_r y_r] = xb_grid_rotate(x_r, y_r, -alpha, 'origin', [xori yori]);
    else
        alpha = 0;
    end
end

%% determine representative cross-section

if isvector(z_w)
    % create dummy grid
    x_d = x_r;
    y_d = [];
    z_d_cs = z_w;
else
    % determine resolution and extent
    [cellsize xmin xmax ymin ymax] = xb_grid_resolution(x_r, y_r);
    
    % crop grid
    if ischar(OPT.crop) && strcmpi(OPT.crop, 'select')
        fh = figure;
        pcolor(x_r, y_r, z_w);
        shading flat; colorbar;
        
        [xin yin] = ginput(2);
        OPT.crop = [min(xin) min(yin) abs(diff(xin)) abs(diff(yin))];
        
        close(fh);
    end
    
    if ~islogical(OPT.crop) && isvector(OPT.crop)
        [xmin xmax ymin ymax] = xb_grid_crop(x_r, y_r, z_w, 'crop', OPT.crop);
    elseif OPT.crop
        [xmin xmax ymin ymax] = xb_grid_crop(x_r, y_r, z_w);
    end

    % create dummy grid
    x_d = xmin:cellsize:xmax;
    y_d = ymin:cellsize:ymax;

    % rotate dummy grid to world coordinates
    [x_d_w y_d_w] = xb_grid_rotate(x_d, y_d, alpha, 'origin', [xori yori]);

    % interpolate elevation data to dummy grid
    z_d = interp2(x_w, y_w, z_w, x_d_w, y_d_w);

    % determine representative cross-section
    z_d_cs = max(z_d, [], 1);
end

% remove nan's
notnan = ~isnan(z_d_cs);
x_d = x_d(notnan);
z_d_cs = z_d_cs(notnan);

%% create xbeach grid

[x_xb z_xb] = xb_grid_xgrid(x_d, z_d_cs, OPT.xgrid{:});
[y_xb] = xb_grid_ygrid(y_d, OPT.ygrid{:});

[xgrid ygrid] = meshgrid(x_xb, y_xb);

% interpolate bathymetry on grid, if necessary
if isvector(z_w)
    % 1D grid
    zgrid = repmat(z_xb, length(y_xb), 1);
    
    % interpolate non-erodable layers
    if ~isempty(OPT.ne)
        negrid = interp1(x_d, ne_w, x_xb);
        if islogical(OPT.ne)
            negrid(isnan(negrid)) = 0;
            idx = ~logical(round(negrid));
            negrid(idx) = OPT.zdepth+zgrid(idx);
            negrid(~idx) = 0;
        end
        negrid = repmat(negrid, length(y_xb), 1);
    end
else
    % 2D grid
    
    % rotate xbeach grid to world coordinates
    [x_xb_w y_xb_w] = xb_grid_rotate(x_xb, y_xb, alpha, 'origin', [xori yori]);
    
    % interpolate elevation data to xbeach grid
    zgrid = interp2(x_w, y_w, z_w, x_xb_w, y_xb_w);
    
    % interpolate non-erodable layers
    if ~isempty(OPT.ne)
        negrid = interp2(x_w, y_w, ne_w, x_xb_w, y_xb_w);
        if islogical(OPT.ne)
            negrid(isnan(negrid)) = 0;
            idx = ~logical(round(negrid));
            negrid(idx) = OPT.zdepth+zgrid(idx);
            negrid(~idx) = 0;
        end
    end
end

% interpolate nan's
if (~islogical(OPT.finalise) && iscell(OPT.finalise)) || (islogical(OPT.finalise) && OPT.finalise)
    for i = 1:size(zgrid, 1)
        notnan = ~isnan(zgrid(i,:));
        if any(~notnan) && sum(notnan) > 1
            zgrid(i,~notnan) = interp1(xgrid(i,notnan), zgrid(i,notnan), xgrid(i,~notnan));
            if ~isempty(OPT.ne); negrid(i,~notnan) = OPT.zdepth+zgrid(i,~notnan); end;
        end

        j = find(~isnan(zgrid(i,:)), 1, 'first');
        if ~isempty(j) && j > 1
            zgrid(i,1:j-1) = zgrid(i,j);
            if ~isempty(OPT.ne); negrid(i,1:j-1) = OPT.zdepth+zgrid(i,j); end;
        end

        j = find(~isnan(zgrid(i,:)), 1, 'last');
        if ~isempty(j) && j < size(zgrid, 2)
            zgrid(i,j+1:end) = zgrid(i,j);
            if ~isempty(OPT.ne); negrid(i,j+1:end) = OPT.zdepth+zgrid(i,j); end;
        end
    end
end

% finalise grid
if ~islogical(OPT.finalise) && iscell(OPT.finalise)
    [xgrid, ygrid, zgrid] = xb_grid_finalise(xgrid, ygrid, zgrid, 'actions', OPT.finalise);
elseif OPT.finalise
    [xgrid, ygrid, zgrid] = xb_grid_finalise(xgrid, ygrid, zgrid);
end

% adapt nelayer to finalised grid
if (~islogical(OPT.finalise) && iscell(OPT.finalise)) || (islogical(OPT.finalise) && OPT.finalise)
    if ~isempty(OPT.ne)
        d1 = size(zgrid, 1) - size(negrid, 1); d11 = floor(d1/2); d12 = ceil(d1/2);
        d2 = size(zgrid, 2) - size(negrid, 2); d21 = floor(d2/2); d22 = ceil(d2/2);

        if d1 < 0
            negrid = negrid(d11+1:end-d12,:);
        elseif d1 > 0
            negrid = [repmat(negrid(1,:), d11, 1) ; negrid ; repmat(negrid(end,:), d12, 1)];
        end

        if d2 < 0
            negrid = negrid(:,d21+1:end-d22);
        elseif d2 > 0
            negrid = [repmat(negrid(:,1), 1, d21) negrid repmat(negrid(:,end), 1, d12)];
        end
    end
end

% determine size
nx = size(zgrid, 2)-1;
ny = size(zgrid, 1)-1;

if OPT.superfast && ny == 2
    ny = 0;
    xgrid = xgrid(1,:);
    ygrid = ygrid(1,:);
    zgrid = zgrid(1,:);
end

if OPT.posdwn
    zgrid = -zgrid;
end

% determine origin
xori = min(min(xgrid));
yori = min(min(ygrid));

xgrid = xgrid - xori;
ygrid = ygrid - yori;

%% create xbeach structures

xb = xb_empty();
xb = xb_set(xb, 'nx', nx, 'ny', ny, 'xori', xori, 'yori', yori, ...
    'alfa', mod(360-alpha, 360), 'vardx', 1, 'posdwn', OPT.posdwn);

if ~isempty(OPT.ne)
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid, negrid);
else
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid);
end

xb = xb_meta(xb, mfilename, 'input');
