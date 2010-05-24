function testResult = mtest_test()
% MTEST_TEST  tests the functionalities of the mtest object
%
% The test involves a basic test of the methods assigned to the mtest object in the classdefinition.
%
%   See also mtest mtestengine mtestcase

%% Credentials
%   --------------------------------------------------------------------
%   2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   --------------------------------------------------------------------
% This test is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 14 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% $Description 
% Name('mtest functionality test')
% This tests checks the functionality of the mtest object. It involves 7 testcases:
%
% # Test of the constructor method
% # Check of the publishDescription method
% # Check of the runTest method
% # Check of the publishResults method
% # Check of the runAndPublish method
% # Check of the cleanUp method
% # Check of the refreshTestResult method
%

%% $RunCode
tr = constructor_simplest_testcase;
tr(2) = constructor_headeronly_testcase;
tr(3) = constructor_versiononly_testcase;
tr(4) = constructor_definitionblockonly_testcase;
tr(5) = constructor_withtestcases_testcase;
tr(6) = publishDescription_method;
tr(7) = runTest_method;
tr(8) = publishResult_method;
tr(9) = runAndPublish_method;
tr(10) = cleanUp_method;

testResult = all(tr);
end

%% TestCases
function testResult = constructor_simplest_testcase()
%% $Description
% Name('Constructor method, simplest')
% In this testcase the constructor method of the mtest object is tested. For tests on the mtest
% object methods the test file mte_simplest_test.m is used. 

%% $Run
t = mtest(which('mte_simplest_test'));
testResult = strcmp(t.runcode{1},'testResult = true;');
end

function testResult = constructor_headeronly_testcase()
%% $Run
t = mtest(which('mte_headeronly_test.m'));
testResult = strcmp(t.h1line,'test h1line') &...
    strcmp(t.description{1},'% test description.') &...
    strcmp(t.seealso{1},'testseealso');
end

function testResult = constructor_versiononly_testcase()
%% $Run
t = mtest(which('mte_versiononly_test.m'));
testResult = strcmp(t.author,'geer');
end

function testResult = constructor_definitionblockonly_testcase()
%% $Run
t = mtest(which('mte_definitionblocksonly_test.m'));
testResult = strcmp(t.descriptioncode{1},'% test description code') &...
    strcmp(t.runcode{1},'testResult = true;') &...
    strcmp(t.publishcode,'% test publish code') &...
    strcmp(t.name,'testname');
end

function testResult = constructor_withtestcases_testcase()
%% $Run
t = mtest(which('mte_fulldefinition_test.m'));
testResult = ...
    numel(t.testcases)==2 &...
    strcmp(t.testcases(1).runcode{2},'testResult = true;') &...
    ~t.testcases(2).ignore &...
    numel(t.testcases(1).publishcode)==1;
end

function testresult = publishDescription_method()
%% $Description 
% Name('publishDescription method unit test')
% This testcase tests the publishDescription method of the mtest object.

%% $RunCode
try
    resdir = tempname;
    mkdir(resdir);
    t = mtest(which('mte_dummy_test.m'));
    t.publishDescription(...
        'resdir',resdir,...
        'filename','testfile',...
        'maxwidth',800);
    testresult = exist(fullfile(resdir,t.descriptionoutputfile),'file');
    rmdir(resdir,'s');
catch me %#ok<NASGU>
    testresult = false;
    rmdir(resdir,'s');
end
end

function testresult = runTest_method()
%% $Description 
% Name('runTest method unit test')
% This testcase tests the runTest method of the mtest object

%% $RunCode
try
    t = mtest(which('mte_dummy_test.m'));
    t.run;
    testresult = ~t.testresult;
catch me %#ok<NASGU>
    testresult = false;
end
end

function testresult = publishResult_method()
%% $Description 
% Name('publishResult method unit test')
% This testcase runs the publishResult method of an mtest object

%% $RunCode
try
    resdir = tempname;
    mkdir(resdir);
    t = mtest(which('mte_dummy_test.m'));
    t.publishResult(...
        'resdir',resdir,...
        'filename','testfile');
    if exist(fullfile(resdir,t.publishoutputfile),'file')
        testresult = true;
    else
        testresult = false;
    end
    rmdir(resdir,'s');
catch me %#ok<NASGU>
    testresult = false;
    try %#ok<TRYNC>
        rmdir(resdir,'s');
    end
end
end

function testresult = runAndPublish_method()
%% $Description (Name = runAndPublish method)
% This testcase tests the runAndPublish method of an mtest object

%% $RunCode
try
    resdir = tempname;
    mkdir(resdir);
    t = mtest(which('mte_dummy_test.m'));
    t.runAndPublish(...
        'resdir',resdir,...
        'outputfile','testfile');
    testresult = exist(t.testcases(1).descriptionoutputfile,'file') && ...
        exist(t.testcases(1).publishoutputfile,'file') && ...
        exist(fullfile(resdir,t.descriptionoutputfile),'file') && ...
        exist(fullfile(resdir,t.publishoutputfile),'file');
    
    rmdir(resdir,'s');
catch me %#ok<NASGU>
    testresult = false;
    try %#ok<TRYNC>
        rmdir(resdir,'s');
    end
end
end

function testresult = cleanUp_method()
%% $Description
% Name('cleanUp method unit test')
% cleanUp method test

%% $RunCode
try
    testresult = false;
    t = mtest(which('mte_dummy_test.m'));
    t.testcases(1).initworkspace = true;
    t.cleanUp;
    if isempty(t.testcases(1).initworkspace)
        testresult = true;
    end
catch me %#ok<NASGU>
    testresult = false;
end
end