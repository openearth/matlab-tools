function testResult = DUROS_test()
% DUROS_TEST  temporal tests for duros
%  
% More detailed description of the test goes here.
%
%
%   See also DUROS

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Deltares
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
% Created: 29 Mar 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = DUROS integration tests)
TeamCity.ignore('WIP'); return;

%% $RunCode

testResult = nan;
DuneErosionSettings('default');

%% case 1 Reference profile
xInitial = [-250;-24.375;5.625;55.725;230.625;2780.625];
zInitial = [15;15;3;0;-3;-20];
D50 = 0.000225;
WL_t = 5;
Hsig_t = 9;
Tp_t = 12;

[result, messages] = DUROS(xInitial, zInitial,...
'D50',D50,...
'WL_t',WL_t,...
'Hsig_t',Hsig_t,...
'Tp_t',Tp_t);
plotDuneErosion(result,figure);

%% case 2 Reference profile with a valley in the dune)
xInitial = [-250;-110;-100;-65;-45;-24.375;5.625;55.725;230.625;2780.625];
zInitial = [15;15;2;2;15;15;3;0;-3;-20];
D50 = 0.000225;
WL_t = 5;
Hsig_t = 9;
Tp_t = 12;

[result, messages] = DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t);
plotDuneErosion(result,figure);

%% case 3 Reference profile with a dune breach
xInitial = [-250;-110;-100;-65;-45;-24.375;5.625;55.725;230.625;2780.625];
zInitial = [15;15;2;2;15;15;3;0;-3;-20];
D50 = 0.000225;
WL_t = 5;
Hsig_t = 12;
Tp_t = 16;

% temporarily shut down Bondary profile. An error occurs...
DuneErosionSettings('set','BoundaryProfile',false);

[result, messages] = DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t);
plotDuneErosion(result,figure);

%% case 4 Profile Noord-Holland transect 5475, year 2005
% profile with low dune rows in front of the main dune.
% In total there are 4 valleys (wrt the water level)
% In the DUROS computation, 2 dune rows breach. Because of the positive
% additional volume, this volume crosses a valley in seaward direction.

