function testresult = addXvaluesExactCrossings_test()
% ADDXVALUESEXACTCROSSINGS_TEST  test defintion routine
%  
% More detailed description of the test goes here.
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

%% $Description (Name = Name of the test goes here)
% Publishable code that describes the test.

%% $RunCode
tr(1) = crosscase1;
tr(2) = crosscase2;
tr(3) = crosscase3;
tr(4) = crosscase4;

testresult = all(tr);

%% $PublishResult

end

function testresult = crosscase1()
%% $Description (Name = simple cross)

%% $RunCode
x_new = [0 2]';
z1_new = [1 1]';
z2_new = [0 2]';

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = x2add == 1;

%% $PublishResult
figure('Color','w');
hold on
plot(x_new,z1_new,'b');
plot(x_new,z2_new,'r');
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
end

end

function testresult = crosscase2()
%% $Description (Name = No crossing)

%% $RunCode

x_new = [0 2]';
z1_new = [1 1]';
z2_new = [2 2]';

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = isempty(x2add);

%% $PublishResult

end

function testresult = crosscase3()
%% $Description (Name = Dealing with nans)

%% $RunCode
x_new = (0:2:4)';
z1_new = [1 1 NaN]';
z2_new = [NaN 0 2]';

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = isempty(x2add);

%% $PublishResult

end

function testresult = crosscase4()
%% $Description (Name = multiple crossings)

%% $RunCode
x_new = (0:0.01:2*pi())';
z1_new = cos(x_new);
z2_new = zeros(size(x_new));

[x2add] = addXvaluesExactCrossings(x_new,z1_new,z2_new);

testresult = length(x2add)==2;

%% $PublishResult
figure('Color','w');
hold on
plot(x_new,z1_new,'b');
plot(x_new,z2_new,'r');
for i=1:length(x2add)
    plot(ones(1,2)*x2add(i),ylim,'LineStyle',':','Color','k');
end
end
