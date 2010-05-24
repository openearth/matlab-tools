function testresult = mtestcase_test()
% MTESTCASE_TEST  tests the functionalities of the mtestcase object
%
% This test involes checks of the methods assigned to the mtestcase object.
%
%   See also mtestcase mtest mtestengine

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
% This testcase tests the functionality of the mtestcase object. 

%% $RunCode
try
    % first create general variable. For this to work both mtest and mtestcase constructors have to
    % work. If they do not work all tests fail anyway.
    
    t = mtest('mte_examplewithtestcases_test');
    mtc = t.testcases(1);
catch me
    mtc = [];
end

tr(1) = Constructor_Method;
tr(2) = publishDescription_Method(mtc);
tr(3) = run_Method(mtc);
tr(4) = publishResults_Method(mtc);
tr(5) = runAndPublish_Method(mtc);
tr(6) = cleanUp_Method(mtc);

testresult = all(tr);

end

function constructortest = Constructor_Method()
%% $Description (Name = all functionalities & IncludeCode = true & EvaluateCode = true)
% This method creates an object. The testcase object created in this testcase comes from
% _dummy_test.m_. This is a dummy test created to test the automated test objects. Since
% mtestcase objects are there to support the mtest objects, creation of an mtestcase
% object is initiated from an mtest object and not directly possible from a test
% definition file. This object is created with the following variables:

descriptioncode = {...
    '% This is just a dummy test it always returns true'};

runcode = {...
    'testresult = true;'};

publishcode = {...
    '% The result of this test is always positive'};
%%
% On creation of the object these variables are assigned to the properties:
%
% * descriptioncode
% * runcode
% * publishcode
%
% The rest of the properties is not specified and therefore taken default.

%% $RunCode
% Perform the first part of the test (creating an object).
try
    constructortest = true;
    mtc = mtestcase(1,...
        'descriptioncode',descriptioncode,...
        'runcode',runcode,...
        'publishcode',publishcode);
    if ~strcmp(class(mtc),'mtestcase') || isempty(mtc)
        constructortest = false;
    end
catch err %#ok<*NASGU>
    constructortest = false;
end

%% $PublishResults(IncludeCode = false & EvaluateCode = true)
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
end

function publishdescrtest = publishDescription_Method(mtc)
%% $Description (Name = publishDescription method & IncludeCode = true & EvaluateCode = true)
% With the created object it is possible to print the description. This should be equal
% to the line mentioned above. The result dir (property resdir) is set to the current
% directory. While running the test we include code to verify if the file is actually
% there. After verification the file is deleted.

resdir = tempname;
outfilename = 'dummytest.html';
%% $RunCode
% Now check the publishDescription function
try
    mkdir(resdir);
    publishdescrtest = false;
    mtc.publishDescription(...
        'resdir',resdir,...
        'filename',outfilename);
    publishdescrtest = exist(fullfile(resdir,outfilename),'file');
    rmdir(resdir,'s');
 catch me
    try
        rmdir(resdir,'s');
    end
end
end

function runtest = run_Method(mtc)
%% $Description (Name = runTest method & IncludeCode = true & EvaluateCode = true)
% Third step of this testcase is run the dummy test. This should not take long whereas
% the runcode is very short.
%% $RunCode
% Now run the test
try
    mtc.run;
    runtest = mtc.testresult;
catch me
    runtest = false;
end
%% $PublishResults(IncludeCode = false & EvaluateCode = true)
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
end

function publishrestest = publishResults_Method(mtc)
%% $Description (Name = publishResults method & IncludeCode = true & EvaluateCode = true)
% As with publishDescription this testcase also includes a test of the publishResults
% functionality. This is done the same way. First we run the function, then we check if
% the html output file exists and than delete the file.
%% $RunCode
% Now publish the dummy result
try
    resdir = tempname;
    mkdir(resdir);
    mtc.publishResult('resdir',resdir);
    publishrestest = exist(fullfile(resdir,mtc.publishoutputfile),'file');
    rmdir(resdir,'s');
catch err
    publishrestest = false;
end
end

function runandpublishtest = runAndPublish_Method(mtc)
%% $Description (Name = runAndPublish method & IncludeCode = true & EvaluateCode = true)
% This function does the same as the last three functions performed successively. After
% running this function we check the existance of both the description html and the
% results html and delete both files.
%% $RunCode
% Now runAndPublish the object
try %#ok<*TRYNC>
    resdir = tempname;
    mkdir(resdir);
    runandpublishtest = false;
    mtc.runAndPublish('resdir',resdir);
    fls = dir(fullfile(resdir,'*.html'));
    if length(fls)==2
        runandpublishtest = true;
    end
    rmdir(resdir,'s');
end
end

function cleanuptest = cleanUp_Method(mtc)
%% $Description (Name = cleanUp method & IncludeCode = true & EvaluateCode = true)
% The cleanUp command seems to change nothing to the object itself, but reduces the
% amount of memory that is needed to store the object. After cleaning up we check
% the hidden workspace property to see if the function performed correctly.
%% $RunCode
% Now cleanUp the hidden workspace
try
    cleanuptest = false;
    mtc.cleanUp;
    cleanuptest = isempty(mtc.runworkspace);
catch err
    cleanuptest = false;
    return
end
end