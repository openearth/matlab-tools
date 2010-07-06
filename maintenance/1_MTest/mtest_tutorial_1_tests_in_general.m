%% 1. General information on testing
% This tutorial will introduce you into the basics of software testing. Testing is becoming
% common practce in software development. This also holds for the software that is being developed
% in the OpenEarthTools repository. This document describes a general background on software
% testing and how we use the MTest tool to test our software in OpenEarthTools.
%
% Tests can be differentiated into various types. The most commonly used types will be shortly
% adressed in this tutorial. Finally also a short chapter about TDD (test-driven development) is
% included. 
%
% <html>
% <a class="relref" href="tutorial_automatedtesting.html" relhref="tutorial_automatedtesting.html">Read more about automated testing</a>
% </html>
% 

%% Unit Tests
% Unit tests are the simplest to understand. A unit test tests a small part of the code (lets say a
% function like "sum" or "unique"). Because of this nature unit tests are normally very fast
% (because they only test a small fraction of a complete function, class, or toolbox).

%% Integration tests
% Integration tests are used to test the integration of multiple elements of a toolbox. This
% typically tests the coupling of smaller parts that are already tested with a Unit test.

%% Regression tests
% Both Unit tests and integration tests compare pieces of code against the desired functionality of
% that code (for example 1 + 1 should be 2). Regression tests typically compare the result of a
% function or toolbox with earlier results (a bench-mark). This type of testing requires the
% possibility to publish results (to make it possible to visually inspect the results).

%% TDD (Test Driven Development)
% The following information is obtained from <http://en.wikipedia.org/wiki/Test-driven_development wikipedia> 
% Test-driven development (TDD) is a software development technique that relies on the repetition of
% a very short development cycle: first the developer writes a failing automated test case that 
% defines a desired improvement or new function, then produces code to pass that test and finally 
% refactors the new code to acceptable standards. Kent Beck, who is credited with having developed 
% or 'rediscovered' the technique, stated in 2003 that TDD encourages simple designs and inspires 
% confidence.
% 
% Test-driven development requires developers to create automated unit tests that define code 
% requirements (immediately) before writing the code itself. The tests contain assertions that are 
% either true or false. Passing the tests confirms correct behavior as developers evolve and 
% refactor the code. Developers often use testing frameworks, such as xUnit, to create and 
% automatically run sets of test cases.
%
% The test-driven development cycle can be summarized as follows:
% # *Add a test* (Each new feature begins with writing a test. This test must inevitably fail because it is written before the feature has been implemented).
% # *Run all tests and see if the new one fails* (This is to ensure that the test is valid. It also tests the test harness).
% # *Write some code* (Write some code that will cause the test to pass). 
% # *Run the automated tests and see them succeed* (If all test cases now pass, the programmer can be confident that the code meets all the tested requirements).
% # *Refactor code* (Now the code can be cleaned up as necessary. The tests are used to check whether the changes did not break anything).  
%
% As can be concluded from the code above, applying TDD asks for the possibility to run Unit and
% regression tests.

%% How we use tests in OpenEarthTools
% The developers of OpenEarthTools are exoected to want to perform a wide range of tests. Some of
% the tools are developed using TDD (requiring the MTest toolbox to be able to run Unit and
% Integration tests), others are used to running regression tests. Due to the possibility of
% publishing test descriptions and results this is also possible with the MTest toolbox.