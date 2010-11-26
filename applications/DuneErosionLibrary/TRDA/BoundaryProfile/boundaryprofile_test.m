function boundaryprofile_test()
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

MTestCategory.Integration;

%% Case 1
% Test with normal boundary profile
[xInitial zInitial] = referenceprofile;
waterLevel = 5;
peakPeriod = 12;
significantWaveHeight = 9;
x0Point = -20;

Result1 = boundaryprofile(xInitial, zInitial, waterLevel, significantWaveHeight, peakPeriod, x0Point);

%% Case 2
% Volumetric boundary test
[xInitial zInitial] = referenceprofile;
waterLevel = 5;
peakPeriod = 12;
significantWaveHeight = 9;
x0Point = 0;

Result2 = boundaryprofile(xInitial, zInitial, waterLevel, significantWaveHeight, peakPeriod, x0Point);

%% Plot figures
figure;
hold on
grid on
box on
set(gca,'Xdir','reverse');
plot(xInitial,zInitial,'Color','k','DisplayName','Initial Profile');
patch([Result1.xActive; flipud(Result1.xActive)],...
    [Result1.z2Active; flipud(Result1.zActive)],...
    'g',...
    'DisplayName','Calculated boundary profile');
h = hline(waterLevel,'b-');
set(h,'DisplayName','Maximum Strom Surge level','HandleVisibility','on');
xlim([-100 300]);
ylim([-2 16]);
legend show

figure;
hold on
grid on
box on
set(gca,'Xdir','reverse');
plot(xInitial,zInitial,'Color','k','DisplayName','Initial Profile');
patch([Result2.xActive; flipud(Result2.xActive)],...
    [Result2.z2Active;flipud(Result2.zActive)],...
    'g',...
    'DisplayName','Calculated boundary profile');
h = hline(waterLevel,'b-');
set(h,'DisplayName','Maximum Strom Surge level','HandleVisibility','on');
xlim([-100 300]);
ylim([-2 16]);
legend show
end