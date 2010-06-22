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

try
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

        %% load oetsettings
        addpath(matlabdir);
        addpath(genpath(fullfile(matlabdir,'maintenance')));
        TeamCity.running(true);
        TeamCity.postmessage('progressStart','Running oetsettings.');
        oetsettings;
        TeamCity.postmessage('progressFinish','Oetsettings enabled.');
    catch me
        TeamCity.running(true);
        TeamCity.postmessage('message', 'text', 'Matlab was unable to run oetsettings.',...
            'errorDetails',me.message,...
            'status','ERROR');
        exit;
    end

    try
        TeamCity.running(true);

        %% start documenting
        tutorials2html(varargin{:},'teamcity');

        %% zip result
        delete(fullfile(teamCityDir,'htmldocumentation.zip'));
        delete(fullfile(teamCityDir,'matlabtocfiles.zip'));
        zip(fullfile(teamCityDir,'htmldocumentation'),{fullfile(oetroot,'tutorials','*.*')});
        zip(fullfile(teamCityDir,'matlabtocfiles'),{fullfile(oetroot,'docs','OpenEarthDocs','*.*')});

        %% remove targetdir
        % rmdir(fullfile(oetroot,'tutorials'),'s');
        rmdir(fullfile(oetroot,'docs'),'s');
    catch me
        TeamCity.postmessage('message', 'text', 'Something went wrong while making documentation.',...
            'errorDetails',me.getReport,...
            'status','ERROR');
        exit;
    end
end
exit;