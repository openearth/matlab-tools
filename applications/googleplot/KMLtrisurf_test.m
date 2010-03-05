function testresult = KMLtrisurf_test()
% KMLTRISURF_TEST  One line description goes here
%
% More detailed description of the test goes here.
%
%
%   See also

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 <Deltares>
%       Thijs Damsma
%
%       <Thijs.Damsma@Deltares.nl>
%
%       Deltares
%       P.O. Box 177
%       2600 MH Delft
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

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 07 Sep 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

%% $Description (Name = KMLtrisurf)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
%try

% 1a

    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31); z = abs(z);  z(z<1) = nan;
    tolerance = .5;
  
    tri1 = delaunay_simplified(lat,lon,z,tolerance);
    KMLtrisurf(tri1,lat-3,lon-3,z,'fileName',KML_testdir('KMLtrisurf_1a.kml'),'zScaleFun',@(z) (z+1).*2000,'reversePoly',true,...
    'colorbartitle',mktex('KMLtrisurf_test 1 delaunay_simplified'));

% 1b

    tri2 = delaunay(lat,lon);
    KMLtrisurf(tri2,lat-3,lon-6,z,'fileName',KML_testdir('KMLtrisurf_1b.kml'),'zScaleFun',@(z) (z+1).*2000,'reversePoly',true,...
    'colorbartitle',mktex('KMLtrisurf_test 1 delaunay'));

    % data from netCDF
    url = vaklodingen_url; url = url{127};
    x = nc_varget(url,'x');
    y = nc_varget(url,'y');
    z = nc_varget(url,'z',[0,0,0],[1,-1,-1]);
    [x,y] = meshgrid(x,y);

% 2

    disp(['elements: ' num2str(sum(~isnan(z(:))))]);
    tolerance = 2;
    tri = delaunay_simplified(x,y,z,tolerance,'maxSize',10000);
    [lon,lat] = convertCoordinates(x,y,'CS1.code',28992,'CS2.name','WGS 84','CS2.type','geo');
    % plot in Google Earth
    KMLtrisurf(tri,lat,lon,z,'fileName',KML_testdir('KMLtrisurf_2.kml'),'zScaleFun',@(z) abs(z).*10,...
    'colorbartitle',mktex('KMLtrisurf_test 2 delaunay_simplified'));

% 3

    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31); z = abs(z); tolerance = 0.3;
    tri = delaunay_simplified(lat,lon,z,tolerance);
    for ii = 1:6;
        KMLtrisurf(tri,lat+12,lon,z,'fileName',KML_testdir(['KMLtrisurf_3_' num2str(ii) '.kml']),'zScaleFun',@(z) (z+5)*(cos(ii))*500,'reversePoly',true,'timeIn',ii,'timeOut',ii+1,...
       'colorbartitle',mktex(['KMLtrisurf_test 1:6 movie']));
    end
    testresult = true;
%catch
%    testresult = false;
%end

%% $PublishResult
% Publishable code that describes the test.

