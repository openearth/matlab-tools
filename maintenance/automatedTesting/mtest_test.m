%% #Test: mtest functionalities
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
% See testcase descriptions for more information

%% #Case1 Description (CaseName = Constructor method)
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
%% #Case1 RunTest
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
catch err
    testresult = false;
    testcell{1,2} = 'X';
end

% Warning test
try
    testcell{2,2} = 'X';
    t2 = mtest(which('mte_dummy_test.m'),'WrongProp','value');
    str = lastwarn;
    if ~isempty(strfind(str,'WrongProp'))
        % Leave testresult true
        testcell{2,2} = 'OK';
    end
catch err
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
catch err
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
catch err
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
catch err
    testresult = false;
    testcell{5,2} = 'X';
end
%% #Case1 TestResults (IncludeCode = false & EvaluateCode = true)
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
snapnow;
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


%% #Case2 Description (IncludeCode = false & EvaluateCode = true & CaseName = publishDescription method)
% This testcase tests the publishDescription method of the mtest object.
%% #Case2 RunTest
try
    resdir = cd;
    t = mtest(which('mte_dummy_test.m'));
    t.publishDescription(...
        'resdir',resdir,...
        'filename','testfile',...
        'casenumber',1:2,...
        'maxwidth',800);
    if exist(fullfile(resdir,t.testcases(1).descriptionoutputfile),'file')
        testresult = true;
        delete(fullfile(resdir,t.testcases(1).descriptionoutputfile));
    end
    if exist(fullfile(resdir,t.testcases(2).descriptionoutputfile),'file')
        delete(fullfile(resdir,t.testcases(2).descriptionoutputfile));
    else
        testresult = false;
    end
catch
    testresult = false;
end
%% #Case2 TestResults (IncludeCode = false & EvaluateCode = true)
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


%% #Case3 Description (IncludeCode = false & EvaluateCode = true & CaseName = runTest method)
% This testcase tests the runTest method of the mtest object
%% #Case3 RunTest
try
    t = mtest(which('mte_dummy_test.m'));
    t.runTest;
    testresult = ~t.testresult;
catch err
    testresult = false;
end
%% #Case3 TestResults (IncludeCode = false & EvaluateCode = true)
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


%% #Case4 Description (IncludeCode = false & EvaluateCode = true & CaseName = publishResult method)
% This testcase runs the publishResult method of an mtest object
%% #Case4 RunTest
try
    testresult = false;
    resdir = cd;
    t = mtest(which('mte_dummy_test.m'));
    t.publishResults(...
        'resdir',resdir,...
        'filename','testfile',...
        'casenumber',1:2);
    if exist(fullfile(resdir,t.testcases(1).publishoutputfile),'file')
        testresult = true;
        delete(fullfile(resdir,t.testcases(1).publishoutputfile));
    end
    if exist(fullfile(resdir,t.testcases(2).publishoutputfile),'file')
        % Leave result unchanged. 
        delete(fullfile(resdir,t.testcases(2).publishoutputfile));
    else
        testresult = false;
    end
catch err
    testresult = false;
end
%% #Case4 TestResults (IncludeCode = false & EvaluateCode = true)
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


%% #Case5 Description (IncludeCode = false & EvaluateCode = true & CaseName = runAndPublish method)
% This testcase tests the runAndPublish method of an mtest object
%% #Case5 RunTest
try
    testresult = false;
    resdir = cd;
    t = mtest(which('mte_dummy_test.m'));
    t.runAndPublish(...
        'resdir',resdir,...
        'outputfile','testfile',...
        'casenumber',1);
    if exist(fullfile(resdir,t.testcases(1).descriptionoutputfile),'file') && ...
            exist(fullfile(resdir,t.testcases(1).publishoutputfile),'file')
        testresult = true;
        delete(fullfile(resdir,t.testcases(1).publishoutputfile));
        delete(fullfile(resdir,t.testcases(1).descriptionoutputfile));
    end
catch err
    testresult = false;
end
%% #Case5 TestResults (IncludeCode = false & EvaluateCode = true)
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


%% #Case6 Description (IncludeCode = false & EvaluateCode = true & CaseName = cleanUp method)
% cleanUp method test
%% #Case6 RunTest
try
    testresult = false;
    t = mtest(which('mte_dummy_test.m'));
    t.testcases(1).testworkspace = true;
    t.cleanUp;
    if isempty(t.testcases(1).testworkspace)
        testresult = true;
    end
catch err
    testresult = false;
end
%% #Case6 TestResults (IncludeCode = false & EvaluateCode = true)
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


%% #Case7 Description (IncludeCode = false & EvaluateCode = true & CaseName = refreahTestResult)
% refreshTestResult method test
%% #Case7 RunTest
try
    t = mtest(which('mte_dummy_test.m'));
    t.runTest;
    testresult = t.testcases(1).testresult & ~t.testcases(2).testresult;
catch err
    testresult = false;
end
%% #Case7 TestResults (IncludeCode = false & EvaluateCode = true)
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
