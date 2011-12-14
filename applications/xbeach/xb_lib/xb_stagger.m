function g = xb_stagger(x, y)
%XB_STAGGER  Computes staggered grids and gridcell properties from XBeach grid
%
%   Computes staggered grids for u-, v- and c-points and gridcell
%   properties like boundary lengths, cell areas and orientations from
%   XBeach grid. Works similar to the gridprops function from XBeach
%   itself.
%
%   The last character of each variable name indicates the location within
%   a grid cell for which the value is computed (z, u, v or c, see
%   illustration). The variable name further consists of x or y,
%   indicating a location in world coordinates, or of ds or dn, indicating
%   distances or surfaces in grid coordinates. The dsdn* variables are grid
%   cell surfaces. The alfa* variables are orientations of the specified
%   points.
%
%        coast
%
%      |   |   |
%   ---+---c-u-+---  ^     ^
%      |   v z |     | ds  |
%   ---+---+---+---  v     | s
%      |   |   |           |
%   ---+---+---+---
%      |   |   |
%
%          <--->
%            dn
%
%      <-------
%          n
%
%         sea
%
%   Syntax:
%   g = xb_stagger(x, y)
%
%   Input:
%   x       = x-coordinates of z-points
%   y       = y-coordinates of z-points
%
%   Output:
%   g       = structure with grid information
%
%   Example
%   g = xb_stagger(x,y);
%
%   See also xb_generate_bathy

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
% Created: 27 Jan 2011
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% transpose grid

if mean(mean(diff(x,1,2))) > mean(mean(diff(x,1,1))) && ...
        mean(mean(diff(y,1,1))) > mean(mean(diff(y,1,2)))
    x = x';
    y = y';
end

%% superfast support

superfast = false;

if size(x,2) == 1
    superfast = true;
    x = repmat(x,1,3);
    y = [y y+1 y+2];
end

%% output struct

g = struct( ...
    'xz',       nan(size(x)), ...
    'yz',       nan(size(y)), ...
    'xu',       nan(size(x)), ...
    'yu',       nan(size(y)), ...
    'xv',       nan(size(x)), ...
    'yv',       nan(size(y)), ...
    'xc',       nan(size(x)), ...
    'yc',       nan(size(y)), ...
    'dsz',      nan(size(x)), ...
    'dsu',      nan(size(x)), ...
    'dsv',      nan(size(x)), ...
    'dsc',      nan(size(x)), ...
    'dnz',      nan(size(y)), ...
    'dnu',      nan(size(y)), ...
    'dnv',      nan(size(y)), ...
    'dnc',      nan(size(y)), ...
    'dsdnz',    nan(size(x)), ...
    'dsdnu',    nan(size(x)), ...
    'dsdnv',    nan(size(x)), ...
    'alfaz',    nan(size(x)), ...
    'alfau',    nan(size(x)), ...
    'alfav',    nan(size(x))  ...
);

%% get dimensions

nx = size(x,1)-1;
ny = size(x,2)-1;

%% stagger grid

g.xz                = x;
g.yz                = y;

i = 1:nx;
j = 1:ny+1;

g.xu(i   ,j)        = 0.5*g.xz(i   ,j) + 0.5*g.xz(i+1,j);
g.yu(i   ,j)        = 0.5*g.yz(i   ,j) + 0.5*g.yz(i+1,j);
g.xu(nx+1,j)        = 1.5*g.xz(nx+1,j) - 0.5*g.xz(nx ,j);
g.yu(nx+1,j)        = 1.5*g.yz(nx+1,j) - 0.5*g.yz(nx ,j);

i = 1:nx+1;
j = 1:ny;

g.xv(i,j   )        = 0.5*g.xz(i,j   ) + 0.5*g.xz(i,j+1);
g.yv(i,j   )        = 0.5*g.yz(i,j   ) + 0.5*g.yz(i,j+1);
g.xv(i,ny+1)        = 1.5*g.xz(i,ny+1) - 0.5*g.xz(i,ny );
g.yv(i,ny+1)        = 1.5*g.yz(i,ny+1) - 0.5*g.yz(i,ny );

