function [x_regular,y_regular,theta] = points_along_polyline_at_interval(x,y,interval)
%POINTS_ALONG_POLYLINE_AT_INTERVAL  returns points spaced at a set inverval along a path
%
%   More detailed description goes here.
%
%   Syntax:
%   [x_regular,y_regular,theta_regular] = points_along_polyline_at_interval(x,y,interval)
%   
%
%   Output:
%   x_regular = x coordinate of regular spaced coordinates along path
%   y_regular = y coordinate of regular spaced coordinates along path
%   theta     = angle of path through point in radians
%
%   Example:
%       x = [3.9977 3.9055 4.2281 5.1959 5.9793 6.3479 6.6244 0.6106 0.9332 2.2696 3.2604];
%       y = [2.2953 5.1901 5.5994 5.6579 5.3070 5.0146 7.0322 9.0205 8.4942 8.2310 9.0789];    
%       [x_regular,y_regular,theta] = geometry.points_along_polyline_at_interval(x,y,1)
%       plot(x,y,'r-x','lineWidth',3)
%       hold on
%       plot(x_regular,y_regular,'b-o','lineWidth',2)
%       offset = 0.4;
%       plot([x_regular-offset*sin(theta) x_regular+offset*sin(theta)]',[y_regular+offset*cos(theta) y_regular-offset*cos(theta)]','g');
%       axis equal
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2012 Van Oord
%       Thijs Damsma
%
%       tda@vanoord.com
%
%       Watermanweg 64
%       3067 GG
%       Rotterdam
%       Netherlands
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

% This tool is part of <a href="http://www.OpenEarth.eu">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 28 Sep 2012
% Created with Matlab version: 8.0.0.783 (R2012b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%
% POINTS_ALONG_POLYLINE_AT_INTERVAL 
%
% Note that the points are spaced over the original track. This does not mean
% this result is evenly spaced. eg:
% distance(x_regular,y_regular) is not constant

distance_along_polyline = distance(x,y);

xx = (0:interval:distance_along_polyline(end))';

[x_regular,y_regular,theta] = deal(nan(size(xx)));
for ii = 1:length(xx);
    nn = find(xx(ii)<=distance_along_polyline,1,'first');
    if nn==1
        nn = 2;
        x_regular(ii) = x(1);
        y_regular(ii) = y(1);
    else
        c = (xx(ii) - distance_along_polyline(nn-1)) / (distance_along_polyline(nn) - distance_along_polyline(nn-1));
        x_regular(ii) = c*x(nn) + (1-c)*x(nn-1);
        y_regular(ii) = c*y(nn) + (1-c)*y(nn-1);
    end
    
    dx = (x(nn) - x(nn-1));
    dy = (y(nn) - y(nn-1));
    theta(ii) = atan(dy/dx);
    if dx<0
        theta(ii) = theta(ii)-pi();
    end
end