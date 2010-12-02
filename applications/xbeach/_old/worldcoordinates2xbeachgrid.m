function [xgrid ygrid] = worldcoordinates2xbeachgrid(xw,yw,alfa,xori,yori)
%WORLDCOORDINATES2XBEACHGRID  replaced by "xb_worldcoordinates2modelgrid"
%
%   Convert x and y world coordinates to values on the XBeach calculation 
%   grid (using the same alfa, xori and yori as defined in params.txt).
%   Use xbeachgrid2worldcoordinates if you want to convert grid coordinates
%   to world coordinates.
%
%   The computation is a simple matrix calculation A*b = c where
%   A = [cos(alpha) sin(alpha);-sin(alpha) cos(alpha)]
%   b = [xgrid; ygrid]
%   c = [xworld; yworld]
%
%   Syntax:
%   [xgrid ygrid] = worldcoordinates2xbeachgrid(xw,yw,alfa,xori,yori)
%
%   Input:
%   xw     = scalar, vector or array with x world coordinates
%   yw     = scalar, vector or array with y world coordinates
%   alfa   = rotational angle of the XBeach grid (in degrees)
%   xori   = origin's x coordinate of XBeach grid in world coordinates
%   yori   = origin's y coordinate of XBeach grid in world coordinates
%
%   Output:
%   xgrid  = scalar, vector or array with corresponding XBeach x coordinates
%   ygrid  = scalar, vector or array with corresponding XBeach y coordinates
%
%   Example
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

%%
warning(['"' mfilename '" is replaced by "xb_worldcoordinates2modelgrid" and will be deleted.'])

[xgrid ygrid] = xb_worldcoordinates2modelgrid(xw,yw,alfa,xori,yori);