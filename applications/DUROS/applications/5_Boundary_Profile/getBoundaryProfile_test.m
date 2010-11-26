function testresult = getBoundaryProfile_test()
% GETBOUNDARYPROFILE_TEST  test defintion routine
%  
% This function describes a test for getBoundaryProfile.
%
%   See also getBoundaryProfile 

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

%% $Description (Name = Boundary profile)
% According to Dutch regulations dunes that are eroded during an extreme storm must have a socalled
% "Grensprofiel". This is a profile shape (or at least the volume that is in that shape) that must
% remain at some place in the transect above the maximum storm surge level after erosion during that
% storm. The boundary profile should match the following requirements:
%
% * minimal height of 2.5 [m above storm surge level]
% * minimal height of :
% $$h_0  = WL + 0.12T_p \sqrt {H_{0s} }$
% , but at least 2.5 [m] above storm surge level.
% * minimal width of 3 meters (at the top)
% * steepness of the inner slope of minimal 1:2
% * minimal steepness of the outerslope (facing seaward) of 1:1
%
% This test checks whether the function does not crash with an input of:
%
% * H0s = 9 [m]
% * WL = 5 [m]
% * Tp = 12 [s]
%

%% $RunCode
WL_t = 5;
Tp_t = 12;
Hsig_t = 9;
x0 = 0;

testresult = false;
try %#ok<TRYNC>
    result = getBoundaryProfile(WL_t, Tp_t, Hsig_t, x0);
    testresult = true;
end

%% $PublishResult (EvaluateCode = true & IncludeCode = false)
% The calculated boundary profile is shown below.
%
% 
disp(['width of the crest = ' num2str(diff(result.xActive(result.z2Active==max(result.z2Active)))) ' [m]']);
disp(['height crest       = ' num2str(max(result.z2Active)-WL_t) ' [m]']);
    
figure('Color','w');
title('BoundaryProfile');
hold on
patch(result.xActive,result.z2Active,[0.7 0.7 0.7],'EdgeColor','k','DisplayName','Boundary Profile');
xlim([-20 5]);
ylim([0 15]);
patch([xlim fliplr(xlim)],[ones(1,2)*WL_t zeros(1,2)],[0.5 0.5 1],'EdgeColor',[0.1 0.1 1],'LineWidth',2,'DisplayName','maximum storm surge level');
legend show
xlabel('Cross-shore distance [m]');
ylabel('heigth [m]');
