function tri2quat_test()
% TRI2QUAT_TEST  test for tri2quat
%  
% This function tests tri2quat.
%
%
%   See also tri2quat

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

Category(TestCategory.Unit);

[cor.x,cor.y] = meshgrid(1:3,1:4);

%tri    = delaunay(x,y);
%qua    = quat(x,y);
%mapper = tri2quat(tri,qua);

map   = triquat(cor.x,cor.y);

tri   = map.tri;
qua   = map.quat;

ntri  = size(tri,1);
nqua  = size(qua,1);

color = 'rgbcmyk';

[xctri,yctri] = tri_corner2center(tri,cor.x,cor.y);

plot(cor.x(qua),cor.y(qua),'bo')

hold on

for iqua=1:nqua

   patch(    cor.x(qua(iqua,:)),...
             cor.y(qua(iqua,:)),color(iqua),'facealpha',.5)
   text(mean(cor.x(qua(iqua,:))),...
        mean(cor.y(qua(iqua,:))),...
        num2str(iqua),'color',color(iqua),'BackgroundColor','w');

end

plot(cor.x(tri),cor.y(tri),'r.')
tm = trimesh(tri,cor.x,cor.y,'Color','r');
text(xctri,yctri,num2str([1:ntri]'),'color','r')
axis equal

% TODO: add assert

