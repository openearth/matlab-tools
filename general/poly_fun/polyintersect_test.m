function polyintersect_test()
% POLYINTERSECT_TEST  test script for POLYINTERSECT
%  
% Test taken from findCrossingsOfPolygonAndPolygon.
%
%
%   See also polyintersect findcrossingsofpolygonandpolygon

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

MTestCategory.Unit;

x1 = [427668 427801 427926 428208 428489 428637 428725 428740 428703 428548 428333 428008 427719 427697 427527 427549 427845 428045 428356 428503];
z1 = [5.09376e+006 5.09371e+006 5.09368e+006 5.09365e+006 5.09363e+006 5.09365e+006 5.09371e+006 5.09376e+006 5.09392e+006 5.09395e+006 5.09398e+006 5.09396e+006 5.09404e+006 5.09408e+006 5.09431e+006 5.09444e+006 5.09451e+006 5.09452e+006 5.09442e+006 5.09437e+006];
x2 = [427037 427318 427948 428801 429595 429906 429586 428898 428025 427531 427337 427424 427987 428607 429208 429440 429150 428617 428074 427715 427754 428151 428578 428810 428675 428239 427880 427909 428132 428316 428423 428432 428297];
z2 = [5.09383e+006 5.09322e+006 5.09292e+006 5.09274e+006 5.09309e+006 5.09403e+006 5.09473e+006 5.09525e+006 5.09527e+006 5.09485e+006 5.0943e+006 5.09376e+006 5.09333e+006 5.09331e+006 5.09348e+006 5.09412e+006 5.09474e+006 5.09496e+006 5.09477e+006 5.09426e+006 5.09382e+006 5.09358e+006 5.09356e+006 5.09401e+006 5.09444e+006 5.09451e+006 5.09418e+006 5.09388e+006 5.09373e+006 5.09371e+006 5.09382e+006 5.09403e+006 5.09413e+006];

[xr1,yr1]=polyintersect(x1,z1,x2,z2);
assert(length(xr1)==8);
assert(length(yr1)==8);

x1 = [0 0 2 3 3 4 4 7 7];
z1 = [0 1 3 3 4 5 6 6 8];
x2 = [-0.5 6.5 6.5];
z2 = [ 0   7   8  ];

[xr2a,yr2a]=polyintersect(x1,z1,x2,z2);
assert(length(xr2a)==4);
assert(length(yr2a)==4);

%[xr2b,yr2b]=polyintersect(x2,z2,x1,z1,'debug',1)

%[xr2c,yr2c]=findcrossingsofpolygonandpolygon(x1,z1,x2,z2)
%[xr2d,yr2d]=findcrossingsofpolygonandpolygon(x2,z2,x1,z1)


x1 = [1 1   nan 2   3   nan 1   3  ];
z1 = [0 1   nan 2   2   nan 2   4  ];
x2 = [1 1   nan 2.1 3.1 nan 1.1 3.1];
z2 = [0 1.1 nan 2   2   nan 2.1 4.1];

[xr3a,yr3a]=polyintersect(x1,z1,x2,z2);
assert(isempty(xr3a));
assert(isempty(yr3a));