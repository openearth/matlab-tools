function testResult = boundaryprofilegeometry_test()
% BOUNDARYPROFILEGEOMETRY_TEST  Unit test of boundaryprofilegrometry
%  
% This unit test examines the working of boundaryprofilegeometry.
%
%
%   See also boundaryprofilegeometry

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

%% $Description (Name = boundaryProfileGeometry unit test)
% The concept of a boundary profile is descibed in the TRDA (add reference). After a storm the Dutch
% authorities would like to have a remaining dune profile that complies to the following rules:
%
% * It must have a minimal height above the maximum storm surge level of h0 (as calculated with the
% following equation).
%
% $$ h_0  = WL + \max \left[ {2.5\quad 0.12T_P \sqrt {H_{0s} } } \right] $$
%
% in which:
% WL = Maximum Storm Surge Level (from HR2006)
% T_p_ = Peak peroiod of the wave spectrum (from HR2006)
% H_0s_ = Expected significant wave height (also from HR2006)
%
% FurtherMore the front of the profile should have a 1:1 slope and the landward side of the profile
% must have a 1:2 slope.
%
% boundaryProfileGeometry should calculate the exact shape of this profile.
%
% To check this we use the following input parameters:
%

significantWaveHeight = 9;
peakPeriod = 8+1/3;
waterLevel = 5;

%% $RunCode
tr(1) = boundaryprofilegeometrywithx0(significantWaveHeight,peakPeriod,waterLevel);
tr(2) = boundaryprofilegeometrynox0(significantWaveHeight,peakPeriod,waterLevel);
testResult = all(tr);
end

%% Testcase 1
function testResult = boundaryprofilegeometrywithx0(significantWaveHeight,peakPeriod,waterLevel)
%% $Description (Name = With x0 input parameter)
% This testcase tests the basic functionality with input parameter x0 = 0.
x0Point = -5;
xExpected = [-12 -6 -3 0]'+x0Point;
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

%% $RunCode
Result = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod, x0Point);
testResult = all(xExpected==Result.xActive) & all(zExpected==Result.z2Active);

%% $PublishResult (EvaluateCode = true & IncludeCode = false)
% The calculated boundary profile is shown below.
%
% 
disp(['width of the crest = ' num2str(diff(Result.xActive(Result.z2Active==max(Result.z2Active)))) ' [m]']);
disp(['height crest       = ' num2str(max(Result.z2Active)-waterLevel) ' [m]']);
    
figure('Color','w');
title('BoundaryProfile');
hold on
plot(xExpected,zExpected,'Color','r','LineWidth',3,'DisplayName','Expected Boundary profile');
patch(Result.xActive,Result.z2Active,[0.7 0.7 0.7],'EdgeColor','k','DisplayName','Boundary Profile');
xlim([-20 5]);
ylim([0 15]);
patch([xlim fliplr(xlim)],[ones(1,2)*waterLevel zeros(1,2)],[0.5 0.5 1],'EdgeColor',[0.1 0.1 1],'LineWidth',2,'DisplayName','maximum storm surge level');
legend show
xlabel('Cross-shore distance [m]');
ylabel('heigth [m]');

end

%% Testcase 2
function testResult = boundaryprofilegeometrynox0(significantWaveHeight,peakPeriod,waterLevel)
%% $Description (Name = Without x0 input parameter)
% This testcase tests the basic functionality without input parameter x0. The function should not
% crash and get the default value of x0 = 0.
xExpected = [-12 -6 -3 0]';
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

%% $RunCode
Result = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod);
testResult = all(xExpected==Result.xActive) & all(zExpected==Result.z2Active);

%% $PublishResult (EvaluateCode = true & IncludeCode = false)
% The calculated boundary profile is shown below.
%
% 
disp(['width of the crest = ' num2str(diff(Result.xActive(Result.z2Active==max(Result.z2Active)))) ' [m]']);
disp(['height crest       = ' num2str(max(Result.z2Active)-waterLevel) ' [m]']);
    
figure('Color','w');
title('BoundaryProfile');
hold on
plot(xExpected,zExpected,'Color','r','LineWidth',3,'DisplayName','Expected Boundary profile');
patch(Result.xActive,Result.z2Active,[0.7 0.7 0.7],'EdgeColor','k','DisplayName','Boundary Profile');
xlim([-20 5]);
ylim([0 15]);
patch([xlim fliplr(xlim)],[ones(1,2)*waterLevel zeros(1,2)],[0.5 0.5 1],'EdgeColor',[0.1 0.1 1],'LineWidth',2,'DisplayName','maximum storm surge level');
legend show
xlabel('Cross-shore distance [m]');
ylabel('heigth [m]');
end