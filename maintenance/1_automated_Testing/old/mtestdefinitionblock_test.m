function testResult = mtestdefinitionblock_test()
% MTE_MTESTDEFINITIONBLOCK_TEST  This function tests the functionality of the mtestdefinitionblock object
%  
% The mtestdefinitionblock object reads the definition part of a test definition file. This function
% is meant to test the basic functionality of that object. It can also be used as an exaple of how
% to define a test
%
%
%   See also mtestdefinitionblock mtest mtestengine

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
% Created: 07 May 2010
% Created with Matlab version: 7.10.0.499 (R2010a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description
% Name('mtestdefinitionblock unit test')
% Ignore('Maintenance')
% Category('Unit')

%% $Run
tr = simplestdefinition_testcase;
tr(2) = ignored_testcase;
tr(3) = justrun_testcase;
tr(4) = fulldefinition_testcase;
tr(5) = evaluatecodeattribute_testcase;
tr(6) = includecodeattribute_testcase;
tr(7) = setcategory_testcase;
tr(8) = setname_testcase;
tr(9) = nodescription_testcase;
tr(10)= noruncode_testcase;
tr(11)= nopublish_testcase;
tr(12)= testcasestring_testcase;
testResult = all(tr);

end

function testResult = simplestdefinition_testcase
%% $Description (Name = Most simple definition with just code)

%% $Run
str = {...
    'testResult = true;'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.runcode,str{1});
end

function testResult = ignored_testcase
%% $Desciption (Name = ignored test(case))

%% $Run
str = {...
    '% Ignore(''test'')'};
o = mtestdefinitionblock(str);
testResult = o.ignore & strcmp(o.ignoremessage,'test');
end

function testResult = justrun_testcase
%% $Description (Name = just RunCode)
str = {...
    '%% $Run';...
    'testResult = true;'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.runcode,str{2});
end

function testResult = fulldefinition_testcase
%% $Description (Name = full definition)
% A test with all three definition blocks (Description, Run, Publish)

%% $Run
str = {...
    '%% $Description';...
    '% This is a decription';...
    'and this is description code';...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish';...
    'publish code'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.runcode,str{5}) & ...
    strcmp(o.publishcode,str{7}) & ...
    numel(o.descriptioncode)==2 & ...
    strcmp(o.descriptioncode{1},str{2}) & ...
    strcmp(o.descriptioncode{2},str{3});
end

function testResult = evaluatecodeattribute_testcase
str = {...
    '%% $Description (EvaluateCode = false)';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish (EvaluateCode = false)'};
o = mtestdefinitionblock(str);
str2 = {...
    '%% $Description (evaluateCode = false)';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish (Evaluatecode = false)'};
o2 = mtestdefinitionblock(str2);

testResult = ~o.descriptionevaluatecode & ~o.publishevaluatecode &...
    ~o2.descriptionevaluatecode & ~o2.publishevaluatecode;
end

function testResult = includecodeattribute_testcase
str = {...
    '%% $Description (IncludeCode = true)';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish (IncludeCode = true)'};
o = mtestdefinitionblock(str);
str2 = {...
    '%% $Description (includeCode = true)';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish (Includecode = true)'};
o2 = mtestdefinitionblock(str2);

testResult = o.descriptionincludecode & o.publishincludecode &...
    o2.descriptionincludecode & o2.publishincludecode;
end

function testResult = setcategory_testcase
%% $Description (Name = set Category)

%% $Run
str = {...
    '%% $Description';...
    '% Category(''test'')';...
    '%% $Run';...
    'testResult = true;'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.category,'test');
end

function testResult = setname_testcase
%% $Description (Name = set Name)

%% $Run
str = {...
    '%% $Description (Name = testname)';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;'};
o = mtestdefinitionblock(str);

str2 = {...
    '%% $Description';...
    '% Name(''testname'')';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;'};
o2 = mtestdefinitionblock(str2);

testResult = strcmp(o.name,'testname') & strcmp(o2.name,'testname');
end

function testResult = nodescription_testcase
str = {...
    '%% $Run';...
    'testResult = true;';...
    '%% $Publish';...
    'publish code'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.publishcode,str{end}) & strcmp(o.runcode,str{2});
end

function testResult = noruncode_testcase
str = {...
    '%% $Description';...
    'description code';...
    '%% $Publish';...
    'publish code'};
o = mtestdefinitionblock(str);
testResult = o.ignore & strcmp(o.ignoremessage,'No run code in definition.');
end

function testResult = nopublish_testcase
str = {...
    '%% $Description';...
    '% This is a decription';...
    '%% $Run';...
    'testResult = true;'};
o = mtestdefinitionblock(str);
testResult = strcmp(o.descriptioncode,str{2}) & strcmp(o.runcode,str{end});
end

function testResult = testcasestring_testcase
str = {...
    'function testResult = testcase1';...
    '%% $Run';...
    'testResult = true;';...
    'end'};
o = mtestdefinitionblock(str);
testResult = numel(o.runcode)==1;
end