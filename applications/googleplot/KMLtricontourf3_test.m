function testresult = KMLtricontourf3_test()
% KMLTRICONTOURF3_TEST  unit test for KMLtricontourf3_test
%
% See also: googleplot

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
%try
    
    %test 1
    [x,y] = meshgrid(1:10,21:30);
    z = peaks(10);
    tri = delaunay(x,y);
    tri(60:74,:)=[];
    KMLtricontourf3(tri,x,y,z,'levels',100,'fileName',KML_testdir('KMLtricontourf3 - 1.kml'),...
        'zScaleFun',@(z) (abs(z)+0.3)*10000,'staggered',false);
    
    %test 2
    
    [x,y] = meshgrid(1.1:.5:100.1,201.2:.5:300.2);
    x = (x+sin(y).^3);
    y = (y+sin(x));
    z = repmat(peaks(100),2,2)+2*cos(peaks(200))+3*sin(peaks(200))+3*peaks(200);
    tri = delaunay(x,y);
    tri(any((((x(tri)-50).^2 + (y(tri)-250).^2).^.5)>44,2),:)=[];
    x = x/10+10;y = y/10+10;
    KMLtricontourf3(tri,x,y,z,'levels',40,'fileName',KML_testdir('KMLtricontourf3 - 2.kml'),...
        'zScaleFun',@(z) (abs(z)+0.3)*3000,'staggered',true);
    
    %test3
    [x,y] = meshgrid(1:3,7:9);
    z = ones(3,3);
    z(2,2) = 5;
    z(3,2) = 9;
    tri = delaunay(x,y);
    tri(6,:)=[];
    trisurf(tri,x,y,z);

    KMLtricontourf3(tri,x,y,z,'levels',3,'fileName',KML_testdir('KMLtricontourf3 - 3.kml'),...
        'zScaleFun',@(z) (abs(z)+0.3)*10000,'staggered',true);
    
    testresult = true;
%catch
%    testresult = false;
%end
%% $PublishResult
% Publishable code that describes the test.

