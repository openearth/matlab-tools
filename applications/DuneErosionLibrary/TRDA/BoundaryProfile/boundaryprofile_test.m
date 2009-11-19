function testResult = boundaryprofile_test()
% BOUNDARYPROFILE_TEST  unit test for boundaryprofile
%  
% This function describes a unit test for boundaryprofile.
%
%
%   See also boundaryprofile

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
tr(1) = boundaryprofilenormaltest();
tr(2) = boundaryprofilevolumetrictest();
testResult = all(tr);

end

%% Case 1
function testResult = boundaryprofilenormaltest()
%% $Description(Name = Test with normal boundary profile)

%% $RunCode
[xInitial zInitial] = referenceprofile;
waterLevel = 5;
peakPeriod = 12;
significantWaveHeight = 9;
x0Point = -20;

testResult = false;
try %#ok<TRYNC>
    Result = boundaryprofile(xInitial, zInitial, waterLevel, significantWaveHeight, peakPeriod, x0Point);
    testResult = true;
end

%% $PublishResult
figure;
hold on
grid on
box on
set(gca,'Xdir','reverse');
plot(xInitial,zInitial,'Color','k','DisplayName','Initial Profile');
patch([Result.xActive; flipud(Result.xActive)],...
    [Result.z2Active; flipud(Result.zActive)],...
    'g',...
    'DisplayName','Calculated boundary profile');
h = hline(waterLevel,'b-');
set(h,'DisplayName','Maximum Strom Surge level','HandleVisibility','on');
xlim([-100 300]);
ylim([-2 16]);
legend show

end

%% Case 2
function testResult = boundaryprofilevolumetrictest()
%% $Description (Name = Volumetric boundary test)

%% $RunCode
[xInitial zInitial] = referenceprofile;
waterLevel = 5;
peakPeriod = 12;
significantWaveHeight = 9;
x0Point = 0;

testResult = false;
try %#ok<TRYNC>
    Result = boundaryprofile(xInitial, zInitial, waterLevel, significantWaveHeight, peakPeriod, x0Point);
    testResult = true;
end

%% $PublishResult
figure;
hold on
grid on
box on
set(gca,'Xdir','reverse');
plot(xInitial,zInitial,'Color','k','DisplayName','Initial Profile');
patch([Result.xActive; flipud(Result.xActive)],...
    [Result.z2Active;flipud(Result.zActive)],...
    'g',...
    'DisplayName','Calculated boundary profile');
h = hline(waterLevel,'b-');
set(h,'DisplayName','Maximum Strom Surge level','HandleVisibility','on');
xlim([-100 300]);
ylim([-2 16]);
legend show
end