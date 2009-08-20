function testresult = mte_simple_test()
% MTE_SIMPLE_TEST  Performs a test is its most basal form
%
% This test performs a very simple test of the sum function
%
%   See also sum

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

%% $Description (Name = Simple test (sum))
% We are going to test whether 2 + 3 = 5

%% $RunCode
answer = sum([2 3]);
testresult = answer==5;

%% $PublishResult (IncludeCode = true)
% Result of the test:
disp(num2str(testresult));
