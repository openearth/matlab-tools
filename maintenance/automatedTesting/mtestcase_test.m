%% #Test: mtestcase functionalities
% This test looks at the functionalities of an mtestcase object. Since this test was written first
% all tests are compacted in one testcase. This is of course not the most easy way te test, whereas
% in the overview of the test results we can only see one result of a testcase. The test setup of
% mtest_test is therefore recommended. However, we need this test to check the functionalities of
% the mtestcase object. More information about this test is given in the testcase descripton.


%% #Case1 Description (IncludeCode = true & EvaluateCode = true & CaseName = all functionalities)
% This testcase tests the functionality of the mtestcase object. This is done according to the
% mtestcase methods. Since an mtestcase can only contain one testcase, we try to test the basic
% functionality of the object in one testcase to avoid multiple creation of the object in tests.
% (No real reason, but ok... the code is there already..).
%% mtestcase (constructor)
% This method creates an object. The testcase object created in this testcase comes from
% _dummy_test.m_. This is a dummy test created to test the automated test objects. Since
% mtestcase objects are there to support the mtest objects, creation of an mtestcase
% object is initiated from an mtest object and not directly possible from a test
% definition file. This object is created with the following variables:

description = {...
    '% This is just a dummy test it always returns true'};

runcode = {...
    'testresult = true;'};

publishcode = {...
    '% The result of this test is always positive'};
%%
% On creation of the object these variables are assigned to the properties:
%
% * description
% * runcode
% * publishcode
%
% The rest of the properties is not specified and therefore taken default.
%% publishDescription
% With the created object it is possible to print the description. This should be equal
% to the line mentioned above. The result dir (property resdir) is set to the current
% directory. While running the test we include code to verify if the file is actually
% there. After verification the file is deleted.

resdir = cd;
outfilename = 'dummytest.html';
%% runTest
% Third step of this testcase is run the dummy test. This should not take long whereas
% the runcode is very short.
%% publishResults
% As with publishDescription this testcase also includes a test of the publishResults
% functionality. This is done the same way. First we run the function, then we check if
% the html output file exists and than delete the file.
%% runAndPublish
% This function does the same as the last three functions performed successively. After
% running this function we check the existance of both the description html and the
% results html and delete both files.
%% cleanUp
% The cleanUp command seems to change nothing to the object itself, but reduces the
% amount of memory that is needed to store the object. After cleaning up we check
% the hidden workspace property to see if the function performed correctly.
%% #Case1 RunTest
% Perform the first part of the test (creating an object).
testresult = true;
try
    constructortest = true;
    mtc = mtestcase(1,...
        'description',description,...
        'runcode',runcode,...
        'publishcode',publishcode);
    if ~strcmp(class(mtc),'mtestcase') || isempty(mtc)
        testresult = false;
        constructortest = false;
    end
catch err
    testresult = false;
end

% Now check the publishDescription function
try
    publishdescrtest = false;
    mtc.publishDescription(...
        'resdir',resdir,...
        'filename',outfilename);
    if exist(fullfile(cd,outfilename),'file')
        delete(fullfile(cd,outfilename));
        testresult = testresult;
        publishdescrtest = true;
    end
catch err
    testresult = false;
end


% Now run the test
try
    mtc.runTest;
    testresult = mtc.testresult && testresult;
    runtest = mtc.testresult;
catch err
    testresult = false;
    runtest = false;
end

% Now publish the dummy result
try
    publishrestest = false;
    mtc.publishResults(...
        'resdir',resdir,...
        'filename',outfilename);
    if exist(fullfile(cd,outfilename),'file')
        delete(fullfile(cd,outfilename));
        testresult =  testresult;
        publishrestest = true;
    end
catch err
    testresult = false;
    publishrestest = false;
end

% Now runAndPublish the object
try
    runandpublishtest = false;
    mtc.runAndPublish(...
        'resdir',resdir,...
        'outputfile',outfilename);
    [pt fname] = fileparts(outfilename);
    fls = dir(fullfile(resdir,[fname '*']));
    if length(fls)==2 && testresult
        testresult = true;
        runandpublishtest = true;
    end
    for ifls = 1:length(fls)
        delete(fullfile(resdir,[fls(ifls).name]))
    end
catch err
    runandpublishtest = false;
    testresult = false;
end

% Now cleanUp the hidden workspace
try
    cleanuptest = false;
    mtc.cleanUp;
    if isempty(mtc.testworkspace) 
        testresult = testresult;
        cleanuptest = true;
    end
catch err
    testresult = false;
    cleanuptest = false;
    return
end
%% #Case1 TestResults (IncludeCode = false & EvaluateCode = true)
% Since we performed all tests on the object in one testcase, the testresult variable only gives an
% overview of the complete test result. We also created a boolean for each individual test to
% indicate whether the tests were ok. The result are summed up below:
%% Overall result
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
%% Constructor test
% The object was constructed:
clr = 'r';
txt = 'negative';
if constructortest
    clr = 'g';
    txt = 'positive';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);
%% publishDescription
% The description was published:
clr = 'r';
txt = 'unseccessful';
if publishdescrtest
    clr = 'g';
    txt = 'successful';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);
%% runTest
% The test was run:
clr = 'r';
txt = 'unseccessful';
if runtest
    clr = 'g';
    txt = 'successful';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);
%% publishResults
% The results were published:
clr = 'r';
txt = 'unseccessful';
if publishrestest
    clr = 'g';
    txt = 'successful';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);
%% runAndPublish
% runAndPublished was performed:
clr = 'r';
txt = 'unseccessful';
if runandpublishtest
    clr = 'g';
    txt = 'successful';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);
%% cleanUp
% after performing the cleanUp function, the object was:
% runAndPublished was performed:
clr = 'r';
txt = 'not clean';
if cleanuptest
    clr = 'g';
    txt = 'clean';
end
h = figure('Units','centimeter','Position',[10 10 0.5 0.5],'Color',clr,'MenuBar','none','Toolbar','none');
ha = axes('Parent',h,'Units','normalized','Position',[0 0 1 1],'Color',clr);
axis(ha,'off');
text(mean(xlim),mean(ylim),txt,'HorizontalAlignment','center','BackGroundColor',clr);
snapnow;
close(h);