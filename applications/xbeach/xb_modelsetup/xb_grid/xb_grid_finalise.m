function [x y z] = xb_grid_finalise(x, y, z, varargin)
%XB_GRID_FINALISE  Performs several finalisation actions on an XBeach grid
%
%   Performs several finalisation actions on an XBeach grid, like extending
%   and flattening boundaries to prevent numerical instabilities in the
%   calculation.
%
%   Syntax:
%   [x y z] = xb_grid_finalise(x, y, z, varargin)
%
%   Input:
%   x           = x-coordinates of grid to be finalised
%   y           = y-coordinates of grid to be finalised
%   z           = elevations of grid to be finalised
%   varargin    = actions:  cell array containing strings indicating the
%                           order and actions to be performed
%
%                           currently available actions:
%                               lateral_extend:     copy lateral boundaries
%                               lateral_seawalls:   close dry lateral
%                                                   boundaries with
%                                                   sandwalls
%                               seaward_flatten:    flatten offshore
%                                                   boundary
%                               landward_polder:    add polder at -5 at
%                                                   landward side of model
%
%                 cells:    number of cells to use in each action
%
%   Output:
%   x           = x-coordinates of finalised grid
%   y           = y-coordinates of finalised grid
%   z           = elevations of finalised grid
%
%   Example
%   [x y z] = xb_grid_finalise(x, y, z)
%   [x y z] = xb_grid_finalise(x, y, z, 'actions', {'landward_polder' 'lateral_sandwalls' 'lateral_extend' 'seaward_flatten'})
%
%   See also xb_generate_grid

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
% Created: 17 Dec 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% read options

OPT = struct( ...
    'actions', {{'lateral_extend' 'seaward_flatten'}}, ...
    'n', 3, ...
    'zoff', -20, ...
    'slope', 1/50 ...
);

OPT = setproperty(OPT, varargin{:});

%% finalise grid

for i = 1:length(OPT.actions)
    action = OPT.actions{i};
    
    switch action
        case 'lateral_extend'
            if min(size(z)) > 3
                [x y z] = lateral_extend(x, y, z, OPT);
            end
        case 'lateral_sandwalls'
            if min(size(z)) > 3
                [x y z] = lateral_sandwalls(x, y, z, OPT);
            end
        case 'seaward_flatten'
            [x y z] = seaward_flatten(x, y, z, OPT);
        case 'seaward_extend'
            [x y z] = seaward_extend(x, y, z, OPT);
        case 'landward_polder'
            [x y z] = landward_polder(x, y, z, OPT);
        otherwise
            warning(['Ignoring non-existing grid finalisation option [' action ']']);
    end
end

%% private functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x y z] = lateral_extend(x, y, z, OPT)
    dy1 = y(2,1)-y(1,1);
    dy2 = y(end,1)-y(end-1,1);
    
    x = [ones(OPT.n,1)*x(1,:) ; x ; ones(OPT.n,1)*x(end,:)];
    y = [(y(1,1)-[OPT.n*dy1:-dy1:dy1])'*ones(1,size(y,2)) ; y ; (y(end,1)+[dy2:dy2:OPT.n*dy2])'*ones(1,size(y,2))];
    z = [ones(OPT.n,1)*z(1,:) ; z ; ones(OPT.n,1)*z(end,:)];

function [x y z] = lateral_sandwalls(x, y, z, OPT)
    z0 = 5;
    z1 = 0; z2 = 0;
    for i = 1:size(z,2)
        if z(1,i) > z0 || z1 > 0
            z1 = max(z1,z(1,i));
            z(1:n,i) = interp1(y([1 OPT.n+1],i),[z1 z(OPT.n+1,i)],y(1:OPT.n,i));
        end
        if z(end,i) > z0 || z2 > 0
            z2 = max(z2,z(end,i));
            z(end-OPT.n+1:end,i) = interp1(y([end end-OPT.n],i),[z2 z(end-OPT.n,i)],y(end-OPT.n+1:end,i));
        end
    end

function [x y z] = seaward_flatten(x, y, z, OPT)
    z0 = min(z(:,1));
    
    z(:,1) = z0;
    for i = 1:size(z,1)
        z(i,2:OPT.n) = interp1(x(i,[1 OPT.n+1]),[z0 z(i,OPT.n+1)],x(i,2:OPT.n));
    end
    
function [xn yn zn] = seaward_extend(x, y, z, OPT)

z0 = max(z(:,1));
dxoff = x(1,2)-x(1,1);
dn = ceil(max(z0-OPT.zoff,0)/(OPT.slope*dxoff))+OPT.n;
zt = NaN*zeros(size(x,1), size(x,2)+OPT.n);
zt(:,1:OPT.n) = OPT.zoff;
zt(:,OPT.n+1:end) = z; 
% extended xbeach grid
xn = [ x(1,1)-[-1:-1:-dn]*dxoff x(1,:)+dn*dxoff ]; 
[xn,yn] = meshgrid(xn,y(:,1));
% temporary xbeach grid
xt = [xn(1,1:OPT.n) x(1,:)+dn*dxoff]; 
[xt,yt] = meshgrid(xt,y(:,1));
% interpolate
zn = interp2(xt,yt,zt,xn,yn);