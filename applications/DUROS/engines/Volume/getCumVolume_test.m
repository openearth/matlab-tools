function testresult = getCumVolume_test()
% GETCUMVOLUME_TEST  Unit test for getCumVolume
%  
% This test definition defines a unit test for getCumVolume
%
%
%   See also getCumVolume 

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
% Created: 29 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Integration;

%% $Description (Name = getCumVolume unit test & IncludeCode = false & EvaluateCode = true)
% getCumVolum only calculates the cumulative volumes between two lines (based on their x-grid.
%
% To test this function we use two lines:

x = [0 2]';
z = [1 1]';
z2 = [0 2]';

figure('Color','w');
hold on
box on
grid on
patch([x; flipud(x)],[z; flipud(z2)],[0.8 0.8 0.8]);
plot(x,z,'Color','g','LineWidth',2);
plot(x,z2,'Color','r','LineWidth',2);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);

%%
% The cumulative volume between those two lines should of course be zero.

%% $RunCode

[volumes, CumVolume] = getCumVolume (x, z, z2);
testresult = volumes==0;

%% $PublishResult
% The following figure prints the result of this test:
figure('Color','w');
hold on
box on
grid on
patch([x; flipud(x)],[z; flipud(z2)],[0.8 0.8 0.8]);
plot(x,z,'Color','g','LineWidth',2);
plot(x,z2,'Color','r','LineWidth',2);
xlim([-0.5 2.5]);
ylim([-0.5 2.5]);
text(min(xlim)+0.5*diff(xlim),min(ylim)+0.1*diff(ylim),['Cumulative volume = ' num2str(CumVolume)],'HorizontalAlignment','center','FontName','Arial','FontSize',14);