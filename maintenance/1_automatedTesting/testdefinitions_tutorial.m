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
% (_oetnewtest_). The help of this function shows you how it can be used.
%
% There are several ways to call oetnewtest:
% 
% * Without input arguments
% * With the name of the test function
% * with the name of the function that is tested by the new testfunction
% * For the file currently edited in the matlab editor
% 
% The help of oetnewtest provides more information on the options that can be specified for _oetnewfun_.

help oetnewtest

%% Simple test
% For the sake of simplicity the most simple test is just a function that returns a testresult. The
% function must obay the following rules:
%
% * The function name should contain *_"_test"_*.
% * The function should be addressed *_without any input parameters_*
% * The *_first output argument_* of the function should be a *_boolean_* (logical) indicating the result of the test {true | false | NaN}
%
% Such a function could look like this:

% function testresult = testname_test()
%
% testresult = sum([2,3])==5;

%% Basic elements of a test
% A Testdefinition can be divided into two parts:
%
% # Function help block
% # Basic parts of the test definition
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
% *Basic parts of the test definition*
%
% Secondly (regression) tests are often accompanied by an extensive documentation. Many developers
% have to cope with the problem of updating / renewing the tests and at the same time keeping the
% documentation of these tests up to date. In an attempt to deal with this problem testdefinitions 
% in OpenEarthTools can contain documentation of the tests and visualization of the results. This is
% achieved distinguishing three code blocks:
%
% # Description of the test
% # The actual code that is executed
% # Documentation / visualization of the results
% 
% <<prerendered_images/test_documentation_blocks.png>>
%
% *Description block*
% 
% The description typically does not depend on the test result. This block can contain publishable
% code (see next section for formatting tips) to document the purpose of the test and what can be
% expected as outcome. This block is preceeded by a cell divider ("%% ") followed by the keyword
% $Description:
%
% %% $Description
%
% *RunCode block*
%
% This block of code contains the actual test. The test engine automatically runs this block of code
% preceeded by the description code (so that all variables created in the description block are
% known) and saves the resulting workspace. Any figures created during the test will be deleted and
% are not included in the publication (This is no real problem, since we seperate computational
% functions from plot functions). During this block of code the first output argument should be
% created (indicating the testresult by either a boolean (false / true) or a NaN. The start of the
% RunCode block is indicated with a cell divider similar to the one to indicate the Description, but
% now with the keyword $RunCode:
%
% %% $RunCode
%
% This cell divider automatically defines the end of the preceeding block of code ($Description or
% $PublishResult).
%
% *PublishResult block*
%
% This block of code (ending at the end of the file in case no testcases are defined, or at the last
% "end" keyword prior to a testcase) contains publishable code to visualize the test result.
% Typically this can contain some plots of the result in case of a regression test to visually
% inspect the result. The following section explaines more about the publication blocks. The start
% of the PublishResult block is indicated with:
%
% %% $PublishResult

%% Formatting the publishable elements of a test
% There are two publishable elements in a test definition (description and publishresult blocks).
% Publication of these parts to html is done with the matlab function *_"publish"_*. A lot of
% information on formatting the output html pages can be found in the matlab documentation.
%
% *Block attributes*
%
% Each publishable block in the testdefinition (see previous section of this document) can contain
% atributes in its header. The attributes determine publish options of the specific block, test or
% testcase. The following table gives an overview of the possible attributes that can be defined for
% the $Description and $PublishResult code blocks.
%
% <html>
% <table cellspacing="0" class="body" cellpadding="4" summary="" width="100%" border="2">
%   <colgroup>
%       <col width="16%">
%       <col width="21%">
%       <col width="63%">
%   </colgroup>
%   <thead>
%       <tr valign="top">
%           <th bgcolor="#B2B2B2">Attribute Name</th>
%           <th bgcolor="#B2B2B2"><p>Class</p></th>
%           <th bgcolor="#B2B2B2"><p>Description</p></th>
%       </tr>
%   </thead>
%   <tbody>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Name</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>char</tt> Default=<tt>''</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Custom name of the test or testcase.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>IncludeCode</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>false</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Determines the publish option showCode for this publishable section.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>EvaluateCode</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>true</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Determines the publish option evalCode for this publishable section.
%           </td>
%       </tr>
%   </tbody>
% </table>
% </html>
%
% Attributes can be added between brackets after the dedicated keyword that defines the function of
% the cell in particular:
%
% %% $Description (Name = Tutorial Name)
%
% Attributes can be seperated by the *_"&"_* sign.
%
% %% $Description (Name = Tutorial Name & IncludeCode = true)
%
% *Formatting of cells for publishing*
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

%% Working with testcases
% The test definition allows for the use of testcases. One test can contain an unlimited amount of
% testcases. Typically one uses testcases to test different functionalities of the same applicaion
% or engine to avoid including multiple testdefinitions for one function. A testcase can be defined
% by including a subfunction that is addressed in the RunCode block. It is important to know that:
%
% # It should be subfunctions, not nested functions (in other words, the main function should be 
%   terminated with an "end" keyword before declaration of the subfunction / testcase.
% # A testcase can have input arguments (generated in the Description or RunCode part of the test)
% # A testcase can have multiple output arguments.
% # The first output argument should be of type boolean (logical), indicating whether the testcase
%   was successfull.
% # A testcase is also a function and therefore its name cannot interfere with other functionsnames
%
% The following image shows an example of a testcase declaration.
%
% <<prerendered_images/test_testcases.png>>

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

