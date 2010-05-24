classdef MTestFactory
    properties
        MaxWidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        MaxHeight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        StyleSheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
        Category = 'Unit';
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
            
            %% Retrieve full definition string
            newTest = MTestFactory.retrievestringfromdefinition(newTest);
            newTest = MTestFactory.resetstringids(newTest);
            
            %% Split definition string
            newTest = MTestFactory.splitdefinitionstring(newTest);
            
            %% Interpret Header
            newTest = MTestFactory.interpretheader(newTest);
            
            %% Identify Definition Blocks
            newTest = MTestFactory.splitdefinitionblocks(newTest);
            
            %% Search for Category and Name
            newTest = MTestFactory.findcatagory(newTest);
            newTest = MTestFactory.findname(newTest);
            
            %% Apply other input
            newTest = setproperty(newTest,varargin{:});
            
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
        end
        function obj = resetstringids(obj)
            idBase = false(numel(obj.FullString),1);
            obj.IDTestFunction = idBase;
            obj.IDOetHeaderString = idBase;
            obj.IDTestCode = idBase;
            obj.IDDescriptionCode = idBase;
            obj.IDRunCode = idBase;
            obj.IDPublishCode = idBase;
            obj.IDTeamCityCommands = idBase;
        end
        function obj = splitdefinitionstring(obj)
            str = strtrim(obj.FullString);
            
            %% -- find function calls
            % getcallinfo is an undocumented function and can be changed in future...
            if ~exist(fullfile(obj.FilePath,[obj.FileName '.m']),'file')
                error('MTestFactory:DefinitionFileNotFound','Definition file could not be found.');
            end
            fcncalls = getcallinfo(fullfile(obj.FilePath,[obj.FileName,'.m']));
            if datenum(version('-date')) > datenum(2010,1,1)
                mainFunction = fcncalls(cellfun(@(tp) tp == internal.matlab.codetools.reports.matlabType.Function,{fcncalls.type}));
            else
                mainFunction = fcncalls(cellfun(@(tp) strcmp(tp,'function'), {fcncalls.type}));
            end
            obj.SubFunctions = fcncalls(cellfun(@(tp) strcmp(tp,'subfunction') ,{fcncalls.type}));

            if isempty(mainFunction)
                % No function declaration. This is not a test definition
                error('MTestFactory:NoFunction','This test definition file has no function declaration. definition could not be read.');
            end
            obj.IDTestFunction = mainFunction.linemask;
            obj.IDTeamCityCommands = cellfun(@length,strfind(str,'TeamCity.')) - cellfun(@length,strfind(str,'TeamCity.running')) > 0;
            % Do not find the running command. This is often used in an if statement and therefore
            % causes an error if only the if (and not the matching end) is transferred
            obj.FunctionName = mainFunction.name;
            if strncmp(str{mainFunction.lastline},'end',3) && ~isempty(obj.SubFunctions)
                obj.IDTestFunction(mainFunction.lastline) = false;
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
                obj.IDTestCode = obj.IDTestFunction;
                obj.IDTestCode(1:find(codelines(2:end),1,'first'))=false;
                
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
                
                %% Credentials
