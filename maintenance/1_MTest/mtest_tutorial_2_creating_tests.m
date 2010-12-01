%% 2. Creating a test
% Test definitions can contain several parts, but can also be minimal. This tutorial will first show
% all you know to generate a test according to the OpenEarhtTools conventions and will then explain
% the conventions in detail.
%
% <html>
% <a class="relref" href="tutorial_automatedtesting.html" relhref="tutorial_automatedtesting.html">Read more about automated testing</a>
% </html>

%% Creating tests
% Like functions OpenEarthTools also contains a function to automatically generate a new test
% (_oetnewtest_). _oetnewtest_ can be used the following ways:
%
% *Syntax*
%
% * oetnewtest('filename');
% * oetnewtest('currentfile');
% * oetnewtest('functionname');
% * oetnewfun(..., 'PropertyName', PropertyValue,...);
%
% *Input*
% 
% * 'filename'    -   name of the test file (this should end with "_test.m" otherwise it is treated
% as a function name. If the filename is not specified, an Untitled test will be generated.
% * 'currentfile' -   Looks up the last selected file in the matlab editor and creates a test for that function. 
% * 'functionname'-   Name of the function for which this file should provide a test.
%
% *PropertyNames*
%
% * 'h1line'      -   One line description
% * 'description' -   Detailed description of the test
%
% *Examples*
%
% * oetnewtest('oetnewtest_test');
% * oetnewtest('currentfile');
% * oetnewtest('oetnewtest');

%% Simple test
% For the sake of simplicity the most simple test is just a function with one line of code. The
% function must obay the following rules:
%
% * The function name should contain *_"_test"_*.
% * The function should be addressed *_without any input parameters_*
%
% Such a function could look like this:
function testname_test()
assert(true,'This test does not crash');

%% Basic elements of a test
% A Testdefinition can be divided into two parts:
%
% # Function help block
% # the test code itself
%
% *Function help block*
%
% <html>
% Firstly a testdefinition is a function. Following the basic function documentation described in the 
% <a href="http://public.deltares.nl/display/OET/OpenEarth+guidelines+-+Matlab">Matlab style guide</a>
% we should include a help block in the function with a layout similar to the one provided by
% _oetnewfun_.
% </html>
%
% <<prerendered_images/test_helpblock.png>>
%

%% Test code
%
% The code body of the test contains code to test a function or functions. If the function does not
% return a variable it is counted as succeeded whenever there is no error detected. It is also
% possible to include a boolean variable as first output argument, which indicates whether the test
% was successfull or not.
%
% The use of the matlab build-in function "_assert_" can come in handy when testing the result of a
% function against requirements. For example:
%
a = sum([1, 1]);
assert(a==2,'1+1 should be equal to 2');

%% Additional functions / methods
% Furthermore one can use several functions available in the MTest toolbox for example to ignore tests:
%
% * TeamCity.running
% * TeamCity.ignore
% * MTest.name
% * MTest.category
%
% *TeamCity.running*
%
% returns a boolean that is true whenever the TeamCity server is running tests. This function can
% typically be used to do something that is only needed when running test at the buildserver (for
% example ignore the result).
%
% *TeamCity.ignore*
%
% Causes the teamcity server to ignore the current test. The reason to ignore should be included as 
% a string input into this function. If the TeamCity server is not running this function will do
% nothing.
%
% An example of using both methods mentioned above to ignore tests:
%
if TeamCity.running
    TeamCity.ignore('Work In Progress');
    return;
end

%%
% *MTest.name*
%
% Can be used to give a test a custome name (by default a tests gets the filename as name).

MTest.name('New name');

%% Setting test category
% Furthermore it is possible to set the category of a test. This requires
% only one line in your code:
%
% MTestCategory.(categoryname)
%
% in which categoryname is one of the predefined categories that can be
% obtained by pressing the tab key while holding the caret position at the
% right of the dot in the above statement. As an example:

MTestCategory.DataAccess
MTestCategory.Integration
MTestCategory.Performance
MTestCategory.Unit
MTestCategory.UserInput
MTestCategory.WorkInProgress

