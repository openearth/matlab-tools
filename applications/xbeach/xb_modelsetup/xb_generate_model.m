function xb = xb_generate_model(varargin)
%XB_GENERATE_MODEL  Generates a minimal model setup based on bathymetry and boundary conditions
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
    'bathy', {{}}, ...
    'waves', {{}}, ...
    'tide', {{}}, ...
    'settings', {{ ...
        'thetamin', -37.5, ...
        'thetamin', -37.5, ...
        'thetamax', 37.5, ...
        'dtheta', 15, ...
        'tstop', 3600 ...
    }
});

OPT = setproperty(OPT, varargin{:});

% create xbeach structure
xb = xb_empty();

%% create boundary conditions

[waves instat swtable] = xb_generate_waves(OPT.waves{:});
tide = xb_generate_tide(OPT.tide{:});

%% create grid

[bathy nx ny] = xb_generate_grid(OPT.bathy{:});
[xfile yfile depfile nelayer] = xb_split(bathy, 'xfile', 'yfile', 'depfile', 'ne_layer');

%% create model

xb = xb_set(xb, ...
    'nx', nx, ...
    'ny', ny, ...
    'vardx', 1, ...
    'instat', instat, ...
    'bcfile', waves, ...
    'zs0file', tide, ...
    'xfile', xfile, ...
    'yfile', yfile, ...
    'depfile', depfile ...
);

if ~isempty(swtable.data); xb = xb_set(xb, 'swtable', swtable); end;
if ~isempty(nelayer.data); xb = xb_set(xb, 'nelayer', nelayer); end;

for i = 1:2:length(OPT.settings)
    xb = xb_set(xb, OPT.settings{i}, OPT.settings{i+1});
end

xb = xb_meta(xb, mfilename, 'input');

%% write model

xb_write_input('params.txt', xb);