%                 celldivisions = find(strncmp(oetTestHeaderString,'%%',2));
%                 credid = find(strncmp(oetTestHeaderString,'%% Credentials',14) | strncmp(oetTestHeaderString,'%% Copyright',12));
%                 if ~isempty(credid)
%                     %% do something with the credentials?
%                     % credend = min([length(oetTestHeaderString) celldivisions(celldivisions>credid)-1]);
%                 end
                
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
        function obj = splitdefinitionblocks(obj)
            str = repmat({''},numel(obj.FullString),1);
            str(obj.IDTestCode) = strtrim(obj.FullString(obj.IDTestCode));
            
            %% Scan definition block for a Description, RunCode and PublishResult section
            iddescr = find(~cellfun(@isempty,strfind(str,'$Description')));
            if isempty(iddescr)
                iddescr = nan;
            end
            
            idrun = find(~cellfun(@isempty,strfind(str,'$Run'))); % Also accepts RunCode
            if isempty(idrun)
                idrun = nan;
            end
            
            idpublish = find(~cellfun(@isempty,strfind(str,'$Publish'))); % Also accepts PublishResult
            if isempty(idpublish)
                idpublish = nan;
            end
            
            %% list all celldividers that separate the main definition parts
            celldividers = sort(cat(1,iddescr,idrun,idpublish,find(obj.IDTestCode,1,'last')+1));
            
            %% Analyse the definition
            if sum(~isnan(celldividers))>=2
                %% Isolate description
                if ~isnan(iddescr)
                    %% header
                    descrheader = str{iddescr};
                    %% body
                    idend = min(celldividers(celldividers>iddescr))-1;
                    
                    %% store body information
                    obj.IDDescriptionCode(iddescr+1:idend) = obj.IDTestFunction(iddescr+1:idend) & ~obj.IDTeamCityCommands(iddescr+1:idend);
                    
                    obj.DescriptionIncludecode = false;
                    obj.DescriptionEvaluatecode = true;
                    
                    %% isolate attributes
                    attributes = strread(descrheader(strfind(descrheader,'(')+1:strfind(descrheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'name'
                                obj.Name = attrinfo{2};
                            case 'includecode'
                                obj.DescriptionIncludecode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                obj.DescriptionEvaluatecode = eval(strrep(attrinfo{2},'''',''));
                        end
                    end
                end
                
                %% Isolate Run Codes
                if ~isnan(idrun)
                    %% body
                    idend = min(celldividers(celldividers>idrun))-1;
                    obj.IDRunCode(idrun+1:idend) = obj.IDTestFunction(idrun+1:idend);
                end
                
                %% Isolate publish codes
                if ~isnan(idpublish)
                    %% header
                    publishheader = str{idpublish};
                    
                    %% storebody
                    idend = min(celldividers(celldividers>idpublish))-1;
                    obj.IDPublishCode(idpublish+1:idend) = obj.IDTestFunction(idpublish+1:idend);
                    obj.PublishIncludecode = false;
                    obj.PublishEvaluatecode = true;
                    
                    %% isolate attributes
                    attributes = strread(publishheader(strfind(publishheader,'(')+1:strfind(publishheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'name'
                                obj.name = attrinfo{2};
                            case 'includecode'
                                obj.PublishIncludecode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                obj.PublishEvaluatecode = eval(strrep(attrinfo{2},'''',''));
                        end
                    end
                end
            else
                %% All code is runcode
                obj.IDRunCode = obj.IDTestCode;
            end
        end
        function obj = findcatagory(obj)
            mTestFactory = MTestFactory;
            obj.Category = mTestFactory.Category;

            testCode = obj.FullString(obj.IDTestCode);
            id = find(~cellfun(@isempty,strfind(testCode,'TeamCity.category')),1,'first');
            if any(id)
                command = testCode{id};
                idbegin = strfind(command,'TeamCity.category(')+18;
                idend = max(strfind(command,')'))-1;
                if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                    try
                        obj.Category = eval(command(idbegin:idend));
                    catch me
                        warning('MTestFactory:UnableToSetCategory',['MTestFactory was not able to set the category.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                    end
                end
            end
            
        end
        function obj = findname(obj)
            obj.Name = obj.FileName;
            
            testCode = obj.FullString(obj.IDTestCode);
            id = find(~cellfun(@isempty,strfind(testCode,'TeamCity.name')),1,'first');
            if any(id)
                command = testCode{id};
                idbegin = strfind(command,'TeamCity.name(')+14;
                idend = max(strfind(command,')'))-1;
                if ~isempty(idbegin) && ~isempty(idend) && idend > idbegin
                    try
                        obj.Name = eval(command(idbegin:idend));
                    catch me
                        warning('MTestFactory:UnableToSetCategory',['MTestFactory was not able to set the category.';'The following exeption was thrown when evaluating the input:';me.getReport]);
                    end
                end
            end
            
        end
    end
end
