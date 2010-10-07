function D = jarkus_distancetoZ(Z,z,x)
% jarkus_distancetoZ calculates the distance to a certain depth 
%  (is used by jarkus_getdepthline)
%
%   Input:
%     Z = specified depth
%     z = vector with depths at locations x
%     x = vector with distances (for example distance from RSP)
%
%   Output:
%     D = distance to Z
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
x = x(find(~isnan(z)));
z = z(find(~isnan(z)));

A=find(z<Z);
if ~isempty(A) && A(1)~=1
    dz  = z(A(1))-z(A(1)-1);
    dx  = x(A(1))-x(A(1)-1);
    ddz = (Z-z(A(1)-1))/dz;
    
    D = x(A(1)-1)+ddz*dx;
else
    D=NaN;
end