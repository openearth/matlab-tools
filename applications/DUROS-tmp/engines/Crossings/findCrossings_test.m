function testresult = findCrossings_test()
% FINDCROSSINGS_TEST  unit test for findCrossings
%  
% test defintion for findCrossings unit test
%
%
%   See also findCrossings 

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

%% $Description (Name = findCrossings unit test)
% The testcases for findcrossings contain:
%
% * Test for ordinary crossing between two lines
% * Test for two lines that do not cross
% * Test with two lines including NaN values
% * Test with multiple crossings
% * Test of the synchronize grid option
%
% Of course findCrossings should return correct x and z values, but also the correct profiles and
% up/downcrossing.

%% $RunCode

tr(1) = findCrossingscase1();
tr(2) = findCrossingscase2();
tr(3) = findCrossingscase3();
tr(4) = findCrossingscase4();
tr(5) = findCrossingscase5();
testresult = all(tr);

end

function testresult = findCrossingscase1()
%% $Description (Name = Simple crossing & IncludeCode = true & EvaluateCode = true)
% First of all the routine should return the correct crossing between two lines. In this testcase we
% take two simple lines (one horizontal and one linearly increasing):

x_new = [0 2]';
z1_new = [1 1]';
z2_new = [0 2]';

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 1: simple crossing');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
xlim([0 4]);
ylim([0 2]);
%%
% Of course the expected result of the testcase would be x = 1, z = 0;

%% $RunCode

[xcr zcr xout1 zout1 xout2 zout2 crossdir] = findCrossings(x_new,z1_new,x_new,z2_new);
testresult = roundoff(xcr,8) == 1 &&...
    zcr==1 &&...
    all(ismember(xout1,xout2)) &&...
    crossdir ==2;

%% $PublishResult (IncludeCode = false & EvaluateCode = true)
% The function returned the following information:

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 1: simple crossing');
plot(xout1,zout1,'Marker','o','Color',[0.4 0.4 0.8]);
plot(xout2,zout2,'Marker','o','Color',[0.8 0.4 0.4]);
scatter(xcr,zcr,'Marker','h','MarkerEdgeColor','k','SizeData',120,'MarkerFaceColor','g');
text(xcr+0.1*diff(xlim),zcr,['x = ' num2str(xcr,'%0.0f') char(10) 'z = ' num2str(zcr,'%0.0f')]);
axis image
xlim([0 4]);
ylim([0 2]);
end

function testresult = findCrossingscase2()
%% $Description (Name = No Crossing)
% This testcase consists of a call to addXvaluesExactCrossings with two parallel horizontal lines.

x_new = [0 2]';
z1_new = [1 1]';
z2_new = [2 2]';

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 2: no crossing');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
xlim([0 4]);
ylim([0 2]);

%% $RunCode
[xcr zcr xout1 zout1 xout2 zout2] = findCrossings(x_new,z1_new,x_new,z2_new);
testresult = isempty(xcr) && isempty(zcr);

%% $PublishResult
figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 2: no crossing - result');
plot(xout1,zout1,'Marker','o','Color',[0.4 0.4 0.8]);
plot(xout2,zout2,'Marker','o','Color',[0.8 0.4 0.4]);
if testresult
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),'crossing : No Crossings','HorizontalAlignment','right');
end
axis image
xlim([0 4]);
ylim([0 2]);
end

function testresult = findCrossingscase3()
%% $Description (Name = NaN values)
% Of course the function should not crash when the input contains NaN values:
x_new = (0:2:4)';
z1_new = [1 1 NaN]';
z2_new = [NaN 0 2]';

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 3: NaN values');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
xlim([0 4]);
ylim([0 2]);

%% $RunCode
warning('off','MATLAB:interp1:NaNinY');
[xcr zcr xout1 zout1 xout2 zout2] = findCrossings(x_new,z1_new,x_new,z2_new);
warning('on','MATLAB:interp1:NaNinY');
testresult = isempty(xcr) && isempty(zcr);

%% $PublishResult
figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 3: NaN values - result');
plot(xout1,zout1,'Marker','o','Color',[0.4 0.4 0.8]);
plot(xout2,zout2,'Marker','o','Color',[0.8 0.4 0.4]);
if testresult
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),'crossing : No Crossings','HorizontalAlignment','right');
end
axis image
xlim([0 4]);
ylim([0 2]);
end

function testresult = findCrossingscase4()
%% $Description (Name = Multiple crossings / crossdir)
% Test the function with multiple crossings. This should result in different values of crossdir as
% well:

x_new = (0:0.01:2*pi())';
z1_new = cos(x_new);
z2_new = zeros(size(x_new));

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 4: Multiple crossings');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
axis image

%% $RunCode
[xcr zcr xout1 zout1 xout2 zout2 crossdir] = findCrossings(x_new,z1_new,x_new,z2_new);
testresult = length(xcr)==2 && all(crossdir == [2; -2]);

%% $PublishResult
figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 4: Multiple crossings - result');
plot(xout1,zout1,'Color',[0.4 0.4 0.8]);
plot(xout2,zout2,'Color',[0.8 0.4 0.4]);
scatter(xcr,zcr,'Marker','h','MarkerEdgeColor','k','SizeData',120,'MarkerFaceColor','g');
for i = 1:length(xcr)
    text(xcr(i)+0.02*diff(xlim),zcr(i),['x = ' num2str(xcr(i),'%0.0f') char(10) 'z = ' num2str(zcr(i),'%0.0f') char(10) 'crossdir = ' num2str(crossdir(i))]);
end
axis image

end

function testresult = findCrossingscase5()
%% $Description (Name = synchonize grid)
% findCrossings automatically adds the found crossings to the grids of both input variables. There
% is also a possibility to include all gridpoints of the two lines in the resulting output. This
% testcase tests the output for both switches.

xin1 = (0:0.5:2*pi());
zin1 = cos(xin1);
xin2 = [0 2*pi()];
zin2 = [0 0];

figure('Color','w');
title('testcase 5: synchronize grid');
hold on
plot(xin1,zin1,'Marker','*','Color','k');
plot(xin2,zin2,'Marker','o','Color','r');

%% $RunCode
[x1cr z1cr x1out1 z1out1 x1out2 z1out2] = findCrossings(xin1,zin1,xin2,zin2,'keeporiginalgrid');
[x2cr z2cr x2out1 z2out1 x2out2 z2out2] = findCrossings(xin1,zin1,xin2,zin2,'synchronizegrids');
testresult = length(x1out2) == length(unique([xin2,x1cr])) && ...
    length(x2out2) == length(unique([xin1,xin2,x2cr]));

%% $PublishResult
figure('Color','w','Units','pixels','Position',[100 100 600 300]);
subplot(1,2,1);
title('keeporiginalgrid');
hold on
plot(x1out1,z1out1,'Marker','*','Color','k');
plot(x1out2,z1out2,'Marker','o','Color','r');

subplot(1,2,2);
title('synchronizegrids');
hold on
plot(x2out1,z2out1,'Marker','*','Color','k');
plot(x2out2,z2out2,'Marker','o','Color','r');

end