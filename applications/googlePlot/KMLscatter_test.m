function testresult = KMLscatter_test()
% KMLSCATTER_TEST  test for kmlscatter
%  
% %See also: googlePlot, KMLscatter, scatter, plotc
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
% Created: 14 Sep 2009
% Created with Matlab version: 7.5.0.342 (R2007b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = KMLscatter)
% Publishable code that describes the test.

%% $RunCode
try
    KMLscatter(linspace(53.10,53.75,21),linspace(4.75,8,21),linspace(-1,4,21),...
        'fileName',KML_testdir('KMLscatter_1.kml'),...
        'long_name','mud',...
        'units','%',...
        'description','mud content derived from sediment size distribution curves in <a href="http://www.waddenzee.nl/Sedimentatlas.729.0.html"> Sediment Atlas WaddenZee </a>.',...
        'kmlName','mud content',...
        'cLim',[0 3])
        
    [lat,lon] = meshgrid(56:.02:57,6:.02:7);
    z = peaks(51);
    KMLscatter(lat,lon,z,'fileName',KML_testdir('KMLscatter_2.kml'))
    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.