function testresult = KMLcontourf_test()
% KMLCONTOURF_TEST  unit test for KMLcontourf
%
% See also: googleplot, KMLtricontourf_test

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

disp(['... running test:',mfilename])

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
%try
    
    %test 1
    [x,y] = meshgrid(0.5:0.5:100,200.5:0.5:400);

    z = [peaks(200); peaks(200)]+9;  
%     z(3:4,3:4) = nan; % test a hole 
    KMLcontourf(x/10,y/10,z*1000,'levels',100,'fileName',KML_testdir('KMLcontourf - 1.kml'),...
        'colorbartitle','KMLcontourf - 1','is3D',false,'staggered',true,'extrude',true);
    
%     %test 2
%     [x,y] = meshgrid(1.1:.5:100.1,201.2:.5:300.2);
%     x(60:80,60:80) = nan; % test a hole 
%     y(60:80,60:80) = nan;
%     x = (x+sin(y).^3);
%     y = (y+sin(x));
%     z = repmat(peaks(100),2,2)+2*cos(peaks(200))+3*sin(peaks(200))+3*peaks(200);
%     x = x/10+10;y = y/10+10;
%     KMLcontourf(x,y,z,'levels',40,'fileName',KML_testdir('KMLcontourf - 2.kml'),'colorbartitle','KMLcontourf - 2');
%     testresult = true;
%catch
%    testresult = false;
%end
%% $PublishResult
% Publishable code that describes the test.

