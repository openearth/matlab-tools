function [x1,y1,z1]=Helmert7(x0,y0,z0,dx,dy,dz,rx,ry,rz,ds)
%HELMERT7  Helmert 7-parameter transformation
%
%  [x2,y2]= [x1,y1,z1]=Helmert7(x0,y0,z0,dx,dy,dz,rx,ry,rz,ds)
%
%See also: CONVERTCOORDINATES
   
%
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares for Building with Nature
%       Maarten van Ormondt
%
%       Maarten.vanOrmondt@deltares.nl	
%
%       Deltares
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

m=1.0 + ds*0.000001;
      
x1 = m*(    x0 - rz*y0 + ry*z0) + dx;
y1 = m*( rz*x0 +    y0 - rx*z0) + dy;
z1 = m*(-ry*x0 + rx*y0 +    z0) + dz;
