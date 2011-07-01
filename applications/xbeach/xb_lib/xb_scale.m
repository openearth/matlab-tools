function xb = xb_scale(xb, varargin)
%XB_SCALE  Scales XBeach model input according to Vellings (1986)
%
%   Scales XBeach model input according to Vellings (1986). All scaling
%   dependent parameters should be present in the model input structure.
%
%   Syntax:
%   xb = xb_scale(xb, varargin)
%
%   Input:
%   xb          = XBeach input structure
%   varargin    = depthscale:   depthscale nd
%                 contraction:  horizontal contraction S
%                 zmin:         minimal z-value
%
%   Output:
%   xb          = Scaled XBeach input structure
%
%   Example
%   xb = xb_scale(xb, 'depthscale', 40, 'contraction', 1.68)
%   xb = xb_scale(xb, 'depthscale', 40, 'contraction', 1.68, 'zmin', 0)
%
%   See also xb_generate_model

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
% Created: 01 Jul 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'depthscale', 1, ...
    'contraction', 1, ...
    'zmin', [] ...
);

OPT = setproperty(OPT, varargin{:});

if OPT.depthscale == 1 && OPT.contraction == 1; return; end;

%% determine constants

nd = OPT.depthscale;
nl = nd*OPT.contraction;
nt = sqrt(nd);
nw = nd^2.5/nl^2;

xb = xb_set(xb, 'depthscale', nd);

%% scale bathymetry

[x y z] = xb_input2bathy(xb);

x = x/nl;
z = z/nd;

dz = 0;
if ~isempty(OPT.zmin); dz = OPT.zmin-min(min(z)); end;

xb = xb_bathy2input(xb, x, y, z+dz);

%% scale waves

switch xb_get(xb, 'instat')
    case {'jons' 'jons_table' 4 41}
        xb = xb_set(xb, 'bcfile.Hm0', xb_get(xb, 'bcfile.Hm0')/nd);
        xb = xb_set(xb, 'bcfile.Tp',  xb_get(xb, 'bcfile.Tp' )/nt);
        xb = xb_set(xb, 'bcfile.fp',  xb_get(xb, 'bcfile.fp' )*nt);
    case {'vardens', 6}
        xb = xb_set(xb, 'bcfile.freqs', xb_get(xb, 'bcfile.freqs')*nt);
        xb = xb_set(xb, 'bcfile.vardens', (sqrt(xb_get(xb, 'bcfile.vardens'))/nd).^2);
end

%% scale tide

if xb_exist(xb,'zs0'); xb_set(xb,'zs0',xb_get(xb,'zs0')/nd+dz); end;
if xb_exist(xb,'zs0file'); xb_set(xb,'zs0file.tide',xb_get(xb,'zs0file.tide')/nd+dz); end;

%% scale sediment

if xb_exist(xb,'D50'); xb_set(xb,'D50',xb_get(xb,'D50')/nw); end;
if xb_exist(xb,'D90'); xb_set(xb,'D90',xb_get(xb,'D90')/nw); end;

%% scale time

if xb_exist(xb,'tstart');   xb_set(xb,'tstart',        xb_get(xb,'tstart')/nt); end;
if xb_exist(xb,'tstop');    xb_set(xb,'tstop',         xb_get(xb,'tstop') /nt); end;
if xb_exist(xb,'tint');     xb_set(xb,'tint',          xb_get(xb,'tint')  /nt); end;
if xb_exist(xb,'tintg');    xb_set(xb,'tintg',         xb_get(xb,'tintg') /nt); end;
if xb_exist(xb,'tintm');    xb_set(xb,'tintm',         xb_get(xb,'tintm') /nt); end;
if xb_exist(xb,'tintp');    xb_set(xb,'tintp',         xb_get(xb,'tintp') /nt); end;
if xb_exist(xb,'tsglobal'); xb_set(xb,'tsglobal.data', xb_get(xb,'tsglobal.data')/nt); end;
if xb_exist(xb,'tsmean');   xb_set(xb,'tsmean.data',   xb_get(xb,'tsmean.data')  /nt); end;
if xb_exist(xb,'tspoint');  xb_set(xb,'tspoint.data',  xb_get(xb,'tspoint.data') /nt); end;

%% set meta data

xb = xb_meta(xb, mfilename, 'input');