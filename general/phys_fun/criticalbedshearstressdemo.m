function criticalbedshearstressdemo
%criticalbedshearstressdemo  demo criticalbedshearstress
%
%   Syntax:
%   criticalbedshearstressdemo
%
%   See also criticalbedshearstress

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2010 Alkyon Hydraulic Consultancy & Research
%       grasmeijerb
%
%       bart.grasmeijer@alkyon.nl	
%
%       P.O. Box 248
%       8300 AE Emmeloord
%       The Netherlands
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

% This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and 
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute 
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 11 Oct 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%%

clear all;
close all;
clc;

rhos = 2650;
rhow = 1000;
s = rhos/rhow;
D = 4e-6:10e-6:250e-6;
[ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn, ReGrain] = criticalbedshearstress(D,rhos,rhow);
[ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn02, ReGrain] = criticalbedshearstress(D,rhos,rhow,'gamma',2);
[ThetaCrZanke, ThetaCrBrownlie, ThetaCrVanRijn03, ReGrain] = criticalbedshearstress(D,rhos,rhow,'gamma',1);

rhos = 2650;
rhow = 1000;
g = 9.81;

figure;
semilogx(D.*1e6,ThetaCrVanRijn.* (g .* (rhos - rhow) .* D),'k-','linewidth',1.2);
hold on;
semilogx(D.*1e6,ThetaCrVanRijn02.* (g .* (rhos - rhow) .* D),'b--','linewidth',1.2);
semilogx(D.*1e6,ThetaCrVanRijn03.* (g .* (rhos - rhow) .* D),'r-.','linewidth',1.2);
grid on;
xlim([1 1000]);
ylim([0 0.6]);
xlabel('D (\mum)');
ylabel('\tau_{cr} (N/m^2)');
legend('\gamma = 1.5','\gamma = 2','\gamma = 1');
print('-dpng','-r300','criticalbedshearstressVanRijn')