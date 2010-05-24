function TeamCity_runtests(varargin)
%TEAMCITYRUNOETTESTS  Function that runs all tests available in the OpenEarthTools repository.
%
%   This function gathers and runs all tests in the OpenEarthTools repository.
%
%   Syntax:
%   teamcityrunoettests;
%
%   See also mtestengine mtest oetruntests

%% Copyright notice
%   --------------------------------------------------------------------
%   Copyright (C) 2009 Deltares
%       Pieter van Geer
%
%       pieter.vangeer@deltares.nl
%
%       Rotterdamseweg 185
%       2629 HD Delft
%       P.O. 177
%       2600 MH Delft
%
%   This library is free software: you can redistribute it and/or
%   modify it under the terms of the GNU Lesser General Public
%   License as published by the Free Software Foundation, either
%   version 2.1 of the License, or (at your option) any later version.
%
%   This library is distributed in the hope that it will be useful,
%   but WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   Lesser General Public License for more details.
%
%   You should have received a copy of the GNU Lesser General Public
%   License along with this library. If not, see <http://www.gnu.org/licenses/>.
%   --------------------------------------------------------------------

% This tools is part of <a href="http://OpenEarth.Deltares.nl">OpenEarthTools</a>.
% OpenEarthTools is an online collaboration to share and manage data and
% programming tools in an open source, version controlled environment.
% Sign up to recieve regular updates of this function, and to contribute
% your own tools.

%% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
% Created: 15 Sep 2009
% Created with Matlab version: 7.8.0.347 (R2009a)

% $Id$
% $Date$
% $Author$
% $Revision$
% $HeadURL$
% $Keywords: $

%% First load oetsettings
try
    oetdir = strrep(fileparts(mfilename('fullpath')),'maintenance\TeamCity',''); 
    addpath(oetdir);
    addpath(genpath(fullfile(oetdir,'maintenance')));
    TeamCity.postmessage('progressStart','Running oetsettings.');
    oetsettings;
    TeamCity.postmessage('progressFinish','Oetsettings enabled.');
catch me
    TeamCity.postmessage('message', 'text', 'Matlab was unable to run oetsettings.',...
        'errorDetails',me.getReport,...
        'status','ERROR');
    %% Remove template files
    delete('matlabruns.busy');
%     rethrow(me);
    exit;
end

try
    TeamCity.running(true);
    TeamCity.postmessage('progressStart','Prepare for running tests.');
    %% initiate variables:
    maindir = oetroot;
    targetdir = fullfile(oetroot,'teamcitytesthtml');
    if isdir(targetdir)
        rmdir(targetdir,'s');
    end
    
    exclusions = {...
        '.svn',...
        '_tutorial',...
        'KML_testdir',...
        'mtest',...
        '1_automated_Testing',...
        ...
        ... These tests ask for user input....
        'rws_waterbase_read_test',...
        'rws_getDataInPolygon_test'...
        'KMLmesh_test',...
        ...
        ... Takes too long for a test...
        'KMLcontourf_test',...
        'KMLfig2pngNew_test',...
        };
    
    %% Create testengine
    mtr = MTestRunner(...
        'MainDir'  ,maindir,...
        'Recursive',true,...
        'Targetdir',targetdir,...
        'Exclusions',exclusions,...
        'Verbose'  ,true,...
        'CopyMode' ,'svnkeep',... {remove | svnkeep | keep}
        'IncludeCoverage',false,...
        'Publish',false,...
        'Template' ,'oet');
    
    
    %% Run tests and publish results
    mtr.run;
    TeamCity.postmessage('progressFinish','Tests finished.');
    
%     %% publish list with files that did not run.
%     if ~isempty(mte.wrongtestdefs)
%         fid = fopen(fullfile(targetdir,'CrashTests.txt'),'w');
%         fprintf(fid,'%s\n',mte.wrongtestdefs{:});
%         fclose(fid);
%     end
    
    %% Remove template files
    delete(fullfile(targetdir,'mxdom2defaulthtml.xsl'));
    
    %% zip result
    delete('testresult.zip');
    zip('testresult',{fullfile(targetdir,'*.*')});
    
    %% save tests
    save('tests.mat','mtr');
    
    %% remove targetdir
    rmdir(targetdir,'s');
    
catch me
    TeamCity.postmessage('message', 'text', 'Something went wrong while running the tests.',...
        'errorDetails',me.getReport,...
        'status','ERROR');
    delete('matlabruns.busy');
%     rethrow(me);
    exit;
end

delete('matlabruns.busy');
exit;
