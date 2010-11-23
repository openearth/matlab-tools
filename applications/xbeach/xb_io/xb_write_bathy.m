function [xfile yfile depfile ne_layer] = xb_write_bathy(xbSettings, varargin)
%XB_WRITE_BATHY  Writes XBeach bathymetry files from XBeach settings struct
%
%   Writes XBeach bathymetry files x, y, depth and non-erodable layers
%   based on a name/value formatted XBeach settings struct.
%
%   Syntax:
%   [xfile yfile depfile ne_layer] = xb_write_bathy(xbSettings, varargin)
%
%   Input:
%   xbSettings  = XBeach settings struct (name/value)
%   varargin    = x_file:       filename of x definition file
%                 y_file:       filename of y definition file
%                 dep_file:     filename of depth definition file
%                 nelayer_file: filename of non-erodable layer definition
%                               file
%
%   Output:
%   xfile       = filename of x definition file, if used
%   yfile       = filename of y definition file, if used
%   depfile     = filename of depth definition file, if used
%   ne_layer    = filename of non-erodable layer definition file, if used
%
%   Example
%   [xfile yfile depfile ne_layer] = xb_write_bathy(xbSettings)
%
%   See also xb_read_bathy, xb_write_input

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
% Created: 19 Nov 2010
% Created with Matlab version: 7.4.0.287 (R2007a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'x_file', 'x.grd', ...
    'y_file', 'y.grd', ...
    'dep_file', 'bed.dep', ...
    'nelayer_file', 'nebed.dep' ...
);

OPT = setproperty(OPT, varargin{:});

%% write bathymetry files

xfile = '';
yfile = '';
depfile = '';
ne_layer = '';

idx = strcmpi('x', {xbSettings.name})|strcmpi('xfile', {xbSettings.name});
if any(idx)
    xfile = OPT.x_file;
    data = xbSettings(idx).value;
    save(xfile, '-ascii', 'data');
end

idx = strcmpi('y', {xbSettings.name})|strcmpi('yfile', {xbSettings.name});
if any(idx)
    yfile = OPT.y_file;
    data = xbSettings(idx).value;
    save(yfile, '-ascii', 'data');
end

idx = strcmpi('z', {xbSettings.name})|strcmpi('depfile', {xbSettings.name});
if any(idx)
    depfile = OPT.dep_file;
    data = xbSettings(idx).value;
    save(depfile, '-ascii', 'data');
end

idx = strcmpi('ne', {xbSettings.name})|strcmpi('ne_layer', {xbSettings.name});
if any(idx)
    ne_layer = OPT.nelayer_file;
    data = xbSettings(idx).value;
    save(ne_layer, '-ascii', 'data');
end
