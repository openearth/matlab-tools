classdef mtestdefinitionblock < handle
    
    properties
        name = [];                      % Name of the test
        
        functionheader = '';                % Header of the test(case) function (first line)
        functionname = '';                  % Name of the test(case) function
        functionoutputname = '';            % Name of 1x1 output boolean
        
        descriptioncode = {};                   % Code that was included in the testfile description cell
        descriptionincludecode = false;     % Attribute IncludeCode for publishing the description cell
        descriptionevaluatecode = true;     % Attribute EvaluateCode for publishing the description cell
        
        runcode = {};                       % Code that was included in the testfile RunTest cell
        
        publishcode = {};                   % Code that was included in the testfile TestResults cell
        publishincludecode = false;         % Attribute IncludeCode for publishing the TestResults cell
        publishevaluatecode = true;         % Attribute EvaluateCode for publishing the TestResults cell
        
        publish = true;                     % Determines whether test results, coverage and description are published to html
        % TODO implement the publish property
        
        ignore = false;                     % If ignore = true, this test is ignored
        ignoremessage = '';                 % Optional string to point out why this test(case) was ignored
        category = 'unit';                  % Category of the test(case)
    end
    properties (Hidden = true)
        fulldefinitionstring = {};
    end
    
    methods
        function obj = mtestdefinitionblock(str)
            if nargin == 0
                return
            end
            obj.fulldefinitionstring = str;
            obj.interpretDefinitionBlock;
        end
        function interpretDefinitionBlock(obj)
            
            %% Retrieve the definition block string from the object
            str = obj.fulldefinitionstring;
            
            %% Retrieve function properties
            if strncmp(str{1},'function',8)
                obj.functionheader = str{1};
                functioncall = strtrim(obj.functionheader(strfind(obj.functionheader,'=')+1:end));
                str(1) = [];
                
                % name of the testcase subfunction
                tmp = strfind(functioncall,'(');
                if isempty(tmp)
                    tmp = length(functioncall)+1;
                end
                % find the name of the testcase function in the base workspace code
                obj.functionname = functioncall(1:tmp-1);
                
                % This is a testcase, so remove the trailing end
                endid = find(~cellfun(@isempty,str),1,'last');
                if strncmp(str{endid},'end',3)
                    str(endid:end)=[];
                end
            end
            %% Retrieve name
            if any(~cellfun(@isempty,regexpi(str,'% Name(''')))
                idName = find(~cellfun(@isempty,regexpi(str,'% Name(''')),1,'first');
                namestatement = str{idName};
                obj.name = namestatement(min(strfind(namestatement,'('''))+2 : max(strfind(namestatement,''')'))-1);
                str(idName)=[];
            end
            
            %% Retrieve category
            if any(~cellfun(@isempty,regexpi(str,'% Category(''')))
                idCategory = find(~cellfun(@isempty,regexpi(str,'% Category(''')),1,'first');
                categorystatement = str{idCategory};
                obj.category = categorystatement(min(strfind(categorystatement,'('''))+2 : max(strfind(categorystatement,''')'))-1);
                str(idCategory)=[];
            end
            
            %% Look for an ignore statement
            obj.ignore = any(~cellfun(@isempty,regexpi(str,'% Ignore')));
            if obj.ignore
                idIgnore = find(~cellfun(@isempty,regexpi(str,'% Ignore')),1,'first');
                ignorestatement = str{idIgnore};
                obj.ignoremessage = ignorestatement(min(strfind(ignorestatement,'('''))+2 : max(strfind(ignorestatement,''')'))-1);
                str(idIgnore)=[];
            end
    
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
            celldividers = sort(cat(1,iddescr,idrun,idpublish,length(str)+1));
            
            %% Analyse the definition
            idused = false(size(str));
            if sum(~isnan(celldividers))>=2
                %% Isolate description
                if ~isnan(iddescr)
                    %% header
                    descrheader = str{iddescr};
                    %% body
                    idend = min(celldividers(celldividers>iddescr))-1;
                    descstr = str(iddescr+1:idend);
                    
                    %% store body information
                    obj.descriptioncode = descstr;
                    obj.descriptionincludecode = false;
                    obj.descriptionevaluatecode = true;
                    idused(iddescr:idend) = true;
                    
                    %% isolate attributes
                    attributes = strread(descrheader(strfind(descrheader,'(')+1:strfind(descrheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'name'
                                obj.name = attrinfo{2};
                            case 'includecode'
                                obj.descriptionincludecode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                obj.descriptionevaluatecode = eval(strrep(attrinfo{2},'''',''));
                            case 'category'
                                obj.category = attrinfo{2};
                        end
                    end
                end
                
                %% Isolate Run Codes
                if ~isnan(idrun)
                    %% body
                    idend = min(celldividers(celldividers>idrun))-1;
                    obj.runcode = str(idrun+1:idend);
                end
                
                %% Isolate publish codes
                if ~isnan(idpublish)
                    %% header
                    publishheader = str{idpublish};
                    %% body
                    idend = min(celldividers(celldividers>idpublish))-1;
                    publishstr = str(idpublish+1:idend);
                    
                    %% store body
                    obj.publishcode = publishstr;
                    obj.publishincludecode = false;
                    obj.publishevaluatecode = true;
                    idused(idpublish:idend) = true;
                    
                    %% isolate attributes
                    attributes = strread(publishheader(strfind(publishheader,'(')+1:strfind(publishheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'name'
                                obj.name = attrinfo{2};
                            case 'includecode'
                                obj.publishincludecode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                obj.publishevaluatecode = eval(strrep(attrinfo{2},'''',''));
                            case 'category'
                                obj.category = attrinfo{2};
                        end
                    end
                end
            end
            
            %% Some fallback options in case this routine could not read the definition
            if isnan(idrun) && isempty(str)
                %% There is no code specified
                warning('Mtest:NoRunCode','No runcode defined...');
            elseif isnan(idrun)
                if any(~idused)
                    %% Take all unused code and past it as runcode
                    obj.runcode = str(~idused);
                else
                    %% set test to ignore and give message
                    obj.ignore = true;
                    obj.ignoremessage = 'No run code in definition.';
                end
            else
                %% We do have a runcode, lets just try that
                % This occurs when we only specify a $Run section.
                tempid =  min(celldividers(celldividers>idrun));
                % runcode
                obj.runcode = str(idrun+1:tempid-1);
            end
        end
    end
end