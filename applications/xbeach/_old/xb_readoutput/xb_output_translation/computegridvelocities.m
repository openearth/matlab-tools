function [ug, vg] = computegridvelocities(u,v,alfa)
%COMPUTEGRIDVELOCITIES  Compute u and v velocities aligned to grid.
%
%   Standard XBeach output gives u and v veloctities according to world
%   coordinates: u is the East-West velocity, v is the North-South
%   velocity. If the computation grid has a rotation alfa, u and v do not
%   allign to the grid. This function computes u_grid and v_grid: the
%   velocities along the x-axis resp. the y-axis of the XBeach grid.
%   
%   The computation is a simple matrix calculation A*b = c where
%   A = [cos(alfa) -sin(alfa);sin(alfa) +cos(alfa)]
%   b = [ug; vg]
%   c = [u; v]
%
%   Syntax:
%   [ug vg] = computegridvelocities(u,v,alfa)
%
%   Input:
%   u       = array of u velocities (XBeach output)
%   v       = array of v velocities (XBeach output)
%   alfa    = rotation of XBeach grid
%
%   Output:
%   ug      = velocities along x-axis of XBeach grid
%   vg      = velocities along y-axis of XBeach grid
%
%   Example
%   computegridvelocities
%
%   See also

%   --------------------------------------------------------------------
%   Copyright (C) 2009 Delft University of Technology
%       Arend Pool
%       arend.pool@gmail.com	
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

% Created: 06 Feb 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$

%% Main function
A  = [cos(alfa) -sin(alfa); sin(alfa) cos(alfa)];

c(1,:) = reshape(u,1,numel(u));
c(2,:) = reshape(v,1,numel(v));

% Compute ug and vg for every gridpoint and every timestep
b=A\c;

% Reshape array b to ug and vg, which have the same size as u and v
ug = reshape(b(1,:),size(u));
vg = reshape(b(2,:),size(v));