%% #Test: Dummy
% This testcase does not test anything. It is solely created to test the functionalities of mtest,
% mtestcase or mtestengine objects. The dummy tests has three testcases:
%
% # A testcase that always returns true.
% # A testcase that always returns false.
% # A testcase that does not produce a testresult variable.
%


%% #Case1 Description (IncludeCode = false & EvaluateCode = true & CaseName = Always true)
% This is just a dummy test. it always returns true and there is no testing involved.
%% #Case1 RunTest
testresult = true;
z = peaks(40);
%% #Case1 TestResults (IncludeCode = true & EvaluateCode = true)
% The result of this test is always positive of course, whereas it does not really test anything. To
% get a nice idea of the possibilities of the possibilities of the mtest object, we now include a
% nice example. 
%
% Let say we tested the peaks function and just want to visually inspect the result.
% During the test we already created the necessary variable z:
%
% $$z = peaks(40);$$
%
% Now we only want to visualize the result:

figure;
hold on
grid on
surf(z);
shading interp
view(3)
%%
% Now we want to compare the results with some data. Maybe the data is as follows:

zdata = z*1.5;
mesh(zdata,'FaceColor','none','EdgeColor','k');
snapnow;
close(gcf);
%% 
% From the above figure we can see that the calculated data (z) does not coincide with zdata.
% Despite the positive result of the test one maybe decide that this is not good enough.


%% #Case2 Description (IncludeCode = true)
% As with the first dummy testcase this testcase also does not perform any test. It just returns
% false.
%% #Case2 RunTest
testresult = false;
%% #Case2 TestResults
% There is no need to further demonstrate the results, because there aren't any...

%% #Case3 Description
% As with the first two dummy testcase this testcase also does not perform any test. It also does 
% not create the testresult variable.
%% #Case3 RunTest
tr = false;
%% #Case3 TestResults
% If the mtestengine works correct the icon for this testcase should be neutral...