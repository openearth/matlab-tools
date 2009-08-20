function testresult = mte_dummy_test
% MTE_DUMMY_TEST  fakes a test and is used to test the testengine
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

%% $Description (Name = dummy test)
% This testcase does not test anything. It is solely created to test the functionalities of mtest,
% mtestcase or mtestengine objects. The dummy tests has three testcases:
%
% # A testcase that always returns true.
% # A testcase that always returns false.
% # A testcase that does not produce a testresult variable.
%

%% $RunCode
tr{1} = always_true;
tr{2} = always_false;
tr{3} = no_result;

testresult = all([tr{:}]);

%% $PublishResult
% Publish function does not work yet...

end

function testresult = always_true()
%% $Description (IncludeCode = false & EvaluateCode = true & Name = Always true)
% This is just a dummy test. it always returns true and there is no testing involved.

%% $RunCode
testresult = true;

%% $PublishResult
% The result of this test is always positive of course, whereas it does not really test anything.
end

function testresult = always_false()
%% $Description (IncludeCode = true & Name = Always false)
% As with the first dummy testcase this testcase also does not perform any test. It just returns
% false.
%% $RunCode
testresult = false;
%% $PublishResult
% There is no need to further demonstrate the results, because there aren't any...

end

function testresult = no_result()
%% $Description (Name = No result)
% As with the first two dummy testcase this testcase also does not perform any test. Test without
% result can be created in two ways. Either we do not produce the variable testresult at all
% (this will generate a warning when running the test), or we return testresult = NaN (which is
% what we do in this case. This is an expected result by the mtest object and therefore does not
% generate a warning.
%% $RunCode
testresult = NaN;
%% $PublishResult
% If the mtestengine works correct the icon for this testcase should be neutral...
end