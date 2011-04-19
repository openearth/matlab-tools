function xbo = xb_get_morpho(xb, varargin)
%XB_GET_MORPHO  One line description goes here.
%
%   More detailed description goes here.
%
%   Syntax:
%   varargout = xb_get_morpho(varargin)
%
%   Input:
%   varargin  =
%
%   Output:
%   varargout =
%
%   Example
%   xb_get_morpho
%
%   See also 

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

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

if ~xb_check(xb); error('Invalid XBeach structure'); end;

OPT = struct( ...
    'level',            0 ...
);

OPT = setproperty(OPT, varargin{:});

%% determine profiles

x       = xb_get(xb, 'DIMS.globalx_DATA');
j       = ceil(xb_get(xb, 'DIMS.globaly')/2);
x       = squeeze(x(j,:));

% determine bathymetry
if xb_exist(xb, 'zb')
    zb      = xb_get(xb,'zb');
    zb      = squeeze(zb(:,j,:));
else
    error('No bathymetry data found');
end

%% compute sedimentation and erosion

R   = nan(1,size(xb,1));
Q   = nan(1,size(xb,1));
P   = nan(1,size(xb,1));

sed = zeros(1,size(xb,1));
ero = zeros(1,size(xb,1));

dz  = zb-repmat(zb(1,:),size(zb,1),1);

for i = 2:size(dz,1)

    [xc zc] = findCrossings(x,zb(1,:),x,zb(i,:));

    R(i)    = min(xc(zc>OPT.level));
    Q(i)    = max(xc(zc<OPT.level));
    P(i)    = max(xc(xc<Q(i)));

    iR      = find(x<R(i),1,'last');
    iQ      = find(x<Q(i),1,'last');
    iP      = find(x<P(i),1,'last');

    % accretion area
    sed(i)  =          .5 *     (x(iP+1)    - P(i)        ) .*  dz(i,iP+1)                       ;
    sed(i)  = sed(i) + .5 * sum((x(iP+2:iQ) - x(iP+1:iQ-1)) .* (dz(i,iP+2:iQ) + dz(i,iP+1:iQ-1)));
    sed(i)  = sed(i) + .5 *     (Q(i)       - x(iQ)       ) .*  dz(i,iQ)                         ;

    % erosion area
    ero(i)  =          .5 *     (x(iQ+1)    - Q(i)        ) .*  dz(i,iQ+1)                       ;
    ero(i)  = ero(i) + .5 * sum((x(iQ+2:iR) - x(iQ+1:iR-1)) .* (dz(i,iQ+2:iR) + dz(i,iQ+1:iR-1)));
    ero(i)  = ero(i) + .5 *     (R(i)       - x(iR)       ) .*  dz(i,iR)                         ;
    
end

ero = -ero;

%% create xbeach structure

xbo = xb_empty();

xbo = xb_set(xbo, 'SETTINGS', xb_set([], ...
    'level',  OPT.level                         ));

xbo = xb_set(xbo, 'DIMS', xb_get(xb, 'DIMS'));

xbo = xb_set(xbo, 'R',      R   );
xbo = xb_set(xbo, 'Q',      Q   );
xbo = xb_set(xbo, 'P',      P   );
xbo = xb_set(xbo, 'sed',    sed );
xbo = xb_set(xbo, 'ero',    ero );
xbo = xb_set(xbo, 'dz',     dz  );

xbo = xb_meta(xbo, mfilename, 'morphology');