i = 1:nx;
j = 1:ny;

g.xc(i   ,j   )     = 0.25*(g.xz(i,j) + g.xz(i+1,j) + g.xz(i,j+1) + g.xz(i+1,j+1));
g.yc(i   ,j   )     = 0.25*(g.yz(i,j) + g.yz(i+1,j) + g.yz(i,j+1) + g.yz(i+1,j+1));
g.xc(nx+1,j   )     = 0.5 *(g.xu(nx+1,j) + g.xu(nx+1,j+1));
g.yc(nx+1,j   )     = 0.5 *(g.yu(nx+1,j) + g.yu(nx+1,j+1));
g.xc(i   ,ny+1)     = 0.5 *(g.xv(i,ny+1) + g.xv(i+1,ny+1));
g.yc(i   ,ny+1)     = 0.5 *(g.yv(i,ny+1) + g.yv(i+1,ny+1));
g.xc(nx+1,ny+1)     = 1.5 * g.xu(nx+1,ny+1) - 0.5*g.xu(nx,ny+1);
g.yc(nx+1,ny+1)     = 1.5 * g.yu(nx+1,ny+1) - 0.5*g.yu(nx,ny+1);

%% compute cell boundary lengths

g.dsz(2:nx+1,:) = sqrt((g.xu(2:nx+1,:)-g.xu(1:nx,:)).^2+(g.yu(2:nx+1,:)-g.yu(1:nx,:)).^2);
g.dsz(1,:)      = g.dsz(2,:);

g.dsu(1:nx,:)   = sqrt((g.xz(2:nx+1,:)-g.xz(1:nx,:)).^2+(g.yz(2:nx+1,:)-g.yz(1:nx,:)).^2);
g.dsu(nx+1,:)   = g.dsu(nx,:);

i = 2:size(x,1);
j = 1:size(y,2);
g.dsv(i,j)      = sqrt( (g.xc(i,j)-g.xc(i-1,j)).^2 + (g.yc(i,j)-g.yc(i-1,j)).^2 );
g.dsv(1   , j)  = g.dsv(2 , j);
g.dsv(nx+1, j)  = g.dsv(nx, j);

g.dsc(1:nx,:)   = sqrt((g.xv(2:nx+1,:)-g.xv(1:nx,:)).^2+(g.yv(2:nx+1,:)-g.yv(1:nx,:)).^2);
g.dsc(nx+1,:)   = g.dsc(nx,:);

g.dnz(:,2:ny+1) = sqrt((g.xv(:,2:ny+1)-g.xv(:,1:ny)).^2+(g.yv(:,2:ny+1)-g.yv(:,1:ny)).^2);
g.dnz(:,1)      = g.dnz(:,2);

g.dnu(:,2:ny+1) = sqrt((g.xc(:,2:ny+1)-g.xc(:,1:ny)).^2+(g.yc(:,2:ny+1)-g.yc(:,1:ny)).^2);
g.dnu(:,1)      = g.dnu(:,2);

g.dnv(:,1:ny)   = sqrt((g.xz(:,2:ny+1)-g.xz(:,1:ny)).^2+(g.yz(:,2:ny+1)-g.yz(:,1:ny)).^2);
g.dnv(:,ny+1)   = g.dnv(:,ny);

g.dnc(:,1:ny)   = sqrt((g.xu(:,2:ny+1)-g.xu(:,1:ny)).^2+(g.yu(:,2:ny+1)-g.yu(:,1:ny)).^2);
g.dnc(:,ny+1)   = g.dnc(:,ny);

%% compute cell areas

% dsdnz
i = 2:nx+1;
j = 2:ny+1;

