function xb = xb_generate_model(varargin)
%XB_GENERATE_MODEL  Generates a XBeach structure with a full model setup
%
%   Generates a XBeach structure with a full model setup. By default this
%   is a minimal setup with default bathymetry, boundary conditions and
%   settings. The defaults can be overwritten by supplying cell arrays with
%   settings for either the bathymetry, waves, tide or model settings. The
%   result is a XBeach structure, which can be written to disk easily.
%
%   Syntax:
%   varargout = xb_generate_model(varargin)
%
%   Input:
%   varargin  = bathy:      cell array of name/value pairs of bathymetry
%                           settings supplied to xb_generate_grid
%               waves:      cell array of name/value pairs of waves
%                           settings supplied to xb_generate_waves
%               tide:       cell array of name/value pairs of tide
%                           settings supplied to xb_generate_tide
%               settings:   cell array of name/value pairs of model
%                           settings supplied to xb_generate_settings
%               write:      boolean that indicates whether model setup
%                           whould be written to disk (default: true)
%               path:       destination directory of model setup, if
%                           written to disk
%
%   Output:
%   xb        = XBeach structure array
%
%   Example
%   xb = xb_generate_model();
%   xb = xb_generate_model('write', false);
%   xb = xb_generate_model('bathy', {'x', [ ... ], 'z', [ ... ]}, 'waves', {'Hm0', 9, 'Tp', 18});
%
%   See also xb_generate_settings, xb_generate_grid, xb_generate_waves,
%   xb_generate_tide, xb_write_input

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
    'settings', {{}}, ...
    'write', true, ...
    'path', '' ...
);

OPT = setproperty(OPT, varargin{:});

% create xbeach structure
xb = xb_empty();

%% create settings

settings = xb_generate_settings(OPT.settings{:});

%% create boundary conditions

[waves instat swtable] = xb_generate_waves(OPT.waves{:});
tide = xb_generate_tide(OPT.tide{:});

%% create grid

[bathy nx ny] = xb_generate_grid(OPT.bathy{:});
bathy = xb_bathy2input(bathy);

%% create model

xb = xb_set(xb, ...
    'nx', nx, ...
    'ny', ny, ...
    'vardx', 1, ...
    'instat', instat, ...
    'bcfile', waves, ...
    'zs0file', tide ...
);

if ~isempty(swtable.data); xb = xb_set(xb, 'swtable', swtable); end;

% add bathymetry
xb = xb_join(xb, bathy);

% add settings
xb = xb_join(xb, settings);

% add meta data
xb = xb_meta(xb, mfilename, 'input');

%% write model

if OPT.write
    fpath = fullfile(OPT.path, 'params.txt');
    xb_write_input(fpath, xb);
end

