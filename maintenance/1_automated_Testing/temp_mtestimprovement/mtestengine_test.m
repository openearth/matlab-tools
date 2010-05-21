function testResult = mtestengine_test()
% MTESTENGINE_TEST  tests the functionalities of the mtestengine object
%
% This file tests the methods assigned to the mtest engine object.
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


%% $Description

%% $Run
tr(1) = constructor_testcase;
tr(2) = run_testcase;

assert(all(tr));

testResult = all(tr);
end

function testResult = constructor_testcase
%% $Description 
% Name('Constructor method')
% This testcase tests the constructor method. It simply uses setProperty to set the properties of
% the object before leaving the constructor. The test should therefore be no large problem.

%% $Run
mte = mtestengine(...
    'targetdir',fileparts(which('mtestengine.m')),...
    'recursive',true,...
    'verbose',true);

assert(strcmp(class(mte),'mtestengine'));

testResult = true;
end

function testResult = run_testcase
%% $Description
% Name('run')

%% $Run

mte = mtestengine(...
    'targetdir',fullfile(tempdir,'mtest'),...
    'postteamcity',false,...
    'maindir',fullfile(fileparts(which('mtestengine')),'examples'),...
    'verbose',true);
mte.catalogueTests;

mte.runAndPublish;
end