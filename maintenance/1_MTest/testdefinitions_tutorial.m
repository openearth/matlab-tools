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
assert(a==1,'1+1 should be equal to 2');

%% Additional functions / methods
% Furthermore one can use several functions available in the MTest toolbox to ignore tests, or
% document a test or its result:
%
% * TeamCity.running
% * TeamCity.ignore
% * TeamCity.publishdescription
% * TeamCity.publishresult
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
% *TeamCity.publishdescription*
%
% This function adds a reference to the documentation of the test. This documentation can be located
% in a subfunction of the test, or a file outside the testdefinition (as a script or function). When
% using this function to publish the test description, the code of the specified function is copied
% and pasted into a temp file. This temp file gets published. Before and after publication of the
% description the active workspace (of the test function) is copied in such a way that the result of
% the publishable description is available in the workspace after finishing publication. Som of the
% publish options can be included as input parameters. An example of how to use this function is
% given below:
TeamCity.publishdescription(@mte_descriptionhelper,...
    'EvaluateCode',true,...
    'IncludeCode',true,...
    'maxWidht',400);

%%
% Or:

TeamCity.publishdescription('mte_descriptionhelper',...
    'EvaluateCode',true,...
    'IncludeCode',true,...
    'maxWidht',400);

%% 
% *TeamCity.publishresult*
%
% Similar to TeamCity.publishdescription, this function adds a reference to publishable code that
% describes the test result. Useage is also similar to TeamCity.publishdescription.
%
% *MTest.name*
%
% Can be used to give a test a custome name (by default a tests gets the filename as name).

MTest.name('New name');

%%
% *MTest.category*
%
% This method specifies the Category of the test.

MTest.category('Integration');

%%
% Or:

MTest.category('Slow');

%%
% Or:

MTest.category('UnitTest');

%% Formatting the publishable elements of a test
% There are two publishable elements in a test definition (description and result).
% Publication of these parts to html is done with the matlab function *_"publish"_*. A lot of
% information on formatting the output html pages can be found in the matlab documentation.
%
% <html>
% The 
% <a href="http://www.mathworks.com/access/helpdesk/help/techdoc/index.html?/access/helpdesk/help/techdoc/matlab_env/f6-30186.html&http://www.mathworks.com/cgi-bin/texis/webinator/search_spt?db=MSS&prox=page&rorder=750&rprox=750&rdfreq=500&rwfreq=500&rlead=250&sufs=0&order=r&is_summary_on=1&pr=SPT&cq=1&collection=1&ResultCount=10&query=Formatting+M-Files+Comments+for+publishing&x=8&y=8" target="new">
% matlab help documentation
% </a>
% contains a lot of information on formatting comments or code for publishing with the publish
% function. It is for example possible to include equations, force a snapshot or include a
% prerendered image. The matlab editor also contains a menu item with all of these functionalities:
% </html>
%
% <<prerendered_images/test_cell_menu.png>>

%% Examples
% The following files contain examples of how te use the testdefinition to obtain the desired
% result:
%
% <html>
%   <ul>
%       <li><a href="http://crucible.delftgeosystems.nl/browse/~raw,r=trunk/OpenEarthTools/trunk/matlab/maintenance/automatedTesting/examples/mte_simple_test.m" target="new">Basic test</a></li>
%       <li><a href="http://crucible.delftgeosystems.nl/browse/~raw,r=trunk/OpenEarthTools/trunk/matlab/maintenance/automatedTesting/examples/mte_dummy_test.m" target="new">Use of testcases</a></li>
%   </ul>
% </html>
%

