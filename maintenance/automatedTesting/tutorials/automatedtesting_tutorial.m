%% Openearth automated testing


%% Test definitions

%% Running individual tests

%% Running tests automatically with mtestengin

%% Examples


function testresult = sin_test
%% #Case1 Description (IncludeCode = false & EvaluateCode = true)
% This test file demonstrates the possibilities of the automatic test
% engine incorporated in the source code of WaveLab. Any file that ends
% with "__test.m_" is analysed and run / published according to the
% following rules:
%
% Each test file should contain the following sections:
%
%%
% These three cells describe, define and run a test and publish the
% results. All cells should start with *#CaseX* (in which X denotes the
% testcase number, so that multiple tests can be defined in one file). 
%
%% *%% #CaseX Descripton*
%
% Describes the tests. This part of the code is published with the publish
% function. This implies that formatting of the text can be applied
% according to the cell formatting rules. This for example enables the use
% of:
%
% * bullets
%
% # numbered bulltets
% 
% * An external image
% * An equation:
%
% $$e^{\pi i} + 1 = 0$$
% 
% * html code
% * and much more....
%
% The header of the cell can contain two attributes:
%
% # IncludeCode
% # EvaluateCode
%
% These two attributes can either be true or false and refer to the
% settings that can be set in the publish function. An example of the
% useage of the attribute IncludeCode:
% 
% *%% #Case1 Description (IncludeCode = true)*
%
%% *%% #CaseX RunTest*
%
% This section is not published. You can type any code in this section to
% perform the test described in the *Description* section. The automatic
% test engine tries to create an overview page of the successfull tests. To
% do this the RunTest section should at least provide a boolean named
% _"testresult"_ at the end, indicating whether this test was successfull 
% or not. 
%
%% *%% #CaseX TestResults*
%
% This section is used to create a result page of the test. By default the
% test result is only incorporated in the overview page. In case you want
% to create a result page for the test in particular (for example to plot
% some figures) this section can be used. The page is created by applying
% the publish function to the text in this region. All formatting rules as
% described in the matlab help for cell editing can therefore be used (Most
% functionalities can also be found in matlabs _"Cell"_ menu item.

%% #Case1 RunTest
% Any cell that is named in the above way is considered testcode. 
% This code is not included in any documentation. It only functiones to
% perform a test. The number of the testcase can be specified, so that 
% multiple tests can be included in one file. There should be at least
% one cell with this format in the file. The test code is required to 
% produce one output variable named _"testresult"_ (boolean) to indicate 
% the success of the test. 
%
% The following test is an example:

x = 0 : (2*pi()/200) : 2*pi();
try
    y = sin(x);
catch
    y = nan(size(x));
end

%%
% With the above code we tested the function. It is now important that we
% tell the test engine whether this test was a success:

testresult = y(151)==-1;

%% #Case1 TestResults (IncludeCode = false & EvaluateCode = true)
% This section is used to print a html page. The variables created in the
% *RunTest* section can be used for the visualization. In the same way as
% with the description also the two attributes can be specified. In many
% case one only wants a figure to appear on the result page and not the 
% complete code that was used to create the figure.

%% Print results
% At the end of a cell figures are printed and included in the html page.
% If we do not want the figure to appear in the next cell we can do two
% things:
%
% # Force a snapshot in the cell we want the figure to appear and delete
% the figure afterwards (matlab command "snapnow;").
% # Let matlab print the figure at the end of the cell and close the figure
% before the end of the following cell:
figure(...
    'Color','w');
box on
grid on
hold on
xlim([0 2*pi()]);
xlabel('x');
ylabel('sin(x) / cos(x)');
title('Result of test sin function');
plot(x,y,...
    'Color','b',...
    'LineWidth',2,...
    'DisplayName','TestResult')
snapnow;
plot(x,cos(x),...
    'Color','r',...
    'LineStyle','--',...
    'DisplayName','Data for Comparison');

legend show

%%
% After any matlab code we can continue writing with the use of an empty
% cell header.

close(gcf);
%% New cell
% Defininf a new cell creates a new chapter in the html page and adds a
% content list on top of the page.

%% Second New Cell.
% Just some cell
figure(14);

%% #Case2 RunTest
testresult = true;
figure(10);
figure(3);

%% #Case2 Description (IncludeCode = true)
% This second case just tests the possibility of multiple test cases. It has no visualization. 
% The test result is always true. 
%
% This section also shows that it is not necessary to first give the description of the test and
% than the testcode. The three parts of the test definition can be in any order.
