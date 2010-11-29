function testresult = KMLtricontourf_test()
% KMLTRICONTOURF_TEST  unit test for KMLtricontourf
%
% See also: googleplot, KMLcontourf_test

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

MTestCategory.DataAccess;
if TeamCity.running
    TeamCity.ignore('This test takes very long');
    return;
end

disp(['... running test:',mfilename])

%test 1
[x,y] = meshgrid(1:10,21:30);
z = peaks(10);
tri = delaunay(x,y);
tri(60:74,:)=[];
KMLtricontourf(tri,x,y-10,z,'levels',100,'fileName',KML_testdir('KMLtricontourf - 1.kml'),'colorbartitle','KMLtricontourf - 1');
%test 2

[x,y] = meshgrid(1.1:.5:100.1,201.2:.5:300.2);
x = (x+sin(y).^3);
y = (y+sin(x));
z = repmat(peaks(100),2,2)+2*cos(peaks(200))+3*sin(peaks(200))+3*peaks(200);
tri = delaunay(x,y);
tri(any((((x(tri)-50).^2 + (y(tri)-250).^2).^.5)>44,2),:)=[];
x = x/10+10;y = y/10+10;
KMLtricontourf(tri,x,y-10,z,'levels',40,'fileName',KML_testdir('KMLtricontourf - 2.kml'),'colorbartitle','KMLtricontourf - 2');
testresult = true;

