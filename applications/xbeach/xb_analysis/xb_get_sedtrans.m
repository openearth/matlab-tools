function xbo = xb_get_sedtrans(xb, varargin)
%XB_GET_SEDTRANS  Compute sediment transport parameters from XBeach output structure
%
%   Compute sediment transport parameters like sediment concentrations and
%   transport volumes from XBeach output structure. The results are stored
%   in an XBeach sedimenttransport structure and can be plotted with
%   xb_plot_sedtrans.
%
%   Syntax:
%   xbo = xb_get_sedtrans(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = Trep:   representative wave period
%               rho:    sediment density
%               por:    porosity
%
%   Output:
%   xbo       = XBeach sedimenttransport structure
%
%   Example
%   xbo = xb_get_sedtrans(xb)
%
%   See also xb_plot_sedtrans, xb_get_hydro, xb_get_morpho, xb_get_spectrum

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
% Created: 17 Jun 2011
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
    'Trep', 12, ...
    'rho', 2650, ...
    'por', .4 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine profiles

xb      = xb_get_transect(xb);

t       = xb_get(xb, 'DIMS.globaltime_DATA');
x       = xb_get(xb, 'DIMS.globalx_DATA');
x       = squeeze(x(1,:));
dx      = diff(x); dx = dx([1 1:end]);

%% initialize output

c           = 0;
k_wavg      = 0;
k_bavg      = 0;
k_bavg_nb   = 0;
S_dz        = 0;
S_av        = 0;
S_s         = 0;
S_b         = 0;
S_lf        = 0;
S_ut        = 0;
S_as        = 0;

%% compute sediment transport characteristics

% sediment concentration
if xb_exist(xb, 'ccg')
    c = OPT.rho.*mean(xb_get(xb, 'ccg'), 1);
end

% turbulence
if xb_exist(xb, 'DR')
    k_wavg = mean((xb_get(xb, 'DR')/OPT.rho).^(2/3),1);
    if xb_exist(xb, 'Tbore')
        k_bavg = mean((xb_get(xb, 'DR')/OPT.rho).^(2/3).*OPT.Trep./xb_get(xb, 'Tbore'),1);
    end
end

if xb_exist(xb, 'kb')
    k_bavg_nb = mean(xb_get(xb, 'kb'),1);
end

% sediment transports
if xb_exist(xb, 'zb')
    zb = xb_get(xb, 'zb');
    dz = squeeze(zb(end,:)-zb(1,:));
    dz = dz(:);
    S_dz = (1-OPT.por)*flipud(cumsum(flipud(dz))).*dx'./range(t);
end

if xb_exist(xb, 'dzav')
    dzav = xb_get(xb, 'dzav');
    dzav = squeeze(dzav(end,:,:));
    S_av = (1-OPT.por)*flipud(cumsum(flipud(dzav))).*dx'./range(t);
end

if xb_exist(xb, 'Susg')
    Susg = xb_get(xb, 'Susg');
    Szsg = Susg;
    Szsg(:,2:end) = 0.5*(Susg(:,:,1:end-1)+Susg(:,:,2:end));
    S_s = mean(Szsg,1);
end

if xb_exist(xb, 'Subg')
    Subg = xb_get(xb, 'Subg');
    Szbg = Subg;
    Szbg(:,2:end) = 0.5*(Subg(:,:,1:end-1)+Subg(:,:,2:end));
    S_b = mean(Szbg,1);
end

if xb_exist(xb, 'zs', 'zb', 'ccg') == 3
    h = xb_get(xb, 'zs') - xb_get(xb, 'zb');
    if xb_exist(xb, 'u')
        S_lf = mean(xb_get(xb, 'u').*xb_get(xb, 'ccg').*h,1);
        if xb_exist(xb, 'ue')
            S_ut = mean((xb_get(xb, 'ue')-xb_get(xb, 'u')).*xb_get(xb, 'ccg').*h,1);
        end
    end
    
    if xb_exist(xb, 'ua')
        S_as = mean(xb_get(xb, 'ua').*xb_get(xb, 'ccg').*h,1);
    end
end

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'SETTINGS', xb_set([]));

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

if ~isscalar(c);        xbo = xb_set(xbo, 'c',          squeeze(c));        end;
if ~isscalar(k_wavg);   xbo = xb_set(xbo, 'k_wavg',     squeeze(k_wavg));   end;
if ~isscalar(k_bavg);   xbo = xb_set(xbo, 'k_bavg',     squeeze(k_bavg));   end;
if ~isscalar(k_bavg_nb);xbo = xb_set(xbo, 'k_bavg_nb',  squeeze(k_bavg_nb));end;
if ~isscalar(S_dz);     xbo = xb_set(xbo, 'S_dz',       squeeze(S_dz));     end;
if ~isscalar(S_av);     xbo = xb_set(xbo, 'S_av',       squeeze(S_av));     end;
if ~isscalar(S_s);      xbo = xb_set(xbo, 'S_s',        squeeze(S_s));      end;
if ~isscalar(S_b);      xbo = xb_set(xbo, 'S_b',        squeeze(S_b));      end;
if ~isscalar(S_lf);     xbo = xb_set(xbo, 'S_lf',       squeeze(S_lf));     end;
if ~isscalar(S_ut);     xbo = xb_set(xbo, 'S_ut',       squeeze(S_ut));     end;
if ~isscalar(S_as);     xbo = xb_set(xbo, 'S_as',       squeeze(S_as));     end;

xbo = xb_meta(xbo, mfilename, 'sedimenttransport');
