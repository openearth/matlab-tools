function poly_simplify_test
% POLY_SIMPLIFY_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Van Oord Dredging and Marine Contractors BV
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

% This tools is part of OpenEarthTools.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 03 Nov 2010
% Created with Matlab version: 7.11.0.584 (R2010b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

%% Original code of poly_simplify_test.m
x1 = [0.2518    0.2904    0.6171    0.2653    0.8244    0.9827    0.7302    0.3439    0.5841    0.1078];
y1 = [0.9063    0.8797    0.8178    0.2607    0.5944    0.0225    0.4253    0.3127    0.1615    0.1788];

n = length(x1);
t  = 1:n;
ts = linspace(1,n,1e3);
x = spline(t,x1,ts)';
y = spline(t,y1,ts)';

tolerance = 0.05;

% make maximum error polygon
theta = poly_bisect(x,y);

max_error_polygon.x = [x-tolerance*sin(theta); flipud(x)+tolerance*sin(flipud(theta)); x(1)-tolerance*sin(theta(1));];
max_error_polygon.y = [y+tolerance*cos(theta); flipud(y)-tolerance*cos(flipud(theta)); y(1)+tolerance*cos(theta(1));];

method = {'slow';'fast'};
for ii=1:length(method)
    [x1 y1] = poly_simplify(x,y,tolerance,'method',method{ii});
    
    % interpolate points to finer grid
    x2 = interp1(1:length(x1),x1,1:.05:length(x1),'linear');
    y2 = interp1(1:length(y1),y1,1:.05:length(y1),'linear');
    
    % all these points must be in the polygon
    in = inpolygon(x2,y2,max_error_polygon.x,max_error_polygon.y);
    
    % % plot results
    % plot(x2,y2,'.',...
    %     x2(~in),y2(~in),'ro',...
    %     x,y,'k',...
    %     max_error_polygon.x,max_error_polygon.y)
    % daspect([1 1 1]);

    assert(all(in));
end