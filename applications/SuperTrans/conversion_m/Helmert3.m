function [x1,y1,z1]=Helmert3(x0,y0,z0,dx,dy,dz)
%HELMERT3  Helmert 3-parameter transformation
%
%  [x2,y2]= [x1,y1,z1]=Helmert3(x0,y0,z0,dx,dy,dz)
%
%See also: CONVERTCOORDINATES

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
      
x1 = x0 + dx;
y1 = y0 + dy;
z1 = z0 + dz;
