function edges_structured_grid_test()
% EDGES_STRUCTURED_GRID_TEST  One line description goes here
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
% Created: 19 Apr 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

x = 1:100;
y = 201:400;
[X,Y] = meshgrid(x,y);
Z = repmat(peaks(100),2,1);

Z(50:55,:) = nan;
Z(40:65,20:60) = nan;
Z(Z>5) = nan;
Z(Z<-5) = nan;
Z(Z>-0.1&Z<0.1) = nan;


%     profile on
E = edges_structured_grid(X,Y,Z);
%     profile viewer


surf(X,Y,Z,ones(size(Z)))
hold on
aa = E(:,5)==1;
plot3(E(aa,1),E(aa,2),E(aa,3),'.')
plot3(E(~aa,1),E(~aa,2),E(~aa,3),'ro')
view([0,90])
hold off

legend('surface','filled loop','empty loop')

