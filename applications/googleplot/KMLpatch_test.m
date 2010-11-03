function testresult = KMLpatch_test()
% KMLPATCH_TEST  test for KMLpatch
%  
% See also : googlepLot, patch

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

%% $Description (Name = KMLcontour)
% Publishable code that describes the test.

%% $RunCode
try
    KMLpatch([50   50   50.9 50.9 50  ]'-4,[1.1 2   2   1.1 1.1]'+8,'fileName',KML_testdir('KMLpatch_test1a.kml'),'fillColor',[1 0 0],'polyOutline',false,'lineOutline',true );
    KMLpatch([50.9 50.9 50   50   50.9]'-4,[0   0.9 0.9 0   0  ]'+8,'fileName',KML_testdir('KMLpatch_test2a.kml'),'fillColor',[0 1 0],'polyOutline',false,'lineOutline',false);
    KMLpatch([52   52   51.1 51.1 52  ]'-4,[1.1 2   2   1.1 1.1]'+8,'fileName',KML_testdir('KMLpatch_test1b.kml'),'fillColor',[0 0 1],'polyOutline',true ,'lineOutline',false);
    KMLpatch([51.1 51.1 52   52   51.1]'-4,[0   0.9 0.9 0   0  ]'+8,'fileName',KML_testdir('KMLpatch_test2b.kml'),'fillColor',[1 1 1],'polyOutline',true ,'lineOutline',true );
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.