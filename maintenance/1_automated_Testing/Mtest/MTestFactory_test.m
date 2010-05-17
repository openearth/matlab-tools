function testResult = MTestFactory_test()
% MTESTFACTORY_CREATETEST_TEST  tests the MTestFactory object
%  
% This function tests the MTestFactory object.
%
%
%   See also MTest MTestFactory MTestRunner

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
% Created: 17 May 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

testResult = true;

%% ResetIDs method
mt = MTest;
mt.FullString = {'test';'1';'2';'3'};
mt = MTestFactory.resetstringids(mt);
assert(length(mt.IDTestString)==4);

%% Splitdefinitionstring method
mt = MTest;
% Subfunctions with "end" at the end of function
mt.FullString = {...
    'function t = test_test()';...
    'TEST_TEST tests the splitdefinitionstring method the splits a testdef in a test and subfunctions';...
    'end';...
    'function a = subfunction1()';...
    'end';...
    'function a = subfunction2()'};

mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
assert(all(mt.IDTestString == [1;1;1;0;0;0]));

% No end between function and subfunctions
mt.FullString(3)=[];
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
assert(all(mt.IDTestString == [1;1;0;0;0]));

% No subfunctions
mt.FullString = {...
    'function t = test_test()';...
    'TEST_TEST tests the splitdefinitionstring method the splits a testdef in a test and subfunctions'};
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
assert(all(mt.IDTestString));

% No function declaration
mt.FullString = {...
    'This test has no function declaration';...
    'Therefore we expect an error'};
mt = MTestFactory.resetstringids(mt);
try
    mt = MTestFactory.splitdefinitionstring(mt);
catch me
    assert(strcmp(me.identifier,'MTestFactory:NoFunction'));
end

%% interpretheader method
mt = MTest;
mt.FileName = 'mte_headeronly_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
mt = MTestFactory.interpretheader(mt);
assert(strcmp(mt.H1Line,'test h1line'));
assert(length(mt.Description)==1);
assert(length(mt.SeeAlso)==1);

mt = MTest;
mt.FileName = 'mte_versiononly_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
mt = MTestFactory.interpretheader(mt);
assert(strcmp(mt.Author,'geer'));

mt = MTest;
mt.FileName = 'mte_fulldefinition_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
mt = MTestFactory.interpretheader(mt);
assert(strcmp(mt.H1Line,'test h1line'));
assert(length(mt.Description)==1);
assert(length(mt.SeeAlso)==1);
assert(strcmp(mt.Author,'geer'));

%% Split definition blocks
mt = MTest;
mt.FileName = 'mte_fulldefinition_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);
mt = MTestFactory.interpretheader(mt);
mt = MTestFactory.splitdefinitionblocks(mt);
assert(length(mt.DescriptionCode)==3);

%% Create the simplest test
mt = MTestFactory.createtest(which('mte_simplest_test.m'));
assert(strcmp(mt.FunctionHeader,'function testResult = mte_simplest_test()'));
assert(length(mt.DescriptionCode)==1);