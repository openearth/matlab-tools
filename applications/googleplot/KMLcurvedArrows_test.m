function testresult = KMLcurvedArrows()
% KMLcurvedArrows_TEST  unit test for KMLcurvedArrows
%  
% See also : googleplot, KMLcurvedArrows, KMLquiver_test

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

    scale = 1;
    [lat,lon] = meshgrid(54:.1:57,2:.1:5);
    z = peaks(31);
    z = abs(z);
    
   [u,v] = gradient(z);

    KMLpcolor      (lat,lon,                 z,'fileName',KML_testdir('KMLcurvedArrows_test_streamfunction.kml'),'disp',0);
   [x,y] = convertCoordinates(lon,lat,'CS1.code',4326,'CS2.code',28992);

    KMLcurvedArrows(x,y,-scale.*u,scale.*v,... % transform u,v too ?
                      'time',[],...
              'interp_steps',0,...
                   'kmlName','velocity surface (black)',...
                  'n_arrows',250,...
                  'fileName',KML_testdir('KMLcurvedArrows_test.kml'),...
                        'dt',1200,...
                  'colorMap',@(m) [0 0 0],...
                'colorSteps',1);
    
    testresult = true;
catch
    testresult = false;
end
