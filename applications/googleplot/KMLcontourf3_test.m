function KMLcontourf3_test()
% KMLCONTOURF3_TEST  testcase for KMLcontourf3
%
% Should give about the same results as KMLtricontourf3_test
%
%
%   See also: KMLtricontourf3_test

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
% Created: 16 Mar 2010
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

test1;
test2;
test3;
test4;
end

function test1()
[x,y] = meshgrid(11:20,21:30);
z = peaks(10);
x = x+sin(y)/10;
nn = 25;
KMLcontourf3(x,y,z,'levels',nn,'fileName',KML_testdir('KMLcontourf3 - 1.kmz'),...
    'zScaleFun',@(z) (z+10)*1400,'staggered',false,'debug',0,...
    'colorbar',true,'colorMap', @(m) colormap_cpt('bathymetry_vaklodingen',m),'CBcolorbarlocation',{'NNW','WNW'})
assert(exist(KML_testdir('KMLcontourf3 - 1.kmz'),'file')==2,'File should be created.');
end

function test2()
[x,y] = meshgrid(1:10,21:30);
z = peaks(10);
x = x+sin(y)/10;
y = y+sin(x)/10;
nn=7;
KMLcontourf3(x,y,z,'levels',nn,'fileName',KML_testdir('KMLcontourf3 - 2.kmz'),...
    'zScaleFun',@(z) (z+20)*4000,'staggered',true,'debug',false,'colorbar',true,'colorMap', @(m) bone(m))
end

function test3()
[x,y] = meshgrid(1:100,201:300);
z = repmat(peaks(25),4,4)+3*peaks(100)+2*repmat(peaks(50),2,2);
remove = [1:15 85:100];
x(remove,:)=[];
y(remove,:)=[];
z(remove,:)=[];
x = x+sin(y)/10;
nn=30;

% tri([500:510],:) = [];
% tri(rand(length(tri),1)>0.999,:) = [];

% trisurf(tri,y,x,z)

KMLcontourf3(x/30,y/30,z,'levels',nn,'fileName',KML_testdir('KMLcontourf3 - 3.kmz'),...
    'zScaleFun',@(z) (z+20)*400,'staggered',false,'colorbar',false,'debug',false)
end

function test4()
url = 'http://opendap.deltares.nl:8080/opendap/hyrax/rijkswaterstaat/vaklodingen/vaklodingenKB136_0908.nc';
x = nc_varget(url,'x');
y = nc_varget(url,'y');
[X,Y] = meshgrid(x,y);
Z = nc_varget(url,'z',[0 0 0],[1 -1 -1]);


nn = 1:1:325;
mm = 300:1:350;
[lon,lat] = convertCoordinates(X(nn,mm),Y(nn,mm),'CS1.code',28992,'CS2.code',4326);
z = Z(nn,mm);
KMLcontourf3(lat,lon,z,'levels',50,'fileName',KML_testdir('KMLcontourf3 - 4a.kmz'),...
    'zScaleFun',@(z) (z+10)*4,'staggered',0,'debug',0,'colorbar',true)

levels=[-11 -9:0.5:-4 -3.5:0.25:3.5 4:.5:26];

nn = 1:1:325;
mm = 250:1:275;
[lon,lat] = convertCoordinates(X(nn,mm),Y(nn,mm),'CS1.code',28992,'CS2.code',4326);
z = Z(nn,mm);
KMLcontourf3(lat,lon,z,'levels',levels,'fileName',KML_testdir('KMLcontourf3 - 4b.kmz'),...
    'zScaleFun',@(z) (z+10)*4,'staggered',1,'debug',0,'colorbar',true,...
    'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),'colorSteps',250,...
    'cLim',[-50 25],'CBcolorbarlocation','N')

nn = 1:1:325;
mm = 275:1:300;
[lon,lat] = convertCoordinates(X(nn,mm),Y(nn,mm),'CS1.code',28992,'CS2.code',4326);
z = Z(nn,mm);
KMLcontourf3(lat,lon,z,'levels',levels,'fileName',KML_testdir('KMLcontourf3 - 4c.kmz'),...
    'zScaleFun',@(z) (z+10)*4,'staggered',0,'debug',0,'colorbar',false,...
    'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),'colorSteps',250,...
    'cLim',[-50 25])





nn = 1:325;
mm = 200:250;
[lon,lat] = convertCoordinates(X(nn,mm),Y(nn,mm),'CS1.code',28992,'CS2.code',4326);
z = Z(nn,mm);
KMLcontourf(lat,lon,z,'levels',levels,'fileName',KML_testdir('KMLcontourf - 4.kmz'),...
    'staggered',false,'debug',0,'colorbar',true,...
    'colorMap',@(m)colormap_cpt('bathymetry_vaklodingen',m),'colorSteps',250,'cLim',[-50 25])
end
