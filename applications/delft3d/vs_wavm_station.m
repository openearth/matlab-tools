function H = vs_wavm_station(varargin)
%VS_WAVM_STATION  Read timeseries from one location from map file
%
%     H = vs_wavm_station(nefisfile,m,n)
%
%  loads timeseries of 2D variable at grid cell (m,n) into struct H.
%
% Example:
%
%   H = vs_wavm_station('wavm-3e-5mps.dat',m,n)
%
%See also: DELFT3D, vs_trim_station, vs_meshgrid2dcorcen, vs_let

%   --------------------------------------------------------------------
%   Copyright (C) 2010 Technische Universiteit Delft,
%       Gerben J. de Boer
%
%       g.j.deboer@tudelft.nl
%
%       Fluid Mechanics Section
%       Faculty of Civil Engineering and Geosciences
%       PO Box 5048
%       2600 GA Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

if       ischar(varargin{1})
    S =    vs_use(varargin{1});
elseif isstruct(varargin{1})
    S =           varargin{1};
end

m = varargin{2};
n = varargin{3};

OPT.turb = 0;
OPT.w = 0;
OPT.visc = 0;
OPT.constituents = 0;

if nargin > 3
    OPT = setproperty(OPT,varargin{4:end});
end

G     = vs_meshgrid2dcorcen(S);

%% coordinates

H.m        = m;
H.n        = n;
H.x        = G.cor.x  (n,m);
H.y        = G.cor.y  (n,m);
H.datenum  = vs_time(S,0,1);

%% Parameters
H.HSIGN = vs_let(S,'map-series','HSIGN',{[ m ],[ n ]});
H.DIR = vs_let(S,'map-series','DIR',{[ m ],[ n ]});
H.DEPTH = vs_let(S,'map-series','DEPTH',{[ m ],[ n ]});
H.DSPR = vs_let(S,'map-series','DSPR',{[ m ],[ n ]});
H.QB = vs_let(S,'map-series','QB',{[ m ],[ n ]});
H.XP = vs_let(S,'map-series','XP',{[ m ],[ n ]});
H.YP = vs_let(S,'map-series','YP',{[ m ],[ n ]});

