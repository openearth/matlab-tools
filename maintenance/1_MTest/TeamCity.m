classdef TeamCity < handle
    properties
        CurrentTest
        TeamCityRunning = false;
        WorkDirectory = cd;
        Publish = false;
        PublishDirectory = fullfile(cd,'TeamcityPublish');
        Timer
        CurrentWorkSpace
    end
    methods
        function obj = TeamCity()
            % add to appliction data (or retrieve if it is already there)
            if isappdata(0,'MTestTeamCityObject')
                obj = getappdata(0,'MTestTeamCityObject');
            else
                setappdata(0,'MTestTeamCityObject',obj);
            end
            %% Lock the teamcity file
%             mlock;
        end
    end
    methods (Static = true)
        function value = publish(varargin)
            tc = TeamCity;
            if nargin > 0
                tc.Publish = varargin{1};
            end
            value = tc.Publish;
        end
        function answer = running(varargin)
            tc = TeamCity;
            if nargin > 0
                tc.TeamCityRunning = varargin{1};
            end
            answer = tc.TeamCityRunning;
        end
        function obj = currenttest()
            tc = TeamCity;
            obj = tc.CurrentTest;
        end
        function ignore(ignoreMessage)
            %% Retrieve TeamCity object
            obj = TeamCity;
                        
            %% find ignore message
            if nargin==0
                ignoreMessage = '';
            end
            
            %% Retrieve current test
            currentTest = obj.CurrentTest;
            
            %% Post ignore message
            if ~isempty(currentTest)
                %% Set test properties
                currentTest.Ignore = true;
                currentTest.IgnoreMessage = ignoreMessage;
                %% Post TeamCity message
                TeamCity.postmessage('testIgnored','name',currentTest.Name,'message',currentTest.IgnoreMessage);
                if currentTest.Verbose
                    disp(['     Test Ignored: ' currentTest.IgnoreMessage]);
                end
            else
                disp(['     Test Ignored: ' ignoreMessage]);
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
            if ~obj.TeamCityRunning
                return;
            end
            
            %% Check whether we still have an outstanding message
            h = tic;
            while exist(fullfile(obj.WorkDirectory,'teamcitymessage.matlab'),'file')
                pause(0.001);
                if toc(h) > 0.1 % Give teamcity som time to read the file
                    delete(fullfile(obj.WorkDirectory,'teamcitymessage.matlab'));
                end
            end
            
            %% Build TeamCity message string
            teamcityString = ['##teamcity[', messageName, ' '];
            if numel(varargin)==1
                teamcityString = cat(2,teamcityString,' ''',varargin{1},'''');
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
                    teamcityString = cat(2,teamcityString,varargin{ivararg},'=''', tmpstring,'''',' ');
                end
            end
            
            %% Write the string to a temp file
            % This is necessary to prevent TeamCity from echoing before we finished writeing the
            % messagefile
            teamcityString = cat(2,teamcityString,']');
            dlmwrite(fullfile(obj.WorkDirectory,'teamcitymessage.matlabtemp'),...
                teamcityString,...
                'delimiter','','-append');
            movefile(fullfile(obj.WorkDirectory,'teamcitymessage.matlabtemp'),...
                fullfile(obj.WorkDirectory,'teamcitymessage.matlab'));
        end
        function publishdescription(varargin)
            profile off
            tc = TeamCity;
            mt = TeamCity.currenttest;
            if tc.Publish && mt.Publish && ~isdir(tc.PublishDirectory)
                mkdir(tc.PublishDirectory);
            end
            if nargin < 1
                error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function as first input argument');
            end
            functionname = varargin{1};
            varargin{1} = [];
            
            evalin('caller','TeamCity.storeworkspace;');
            if tc.Publish && mt.Publish
                mt.publishdescription(functionname,...
                    'outputdir',tc.PublishDirectory,...
                    varargin{:});
            else
                mt.evaluatedescription(functionname);
            end
            evalin('caller','TeamCity.restoreworkspace;');
            profile on
        end
        function publishresult(varargin)
            profile off
            tc = TeamCity;
            mt = TeamCity.currenttest;
            if tc.Publish && mt.Publish && ~isdir(tc.PublishDirectory)
                mkdir(tc.PublishDirectory);
            end
            if nargin < 1
                error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function as first input argument');
            end
            functionname = varargin{1};
            varargin{1} = [];
            
            evalin('caller','TeamCity.storeworkspace;');
            if tc.Publish && mt.Publish
                % We assume there is no testcode after publication....?
                mt.publishresult(functionname,...
                    'outputdir',tc.PublishDirectory,...
                    varargin{:});
            end
            profile on
        end
    end
    methods (Static = true, Hidden = true)
        function category(category)
            %% Give Category name
            obj = TeamCity;
            currentTest = obj.CurrentTest;
            if ~isempty(currentTest)
                currentTest.Category = category;
            end
        end
        function name(proposedname)
            obj = TeamCity;
            currentTest = obj.CurrentTest;
            if ~isempty(currentTest)
                if obj.TeamCityRunning
                    %% Set test properties
                    if ~strcmp(currentTest.Name,proposedname)
                        return;
                        % TODO give warning
                    end
                else
                    currentTest.Name = proposedname;
                end
            end
        end
        function storeworkspace()
            varnames = evalin('caller','whos;');
            obj = TeamCity;
            obj.CurrentWorkSpace = {};
            for ivarnames = 1:length(varnames)
                varname = varnames(ivarnames).name;
                try
                    varvalue = evalin('caller',varname);
                    obj.CurrentWorkSpace(ivarnames,1:2) = {varname,varvalue};
                catch
                    % don't mind, this is probably a nested function that has predeclared variables
                    % that are not defined yet
                end
            end
        end
        function restoreworkspace()
            tc = TeamCity;
            evalin('caller','clear;');
            for ivars = 1:size(tc.CurrentWorkSpace,1)
                assignin('caller',tc.CurrentWorkSpace{ivars,1},tc.CurrentWorkSpace{ivars,2});
            end
        end
        function destroy()
            % DESTROY deletes the stored object and therefore all stored information
            if isappdata(0,'MTestTeamCityObject')
                rmappdata(0,'MTestTeamCityObject');
            end
        end
    end
end