function testresult = boundaryprofilevolumetric_test()
% BOUNDARYPROFILEVOLUMETRIC_TEST  Unit test of boundaryProfileVolumetric
%  
% This function defines a test for boundaryprofilevolumetric.
%
%
%   See also boundaryprofilevolumetric

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

%% $Description (Name = boundaryProfileVolumetric unit test)
% According to the Dutch Dune Safety Assessment rules A dune must have a remaining profile after a
% storm to be safe against flooding. This profile is described in detail in the TRDA (add
% reference). If the profile cannot be fit into the remaining dune, it is also allowed to have an
% alternative boundary profile with the same sediment volume above the maximum storm surge level.
% boundaryProfileVolumetric calculates this volumetric boundary profile.

%% $RunCode
tr(1) = boundaryprofilevolumetrichydraulicinput;
tr(2) = boundaryprofilevolumetricvolumeinput;
tr(3) = boundaryprofilevolumetricexceptions;
testresult = all(tr);

%% $PublishResult
% Publishable code that describes the test.

end

%% Case 1
function testResult = boundaryprofilevolumetrichydraulicinput()
%% $Description (Name = Hydraulic input)

xProfile = [-100 -5 0 100]';
zProfile = [10 10 5 5]';
x0Point = 0;
significantWaveHeight = 9;
peakPeriod = 8+1/3;
waterLevel = 5;


%% $RunCode
Result = boundaryprofilevolumetric(xProfile,zProfile,waterLevel,x0Point,...
    'Hs',significantWaveHeight,...
    'Tp',peakPeriod);
testResult = Result.info.x0==-7;

%% $PublishResult
plotduneerosion(Result,figure);
end

%% Case 2
function testResult = boundaryprofilevolumetricvolumeinput()
%% $Description (Name = Volumetric input)

xProfile = [-100 -5 0 100]';
zProfile = [10 10 5 5]';
waterLevel = 5;
x0Point = 0;
targetVolume = -100;

%% $RunCode
Result = boundaryprofilevolumetric(xProfile,zProfile,waterLevel,x0Point,...
    'TargetVolume',targetVolume);
testResult = Result.info.x0 == -22.5;

%% $PublishResult
plotduneerosion(Result,figure);
end

%% Case 3
function testResult = boundaryprofilevolumetricexceptions()
%% $Description (Name = exceotions in input)

xProfile = [-100 -25 -20 -15 -10 -5 0 100]';
zProfile = [10 10 -5 10 -5 10 5 5]';
waterLevel = 5;
x0Point = 0;
targetVolume = -100;

%% $RunCode
Result = boundaryprofilevolumetric(xProfile,zProfile,waterLevel,x0Point,...
    'TargetVolume',targetVolume);
testResult = roundoff(Result.Volumes.Volume,1) == -100;

%% $PublishResult
plotduneerosion(Result,figure);
end