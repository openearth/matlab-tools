%% MTESTENGINE_TEST  Tests the functionalities of the mtestengine object
%
% TestName: mtestengine functionality test
%  
% This test tests the mtestengine object. Tests must still be further specified.
%
%
%   See also mtestengine mtest mtestcase

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