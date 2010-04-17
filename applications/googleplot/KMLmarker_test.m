function testresult = KMLmarker_test()
% KMLMARKER_TEST  One line description goes here
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
% Created: 17 Apr 2010
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
try
    nn = 100;
    
    xRD = 60500+1000*randn(nn,1);
    yRD = 450000-6500+1000*randn(nn,1);
    
    [lon,lat]=convertCoordinates(xRD,yRD,'CS1.code',28992,'CS2.code',4326);
    
    OPT.fileName            =  KML_testdir('marker.kml');
    OPT.kmlName             =  'CPT';
    OPT.openInGE            =  false;
    OPT.markerAlpha         =  1;
    OPT.description         =  'CPT';
    OPT.iconnormalState     =  'http://damsma.net/cpt.png';
    OPT.iconhighlightState  =  'http://damsma.net/cpt.png';
    OPT.scalenormalState    =  0.5;
    OPT.scalehighlightState =  1.0;
    OPT.colornormalState    =  [1 1 1];
    OPT.colorhighlightState =  [1 1 0];
    
    for ii = 1:nn
        OPT.name{ii} = sprintf('ctp %d',ii);
    end
    
    OPT.timeIn = now+1000*rand(nn);
    
    OPT.html = '<img border="0" src="http://damsma.net/cpt.png">';
    KMLmarker(lat,lon,OPT);
    testresult = true;
catch
    testresult = false;
end
%% $PublishResult
% Publishable code that describes the test.

