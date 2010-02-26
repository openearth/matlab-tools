function testresult = KMLtricontourf_test()
% KMLTRICONTOURF_TEST  One line description goes here
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
% Created: 24 Feb 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
% try

   
[x,y] = meshgrid(-74:75,-74:75);
    z = repmat(peaks(50),3,3)+3*cos(peaks(150))+6*sin(peaks(150))+peaks(150)-(abs(x)+abs(y))/3;
    [x,y] = meshgrid(1:150,201:350);
       x(1:25,:) = [];
    y(1:25,:) = [];
    z(1:25,:) = [];
% %     
    x = x(:)/10;
    y = y(:)/10;
    z = z(:)+40;
%   [x,y] = meshgrid(1:10,21:30);  
%   z = peaks(10);
% 
% x([1:3 9 10],:) = [];
% y([1:3 9 10],:) = [];
% z([1:3 9 10],:) = [];
 tri = delaunay(x,y);

tri(10500:14800,:) = [];

KMLtricontourf(tri,x,y,z,'levels',100,'fileName',KML_testdir('KMLtricontourf.kml'),'zScaleFun',@(z)(z)*5000,'staggered',false)
    
%     KMLtricontourf(tri,x,y,z,'levels',10,'fileName',KML_testdir('KMLtricontourf2.kml'),'zScaleFun',@(z)(z+7)*1000,'staggered',false)
%    KMLtricontour3(tri,x,y,z,'levels',10,'fileName',KML_testdir('KMLtricontour3.kml'),'zScaleFun',@(z)(z+7)*10000)
%     testresult = true;
% catch
%     testresult = false;
% end
%% $PublishResult
% Publishable code that describes the test.

