function xb = xb_grid_add(varargin)
%XB_GRID_ADD  Finalise grid and determine properties
%
%   Finalizes a given grid and determines dimensions and other properties.
%   The result is stored in an XBeach structure that can be used as model
%   input.
%
%   Syntax:
%   xb = xb_grid_add(varargin)
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
%   xb = xb_grid_add('x', x, 'y', y, 'z', z);
%
%   See also xb_generate_bathy, xb_grid_optimize

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
%       Bas Hoonhout
%
%       bas.hoonhout@deltares.nl
%
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software: you can redistribute it and/or modify
%   it under the terms of the GNU General Public License as published by
%   the Free Software Foundation, either version 3 of the License, or
%   (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%   GNU General Public License for more details.
%
%   You should have received a copy of the GNU General Public License
%   along with this library.  If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 09 Sep 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'x', [], ...
    'y', [], ...
    'z', [], ...
    'ne', [], ...
    'finalise', true, ...
    'posdwn', false, ...
    'zdepth', 100, ...
    'superfast', true ...
);

OPT = setproperty(OPT, varargin{:});

%% load grid

xgrid = OPT.x;
ygrid = OPT.y;
zgrid = OPT.z;
negrid = OPT.ne;

%% finalise grid

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

% perform finalise actions
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
            negrid = [repmat(negrid(:,1), 1, d21) negrid repmat(negrid(:,end), 1, d22)];
        end
    end
end

%% determine size

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

%% derive whether xgrid is variable or equidistant

dx = unique(diff(xgrid,1,2));
dy = unique(diff(ygrid,1,1));

vardx = ~isscalar(dx)||(~isempty(dy)&&~isscalar(dy));

%% create xbeach structures

xb = xb_empty();
xb = xb_set(xb, 'nx', nx, 'ny', ny, 'xori', xori, 'yori', yori, ...
    'vardx', vardx, 'posdwn', OPT.posdwn);

if ~vardx
    xgrid = [];
    ygrid = [];
    
    if ~isempty(dy)
        xb = xb_set(xb, 'dx', dx, 'dy', dy);
    else
        xb = xb_set(xb, 'dx', dx);
    end
end

if ~isempty(OPT.ne)
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid, negrid);
else
    xb = xb_bathy2input(xb, xgrid, ygrid, zgrid);
end

xb = xb_meta(xb, mfilename, 'input');
