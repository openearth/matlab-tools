function D = jarkus_depthatX(X,z,x)
% jarkus_depthatX calculates the depth at a certain distance
%
%   Input:
%     X = specified distance
%     z = vector with depths at locations x
%     x = vector with distances (for example distance from RSP)
%
%   Output:
%     D = depth at distance X
%
% See also: JARKUS, snctools

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Tommer Vermaas
%
%       tommer.vermaas@gmail.com
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

x = x(~isnan(z));
z = z(~isnan(z));

if find(x==X)
    D=z(x==X);
elseif ~isempty(x) && max(x)>X && min(x)<X
    b=find(x<X, 1, 'last' );
    e=find(x>X, 1 );
    
    D = z(b) - ( ((z(b)-z(e))/(x(b)-x(e))) * (x(b)-X) );
else
    D=NaN;
end