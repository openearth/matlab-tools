function testresult = tricontour3_test()
% TRICONTOUR3_TEST  One line description goes here
%  
% More detailed description of the test goes here.
%
%
%   See also 

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 <COMPANY>
%       Thijs
%
%       <EMAIL>	
%
%       <ADDRESS>
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
% Created: 21 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

try
    [x,y] = meshgrid(1.1:10.1,1.1:10.1);
    z = peaks(10);
    plot3(x,y,z,'k:')
    
    hold on
    plot3(x',y',z','k:')
    contour3(x,y,z,-6:2:6,'b:');
    h = get(gca,'Children');
    set(h(1:11),'lineWidth',2)
    tri = delaunay(x(:),y(:));
    colormap([1 0 0])
    tricontour3(tri,x(:),y(:),z(:),-6:2:6);
    testresult = true;
catch
    testresult = false;
end

