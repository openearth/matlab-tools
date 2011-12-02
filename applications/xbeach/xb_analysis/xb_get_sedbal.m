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
%   varargin  = none
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
);

OPT = setproperty(OPT, varargin{:});

if xb_exist(xb, 'DIMS')
    x   = xb_get(xb, 'DIMS.globalx_DATA');
    y   = xb_get(xb, 'DIMS.globaly_DATA');
    t   = xb_get(xb, 'DIMS.globaltime_DATA');
    tm  = xb_get(xb, 'DIMS.meantime_DATA');
    
    g = xb_stagger(x,y);
else
    error('Grid not specified');
end

%% compute sedimentation and erosion

if xb_exist(xb, 'zb')
    zb = xb_get(xb, 'zb');
    
    sed_DATA = squeeze(zb(end,:,:)-zb(1,:,:)).*g.dsdnz';
    ero_DATA = -sed_DATA;
    
    sed_DATA(sed_DATA<0) = 0;
    ero_DATA(ero_DATA<0) = 0;
end

%% compute transports over boundaries

Susg_DATA = integrate_transport(xb, 'Susg', g, x, y, t, tm);
Svsg_DATA = integrate_transport(xb, 'Svsg', g, x, y, t, tm);
Subg_DATA = integrate_transport(xb, 'Subg', g, x, y, t, tm);
Svbg_DATA = integrate_transport(xb, 'Svbg', g, x, y, t, tm);

S_DATA    = [Susg_DATA Svsg_DATA Subg_DATA Svbg_DATA];

S         = struct();
f         = fieldnames(S_DATA);
for i = 1:length(f)
    S.(f{i}) = sum(sum([S_DATA.(f{i})]));
end

%% compute balance

sed     = sum(sum(sed_DATA));
ero     = sum(sum(ero_DATA));
trans   = sum(cell2mat(struct2cell(S)));

bal     = sed-ero-trans;

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

xbo = xb_set(xbo,               ...
    'bal',          bal,        ...
    'sed',          sed,        ...
    'ero',          ero,        ...
    'trans',        trans,      ...
    'sed_DATA',     sed_DATA,   ...
    'ero_DATA',     ero_DATA,   ...
    'trans_DATA', xb_set([],    ...
        'front',    S.front,    ...
        'back',     S.back,     ...
        'right',    S.right,    ...
        'left',     S.left)     ...
);

xbo = xb_meta(xbo, mfilename, 'sedimentbalance');

end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function r = integrate_transport(xb, var, g, x, y, t, tm)
    
    r       = struct('front',[],'back',[],'right',[],'left',[]);
    
    if xb_exist(xb, [var '_mean'])
        var = [var '_mean'];
        t   = tm;
    end
    
    if xb_exist(xb, var)
        
        da      = .5*pi*(var(2)=='v');
        
        tint    = repmat(diff([t(1)-mean(diff(t));t]),[1 1 size(y,1) size(x,2)]);

        v       = xb_get(xb, var);
        v       = squeeze(sum(sum(v,2).*tint,1));

        r.front = squeeze(-v(:,1)    .*cos(g.alfau(1,:)    -da)'.*g.dnu(1,:)'    );
        r.back  = squeeze( v(:,end)  .*cos(g.alfau(end,:)  -da)'.*g.dnu(end,:)'  );
        r.right = squeeze(-v(2,:)    .*cos(g.alfav(:,2)    -da)'.*g.dsv(:,2)'    );
        r.left  = squeeze( v(end-1,:).*cos(g.alfav(:,end-1)-da)'.*g.dsv(:,end-1)');
    end
end