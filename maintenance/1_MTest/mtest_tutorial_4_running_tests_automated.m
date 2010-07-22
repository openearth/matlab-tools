%% 4. Automated tesing with the MTest toolbox
%
% <html>
% The MTest toolbox is based on object oriented programming as introduced in matlab version 7.6
% (2008a). It is able to search a specified maindir (and subdirs) for files that include a
% predefined string (indicating that it is a test). It can transform the found testdefinition files
% (written in the format explained in the <a class="relref" href="testdefinitions_tutorial.html"
% relhref="tutorial_automatedtesting.html">tutorial on testdefinitions</a> into mtest objects
% containing all information that is in the testdefinition. Thest mtest objects can be run and
% published with the mtestengine. The following sections will show how.
% </html>
%
% <html>
% <a class="relref" href="tutorial_automatedtesting.html" relhref="tutorial_automatedtesting.html">Read more about automated testing</a>
% </html>

%% Building an mtestengine
% Creating an mtestengine is as simple as the following code suggests:

mte = MTestRunner;

%%
% Similar to a struct we can now visualize the properties of this object:

mte

%%
% It directly shows the default options for all fields. Of course we would like to set some of the
% properties. This can be done either when creating the object itself (with property value pairs) or
% afterwards in the same way as altering fields of a struct:

mte.TargetDir = fullfile(tempdir,'htmltest');
mte.MainDir = fileparts(which('MTestRunner'));
mte.Verbose = true;
mte.Template = 'oet';

%%
% or:

mte = MTestRunner(...
    'TargetDir',fullfile(tempdir,'htmltest'),...
    'MainDir',fileparts(which('mte_simple_test')),...
    'Verbose',true,...
    'Template','oet');

%% Properties (fieldnames) of the MTestRunner
% The MTestRunner has a couple of properties that can be used to define the behaviour of the
% MTestRunner when running and publishing. The following table lists the properties of an
% MTestRunner object.
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
%           <th bgcolor="#B2B2B2">Property Name</th>
%           <th bgcolor="#B2B2B2"><p>Class</p></th>
%           <th bgcolor="#B2B2B2"><p>Description</p></th>
%       </tr>
%   </thead>
%   <tbody>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>TargetDir</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>char</tt> Default=<tt>cd</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Pathname of the directory where output (html) files must be generated.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>MainDir</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>char</tt> Default=<tt>cd</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Root directory of the toolbox that must be analysed and tested.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Recursive</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>true</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Flag to determine whether the mtestengine only lists tests in the maindir or also in all subdirs of the maindir.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Publish</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>false</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Determines whether the publishable parts of a test get published.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Verbose</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>false</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Flag that determines whether intermediate information must be printed in the command window.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>IncludeCoverage</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>logical</tt> Default=<tt>true</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Flag to turn on / off the profile function during execution of the tests to obtain function coverage information.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>TestID</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>cell</tt> Default=<tt>{'_test'}</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               The character arrays included in this cell determine which functionnames are identified as testdefinition files.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Exclusions</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>cell</tt> Default=<tt>{'.svn','_tutorial'}</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Any function or pathname that includes one of the character arrays filling this cell is excluded from the list of testsdefinitions.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Template</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>char</tt> Default=<tt>default</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Name of the template that must be used to print the testresults of the toolbox.
%               (OpenEarthTools has its own template named: "oet". Use this template when publising
%               tests from OpenEarthTools).
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>Tests</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>mtest</tt> Default=<tt>[]</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               mtest object with the loaded testdefinitions. The mtestengine takes this list whenever the run command is given.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>WrongTestDefs</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>cell</tt> Default=<tt>{}</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Files identified as tests according to the testid and exclusion keywords, but failed
%               to load in an mtest object. This is probably due to a testdefinition that is not
%               according to the convention used for the mtest toolbox.
%           </td>
%       </tr>
%       <tr valign="top">
%           <td bgcolor="#F2F2F2"><tt>FunctionsRun</tt></td>
%           <td bgcolor="#F2F2F2"><p><tt>mtestfunction</tt> Default=<tt>[]</tt></p></td>
%           <td bgcolor="#F2F2F2">
%               Array of mtestfunction objects with information on the functions that were executed during the tests (including coverage information).
%           </td>
%       </tr>
%   </tbody>
% </table>
% </html>
%
% Setting properties is already adressed in the previous section.

%% Specifying tests to run
% After creation of an mtestengine we can see that it does not contain any testdefinitions yet. The
% *_tests_* contains an empty test.

mte.Tests

%%
% *manually add tests*
%
% Specifying tests can be done in two different ways. Of course we can add tests manually to the
% field:

mte.Tests(1) = MTest('mte_simple_test');

%%
% *search for tests*
%
% The catalogueTests method (or function) searches for all testdefinitions that match the following
% requirements:
%
% <html>
%   <ul>
%       <li>Tests should be in the maindir (or one of the subdirs if mte.recursive = true)</li>
%       <li>The filename should include one of the strings specified in the field <b><i>testid</i></b> of the mtestobject</li>
%       <li>The filename should not include one of the strings specified in the field <b><i>exclusion</i></b> of the mtestobject</li>
%       <li>mfiles that match the above mentionned criteria are converted to mtest objects. they must therefore match the layout criteria described in the <a class="relref" href="testdefinitions_tutorial.html" relhref="tutorial_automatedtesting.html">tutorial on testdefinitions</a></li>
%   </ul>
% </html>
%
% By default testdefinition files include the following string in their filename:
mte.TestID

%%
% but we exclude files with one of these strings in the filename
mte.Exclusions

%%
% After automatically searching for testdefinitions and adding them to the testengine ...

gathertests(mte);

%%
% we can see that the content of the *_tests_* field has changed. This is of course due to the fact
% that we just collected all tests that match the description as stated above:

mte

%% Run all tests
% To run all tests specified in the *_tests_* field of the mtestengine object there is a very simple
% function:

run(mte);

%%
% Each mtest object under the field *_"tests"_* contains a field that stores the testresult:

mte.Tests(2).TestResult

%% Run all tests and publish documentation and results
% The run function runs all tests and publishes the description and vizualization of
% results as specified in the testdefinition files.
% TODO: It also publishes the coverage of the tests (which percentages (and lines) of which functions did we actually test).
% More information on this function can be found in its help documentation:

help MTestRunner.run

%% Publication templates
% Publication of the mtestengine results is done acoording to a predefined format. This format is
% determined by the choice for a template. It is of course also possible to write your own template.
% At this moment there is not yet a tutorial on how to write such a template. The (sometimes hidden)
% functions of the MTestRunner object give a lot of information already.
