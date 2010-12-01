%% 3. Running individual tests
% Once we have generated a testdefinition we would like to run a test. In general there are three
% ways to run a test. This tutorial describes these three ways.
%
% <html>
% <a class="relref" href="tutorial_automatedtesting.html" relhref="tutorial_automatedtesting.html">Read more about automated testing</a>
% </html>

%% Command line execution
% Testdefinitions are designed in such a way that simply running the function from the command line
% will evaulate the test. If the test is not successfull it should crash when running command line,
% providing error information on what went wrong in which file.
%
% Example:

mte_simple_test;

%%
% *Advantage*
%
% One command leads to an immediate testresult. This method is therefore suitable for obtaining a
% quick look at the current state of the functions that are tested by this testdefinition.
%
% *Disadvantage*
%
% It is not possible to print either documentation or vizualisation of the result with one command.

%% Run a test with the MTest toolbox
% A testdefinition can also be run with the use of the mtest toolbox. To do this first an instance
% of an mtest object must be created.

t = MTest('mte_simple_test');

%%
% This object contains all information from the testdefinition in the property fields (fields like a
% struct). Several functions can be applied to this object.
%
% For example run the test:

run(t);

%%
% The testresult is now stored in the field: "TestResult":

t.TestResult

%%
% *Advantage*
%
% * With this method additional to running the test, the documentation can also be generated. It
% * requires a relatively small effort.
%
% *Disadvantage*
%
% * he testdefinition must be converted to an object before it can be run or published. Compared to
% command line usage this increases the amount of actions that must be undertaken.
% * Next to that, the
% mtest toolbox is programmed with the use of object oriented programming as introduced with Matlab
% version 7.4 (2008a). This method cannot be used with matlab versions prior to 2008a.

%% Run a test with the MTestRunner
% The third way to run a test is with the use of the MTestRunner that is also used to scan the
% toolbox for testdefinitions and automatically run them. This is done in the same way as with the
% mtest object:
%
% Create an mtestengine object

mtr = MTestRunner('Template','oet');

%%
% More information about calling MTestRunner:

help MTestRunner

%%
% For automatic running test the engine can look for all tests in a particular maindir:

help MTestRunner.gathertests

%%
% We only want to execute one test, so we add this to the tests in the MTestRunner object:

mtr.Tests(1) = MTest('mte_simple_test');

%%
% Now we can use the run command to run the test.

help MTestRunner.run

%%
% TODO: simple method to directly load multiple tests in the MTestRunner
% TODO: simple method to print a summary of the test info to the command window after running
