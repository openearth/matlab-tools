function testresult = valleypoints_test()
% VALLEYPOINTS_TEST  Unit test for valleypoints
%  
% This function describes a unit test for the function valleypoints.
%
%
%   See also valleypoints

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
% Created: 18 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = valleypoints unit test)
% Unit test for valleypoints.

%% $RunCode
tr(1) = valleypointsBasic;
tr(2) = valleypointsRestricted;
tr(3) = valleypointsAtWaterline;
testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

function testresult = valleypointsBasic()
%% $Description(Name = basic test)
%% $RunCode
x = [-100 -25 -20 -15 -10 -5 0 100]';
z = [10 10 -10 10 -10 10 5 5]';
WL = 5;
xexpect = [-13.75, -6.25; -23.75, -16.25];
xresult = valleypoints(x,z,WL);

testresult = all(size(xexpect)==size(xresult));
if testresult
    testresult = all(all(roundoff(xresult-xexpect,4)==0));
end
end

function testresult = valleypointsRestricted()
%% $Description(Name = test with boundaries)
%% $RunCode
x = [-100 -25 -20 -15 -10 -5 0 100]';
z = [10 10 -10 10 -10 10 5 5]';
WL = 5;
SWB = 100;
LWB = -15;

xexpect = [-13.75, -6.25];
xresult = valleypoints(x,z,WL,...
    'SeawardBoundary',SWB,...
    'LandwardBoundary',LWB);

testresult = all(size(xexpect)==size(xresult));
if testresult
    testresult = all(all(roundoff(xresult-xexpect,4)==0));
end
end

function testresult = valleypointsAtWaterline()
%% $Description(Name = test with part of profile exactly at waterline)
%% $RunCode
x = [-100 -25 -20 -15 -12 -10 -5 0 100]';
z = [10 10 -10 5 5 -10 10 5 5]';
WL = 5;

xexpect = [-23.75, -6.25];
xresult = valleypoints(x,z,WL);

testresult = all(size(xexpect)==size(xresult));
if testresult
    testresult = all(all(roundoff(xresult-xexpect,4)==0));
end
end