function testresult = KMLquiver_test()
% KMLQUIVER3_TEST  unit test for KMLquiver3
%  
% See also : googleplot, quiver3, KMLquiver_test, KMLcurvedArrows_test

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

%% case 1

    scale = 5e3;
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);
    
   [u,v] = gradient(z);

    KMLquiver3(lat,lon,1e4*z,-scale.*v,scale.*u,'fileName',KML_testdir('KMLquiver3_test_arrows.kml'));
    KMLsurf   (lat,lon,1e4*z,                 z,'fileName',KML_testdir('KMLquiver3_test_streamfunction.kml'),'disp',0);
    
%% case 2: time does not get through yet

   dt = 30; % a litle slow so it looks clocklike
   t  = 0:dt:360;

   KMLquiver3(repmat(52,size(t)),...
              repmat( 4,size(t)),...
              10*t,...
              sind(t).*10000,... % v
              cosd(t).*10000,... % u
            'fileName',KML_testdir('KMLquiver3_test_unit_circle.kml'),...
             'kmlName','unit_circle',...
          'arrowStyle', 'blackTip',...
            'openInGE',0,...
              'timeIn',+ t,...
             'timeOut',+ t + dt);
    
    testresult = true;
catch
    testresult = false;
end
