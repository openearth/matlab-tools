function testresult = mtest_test()
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

%% $Description (Name = mtest functionality test)
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
testresult(1) = Constructor_method;
testresult(2) = publishDescription_method;
testresult(3) = runTest_method;
testresult(4) = publishResult_method;
testresult(5) = runAndPublish_method;
testresult(6) = cleanUp_method;

testresult = all(testresult);

%% $PublishResult
% TODO

end

%% TestCases
function testresult = Constructor_method()
%% $Description (Name = Constructor method)
% In this testcase the constructor method of the mtest object is tested. For tests on the mtest
% object methods the test fil dummy_test.m is used. This tests nothing and always returns a positive
% testresult. This testcase includes several checks:
%% general "do not crash" check
% When creating an object according to valid input it should not crash of course..
%% warning in case of wrong input
% In case a wrong property value pair is entered, the function should give a reasonable warning
% message.
%% syntax: mtest(filename,...)
% There are two possible syntaxes. One of them is with the filename as a first input argument.
%% syntax: mtest('filename','fn')
% The second syntax possibility is with property value pairs.
%% giving extra input arguments
% Next to the file name of the test definition we can also specify the output filename for the
% description html and the results html. Thjis should of course work...

%% $RunCode
testcell = {...
    'general "do not crash" test' , false ; ...
    'warning test',false;...
    'syntax 1 method',false;...
    'syntax 2 method',false;...
    'property value pairs',false...
    };

% Do not crash test.
testresult = true;
try
    testcell{1,2} = 'X';
    t1 = mtest(which('mte_dummy_test.m'));
    if strcmp(class(t1),'mtest') && ~isempty(t1) && length(t1.testcases)==3
        % Leave testresult true
        testcell{1,2} = 'OK';
    end
catch me %#ok<NASGU>
    testresult = false;
    testcell{1,2} = 'X';
end

% Warning test
try
    testcell{2,2} = 'X';
    mtest(which('mte_dummy_test.m'),'WrongProp','value');
    str = lastwarn;
    if ~isempty(strfind(str,'WrongProp'))
        % Leave testresult true
        testcell{2,2} = 'OK';
    end
catch me %#ok<NASGU>
    testresult = false;
    testcell{2,2} = 'X';
end

% syntax 1
try
    testcell{3,2} = 'X';
    t3 = mtest(which('mte_dummy_test.m'));
    if strcmp(class(t3),'mtest') && ~isempty(t3) && length(t3.testcases)==3
        % Leave testresult true
        testcell{3,2} = 'OK';
    end
catch me %#ok<NASGU>
    testresult = false;
    testcell{3,2} = 'X';
end

% syntax 2
try
    testcell{4,2} = 'X';
    t4 = mtest('filename',which('mte_dummy_test.m'));
    if strcmp(class(t4),'mtest') && ~isempty(t4) && length(t4.testcases)==3
        % Leave testresult true
        testcell{4,2} = 'OK';
    end
catch me %#ok<NASGU>
    testresult = false;
    testcell{4,2} = 'X';
end

% property value pairs test
try
    testcell{5,2} = 'X';
    t5 = mtest('filename',which('mte_dummy_test.m'),...
        'descriptionoutputfile','testname1');
    if strcmp(t5.descriptionoutputfile,'testname1')
        % Leave testresult true
        testcell{5,2} = 'OK';
    end
catch me %#ok<NASGU>
    testresult = false;
    testcell{5,2} = 'X';
end

%% $PublishResult
% The overall test result was:
clr = 'r';
txt = 'negative';
if testresult
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
%%
close(h);
%%
% positive means that all subtests were performed with good results. Negative means that one of the
% subtests was unsuccessful. The table below gives an indication of the individual results of the
% subtests:

h = figure('Units','pixels','Position',[200 200 500 150],'Toolbar','none','Menubar','none');
uitable(h,...
    'Units','normalized',...
    'Position',[0 0 1 1],...
    'Data',testcell,...
    'ColumnName',{'Subtest name','Test result'},...
    'ColumnFormat',{'char','char'},...
    'ColumnWidth',{200,60});
snapnow;
close(h);

end

function testresult = publishDescription_method()
%% $Description (Name = publishDescription method)
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
    if exist(t.descriptionoutputfile,'file')
        testresult = true;
    else
        testresult = false;
    end
    rmdir(resdir,'s');
catch me %#ok<NASGU>
    testresult = false;
    rmdir(resdir,'s');
end

%% $PublishResult
% The result of this test was:
clr = 'r';
txt = 'negative';
if testresult
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);

end

function testresult = runTest_method()
%% $Description (Name = runTest method)
% This testcase tests the runTest method of the mtest object

%% $RunCode
try
    t = mtest(which('mte_dummy_test.m'));
    t.run;
    testresult = ~t.testresult;
catch me %#ok<NASGU>
    testresult = false;
end

%% $PublishResult
% The test was run:
clr = 'r';
txt = 'unsuccessful';
if testresult
    clr = 'g';
    txt = 'successful';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);

end

function testresult = publishResult_method()
%% $Description (Name = publishResult method)
% This testcase runs the publishResult method of an mtest object

%% $RunCode
try
    resdir = tempname;
    mkdir(resdir);
    t = mtest(which('mte_dummy_test.m'));
    t.publishResult(...
        'resdir',resdir,...
        'filename','testfile');
    if exist(t.publishoutputfile,'file')
        testresult = true;
        delete(t.publishoutputfile);
    else
        testresult = false;
    end
    rmdir(resdir);
catch me %#ok<NASGU>
    testresult = false;
    try %#ok<TRYNC>
        rmdir(resdir,'s');
    end
end

%% $PublishResult
% The result of this test was:
clr = 'r';
txt = 'negative';
if testresult
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);

end

function testresult = runAndPublish_method()
%% $Description (Name = runAndPublish method)
% This testcase tests the runAndPublish method of an mtest object

%% $RunCode
try
    testresult = false;
    resdir = tempname;
    mkdir(resdir);
    t = mtest(which('mte_dummy_test.m'));
    t.runAndPublish(...
        'resdir',resdir,...
        'outputfile','testfile');
    if exist(t.testcases(1).descriptionoutputfile,'file') && ...
            exist(t.testcases(1).publishoutputfile,'file') && ...
            exist(t.descriptionoutputfile,'file') && ...
            exist(t.publishoutputfile,'file')
        
        testresult = true;
        rmdir(resdir,'s');
    end
catch me %#ok<NASGU>
    testresult = false;
    try %#ok<TRYNC>
        rmdir(resdir,'s');
    end
end

%% $PublishResult
% The result of this test was:
clr = 'r';
txt = 'negative';
if testresult
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);

end

function testresult = cleanUp_method()
%% $Description (Name = cleanUp method)
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

%% $PublishResult
% The result of this test was:
clr = 'r';
txt = 'negative';
if testresult
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);

end