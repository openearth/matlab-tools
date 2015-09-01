function D = jarkus_distancetoZ(Z,z,x)
% jarkus_distancetoZ calculates the distance to a certain depth 
% if profile crosses depth multiple times all crossings are given
% this function is used by jarkus_getdepthline
%
%   Input:
%     Z = specified depth
%     z = vector with depths at locations x
%     x = vector with distances (for example distance from RSP)
%
%   Output:
%     D = distance(s) to Z or NaN if profile is not crossed
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

A=z>=Z; B=z<Z;
C=A(1:end-1)+B(2:end);
if sum(C~=1)==0
    D = NaN;
else
    dz  = z(find(C~=1)+1)-z(C~=1);
    dx  = x(find(C~=1)+1)-x(C~=1);
    ddz = (Z-z(find(C~=1)+1))./dz;
    
    D = x(find(C~=1)+1)+ddz.*dx;
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    