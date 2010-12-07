classdef MFunctionFileFactory
    %MFUNCTIONFILEFACTORY  One line description goes here.
    %
    %   More detailed description goes here.
    %
    %   See also MFunctionFileFactory.MFunctionFileFactory
    
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
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: 03 Dec 2010
    % Created with Matlab version: 7.11.0.584 (R2010b)
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: $
    
    %% Methods
    methods (Static)
        function argsOut = readfunctionfile(mFunctionFile,varargin)
            %MFUNCTIONFILEFACTORY  One line description goes here.
            %
            %   More detailed description goes here.
            %
            %   Syntax:
            %   this = MFunctionFileFactory(varargin)
            %
            %   Input:
            %   varargin  =
            %
            %   Output:
            %   this       = Object of class "MFunctionFileFactory"
            %
            %   Example
            %   MFunctionFileFactory
            %
            %   See also MFunctionFileFactory
            
            argsOut = MFileFactory.readmfile(mFunctionFile,varargin{:});
            
            MFunctionFileFactory.updatefunction(mFunctionFile);
        end
        function updatefunction(mFunctionFile)
            %% Retrieve full definition string
            MTestFactory.resetstringids(mFunctionFile);
            
            %% Split definition string
            MTestFactory.splitdefinitionstring(mFunctionFile);
            
            %% Interpret Header
            MTestFactory.interpretheader(mFunctionFile);
            
        end
    end
    methods (Static = true, Hidden = true)
        function obj = resetstringids(obj)
            obj.IDOetHeaderString = false(numel(obj.FullString),1);
        end
        function obj = splitdefinitionstring(obj)
            %% -- find function calls
            % getcallinfo is an undocumented function and can be changed in future...
            if ~exist(fullfile(obj.FilePath,[obj.FileName '.m']),'file')
                error('MTestFactory:DefinitionFileNotFound','Definition file could not be found.');
            end
            
            % ----> Be carefull, this function does not take comments into accoutn if there is no
            % runnable code at all <---------
            fcncalls = getcallinfo(fullfile(obj.FilePath,[obj.FileName,'.m']));
            %<----------------------------------------------------------------------------------->
            
            if datenum(version('-date')) > datenum(2010,1,1)
                % 2010a -->
                mainFunctionId = cellfun(@(tp) tp == internal.matlab.codetools.reports.matlabType.Function,{fcncalls.type});
            elseif datenum(version('-date')) > datenum(2009,1,1)
                % 2009a
                mainFunctionId = cellfun(@(tp) tp == codetools.reports.matlabType.Function,{fcncalls.type});
            else
                mainFunctionId = cellfun(@(tp) strcmp(tp,'function'), {fcncalls.type});
            end
            mainFunction = fcncalls(mainFunctionId);
            
            if isempty(mainFunction)
                % No function declaration. This is not a test definition
                error('MTestFactory:NoFunction','This test definition file has no function declaration. definition could not be read.');
            end
            obj.FunctionName = mainFunction.name;
            
            %% Extract name
            calls = fcncalls(mainFunctionId).calls;
            if iscell(calls)
                obj = MTestFactory.findcategory(obj);
                obj = MTestFactory.findname(obj);
            else
                dotCalls = fcncalls(mainFunctionId).calls.dotCalls;
                if ~isempty(dotCalls) && any(ismember(dotCalls.names,{'MTest.name(','TeamCity.name('}))
                    ln = min(dotCalls.lines(ismember(dotCalls.names,{'MTest.name(','TeamCity.name('})));
                    command = obj.FullString{ln};
                    idbegin = min([strfind(command,'TeamCity.name(')+14, strfind(command,'MTest.name(')+11]);
                    idend = max(strfind(command,')'))-1;
                    if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                        try
                            % TODO, Maybe set current test and run entire command?
                            obj.Name = eval(command(idbegin:idend));
                        catch me
                            warning('MTestFactory:UnableToSetName',['MTestFactory was not able to set the name of the test.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                        end
                    end
                end
                
                
                %% Exctract Category
                if ~isempty(dotCalls) && any(~cellfun(@isempty,strfind(dotCalls.names,'MTestCategory.')))
                    ln = min(dotCalls.lines(~cellfun(@isempty,strfind(dotCalls.names,'MTestCategory.'))));
                    obj = MTestFactory.subtractcategoryfromcommand(obj,obj.FullString{ln});
                end
            end
        end
        function obj = interpretheader(obj)
            teststr = repmat({''},numel(obj.FullString),1);
            teststr(~obj.IDOetHeaderString) = strtrim(obj.FullString(~obj.IDOetHeaderString));
            if ~isempty(teststr)
                comments = strncmp(teststr,'%',1);
                empties = cellfun(@isempty,teststr);
                codelines = ~(comments | empties);
                
                %% header
                id = strncmp(teststr{1},'function',8);
                if isempty(id)
                    error('MTestFactory:NoFunction','This test definition file has no function declaration. definition could not be read.');
                end
                
                obj.FunctionHeader = teststr{1};
                endid = find(codelines(2:end),1,'first');
                if isempty(endid)
                    endid = length(teststr);
                end
                beginid = 2;
                if endid == 1
                    beginid = 1;
                end
                oetTestHeaderString = teststr(beginid:endid);
                
                if ~isempty(oetTestHeaderString)
                    %% h1line
                    h1linetemp = oetTestHeaderString{1};
                    if ~strncmp(h1linetemp,'%%',2)
                        obj.H1Line = strtrim(strrep(lower(h1linetemp(find(~ismember(1:length(h1linetemp),strfind(h1linetemp,'%')),1,'first'):end)),lower(obj.FileName),''));
                        oetTestHeaderString(1) = [];
                    end
                end
                
                %% remaining helpblock
                if isempty(oetTestHeaderString)
                    return;
                end
                
                helpend = min([length(oetTestHeaderString);...
                    find(cellfun(@isempty,oetTestHeaderString),1,'first')-1;...
                    find(strncmp(oetTestHeaderString,'%%',2))-1]);
                helpblock = oetTestHeaderString(1:helpend);
                
                % see also
                % remove blanks
                helpblock = helpblock(1:find(~cellfun(@isempty,strtrim(helpblock)),1,'last'));
                % remove single % signs
                helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                
                if ~isempty(helpblock)
                    LastLengthMoreThanOne = length(helpblock{end})>1;
                    SeeAlsoReferencesPresent = strncmpi(strtrim(helpblock{end}(2:end)),'see also ',9);
                    if LastLengthMoreThanOne && SeeAlsoReferencesPresent
                        idbegin = min(strfind(lower(helpblock{end}),'see also'));
                        obj.SeeAlso = strread(strtrim(helpblock{end}(idbegin+8:end)),'%s','delimiter',' ');
                        helpblock(end)=[];
                    end
                    
                    % desciption
                    % remove single % signs
                    helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                    helpblock = helpblock(find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'first'):end);
                    obj.Description = helpblock;
                end
                oetTestHeaderString(1:helpend) = [];
                
                %% Version info
                versionid = find(strncmp(oetTestHeaderString,'%% Version',10), 1);
                if ~isempty(versionid)
                    authorid = find(strncmp(oetTestHeaderString,'% $Author:',10), 1);
                    if ~isempty(authorid)
                        % last author
                        tmpstr = oetTestHeaderString{~cellfun(@isempty,strfind(oetTestHeaderString,'$Author:'))};
                        obj.Author = strtrim(tmpstr(min(strfind(tmpstr,':'))+1:min([length(tmpstr)+1 max(strfind(tmpstr,'$'))])-1));
                    end
                end
            else
                % No runcode
                error('MTestFactory:NoTestCode','The MTestFactory could not find code to run.');
            end
        end
    end
end
