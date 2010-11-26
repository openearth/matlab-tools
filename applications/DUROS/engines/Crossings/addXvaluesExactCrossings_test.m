function testresult = addXvaluesExactCrossings_test()
% ADDXVALUESEXACTCROSSINGS_TEST  test defintion for addXvaluesExactCrossings
%  
% This function describes tests to check the basic working of addXValuesExactCrossings.
%
%
%   See also addXvaluesExactCrossings 

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

%% $Description (Name = addXvaluesExactCrossings test)
% addXvaluesExactCrossings calculates the exact x-values of crossings between two lines. The basic
% functionality is tested with four cases. See case descriptions for more information.
MTestCategory.Unit;
%% $RunCode
tr(1) = crosscase1;
tr(2) = crosscase2;
tr(3) = crosscase3;
tr(4) = crosscase4;

testresult = all(tr);

%% $PublishResult

end

function testresult = crosscase1()
%% $Description (Name = simple crossing & EvaluateCode = true & IncludeCode = true)
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
% Of course the expected result of the testcase would be x = 1;

%% $RunCode

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = roundoff(x2add,8) == 1;

%% $PublishResult (IncludeCode = false & EvaluateCode = true)
% The following figure shows the result of the testcase:

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 1: simple crossing - result');
xlim([0 4]);
ylim([0 2]);
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),['crossing : x=' num2str(x2add(i))],'HorizontalAlignment','right');
end
if isempty(x2add)
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),'crossing : No Crossings','HorizontalAlignment','right');
end
end

function testresult = crosscase2()
%% $Description (Name = No crossing, same grid)
% This testcase consists of a call to addXvaluesExactCrossings with two parallel horizontal lines.

x_new = [0 2]';
z1_new = [1 1]';
z2_new = [2 2]';

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 2: no crossing (horizontal)');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
xlim([0 4]);
ylim([0 2]);

%% $RunCode


[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = isempty(x2add);

%% $PublishResult
% The following figure shows the result of the testcase:

figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 2: no crossing - result');
xlim([0 4]);
ylim([0 2]);
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),['crossing : x=' num2str(x2add(i))],'HorizontalAlignment','right');
end
if isempty(x2add)
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),'crossing : No Crossings','HorizontalAlignment','right');
end
end

function testresult = crosscase3()
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

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = isempty(x2add);

%% $PublishResult
figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
axis image
title('testcase 3: NaN values - result');
xlim([0 4]);
ylim([0 2]);
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),['crossing : x=' num2str(x2add(i))],'HorizontalAlignment','right');
end
if isempty(x2add)
    text(min(xlim)+0.9*diff(xlim),min(ylim)+0.9*diff(ylim),'crossing : No Crossings','HorizontalAlignment','right');
end
end

function testresult = crosscase4()
%% $Description (Name = multiple crossings)
% Test the function with multiple crossings:
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

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = length(x2add)==2;

%% $PublishResult
figure('Color','w','Units','pixels','Position',[200 200 300 150]);
hold on
title('testcase 4: Multiple crossings - result');
plot(x_new,z1_new,'Color',[0.4 0.4 0.8]);
plot(x_new,z2_new,'Color',[0.8 0.4 0.4]);
axis image
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
    text(x2add(i),min(ylim)+0.1*diff(ylim),['x = ' num2str(x2add(i),'%0.2f')]);
end
end