x1 = g.xc(i-1, j  ) - g.xc(i-1, j-1);
x2 = g.xc(i  , j  ) - g.xc(i  , j-1);
x3 = g.xc(i  , j-1) - g.xc(i-1, j-1);
x4 = g.xc(i  , j  ) - g.xc(i-1, j  );

y1 = g.yc(i-1, j  ) - g.yc(i-1, j-1);
y2 = g.yc(i  , j  ) - g.yc(i  , j-1);
y3 = g.yc(i  , j-1) - g.yc(i-1, j-1);
y4 = g.yc(i  , j  ) - g.yc(i-1, j  );

g.dsdnz(i,j) = 0.5 * ( abs(x1.*y3 - x3.*y1) + abs(x2.*y4 - x4.*y2) );
g.dsdnz(:,1) = g.dsdnz(:,2);
g.dsdnz(1,:) = g.dsdnz(2,:);

% dsdnu
i = 1:nx;
j = 2:ny+1;

x1 = g.xv(i  , j  ) - g.xv(i  , j-1);
x2 = g.xv(i+1, j  ) - g.xv(i+1, j-1);
x3 = g.xv(i+1, j-1) - g.xv(i  , j-1);
x4 = g.xv(i+1, j  ) - g.xv(i  , j  );
y1 = g.yv(i  , j  ) - g.yv(i  , j-1);
y2 = g.yv(i+1, j  ) - g.yv(i+1, j-1);
y3 = g.yv(i+1, j-1) - g.yv(i  , j-1);
y4 = g.yv(i+1, j  ) - g.yv(i  , j  );

g.dsdnu(i,j) = 0.5 * ( abs(x1.*y3 - x3.*y1) + abs(x2.*y4 - x4.*y2) );
g.dsdnu(:,1) = g.dsdnu(:,2);
g.dsdnu(nx+1,:) = g.dsdnu(nx,:);

% dsdnv
i = 2:nx+1;
j = 1:ny;

x1 = g.xu(i-1 , j+1) - g.xu(i-1 , j  );
x2 = g.xu(i   , j+1) - g.xu(i   , j  );
x3 = g.xu(i   , j  ) - g.xu(i-1 , j  );
x4 = g.xu(i   , j+1) - g.xu(i-1 , j+1);
y1 = g.yu(i-1 , j+1) - g.yu(i-1 , j  );
y2 = g.yu(i   , j+1) - g.yu(i   , j  );
y3 = g.yu(i   , j  ) - g.yu(i-1 , j  );
y4 = g.yu(i   , j+1) - g.yu(i-1 , j+1);

g.dsdnv(i,j) = 0.5 * ( abs(x1.*y3 - x3.*y1) + abs(x2.*y4 - x4.*y2) );
g.dsdnv(:,ny+1) = g.dsdnv(:,ny);
g.dsdnv(1,:) = g.dsdnv(2,:);

%% compute cell orientations

g.alfaz(2:nx,:) = atan2(g.yz(3:nx+1,:)-g.yz(1:nx-1,:),g.xz(3:nx+1,:)-g.xz(1:nx-1,:));
g.alfaz(1,:)    = g.alfaz(2 ,:);
g.alfaz(nx+1,:) = g.alfaz(nx,:);

g.alfau(1:nx,:) = atan2(g.yz(2:nx+1,:)-g.yz(1:nx,:),g.xz(2:nx+1,:)-g.xz(1:nx,:));
g.alfau(nx+1,:) = g.alfau(nx,:);

g.alfav(:,1:ny) = atan2(g.yz(:,2:ny+1)-g.yz(:,1:ny),g.xz(:,2:ny+1)-g.xz(:,1:ny));
g.alfav(:,ny+1) = g.alfav(:,ny);

%% superfast support (continued)

if superfast
    f = fieldnames(g);
    for i = 1:length(f)
        g.(f{i}) = g.(f{i})(:,1);
    end
end
