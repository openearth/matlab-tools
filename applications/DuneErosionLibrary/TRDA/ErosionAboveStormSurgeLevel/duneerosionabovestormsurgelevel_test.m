function duneerosionabovestormsurgelevel_test()
% DUNEEROSIONABOVESTORMSURGELEVEL_TEST  Unit test for duneerosionabovestormsurgelevel
%  
% This function describes a unit test for duneerosionabovestormsurgelevel.
%
%
%   See also duneerosionabovestormsurgelevel

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
% Created: 19 Nov 2009
% Created with Matlab version: 7.9.0.529 (R2009b)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% basic test
% This testcase describes a basic test of the principle of the function
% duneerosionabovestormsurgelevel.

xPreStorm = [-100 100 110 300];
zPreStorm = [5 5 0 0];
xPostStorm = [-100 0 10 300];
zPostStorm = zPreStorm;
waterLevel = 0;

figure;
hold on
grid on
plot(xPreStorm,zPreStorm,'Color','k','LineWidth',3,'DisplayName','Pre storm Profile');
plot(xPostStorm,zPostStorm,'Color','r','LineWidth',3,'DisplayName','Post storm Profile (shifted 100 meter)');
plot(xlim,ones(1,2)*waterLevel,'Color','b','DisplayName','maximum SSL');
ylim([-1 7]);
leg = legend('show');
set(leg,'Location','NorthWest');
xlabel('Cross-shore location [m]');
ylabel('Elevation [m]');

Result = duneerosionabovestormsurgelevel(...
    xPreStorm,...
    zPreStorm,...
    xPostStorm,...
    zPostStorm,...
    waterLevel);

assert(Result.VTVinfo.AVolume == -500,['Calculated AVolume should be -500, but was: ' num2str(Result.VTVinfo.AVolume)]);