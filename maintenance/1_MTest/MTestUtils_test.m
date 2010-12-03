function MTestUtils_test()
% MTESTUTILS_TEST  Unit test for MTestUtils
%  
% This function tests the static functions of the MTestUtils object.
%
%
%   See also MTestUtils MTest MTestExplorer MTestRunner

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
% Created: 06 Jul 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

MTestCategory.Unit;
MTest.name('MTestUtility integration test');

testsetproperty;
testjavaclass;
testmergeprofileinfo;

end

function testsetproperty()
OPT = struct(...
    'opt1',[],...
    'opt2',[]);

OPT = MTestUtils.setproperty(OPT,'opt1',false,'opt2',true);
assert(~OPT.opt1,'First option should be false');
assert(OPT.opt2,'Second option should be true');
end

function testjavaclass()
cl = MTestUtils.javaclass('logical');
assert(strcmp(class(cl),'java.lang.Class'),'Output should be a java class');
assert(strcmp(cl.toString,'class java.lang.Boolean'),'Output should be a java boolean');
end

function testmergeprofileinfo()
if TeamCity.running
    % Don't mess up the profiler, but also do not perform this testcase
    return;
end
profile clear
profile on
MTest(which('mte_concepttest_test.m'));
profile off
prof1 = profile('info');
profile clear
profile on
if TeamCity.running
    disp('TeamCity is running');
end
prof2 = profile('info');

profcombined = MTestUtils.mergeprofileinfo(prof1,prof2);
assert(length(profcombined.FunctionTable) == length(prof1.FunctionTable),...
    'prof2 added new functions to the functionTable');
end

function testevalinemptyworkspace
MTestUtils.evalinemptyworkspace('setappdata(0,''testevalinemptyworkspace'',whos);');

assert(isappdata(0,'testevalinemptyworkspace'),'Appdata should be created');

data = getappdata(0,'testevalinemptyworkspace');
rmappdata(0,'testevalinemptyworkspace');

assert(isempty(data),'There should be no variables in the workspace of evalinemptyworkspace');
end