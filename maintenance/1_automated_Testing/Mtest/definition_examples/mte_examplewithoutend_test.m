function testResult = mte_examplewithoutend_test
% MTE_EXAMPLEWITHTESTCASES_TEST  fakes a test and is used to test the testengine
%
% This testcase does not test anything. It is solely created to test the functionalities of mtest,
% mtestcase or mtestengine objects. The dummy tests has three testcases:
%
% # A testcase that always returns true.
% # A testcase that always returns false.
% # A testcase that does not produce a testresult variable.
%
%   See also mtest mtestcase mtestengine

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
% Created: 18 Aug 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $
testResult = true;

%% $Description (Name = dummy test)
% This testcase does not test anything. It is solely created to test the functionalities of mtest,
% mtestcase or mtestengine objects. The dummy tests has three testcases:
%
% # A testcase that always returns true.
% # A testcase that always returns false.
% # A testcase that does not produce a testresult variable.
%

%% $RunCode
tr = subfunction1;
assert(tr==true,'subfunction did not return true');

%% $PublishResult
% Publish function does not work yet...

function returnvalue = subfunction1()
returnvalue = true;
end