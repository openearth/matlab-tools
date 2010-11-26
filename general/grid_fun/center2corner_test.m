function center2corner_test()
% CENTER2CORNER_TEST  visual test for center2corner
%  
%
%   See also center2corner, corner2center_test

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
% Created: 23 Jun 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;

%% ----------------------

g.xcen = [0 1 2   3 4 5;
          0 1 nan 3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5;
          0 1 2   3 4 5];

g.ycen = [0 0 0   0   0 0;
          1 1 nan nan 1 1;
          2 2 nan nan 2 2;
          3 3 3   3   3 3;
          4 4 4   4   4 4;
          5 5 5   5   5 5];

figure('name','center2corner')
g.xcor = center2corner(g.xcen);
g.ycor = center2corner(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2corner: g center -- b corner')
axis([-1 6 -1 6])

figure('name','center2cornernan')
g.xcor = center2cornernan(g.xcen);
g.ycor = center2cornernan(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2cornernan: g center -- b corner')
axis([-1 6 -1 6])

%% ----------------------

g.xcen = [...
     0     1     2     3     4     5
     0     1     nan   3     4     5
     0     1     2     3     4     5
     0     1     2     3     nan   nan
     0     1     2     3     nan   nan];


g.ycen = [...
     1     1     1     1     1     1
     2     2     2     2     2     2
     3     3     3     3     3     3
     4     4     4     4     4     4
     5     5     5     5     5     5];


figure('name','center2corner')
g.xcor          = center2corner(g.xcen);
g.ycor          = center2corner(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2corner: g center -- b corner')
axis([-1 6 -1 6])

figure('name','center2cornernan')
g.xcor          = center2cornernan(g.xcen);
g.ycor          = center2cornernan(g.ycen);
grid_plot(g.xcen,g.ycen,'sg-')
hold on
grid_plot(g.xcor,g.ycor,'ob-')
title('center2cornernan: g center -- b corner')
axis([-1 6 -1 6])