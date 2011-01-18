function testresult = rd_correction_shift_test()
% RD_CORRECTION_SHIFT_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2011 Van Oord Dredging and Marine Contractors BV
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       The Netherlands
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
% Created: 18 Jan 2011
% Created with Matlab version: 7.12.0.62 (R2011a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.WorkInProgress;


%% Original code of rd_correction_shift_test.m
[RDx,RDy] = meshgrid((0:50:5000)+207000,(0:50:5000)+504000);
[x_shift,y_shift]     = rd_correction_shift(RDx,RDy);


[c.x,c.y,c.x_shift] = surfer_read('private\x2c.grd');
[c.x,c.y,c.y_shift] = surfer_read('private\y2c.grd');
[c.X,c.Y] = meshgrid(c.x,c.y);
ix = find(c.x<min(min(RDx)),1,'last'):find(c.x>max(max(RDx)),1,'first');
iy = find(c.y<min(min(RDy)),1,'last'):find(c.y>max(max(RDy)),1,'first');


yshift2 = griddata(c.X(iy,ix),c.Y(iy,ix),c.y_shift(iy,ix),RDx,RDy);

d = y_shift - yshift2;

testresult =  max(d(:)) < 0.0005;
% 
% surf(RDx,RDy,yshift2,y_shift - yshift2);
% colormap(colormap_cpt('RdYlBu 09',200));
% hold on
% plot3(c.X(iy,ix),c.Y(iy,ix),c.y_shift(iy,ix),'ro')
% clim([-0.00015,0.00015]);
% hold off
% view([126 44]);
% 
% surf(RDx,RDy,y)
% 
% hold on
% plot3(X(xx,yy),Y(xx,yy),c.y_shift(xx,yy),'.')