D50 = 0.0001831;
Hsig_t = 10.3751;
Tp_t = 18.4016;
WL_t = 6.6559;
AdditionalVolume = -0.18567; % positive additional volume
xInitial = (-250:5:1740)';
zInitial = [10.38 10.36 11.74 14.98 15.07 14.91 15.79 14.16 12.38 10.28 7.95 6.04 5.93 5.98 6.42 7.51 7.7 7.66 7.93 8.02 8.25 8.95 8.48 8.48 9.31 10.34 10.73 11.35 13.11 15.84 18.12 17.35 16.59 16.31 15.78 15.14 13.99 14.73 12.73 12.3 12.02 9.86 7.68 6.56 5.64 6.94 6.67 6.73 6.18 5.74 5.52 6.92 6.55 5.9 5.03 6.46 8.36 8.22 7.47 7.32 7.59 7.55 7.68 7.71 9.07 7.81 7.66 7.07 7.23 6.77 6.07 4.92 3.82 3.65 3.2 3.14 3.38 2.91 2.8 2.65 2.5 2.4 2.32 2.28 2.19 2.11 2.06 1.97 1.88 1.8 1.74 1.7 1.62 1.55 1.49 1.44 1.4 1.32 1.26 1.21 1.18 1.1 1.07 1 0.97 0.9 0.84 0.77 0.74 0.68 0.61 0.55 0.47 0.42 0.35 0.34 0.29 0.21 0.14 0.12 0.08 0.06 0.05 0 -0.06 -0.12 -0.19 -0.32 -0.48 -0.67 -0.86 -0.92 -0.97 -0.815 -0.66 -0.645 -0.63 -0.68 -0.73 -0.77 -0.81 -0.92 -1.03 -1.085 -1.14 -1.255 -1.37 -1.63 -1.89 -2.055 -2.22 -2.38 -2.54 -2.65 -2.76 -2.85 -2.94 -3.02 -3.1 -3.165 -3.23 -3.28 -3.33 -3.365 -3.4 -3.425 -3.45 -3.45 -3.45 -3.44 -3.43 -3.415 -3.4 -3.37 -3.34 -3.31 -3.28 -3.25 -3.22 -3.18 -3.14 -3.095 -3.05 -2.93 -2.81 -2.54 -2.27 -2.22 -2.17 -2.225 -2.28 -2.34 -2.4 -2.495 -2.59 -2.665 -2.74 -2.815 -2.89 -2.97 -3.05 -3.12 -3.19 -3.26 -3.33 -3.39 -3.45 -3.495 -3.54 -3.61 -3.68 -3.725 -3.77 -3.835 -3.9 -3.95 -4 -4.05 -4.1 -4.15 -4.2 -4.245 -4.29 -4.345 -4.4 -4.445 -4.49 -4.525 -4.56 -4.6 -4.64 -4.675 -4.71 -4.77 -4.83 -4.85 -4.87 -4.9 -4.93 -4.96 -4.99 -5.005 -5.02 -5.035 -5.05 -5.065 -5.08 -5.09 -5.1 -5.105 -5.11 -5.13 -5.15 -5.145 -5.14 -5.115 -5.09 -5.08 -5.07 -5.06 -5.05 -5.03 -5.01 -4.99 -4.97 -4.955 -4.94 -4.91 -4.88 -4.86 -4.84 -4.835 -4.83 -4.805 -4.78 -4.77 -4.76 -4.73 -4.7 -4.695 -4.69 -4.67 -4.65 -4.645 -4.64 -4.64 -4.64 -4.635 -4.63 -4.63 -4.63 -4.65 -4.67 -4.68 -4.69 -4.705 -4.72 -4.725 -4.73 -4.735 -4.74 -4.75 -4.76 -4.785 -4.81 -4.84 -4.87 -4.89 -4.91 -4.915 -4.92 -4.92 -4.92 -4.955 -4.99 -5.015 -5.04 -5.065 -5.09 -5.085 -5.08 -5.1 -5.12 -5.135 -5.15 -5.17 -5.19 -5.2 -5.21 -5.22 -5.23 -5.24 -5.25 -5.28 -5.31 -5.32 -5.33 -5.345 -5.36 -5.375 -5.39 -5.405 -5.42 -5.43 -5.44 -5.455 -5.47 -5.49 -5.51 -5.54 -5.57 -5.575 -5.58 -5.61 -5.64 -5.65 -5.66 -5.69 -5.72 -5.725 -5.73 -5.76 -5.79 -5.805 -5.82 -5.845 -5.87 -5.905 -5.94 -5.955 -5.97 -5.99 -6.01 -6.035 -6.06 -6.09 -6.12 -6.145 -6.17 -6.19 -6.21 -6.225 -6.24 -6.255 -6.27 -6.305 -6.34 -6.375 -6.41 -6.425 -6.44 -6.465 -6.49 -6.505 -6.52 -6.545 -6.57 -6.575 -6.58]';

DuneErosionSettings('set',...
'AdditionalVolume', [num2str(AdditionalVolume) '*Volume'],...
'BoundaryProfile', false,...
'FallVelocity', {@getFallVelocity 'a' 0.476 'b' 2.18 'c' 3.226 'D50'});

result = DUROS(xInitial, zInitial, D50, WL_t, Hsig_t, Tp_t);
plotDuneErosion(result, figure);

%% case 5 Test settings as input as well
xInitial = [-250;-24.375;5.625;55.725;230.625;2780.625];
zInitial = [15;15;3;0;-3;-20];
D50 = 0.000225;
WL_t = 5;
Hsig_t = 9;
Tp_t = 12;

[result, messages] = DUROS(xInitial, zInitial,...
'Hsig_t',Hsig_t,...
'WL_t',WL_t,...
'D50',D50,...
'Tp_t',Tp_t,...
'BoundaryProfile',false,...
'AdditionalErosion',false);
plotDuneErosion(result,figure);

DuneErosionSettings('default');

%% $PublishResult
% Publishable code that describes the test.