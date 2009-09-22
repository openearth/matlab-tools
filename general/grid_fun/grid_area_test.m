function testresult = grid_area_test()
% GRID_AREA_TEST  test for grid_area
%  
%
%   See also 

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
% Created: 22 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description (Name = grid_area)

%% $RunCode
Xcorner  = [-3  0  2  3;-1   0 2  3     ;-1 0 2 4;];
Ycorner  = [-1 -1 -2 -2;-0.5 0 1 -2+1e-6; 1 1 2 2;];

[tr(1) Area]  = testcase1(Xcorner,Ycorner);
[tr(2) Area2] = testcase2(Xcorner,Ycorner);
testresult = all(tr);

%% $PublishResult
figure


subplot(2,1,1);
title('Ok for non-convex');
hold on

plot(Xcorner,Ycorner,'-o');
plot(Xcorner',Ycorner',':+');

set(gca,'xtick',[-10:1:10]);
set(gca,'ytick',[-10:1:10]);
grid on

xlims = get(gca,'xlim');
ylims = get(gca,'ylim');

[Xcenter,...
    Ycenter] = corner2center(Xcorner,Ycorner) ;
for i=1:length(Area(:))
    text(Xcenter(i),Ycenter(i),['* A = ',num2str(Area(i))])
end

subplot(2,1,2)
title('wrong for non-convex')
hold on
plot(Xcorner,Ycorner,'-o')
plot(Xcorner',Ycorner',':+')

set(gca,'xtick',[-10:1:10])
set(gca,'ytick',[-10:1:10])
grid on

xlims = get(gca,'xlim');
ylims = get(gca,'ylim');

for i=1:length(Area2(:))
text(Xcenter(i),Ycenter(i),['* A = ',num2str(Area2(i))])
end


end

function [testresult Area] = testcase1(Xcorner,Ycorner)
%% $Description (Name = OK)
%% $RunCode
Area = grid_area(Xcorner,Ycorner);
testresult = nan;
end

function [testresult Area] = testcase2(Xcorner,Ycorner)
%% $Description (Name = Wrong)
%% $RunCode
Area = grid_area(Xcorner,Ycorner,'convex',1);
testresult = nan;
end