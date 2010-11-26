function testresult = getParabolicProfile_test()
% GETPARABOLICPROFILE_TEST  test defintion routine
%  
% This function contains a testdefinition for getParabolicProfile
%
%   See also getParabolicProfile 

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
% Created: 28 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

%% getParabolic profile returns the parabolic profile as described in the dutch safety assessment
% rules for dune safety during extreme storm surges. According to these rules a dune erodes and
% forms a parabolic profile according to:
%
% $$\left( {{{7,6} \over {H_{0s} }}} \right)y = 0,4714\left[ {\left( {{{7,6} \over {H_{0s} }}} \right)^{1,28} \left( {{{12} \over {T_p }}} \right)^{0,45} \left( {{w \over {0,0268}}} \right)^{0,56} x + 18} \right]^{0,5}  - 2,0$$
% 
% The profile extends between the maximum stom surge level and:
%
% $$x_{\max }  = 250\left( {{{H_{0s} } \over {7,6}}} \right)^{1,28} \left( {{{0,0268} \over w}} \right)^{0,56}$$
%
% The getParabolicProfile function works in two ways. To just obtain the maximum x location
% (relative to the origin of the parabolic profile) one has to specify the following input:
%
% * H0s
% * Tp
% * w
% * x0 ( = 0)
%
% The user can also retrieve the complete profile. Therefor he has to specify the x-grid as well.
% This test passes whenever the function does not crash and returns an xmax = 250 [m] when default 
% values are entered (Hs = 7.6, Tp = 12, w = 0.268).

testresult = parabprofilecase1;
[tr x z] = parabprofilecase2;

% The following figure illustrates the returned parabolic profile.

disp(['length x = ' num2str(length(x))]);
disp(['length z = ' num2str(length(z))]);

figure('Color','w');
hold on
plot(x,z,'Color','k','LineWidth',2,'DisplayName','Returned parabolic profile','Marker','o');
text(max(x),min(z),{['xmax = ' num2str(max(x))],['zmin = ' num2str(min(z))]});
xlim([0 450]);
ylim([-16 2]);
plot(xlim,zeros(1,2),'Color','b','LineWidth',2,'DisplayName','maximum storm surge level');
ylabel('height [m]');
xlabel('Cross-shore distance [m]');
legend('show','Location','East');
end

function testresult = parabprofilecase1()
%% $Description (Name = xmax)
% This testcase check whether getParabolicProfile returns the correct xmax.
%
% Input parameters:
%
% * Hs = 7.6 [m]
% * Tp = 12 [s]
% * w = 0.0268 [m/s]
% * x = 0
%
% This should result in xmax = 250 [m]

%% $RunCode
xmax = getParabolicProfile(0, 7.6, 12, 0.0268, 0, []);

testresult = xmax == 250;

%% $PublishResult
% The returned xmax:
disp(['xmax = ' num2str(xmax) ' [m]']);
end

function [testresult x z] = parabprofilecase2()
%% $Description (Name = profile)
% This testcase checks the functionality of getParabolicProfile to calculate z values with the
% following input parameters:
%
% * Hs = 7.6 [m]
% * Tp = 12 [s]
% * w = 0.0268 [m/s]
% * x = [...   ...]
%
% The function checks whether the returned array "z" has the same size as x. Qualitatively the
% result can be inspected at the publication part of this testcase.

%% $RunCode
x = [0 16.254 32.5079 48.7619 65.0158 81.2698 97.5237 113.778 130.032 146.286 162.54 178.793 195.047 211.301 227.555 243.809 260.063 276.317 292.571 308.825 325.079]';
[xmax, z] = getParabolicProfile(0, 7.6, 12, 0.268, 0, x);
testresult = length(z)==length(x);

%% $PublishResult
% The function returned the following:

disp(['length x = ' num2str(length(x))]);
disp(['length z = ' num2str(length(z))]);

figure('Color','w');
hold on
plot(x,z,'Color','k','LineWidth',2,'DisplayName','Returned parabolic profile');
text(max(x),min(z),{['xmax = ' num2str(max(x))],['zmin = ' num2str(min(z))]});
xlim([0 450]);
ylim([-16 2]);
plot(xlim,zeros(1,2),'Color','b','LineWidth',2,'DisplayName','maximum storm surge level');
ylabel('height [m]');
xlabel('Cross-shore distance [m]');
legend('show','Location','East');

end