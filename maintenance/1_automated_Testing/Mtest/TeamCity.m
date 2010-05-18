classdef TeamCity < handle
    properties
        CurrentTest
        TeamCityRunning = false;
        WorkDirectory = cd;
        Timer
    end
    methods
        function obj = TeamCity()
            % add to appliction data (or retrieve if it is already there)
            if isappdata(0,'MTestTeamCityObject')
                obj = getappdata(0,'MTestTeamCityObject');
            else
                setappdata(0,'MTestTeamCityObject',obj);
            end
        end
    end
    methods (Static = true)
        function teamCityRunning = ignore(ignoreMessage)
            %% Retrieve TeamCity object
            obj = TeamCity;
            teamCityRunning = obj.TeamCityRunning;
                        
            %% find ignore message
            if nargin==0
                ignoreMessage = '';
            end
            
            %% Post ignore message
            if obj.TeamCityRunning
                %% Retrieve current test
                currentTest = obj.CurrentTest;
                if ~isempty(currentTest)
                    %% Set test properties
                    currentTest.Ignore = true;
                    currentTest.IgnoreMessage = ignoreMessage;
                    %% Post TeamCity message
                    TeamCity.postmessage('testIgnored','name',currentTest.Name,'message',currentTest.IgnoreMessage);
                end
            else
                %% Post TeamCity message to command window
                TeamCity.postmessage('testIgnored','message',ignoreMessage);
            end
        end
        function category(category)
            %% Give Category name
            obj = TeamCity;
            if obj.TeamCityRunning
                currentTest = obj.CurrentTest;
                if ~isempty(currentTest)
                    currentTest.Category = category;
                end
            end
        end
        function postmessage(messageName,varargin)
            %POSTMESSAGE  Posts a teamcity message file or displays the message in the command window.
            %
            %   Matlab automatically retorns zero when started, disconnecting the matlab command window from the
            %   process it was started with. To still give messages to this process the runner loops until
            %   matlab really finishes (a file called matlab.busy is deleted) and searches for a file called
            %   teamcitymessage.matlab that contains a message for teamcity. This message is than displayed and
            %   the file is deleted afterwards. this function produces the teamcitymessage.matlab file.
            %
            %   Syntax:
            %   TeamCity.postmessage(message, varargin)
            %
            %   Input:
            %   messageName    = teamcity mssage id (keywords that are interpreted by TeamCity)
            %   property value pairs for teamcity (depending on the messageID, see also the TeamCity
            %   reference pages for more information).
            %
            %   See also oetsettings <a href="http://confluence.jetbrains.net/display/TCD5/Build+Script+Interaction+with+TeamCity">TeamCity reference pages</a>
            
            %% Copyright notice
            %   --------------------------------------------------------------------
            %   Copyright (C) 2010 Deltares
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
            
            % This tool is part of <a href="http://OpenEarth.nl">OpenEarthTools</a>.
            % OpenEarthTools is an online collaboration to share and manage data and
            % programming tools in an open source, version controlled environment.
            % Sign up to recieve regular updates of this function, and to contribute
            % your own tools.
            
            %% Retrieve TeamCity object
            obj = TeamCity;
            
            %% Check whether we still have an outstanding message
            h = tic;
            while exist(fullfile(obj.WorkDirectory,'teamcitymessage.matlab'),'file')
                pause(0.001);
                if toc(h) > 0.1 % Give teamcity som time to read the file
                    delete(fullfile(obj.WorkDirectory,'teamcitymessage.matlab'));
                end
            end
            
            %% Build TeamCity message string
            if obj.TeamCityRunning
                teamcityString = ['##teamcity[', messageName, ' '];
            else
                teamcityString = ['TeamCity: ',messageName,char(10)];
            end
            if numel(varargin)/2~=round(numel(varargin)/2)
                for ivararg = 1:length(varargin)
                    teamcityString = cat(2,teamcityString,' = ',varargin{ivararg},', ');
                end
            else
                for ivararg = 1:2:length(varargin)
                    tmpstring = varargin{ivararg+1};
                    if obj.TeamCityRunning
                        %% Remove hyperlinks from messages
                        id1 = unique(cat(2,strfind(tmpstring,'<a href'),strfind(tmpstring,'</a')));
                        id2 = strfind(tmpstring,'>');
                        for ii = length(id1):-1:1
                            tmpstring(id1(ii):min(id2(id2>id1(ii)))) = [];
                        end
                        %% Replace TeamCity characters
                        tmpstring = strrep(tmpstring,'|','||');
                        tmpstring = strrep(tmpstring,char(10),'|n');
                        tmpstring = strrep(tmpstring,']','|]');
                        tmpstring = strrep(tmpstring,'\n','|n');
                        tmpstring = strrep(tmpstring,'''','|''');
                    end
                    %% Concatenate the current property value pair
                    if obj.TeamCityRunning
                        teamcityString = cat(2,teamcityString,varargin{ivararg},'=''', tmpstring,'''',' ');
                    else
                        teamcityString = cat(2,teamcityString,'* ',varargin{ivararg},' = ', tmpstring,char(10));
                    end
                end
            end
            
            if obj.TeamCityRunning
                %% Write the string to a temp file
                % This is necessary to prevent TeamCity from echoing before we finished writeing the
                % messagefile
                teamcityString = cat(2,teamcityString,']');
                dlmwrite(fullfile(obj.WorkDirectory,'teamcitymessage.matlabtemp'),...
                    teamcityString,...
                    'delimiter','','-append');
                movefile(fullfile(obj.WorkDirectory,'teamcitymessage.matlabtemp'),...
                    fullfile(obj.WorkDirectory,'teamcitymessage.matlab'));
            else
                %% Display message to command widow:
                disp(teamcityString);
            end
        end
        function options = publishoptions(varargin)
            options = [];
            obj = TeamCity;
            if obj.TeamCityRunning
                currentTest = obj.CurrentTest;
                if ~isempty(currentTest)
                    options = struct(...
                        'stylesheet',currentTest.stylesheet,...
                        '',currentTest.maxwidth,...
                        '',currentTest.maxheight,...
                        '',currentTest);
                end
            end
        end
        function publishdescription(varargin)
            mt = TeamCity.currenttest;
%             mt.publishdescription(...
%                 'outputfile',fullfile(TeamCity.OutputDir,'');
        end
        function publishresult(varargin)
            mt = TeamCity.currenttest;
%             mt.publishresult(...
%                 'outputfile',fullfile(TeamCity.OutputDir,'');
        end
        function starttimer(varargin)
            tc = TeamCity;
            tc.Timer = tic;
        end
        function stoptimer(varargin)
            tc = TeamCity;
            if isempty(tc.Timer)
                return;
            end
            
            mt = tc.CurrentTest;
            if ~isempty(mt)
                mt.Time = toc(tc.Timer);
            end
        end
        function obj = currenttest()
            tc = TeamCity;
            obj = tc.CurrentTest;
        end
        function collectprofilerinfo()
            mt = TeamCity.currenttest;
            mt.ProfilerInfo = profile('info');
        end
    end
    methods (Static = true, Hidden = true)
        function destroy()
            % DESTROY deletes the stored object and therefore all stored information
            if isappdata(0,'MTestTeamCityObject')
                rmappdata(0,'MTestTeamCityObject');
            end
        end
    end
end