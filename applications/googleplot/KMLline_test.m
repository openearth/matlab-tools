function testresult = KMLline_test()
% KMLline_TEST  unit test for KMLline
%  
% See also: KMLline, line, plot

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl	
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
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
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

disp(['... running test:',mfilename])

%% $Description (Name = KMLline)
% Publishable code that describes the test.

%% $RunCode
% Write test code here
try
    [lat,lon] = meshgrid([51:54],[3:7]);
 
    KMLline(lat ,lon ,'fileName',KML_testdir('KMLline_testh.kml'),'lineColor',jet(3) ,'kmlName','horizontal');%,'text',{'1','2','3','4'});
    KMLline(lat',lon','fileName',KML_testdir('KMLline_testv.kml'),'lineWidth',[1 3 3],'kmlName','vertical'  );%,'text',{'a','b','c','d','e'});

    testresult = true;
catch
    testresult = false;
end

%% $PublishResult
% Publishable code that describes the test.

