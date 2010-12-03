function MTestFactory_test()
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

TeamCity.destroy;

mtestfactory_resetids_test;
mtestfactory_splitdefinitionstring_test;
mtestfactory_interpretheader_test;
mtestfactory_read_simplest_test;
mtestfactory_read_fulldefinition_test;

end

function mtestfactory_resetids_test()
%% ResetIDs method
mt = MTest;
mt.FullString = {'test';'1';'2';'3'};
mt = MTestFactory.resetstringids(mt);
assert(length(mt.IDOetHeaderString)==4);
end

function mtestfactory_splitdefinitionstring_test()
%% Splitdefinitionstring method

% Subfunctions with "end" at the end of function
mt = MTest;
mt.FileName = 'mte_fulldefinition_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);

% No subfunctions
mt.FileName = 'mte_simple_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
mt = MTestFactory.splitdefinitionstring(mt);

% Error when file not found.
mt = MTest;
mt.FullString = {'test'};
try
    mt = MTestFactory.splitdefinitionstring(mt);
    error('MTestFacoty:test','splitdefinitionstring should give an exception if there is no filename to be found.');
catch me
    assert(strcmp(me.identifier,'MTestFactory:DefinitionFileNotFound'),'MTest should give correct error message');
end

% No function declaration
mt.FileName = 'mte_wrongdefinition_test';
mt.FilePath = fileparts(which(mt.FileName));
mt = MTestFactory.retrievestringfromdefinition(mt);
mt = MTestFactory.resetstringids(mt);
try
    MTestFactory.splitdefinitionstring(mt);
catch me
    assert(strcmp(me.identifier,'MTestFactory:NoFunction'));
end

end

function mtestfactory_interpretheader_test()
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
end

function mtestfactory_read_simplest_test()
%% Create the simplest test
mt = MTestFactory.createtest(which('mte_simplest_test.m'));
assert(strcmp(mt.FunctionHeader,'function mte_simplest_test()'),'Function header should be :"function mte_simplest_test()"');
end

function mtestfactory_read_fulldefinition_test()
%% Create the fulldefinition test
mt = MTestFactory.createtest(which('mte_fulldefinition_test.m'));
assert(strcmp(mt.FunctionHeader,'function mte_fulldefinition_test()'));
assert(strcmp(mt.H1Line,'test h1line'),'H1 line was not retrieved correctly');
assert(length(mt.SeeAlso)==1,'There should be one reference in see also');
assert(strcmp(mt.Author,'geer'),'The author of this test should be "geer"');
assert(mt.Category == MTestCategory.Integration,'Test category should be of type Integration');
end