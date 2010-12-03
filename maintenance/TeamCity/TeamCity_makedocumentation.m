function TeamCity_makedocumentation(varargin)
%TEAMCITY_MAKEDOCUMENTATION  Function that creates all tutorials in the OpenEarthTools repository.
%
%   This function gathers and creates all tutorials in the OpenEarthTools repository.
%
%   Syntax:
%   TeamCity_makedocumentation;
%
%   See also mtestengine mtest oetpublish

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
    %% temp remove targetdir from repos checkout
    teamCityDir= fileparts(mfilename('fullpath'));
    matlabdir = strrep(fileparts(mfilename('fullpath')),'maintenance\TeamCity','');
    if isdir(fullfile(matlabdir,'tutorials'))
        rmdir(fullfile(matlabdir,'tutorials'),'s');
    end
    if isdir(fullfile(matlabdir,'docs'))
        rmdir(fullfile(matlabdir,'docs'),'s');
    end

    TeamCity_initialize;

catch me
    TeamCity.postmessage('message', 'text', 'Matlab was unable to initialize.',...
        'errorDetails',me.getReport,...
        'status','ERROR');
    TeamCity.postmessage('progressFinish','Run Oetsettings');
    TeamCity.postmessage('buildStatus',...
        'status','FAILURE',...
        'text', 'FAILURE: Matlab was unable to run oetsettings.');
    %            rethrow(me);
    exit;
end

try
    TeamCity.running(true);

    TeamCity.postmessage('progressStart','Generate OET documentation');
    try
        %% Publish documentation
        TeamCity.postmessage('progressMessage','Generate documentation html files');
        htmlDir = publish_OET_documentation;

        TeamCity.postmessage('progressMessage','remove copy of documentation to server');
        docDir = 'Z:\OpenEarthHtmlDocs\3frames';
        if isdir(docDir)
            rmdir(docDir,'s');
        end
        
        TeamCity.postmessage('progressMessage','Copy documentation to server');
        mkdir(docDir);
        copyfile(htmlDir,docDir);
        
        TeamCity.postmessage('progressMessage','Remove local copy of documentation');
        rmdir(htmlDir,'s');
    catch me
        TeamCity.running(true);
        TeamCity.postmessage('message', 'text', 'Matlab was unable to publish the documentation.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
        TeamCity.postmessage('buildStatus',...
            'status','FAILURE',...
            'text', 'FAILURE: Matlab was unable to publish the documentation.');
    end
    TeamCity.postmessage('progressFinish','Generate OET documentation');

    TeamCity.postmessage('progressStart','Create tutorials');
    try
        %% start documenting
        tutorials2html(varargin{:},'teamcity');

        %% zip result
        TeamCity.postmessage('progressStart','Package tutorials');
        TeamCity.postmessage('progressMessage','Packaging tutorial html files');
        delete(fullfile(teamCityDir,'htmldocumentation.zip'));
        TeamCity.postmessage('progressMessage','Packaging matlab toc files');
        delete(fullfile(teamCityDir,'matlabtocfiles.zip'));

        TeamCity.postmessage('progressMessage','Copying tutorials to server');
        tutorialDir = 'Z:\OpenEarthHtmlTutorials\';
        if isdir(tutorialDir)
            rmdir(tutorialDir,'s');
            mkdir(tutorialDir);
            copyfile(fullfile(oetroot,'tutorials','*.*'),tutorialDir);
        end

        TeamCity.postmessage('progressMessage','Zipping matlab toc files');
        zip(fullfile(teamCityDir,'matlabtocfiles'),{fullfile(oetroot,'docs','OpenEarthDocs','*.*')});
        TeamCity.postmessage('progressFinish','Package tutorials');
    catch me
        TeamCity.running(true);
        TeamCity.postmessage('message', 'text', 'Matlab was unable to publish the tutorials.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
        TeamCity.postmessage('buildStatus',...
            'status','FAILURE',...
            'text', 'FAILURE: Matlab was unable to publish the tutorials.');
    end
    TeamCity.postmessage('progressFinish','Create tutorials');

    %% remove targetdir
    TeamCity.postmessage('progressStart','Cleanup tutorials');
    rmdir(fullfile(oetroot,'tutorials'),'s');
    rmdir(fullfile(oetroot,'docs'),'s');
    TeamCity.postmessage('progressFinish','Cleanup tutorials');

catch me
    TeamCity.running(true);
    TeamCity.postmessage('message', 'text', 'Something went wrong while making documentation.',...
        'errorDetails',me.getReport,...
        'status','ERROR');
    exit;
end
exit;