function varargout = xb_write_bathy(xbSettings, varargin)
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
%   varargin    = xfile:        filename of x definition file
%                 yfile:        filename of y definition file
%                 depfile:      filename of depth definition file
%                 ne_layerfile: filename of non-erodable layer definition
%                               file
%
%   Output:
%   varargout   = filenames of created definition files, if used
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

if ~xb_check(xbSettings); error('Invalid XBeach settings structure'); end;

OPT = struct( ...
    'xfile', 'x.grd', ...
    'yfile', 'y.grd', ...
    'depfile', 'bed.dep', ...
    'ne_layer', 'nebed.dep' ...
);

OPT = setproperty(OPT, varargin{:});

%% write bathymetry files

f = fieldnames(OPT);

varargout = {};

c = 1;
for i = 1:length(f)
    data = xb_get(xbSettings, f{i});
    if ~isnan(data)
        varargout{c} = OPT.(f{i});
        save(OPT.(f{i}), '-ascii', 'data');
        c = c+1;
    end
end
