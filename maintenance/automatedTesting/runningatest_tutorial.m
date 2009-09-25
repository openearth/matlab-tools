%% 3. Running individual tests
% Once we have generated a testdefinition we would like to run a test and publish its results. In
% general there are three ways to either run a test, publish the documentation or do both. This
% tutorial describes these three ways.
%
% <html>
% <a class="relref" href="tutorial_automatedtesting.html" relhref="tutorial_automatedtesting.html">Read more about automated testing</a>
% </html>

%% Command line execution
% Testdefinitions are designed in such a way that simply running the function from the command line
% will evaulate the test and testcases. The first output argument of a testdefinition is always a
% boolean indicating whtether the test was successfull.
%
% Example:

testresult = mte_simple_test

%%
%*Advantage*
%
% One command leads to an immediate testresult. This method is therefore suitable for obtaining a
% quick look at the current state of the functions that are tested by this testdefinition.
%
% *Disadvantage*
%
% It is not possible to print either documentation or vizualisation of the result with one command.

%% Run a test with the mtest toolbox
% A testdefinition can also be run with the use of the mtest toolbox. To do this first an instance
% of an mtest object must be created.

t = mtest('mte_simple_test');

%%
% This object contains all information from the testdefinition in the property fields (fields like a
% struct). Several functions can be applied to this object.
%
% For example run the test:

run(t);

%%
% The testresult is now stored in the field: "testresult":

t.testresult

%%
% With the same object it is also possible to publish the description:

help mtest.publishDescription

%%
% publish the results:

help mtest.publishResult

%%
% Or run and publish the complete test:

help mtest.runAndPublish

%%
% *Advantage*
%
% With this method additional to running the test, the documentation can also be generated. It
% requires a relatively small effort.
%
% *Disadvantage*
%
% The testdefinition must be converted to an object before it can be run or published. Compared to
% command line usage this increases the amount of actions that must be undertaken. Next to that, the
% mtest toolbox is programmed with the use of object oriented programming as introduced with Matlab 
% version 7.4 (2008a). This method cannot be used with matlab versions prior to 2008a.

%% Run a test with the mtestengine
% The third way to run a test is with the use of the mtestengine that is also used to scan the
% toolbox for testdefinitions and automatically run them. This is done in the same way as with the
% mtest object:
%
% Create an mtestengine object

mte = mtestengine('template','oet');

%%
% More information about calling mtestengine:

help mtestengine.mtestengine

%%
% For automatic running test the engine can look for all tests in a particular maindir:

help mtestengine.catalogueTests

%%
% We only want to execute one test, so we add this to the tests in the mtestengine object:

mte.tests(1) = mtest('mte_simple_test');

%%
% To prevent the engine from indexing all testdefinitions we have to set the following field:

mte.testscatalogued = true;

%%
% Now we can use the runAndPublish command to run the test and publish the result.

help mtestengine.runAndPublish
