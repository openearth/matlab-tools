function xb = xb_generate_bathy(varargin)
% XB_GENERATE_BATHY  Creates a model bathymetry
%
%   Creates a model bathymetry in either one or two dimensions based on a
%   given bathymetry. The result is a XBeach input structure containing
%   three matrices of equal size containing a rectilinear grid in x, y and
%   z coordinates.
%
%   Syntax:
%   xb = xb_generate_bathy(varargin)
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
%               optimize:   boolean to enable optimization of the grid, if
%                           switched on, the provided grid is interpreted as
%                           bathymetry and an optimal grid is defined, if
%                           switched off, the provided grid is used as is.
%               superfast:  boolean to enable superfast 1D mode
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_bathy('x', x, 'y', y, 'z', z)
%
%   See also xb_grid_xgrid, xb_grid_ygrid, xb_generate_model
%
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

xb_verbose(0,'---');

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
    'optimize', true, ...
    'superfast', true ...
);

OPT = setproperty(OPT, varargin{:});

%% generate grid

if OPT.optimize
    [x y z ne alpha xori yori] = xb_grid_optimize( ...
        'x', OPT.x, 'y', OPT.y, 'z', OPT.z, 'ne', OPT.ne, ...
        'xgrid', OPT.xgrid, 'ygrid', OPT.ygrid, 'rotate', OPT.rotate, ...
        'crop', OPT.crop, 'finalise', OPT.finalise, 'posdwn', OPT.posdwn, ...
        'zdepth', OPT.zdepth);
else
    [x y z ne alpha xori yori] = deal(OPT.x, OPT.y, OPT.z, OPT.ne, 0, NaN, NaN);
end

%% add bathy

if any(any(isnan(ne)))
    xb_verbose(0,'Add bathymetry');
    
    xb = xb_grid_add('x', x, 'y', y, 'z', z, ...
        'posdwn', OPT.posdwn, ...
        'zdepth', OPT.zdepth, 'superfast', OPT.superfast, ...
        'xori',xori,'yori',yori);
else
    xb_verbose(0,'Add bathymetry and non-erodible layers');
    
    xb = xb_grid_add('x', x, 'y', y, 'z', z, 'ne', ne, ...
        'posdwn', OPT.posdwn, ...
        'zdepth', OPT.zdepth, 'superfast', OPT.superfast, ...
        'xori',xori,'yori',yori);
end

alpha = mod(alpha, 360);
xb = xs_set(xb, 'alfa', alpha);

xb_verbose(0,'Store grid rotation as settings');
xb_verbose(1,'Alfa',alpha);