function boundaryprofilegeometry_test()
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

TeamCity.publishdescription(@boundaryprofilegeometry_test_description,...
    'EvaluateCode',true,...
    'IncludeCode',false);

significantWaveHeight = 9;
peakPeriod = 8+1/3;
waterLevel = 5;

%% Testcase 1
% With x0 input parameter
% This testcase tests the basic functionality with input parameter x0 = 0.

x0Point = -5;
xExpected = [-12 -6 -3 0]'+x0Point;
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

Result1 = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod, x0Point);
assert(all(xExpected==Result1.xActive) & all(zExpected==Result1.z2Active),'X and Z values were not as expected');

%% Testcase 2
% Without x0 input parameter
% This testcase tests the basic functionality without input parameter x0. The function should not
% crash and get the default value of x0 = 0.
xExpected = [-12 -6 -3 0]';
zExpected = [waterLevel waterLevel+3 waterLevel+3 waterLevel]'; 

Result2 = boundaryprofilegeometry(waterLevel, significantWaveHeight, peakPeriod);
assert(all(xExpected==Result2.xActive) & all(zExpected==Result2.z2Active),'X and Z values are not as expected');

%% Publish
TeamCity.publishresult(@boundaryprofilegeometry_test_result,...
    'EvaluateCode',true,...
    'IncludeCode',false);
end

function boundaryprofilegeometry_test_description()
%% boundaryProfileGeometry unit test
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
end

function boundaryprofilegeometry_test_result()
%% With x0 input parameter
% The calculated boundary profile is shown below.
% 
disp(['width of the crest = ' num2str(diff(Result1.xActive(Result1.z2Active==max(Result1.z2Active)))) ' [m]']);
disp(['height crest       = ' num2str(max(Result1.z2Active)-waterLevel) ' [m]']);
    
figure('Color','w');
title('BoundaryProfile');
hold on
plot(xExpected,zExpected,'Color','r','LineWidth',3,'DisplayName','Expected Boundary profile');
patch(Result1.xActive,Result1.z2Active,[0.7 0.7 0.7],'EdgeColor','k','DisplayName','Boundary Profile');
xlim([-20 5]);
ylim([0 15]);
patch([xlim fliplr(xlim)],[ones(1,2)*waterLevel zeros(1,2)],[0.5 0.5 1],'EdgeColor',[0.1 0.1 1],'LineWidth',2,'DisplayName','maximum storm surge level');
legend show
xlabel('Cross-shore distance [m]');
ylabel('heigth [m]');

%% Without x0 input parameter
% The calculated boundary profile is shown below.
%
% 
disp(['width of the crest = ' num2str(diff(Result2.xActive(Result2.z2Active==max(Result2.z2Active)))) ' [m]']);
disp(['height crest       = ' num2str(max(Result2.z2Active)-waterLevel) ' [m]']);
    
figure('Color','w');
title('BoundaryProfile');
hold on
plot(xExpected,zExpected,'Color','r','LineWidth',3,'DisplayName','Expected Boundary profile');
patch(Result2.xActive,Result2.z2Active,[0.7 0.7 0.7],'EdgeColor','k','DisplayName','Boundary Profile');
xlim([-20 5]);
ylim([0 15]);
patch([xlim fliplr(xlim)],[ones(1,2)*waterLevel zeros(1,2)],[0.5 0.5 1],'EdgeColor',[0.1 0.1 1],'LineWidth',2,'DisplayName','maximum storm surge level');
legend show
xlabel('Cross-shore distance [m]');
ylabel('heigth [m]');
end