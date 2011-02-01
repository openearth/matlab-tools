function testresult = KMLcontour_test()
% KMLCONTOUR_TEST  unit test for KMLcontour
%  
% See also: googleplot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) $date(yyyy) $Company
%       $author
%
%       $email	
%
%       $address
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
% Created: 02 Sep 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

try
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);

    KMLcontour(lat   ,lon,   z,'fileName',KML_testdir('KMLcontour1.kml'),'writeLabels',true ,'zScaleFun',@(z) (z+1)*2000,'labelInterval',5);
    KMLcontour(lat   ,lon,   z,'fileName',KML_testdir('KMLcontour1clabel.kml'),'writeLabels',true ,'zScaleFun',@(z) (z+1)*2000,'labelInterval',nan);

    KMLcontour(lat+5 ,lon,   z,'fileName',KML_testdir('KMLcontour2.kml'),'writeLabels',false,'colorMap',@(m) gray(m));
    KMLcontour(lat+10,lon,   z,'fileName',KML_testdir('KMLcontour3.kml'),'writeLabels',false,'colorMap',@(m) colormap_cpt('temperature',m),'is3D',false,'cLim',[-10 10],'lineWidth',3);
    
    KMLcontour(lat+10,lon*10,z,'fileName',KML_testdir('KMLcontour4.kml'),'writeLabels',true ,'zScaleFun',@(z) (z.^2)*10000,'cLim',[200 300],'labelDecimals',4,'labelInterval',5);
    KMLcontour(lat+10,lon*10,z,'fileName',KML_testdir('KMLcontour4clabel.kml'),'writeLabels',true ,'zScaleFun',@(z) (z.^2)*10000,'cLim',[200 300],'labelDecimals',4,'labelInterval',nan);
    testresult = true;
catch
    testresult = false;
end
