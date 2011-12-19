function xbo = xb_get_sedbal(xb, varargin)
%XB_GET_SEDBAL  Computes sediment balance from XBeach output structure
%
%   Computes total sedimentation, erosion and transports over domain
%   borders and determines total sediment budget continuity.
%
%   Syntax:
%   xbo = xb_get_sedbal(xb, varargin)
%
%   Input:
%   xb        = XBeach output structure
%   varargin  = t:          time at which balance should be computed
%                           (approximately)
%               porosity:   porosity of bed
%               morfac:     morphological factor between transports and bed
%
%   Output:
%   xbo       = XBeach sediment balance structure
%
%   Example
%   xbo = xb_get_sedbal(xb);
%   xb_show(xbo);
%
%   See also xb_read_output

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
% Created: 15 Nov 2011
% Created with Matlab version: 7.12.0.635 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    't', Inf, ...
    'porosity', .4, ...
    'morfac', 1 ...
);

OPT = setproperty(OPT, varargin{:});

if xb_exist(xb, 'DIMS')
    x   = xb_get(xb, 'DIMS.globalx_DATA');
    y   = xb_get(xb, 'DIMS.globaly_DATA');
    t   = xb_get(xb, 'DIMS.globaltime_DATA');
    tm  = xb_get(xb, 'DIMS.meantime_DATA');
    
    t0 = t(1);
    t   = t(t<=OPT.t);
    tm  = tm(tm<=OPT.t);
    nt  = length(t);
    
    g   = xb_stagger(x,y);
else
    error('Grid not specified');
end

%% compute sedimentation and erosion
if xb_exist(xb, 'zb')
    zb = xb_get(xb, 'zb');
    
    if nt > size(zb,1)
        nt = size(zb,1);
        [t tm] = deal(t(1:nt), tm(1:nt));
    end
    
    sed_DATA = (1-OPT.porosity)*squeeze(zb(nt,:,:)-zb(1,:,:)).*g.dsdnz';
    ero_DATA = -sed_DATA;
    
    sed_DATA(sed_DATA<0) = 0;
    ero_DATA(ero_DATA<0) = 0;
end

%% compute transports over boundaries

Susg_DATA = integrate_transport(xb, 'Susg', g, x, y, t, tm, OPT.morfac);
Svsg_DATA = integrate_transport(xb, 'Svsg', g, x, y, t, tm, OPT.morfac);
Subg_DATA = integrate_transport(xb, 'Subg', g, x, y, t, tm, OPT.morfac);
Svbg_DATA = integrate_transport(xb, 'Svbg', g, x, y, t, tm, OPT.morfac);

S_DATA    = [Susg_DATA Svsg_DATA Subg_DATA Svbg_DATA];

S_s       = sum(cat(3,S_DATA.s),3);
S_n       = sum(cat(3,S_DATA.n),3);

% positive is cell in, negative is cell out
S_cell    = zeros(size(g.xz))';
S_cell(2:end,2:end) = S_n(1:end-1,2:end)-S_n(2:end,2:end) + ...
                      S_s(2:end,1:end-1)-S_s(2:end,2:end);

S.front   =  [0;S_s(2:end,1  )];
S.back    = -[0;S_s(2:end,end)];
S.right   =  [0;S_n(1  ,2:end)'];
S.left    = -[0;S_n(end,2:end)'];

if xb_exist(xb, 'Susg_mean', 'Svsg_mean', 'Subg_mean', 'Svbg_mean') == 4
    
    t = tm;
end

%% compute balance

sed     = sum(sum(sed_DATA));
ero     = sum(sum(ero_DATA));
trans   = sum(cell2mat(struct2cell(S)));

bal     = sed-ero-trans;

bal_cell = sed_DATA-ero_DATA-S_cell;

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

xbo = xb_set(xbo,               ...
    'tstart',       t0,        ...
    'time',         t(nt),     ...
    'surface',      sum(sum(g.dsdnz)), ...
    'bal',          bal,        ...
    'sed',          sed,        ...
    'ero',          ero,        ...
    'trans',        trans,      ...
    'bal_DATA', xb_set([],      ...
        'total',    bal,        ...
        'cell',     bal_cell,   ...
        'sedero',   sed-ero),   ...
    'sed_DATA',     sed_DATA,   ...
    'ero_DATA',     ero_DATA,   ...
    'trans_DATA', xb_set([],    ...
        'cell',     S_cell,     ...
        's',        S_s,        ...
        'n',        S_n,        ...
        'front',    S.front,    ...
        'back',     S.back,     ...
        'right',    S.right,    ...
        'left',     S.left)     ...
);

xbo = xb_meta(xbo, mfilename, 'sedimentbalance');

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = integrate_transport(xb, var, g, x, y, t, tm, f)
    
    r       = struct('s', [], 'n', []);
    
    if xb_exist(xb, [var '_mean'])
        var = [var '_mean'];
        t   = tm;
    elseif xb_exist(xb, var)
        warning('Using instantaneous transports, which can deviate from the time-averaged transports considerably!');
    end
    
    if xb_exist(xb, var)
        
        da      = .5*pi*(var(2)=='v');
        
        nt      = length(t);
        tint    = repmat(diff([t(1)-mean(diff(t));t]),[1 1 size(y,1) size(x,2)]);

        v       = xb_get(xb, var);
        v       = squeeze(sum(sum(v(1:nt,:,:,:),2).*tint,1));

        r.s     = f.*squeeze(v.*cos(g.alfau-da)'.*g.dnu');
        r.n     = f.*squeeze(v.*cos(g.alfav-da)'.*g.dsv');
    end
end