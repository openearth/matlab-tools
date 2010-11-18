function [xgrid ygrid] = worldcoordinates2xbeachgrid(xw,yw,alpha,xori,yori)
%WORLDCOORDINATES2XBEACHGRID  Convert world coordinates to XBeach grid.
%
%   Convert x and y world coordinates to values on the XBeach calculation 
%   grid (using the same alpha, xori and yori as defined in params.txt).
%   Use xbeachgrid2worldcoordinates if you want to convert grid coordinates
%   to world coordinates.
%
%   The computation is a simple matrix calculation A*b = c where
%   A = [cos(alpha) -sin(alpha);sin(alpha) +cos(alpha)]
%   b = [xgrid; ygrid]
%   c = [xworld; yworld]
%
%   Syntax:
%   [xgrid ygrid] = worldcoordinates2xbeachgrid(xw,yw,alpha,xori,yori)
%
%   Input:
%   xw     = scalar, vector or array with x world coordinates
%   yw     = scalar, vector or array with y world coordinates
%   alpha  = rotational angle of the XBeach grid
%   xori   = origin's x coordinate of XBeach grid in world coordinates
%   yori   = origin's y coordinate of XBeach grid in world coordinates
%
%   Output:
%   xgrid  = scalar, vector or array with corresponding XBeach x coordinates
%   ygrid  = scalar, vector or array with corresponding XBeach y coordinates
%
%   Example
%   worldcoordinates2xbeachgrid
%
%   See also XBEACHGRID2WORLDCOORDINATES, CONVERTCOORDINATES

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Arend Pool
%
%       arend.pool@gmail.com	
%
%       
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

% Created: 08 Jun 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

% Changelog
% 2009-07-31: corrected error with alpha

%% Invert alpa
% Because direction of XBeach alpha is opposite to normal rotation, alpha
% needs to be inverted
alpha = -alpha;

%% Main function
A  = [cos(alpha) -sin(alpha); sin(alpha) cos(alpha)];

% substract xori and yori to get relative coordinates
xw = xw - xori;
yw = yw - yori;

c(1,:) = reshape(xw,1,numel(xw));
c(2,:) = reshape(yw,1,numel(yw));

% Compute xgrid and ygrid for every point (and every timestep)
b=A\c;

% Reshape array b to ug and vg, which have the same size as u and v
xgrid = reshape(b(1,:),size(xw));
ygrid = reshape(b(2,:),size(yw));
