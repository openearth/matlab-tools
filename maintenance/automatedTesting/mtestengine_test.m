%% #Test: mtestengine
% This test tests the mtestengine object. Tests must still be further specified.


%% #Case1 Description (CaseName = Constructor method)
% This testcase tests the constructor method. It simply uses setProperty to set the properties of
% the object before leaving the constructor. The test should therefore be no large problem.
%% #Case1 RunTest
try
    mte = mtestengine(...
        'targetdir',fileparts(which('mtestengine.m')),...
        'recursive',true,...
        'verbose',true);
    testresult = true;
catch err
    testresult = false;
end
%% #Case1 TestResults (IncludeCode = true)
% The test result speaks for itself I think. If there was an error. The error is displayed by the
% following code:

if exist('err','var')
    disp(err.message);
    disp(' ');
    disp(err.identifier);
    disp(' ');
    disp(['In: ' err.stack(1).file ]);
    disp(['    at: line ' num2str(err.stack(1).line)]);
end