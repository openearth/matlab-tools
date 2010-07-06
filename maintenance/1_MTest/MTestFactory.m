classdef MTestFactory
    properties
        MaxWidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        MaxHeight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        StyleSheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
        Category = 'UnCategorized';
    end
    
    methods (Static = true)
        function newTest = createtest(varargin)
            newTest = MTest;
            %% Check whether there is any input
            if nargin == 0
                % give warning
                return
            end
            
            %% Retrieve filename from input
            fname = [];
            if ischar(varargin{1}) && ~strcmpi(varargin{1},'filename')
                fname = varargin{1};
                varargin(1)=[];
            else
                id = find(strcmpi(varargin,'filename'),1,'first');
                if ~isempty(id)
                    fname = varargin{id+1};
                    varargin(id:id+1) = [];
                end
            end
            
            %% split filename into parts
            [pt fn ext] = fileparts(fname);
            if isempty(ext)
                ext = '.m';
            end
            if ~strcmp(ext,'.m')
                error('MTest:NoMatlabFile','Input must be a matlab (*.m) file');
            end
            
            %% Check file existance
            if exist(fullfile(pt,[fn ext]),'file')
                if isempty(pt)
                    pt = fileparts(which([fn ext]));
                end
            else
                % if fullname does not exist, try which
                fls = which(fn,'-all');
                if length(fls)>1
                    warning('MTestFactory:MultipleFiles','Multiple files were found with the same name. The first one in the search path is taken.');
                elseif length(fls) == 1
                    % just take this file (path appears to be wrong)
                else
                    % File can not be found
                    error('MTestFactory:NoFile','Input file could not be found.');
                end
                [pt fn] = fileparts(fls{1});
            end
            newTest.FileName = fn;
            newTest.FilePath = pt;
            
            %% Read test definition
            newTest = MTestFactory.updatetest(newTest,varargin{:});
        end
        function newTest = updatetest(newTest,varargin)
            %% Retrieve full definition string
            newTest = MTestFactory.retrievestringfromdefinition(newTest);
            newTest = MTestFactory.resetstringids(newTest);
            
            %% Split definition string
            newTest = MTestFactory.splitdefinitionstring(newTest);
            
            %% Interpret Header
            newTest = MTestFactory.interpretheader(newTest);
            
            %% Apply other input
            newTest = MTestUtils.setproperty(newTest,varargin{:});
            
            if isempty(newTest.Name)
                newTest.Name = newTest.FileName;
            end
        end
        function [newTest isUpToDate] = verifytimestamp(newTest)
            isUpToDate = false;

            fullname = fullfile(newTest.FilePath, [newTest.FileName ,'.m']);
            if ~exist(fullname,'file')
                fullname = which(newTest.FileName);
                if ~exist(fullname,'file')
                    warning('MTest:DefinitionNotFound',['MTest tried to verify the timestamp of test: "' newTest.FileName '", but failed to do so because of a missing test definition']);
                    return;
                end
                warning('MTest:DefinitionMoved',['MTest could not find a file that exactly matches this test objects definition',char(10),...
                    '(' fullfile(newTest.FilePath,[newTest.FileName '.m']),char(10),'but for timestamp verification used:',char(10),...
                    fullname]);
                newTest.FilePath = fileparts(fullname);
            end
            
            fileinfo = dir(fullname);
            isUpToDate = newTest.TimeStamp == fileinfo.datenum;
        end
    end
    methods (Static = true, Hidden = true)
        function obj = retrievestringfromdefinition(obj)
            %% #1 Open the input file
            % first try full file name
            fid = fopen(fullfile(obj.FilePath,[obj.FileName '.m']));
            %% #2 Read the contents of the file
            str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
            str = str{1};
            %% #3 Close the input file
            fclose(fid);
            %% #4 Process contents of the input file
            obj.FullString = str;
            %% #5 Add timestamp
            infoo = dir(fullfile(obj.FilePath,[obj.FileName '.m']));
            obj.TimeStamp = infoo.datenum;
        end
        function obj = resetstringids(obj)
            idBase = false(numel(obj.FullString),1);
            obj.IDTestFunction = idBase;
            obj.IDOetHeaderString = idBase;
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
                mainFunctionId = cellfun(@(tp) tp == internal.matlab.codetools.reports.matlabType.Function,{fcncalls.type});
            else
                mainFunctionId = cellfun(@(tp) strcmp(tp,'function'), {fcncalls.type});
            end
            mainFunction = fcncalls(mainFunctionId);
            obj.SubFunctions = fcncalls(cellfun(@(tp) strcmp(tp,'subfunction') ,{fcncalls.type}));

            if isempty(mainFunction)
                % No function declaration. This is not a test definition
                error('MTestFactory:NoFunction','This test definition file has no function declaration. definition could not be read.');
            end
            obj.IDTestFunction = mainFunction.linemask;
            obj.FunctionName = mainFunction.name;
            
            %% Extract name
            calls = fcncalls(mainFunctionId).calls;
            if iscell(calls)
                warning('MTestFactory:UnableToSetCategory','Due to version limitations of your matlab MTest was not able to determine the name and category of your test');
                % TODO: read category manually (Look for "MTest.category(" or
                % "TeamCity.category(" and execute that line (until ");")
            else
                dotCalls = fcncalls(mainFunctionId).calls.dotCalls;
                if ~isempty(dotCalls) && any(ismember(dotCalls.names,{'MTest.name','TeamCity.name'}))
                    ln = min(dotCalls.lines(ismember(dotCalls.names,{'MTest.name','TeamCity.name'})));
                    command = obj.FullString{ln};
                    idbegin = min([strfind(command,'TeamCity.name(')+14, strfind(command,'MTest.name(')+11]);
                    idend = max(strfind(command,')'))-1;
                    if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                        try
                            % TODO, Maybe set current test and run entire command?
                            obj.Name = eval(command(idbegin:idend));
                        catch me
                            warning('MTestFactory:UnableToSetName',['MTestFactory was not able to set the category.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                        end
                    end
                end


                %% Exctract Category
                if ~isempty(dotCalls) && any(ismember(dotCalls.names,{'MTest.category','TeamCity.category'}))
                    ln = min(dotCalls.lines(ismember(dotCalls.names,{'MTest.category','TeamCity.category'})));
                    command = obj.FullString{ln};
                    idbegin = min([strfind(command,'TeamCity.category(')+18, strfind(command,'MTest.category(')+15]);
                    idend = max(strfind(command,')'))-1;
                    if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                        try
                            % TODO, Maybe set current test and run entire command?
                            obj.Category = eval(command(idbegin:idend));
                        catch me
                            warning('MTestFactory:UnableToSetCategory',['MTestFactory was not able to set the category.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                        end
                    end
                end
            end
        end
        function obj = interpretheader(obj)
            teststr = repmat({''},numel(obj.FullString),1);
            teststr(obj.IDTestFunction) = strtrim(obj.FullString(obj.IDTestFunction));
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
                oetTestHeaderString = teststr(2:find(codelines(2:end),1,'first'));
                
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
