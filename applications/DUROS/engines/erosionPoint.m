function [x z] = erosionPoint(xInitial, zInitial, WL_t, x0)
% EROSIONPOINT  find x and z of erosion point based on x0
%
% This routine derives the erosion point based on a 1:1 sloping line
% starting from x=x0,z=WL_t. 
%
% Syntax: [x z] = erosionPoint(xInitial, zInitial, WL_t, x0)
%
% Input:
% xInitial = array with x-coordinates
% zInitial = array with z-coordinates
% WL_t     = Water level
% x0       = x-coordinate
%
% Output:
%
% See also

%   --------------------------------------------------------------------
%   Copyright (C) 2008 Deltares
%       C.(Kees) den Heijer
%
%       Kees.denHeijer@deltares.nl	
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
%       The Netherlands
%
%   This library is free software; you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation; either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library; if not, write to the Free Software
%   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
%   USA
%   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
%   --------------------------------------------------------------------

% $Id$ 
% $Date$
% $Author$
% $Revision$

%%
% create 1:1 line above the water level, reaching up to maximum profile
% level
z = [WL_t max(zInitial)];
p = [-1 x0+WL_t];
x = polyval(p, z);

% find crossings of this line with the initial profile
[x z] = findCrossings(x, z, xInitial, zInitial, 'keeporiginalgrid');    
