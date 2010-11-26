function trisurfcorcen_test()
% TRISURFCORCEN_TEST  test for TRISURFCORCE
%  
% This function tests trisurfcorcen.
%
%
%   See also trisurfcorcen

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 22 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

   el = 30;
   nx = 3;
   ny = 2;
   zlims  = [-.4 .4];
   aspect = [1 1 .2];
   
   dx        = 0.5;
   dy        = 0.5;
   [x,y]     = meshgrid(-2:dx:2, -2:dy:2);
   z         = x .* exp(-x.^2 - y.^2);
   
   tri.p     = delaunay(x,y);
   [tri.x,tri.y,tri.z] = tri_corner2center(tri.p,x,y,z);%tri.z    = mean(z(tri.p),2);
   
   %                       zzzzz ccccc
   subplot(ny,nx,1)
   trisurfcorcen(tri.p,x,y,    z,    z);
   ylabel('\rightarrow c at corners (vertices)')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,z,c)')
   
   subplot(ny,nx,2)
   trisurfcorcen(tri.p,x,y,tri.z,    z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,zc,c)')
   
   subplot(ny,nx,3)
   trisurfcorcen(tri.p,x,y,z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,c)')
   
   subplot(ny,nx,4)
   trisurfcorcen(tri.p,x,y,    z,tri.z);
   xlabel('\uparrow    z at corners (vertices)')
   ylabel('\rightarrow c at centers (faces)   ')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,z,cc)')
   
   subplot(ny,nx,5)
   trisurfcorcen(tri.p,x,y,tri.z,tri.z);
   xlabel('\uparrow    z at centers (faces)   ')
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   title('trisurfcorcen(tri,x,y,zc,cc)')
   
   subplot(ny,nx,6)
   trisurfcorcen(tri.p,x,y,tri.z);
   view   (-20,el)
   zlim   (zlims)
   daspect(aspect)
   xlabel('\uparrow    z derived form c')
   title({'trisurfcorcen(tri,x,y,cc)','NOTE: Z NOT DEFINED !!'})
   
%% EOF   