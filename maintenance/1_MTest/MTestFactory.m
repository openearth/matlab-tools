classdef MTestFactory
    properties
        Category = TestCategory.Unit;
    end
    
    methods (Static = true)
        function newTest = createtest(varargin)
            newTest = MTest;
            %% Check whether there is any input
            if nargin == 0
                % give warning
                return
            end
            
            varargin = MFileFactory.readmfile(newTest,varargin{:});
            
            %% Read test definition
            newTest = MTestFactory.updatetest(newTest,varargin{:});
        end
        function newTest = updatetest(newTest,varargin)
            %% Retrieve full definition string
            newTest = MTestFactory.resetstringids(newTest);
            
            %% Split definition string
            newTest = MTestFactory.splitdefinitionstring(newTest);
            
            %% Interpret Header
            newTest = MTestFactory.interpretheader(newTest);
            
            %% find category
            newTest = MTestFactory.findcategory(newTest);
            
            %% Apply other input
            newTest = MTestUtils.setproperty(newTest,varargin{:});
            
            if isempty(newTest.Name)
                newTest.Name = newTest.FileName;
            end
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
        function obj = findcategory(obj)
            testCode = obj.FullString(~obj.IDOetHeaderString);
            id = find(~cellfun(@isempty,strfind(testCode,'MTestCategory.')),1,'first');
            if any(id)
                obj = MTestFactory.subtractcategoryfromcommand(obj,testCode{id});
            end
            
            if isempty(obj.Category)
                mTestFactory = MTestFactory;
                obj.Category = mTestFactory.Category;
            end
        end
        function obj = subtractcategoryfromcommand(obj,command)
            idbegin = strfind(command,'MTestCategory.');
            idend = max([strfind(command,';'), length(command)]);
            if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                try
                    obj.Category = eval(command(idbegin:idend));
                catch me
                    warning('MTestFactory:UnableToSetCategory',['MTestFactory was not able to set the category.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                end
            end
        end
        function obj = findname(obj)
            obj.Name = obj.FileName;
            
            testCode = obj.FullString(~obj.IDOetHeaderString);
            id = find(...
                ~cellfun(@isempty,strfind(testCode,'TeamCity.name')) | ...
                ~cellfun(@isempty,strfind(testCode,'MTest.name')) ...
                 ,1,'first');
            if any(id)
                command = testCode{id};
                idbegin = strfind(command,'MTest.name(')+11;
                if isempty(idbegin)
                    idbegin = strfind(command,'TeamCity.name(')+14;
                end
                idend = max(strfind(command,')'))-1;
                if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                    try
                        obj.Name = eval(command(idbegin:idend));
                    catch me
                        warning('MTestFactory:UnableToSetName',['MTestFactory was not able to set the name of the test.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                    end
                end
            end
        end
     end
end
