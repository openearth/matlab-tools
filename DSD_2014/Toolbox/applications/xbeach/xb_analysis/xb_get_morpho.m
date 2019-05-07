function xbo = xb_get_morpho(xb, varargin)
%XB_GET_MORPHO  Compute morphological parameters from XBeach output structure
%
%   Compute morphological parameters like bed level change, erosion and
%   sedimentation volumes and retreat distances from XBeach output
%   structure. The results are stored in an XBeach morphology structure and
%   can be plotted with xb_plot_morpho.
%
%   Syntax:
%   xbo = xb_get_morpho(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = level:  assumed storm surge level
%
%   Output:
%   xbo       = XBeach morphology structure
%
%   Example
%   xbo = xb_get_morpho(xb)
%   xbo = xb_get_morpho(xb, 'level', 0)
%
%   See also xb_plot_morpho, xb_get_hydro, xb_get_spectrum

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Deltares
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
% Created: 18 Apr 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id: xb_get_morpho.m 4147 2014-10-31 10:12:42Z bieman $
% $Date: 2014-10-31 11:12:42 +0100 (ven, 31 ott 2014) $
% $Author: bieman $
% $Revision: 4147 $
% $HeadURL: https://svn.oss.deltares.nl/repos/xbeach/Courses/DSD_2014/Toolbox/applications/xbeach/xb_analysis/xb_get_morpho.m $
% $Keywords: $

%% read options

if ~xs_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'level',            5 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine profiles

xb      = xb_get_transect(xb);

x       = xs_get(xb, 'DIMS.globalx_DATA');
x       = squeeze(x(1,:));

% determine bathymetry
if xs_exist(xb, 'zb')
    zb      = xs_get(xb,'zb');
    zb      = squeeze(zb(:,1,:));
else
    error('No bathymetry data found');
end

%% compute sedimentation and erosion

[sed ero dz R Q P] = xb_get_sedero(x,zb,'level',OPT.level);

%% create xbeach structure

xbo = xs_empty();

xbo = xs_set(xbo, 'SETTINGS', xs_set([], ...
    'level',  OPT.level                         ));

xbo = xs_set(xbo, 'DIMS', xs_get(xb, 'DIMS'));

xbo = xs_set(xbo, 'R',      R'      );
xbo = xs_set(xbo, 'Q',      Q'      );
xbo = xs_set(xbo, 'P',      P'      );
xbo = xs_set(xbo, 'sed',    sed'    );
xbo = xs_set(xbo, 'ero',    ero'    );
xbo = xs_set(xbo, 'dz',     dz      );

xbo = xs_meta(xbo, mfilename, 'morphology');
