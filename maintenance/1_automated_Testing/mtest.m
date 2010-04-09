classdef mtest < handle
    % MTEST - Object to handle tests written in mtest format
    %
    % TODO: edit help. Adjust to new format and maybe put this in the documentation
    % This objects stores the information written in an mtest format test definition file. The test
    % files consist of three parts divided by a cell break (%%). The three cells represent:
    %
    %   1.  Description of the testcase
    %   2.  Run code
    %   3.  Publish code
    %
    % Each section starts with "%% #CaseX YYYY" in wich X represents the number of the testcase and
    % YYYY is either "Description", "RunTest" or "TestResults", specifying the steps mentioned
    % above.
    %
    % Description is seen purely as documentation of the test (in other words: what do we test, how
    % do we test it and what outcome do we expect).
    %
    % The RunCode section contains code that must be executed in order to test the function (Any
    % code that was already used in the Description is executed as well. The only requirement is
    % that the code produces a variable testresult indicating whether the test was a success or
    % not).
    %
    % The TestResults section includes code that can be used to publish the results of the test. It
    % is published to html with the Matlab publish function. Any variables created in the first two
    % sections of a test (description and test run) can be used in this section. See the Matlab
    % documentation on cell formatting:
    %
    % docsearch('Formatting M-File Code for Publishing');
    %
    % See also mtest.mtest mtest.publishDescription mtest.runTest mtest.publishResults mtestengine
    
    %% Copyright notice
    %     Copyright (c) 2008  DELTARES.
    %
    %       Pieter van Geer
    %
    %       Pieter.vanGeer@deltares.nl
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
    
    %% Version <http://svnbook.red-bean.com/en/1.5/svn.advanced.props.special.keywords.html>
    % Created: $date(dd mmm yyyy)
    % Created with Matlab version: $version
    
    % $Id$
    % $Date$
    % $Author$
    % $Revision$
    % $HeadURL$
    % $Keywords: testing test unittest$
    
    %% Properties
    properties
        testname = [];                      % Name of the test
        filename = [];                      % Original name of the testfile
        filepath = [];                      % Path of the "_test.m" file
        
        header   = [];                      % Function call of the testfunction
        h1line   = [];                      % A one line description of the test (h1 line)
        description = {};                   % Detailed description of the test that appears in the help block
        author   = [];                      % Last author of the test (obtained from svn keywords)
        seealso  = {};                      % see also references
        
        descriptioncode = {};               % Description of the test (first part of the testdescription file before the start of the first testcase)
        descriptionincludecode = false;                % indicates whether the code must be included when publishing the test description
        descriptionevaluatecode = true;
        descriptionoutputfile = {};         % Name of the published output file of the description
        
        runcode  = {};
        coverageoutputfile = {};
        
        publishcode = {};                   % TODO , not included yet..
        publishincludecode = false;
        publishevaluatecode = true;
        publishoutputfile = {};
        
        testcases = mtestcase;              % mtestcases objects that contain testcase information for each individual testcase
        currentcase = [];                   % Number of the testcase that is last adressed
        
        testresult = false;                 % Boolean indicating whether the test was run successfully

        time     = 0;                       % Time that was needed to perform the test
        date     = NaN;                     % Date and time the test was performed
        profinfo = [];                      % Profile info structure
        functioncalls = [];
        
        resdir = '';                        % Directory where published files are stored
    end
    properties (Hidden = true)
        fullstring = [];                    % Full string of the contents of the test file
        tempdir = tempdir;                  % Temporary directory for publishing output files.
        eventlisteners = [];                % Listeren to event runTest of testcases
        runworkspace = [];                  % variable that can be used to store the run workspace (to allow the possibility of publishResults for a test lateron)
        rundir = [];
        tmpobjname = [];
        testperformed = false;
        
        maxwidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        maxheight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
        stylesheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
    end
    
    %% Events
    events
        TestPerformed
        RunWorkspaceSaved
    end
    
    %% Methods
    methods
        function obj = mtest(varargin)
            %mtest  Creates an mtest object from a WaveLab test definition file.
            %
            %   This function reads the contents of a WaveLab test definition file and creates an
            %   mtest object that stores all the necessary test information and results. This object
            %   can later be used to publish the description (mtest.publishDescription), run the
            %   test (mtest.runTest) or publish the testresults (mtest.publishResults).
            %
            %   Syntax:
            %   obj = mtest(filename,...);
            %   obj = mtest(...,'filename',filename);
            %   obj = mtest(...,'property','value');
            %
            %   Input:
            %   filename  = name of a file that is in the matlab search path or a full filename to
            %               the test definition file that has to be converted to an mtest object.
            %               This parameter must be entered to load a test definition.
            %
            %   Property - value pairs:
            %       descriptionoutputfile   -   Name of the html output file created when publishing
            %                                   the description of the test.
            %       includecode             -   TODO
            %       evaluatecode            -   TODO
            %
            %   Output:
            %   obj - mtest object
            %
            %
            %   See also mtest mtest.runTest mtest.publishDescription mtest.publishResults mtestengine mtestcase
            
            %% Check whether there is any input
            if nargin == 0
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
            %% Set other properties that are defined in the input
            if ~isempty(varargin)
                propstoset = {'descriptionoutputfile','publishoutputfile','testname'};
                propsid = 1:2:length(varargin);
                memid = ismember(varargin(propsid),propstoset);
                for im = 1:length(memid)
                    prop = varargin{propsid(im)};
                    if ~memid(im)
                        warning('MTest:NoProperty',['The property "' prop '" could not be found or set.']);
                    else
                        obj.(prop) = varargin{propsid(im)+1};
                    end
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
            %% #1 Open the input file
            % first try full file name
            if exist(fullfile(pt,[fn ext]),'file')
                fid = fopen(fullfile(pt,[fn ext]));
                if isempty(pt)
                    pt = fileparts(which([fn ext]));
                end
            else
                % if fullname does not exist, try which
                fls = which(fn,'-all');
                if length(fls)>1
                    warning('MTest:MultipleFiles','Multiple files were found with the same name. The first one in the search path is taken.');
                    fid = fopen(fls{1});
                elseif length(fls) == 1
                    fid = fopen(fls{1});
                else
                    % which didn't work either. File can not be
                    % found
                    error('MTest:NoFile','Input file could not be found.');
                end
                [pt fn] = fileparts(fls{1});
            end
            %% #2 Read the contents of the file
            str = fread(fid,'*char')';
            str = strread(str,'%s','delimiter',char(10));
            %% #3 Close the input file
            fclose(fid);
            %% #4 Process contents of the input file
            str = strtrim(str);
            obj.filename = fn;
            obj.filepath = pt;
            obj.fullstring = str;
            %% -- find function calls
            fcnid = find(strncmp(str,'function ',9));
            endid = find(strcmp(str,'end') | strncmp(str,'end ',4) | strncmp(str,'end%',4) | strncmp(str,'end...',6));
            
            % Create temp testcase struct
            testcasesstruct = struct(...
                'fullstring',[],...
                'functioncall',[],...
                'functionname',[],...
                'fullfunctioncall',[],...
                'functionoutputname',[],...
                'initcode',[],...
                'baseruncode',[],...
                'inputneeded',[],...
                'caseNumber',[],...
                'caseName',[],...
                'description',[],...
                'descrIncludeCode',[],...
                'descrEvaluateCode',[],...
                'runcode',[],...
                'publishcode',[],...
                'publishIncludeCode',[],...
                'publishEvaluateCode',[]);
            %% -- Divide info string
            if length(fcnid)>1
                %% subtract testinfo
                teststr = str(1:max(endid(endid<min(fcnid(fcnid>1))))-1);                
                %% seperate full strings of testcases
                fcnid = cat(1,fcnid,length(str)+1);
                for icase = 1:length(fcnid)-2
                    testcasesstruct(icase).fullstring = str(fcnid(icase+1):max(endid(endid<fcnid(icase+2))));
                end
            elseif length(fcnid)==1
                %% subtract testinfo
                teststr = str(fcnid:end);
                testcasesstruct = [];
            else
                teststr = str;
                testcasesstruct = [];
            end
            %% -- Process test information
            % Read test specifications
            % testname
            % h1line
            % description
            % see also
            % last author
            % publishdescription
            % runcode
            
            if ~isempty(teststr)
                comments = strncmp(teststr,'%',1);

                % header
                id = strfind(teststr{1},'function');
                if ~comments(1) && ~isempty(id)
                    obj.header = teststr{1};
                    teststr(1)=[];
                    comments(1)=[];
                end
                
                % h1line
                if comments(1)
                    h1linetemp = teststr{1};
                    obj.h1line = strtrim(strrep(lower(h1linetemp(find(~ismember(1:length(h1linetemp),strfind(h1linetemp,'%')),1,'first'):end)),lower(fn),''));
                    teststr(1)=[];
                    comments(1)=[];
                end
                
                % remaining helpblock
                idcommend = min([find((~comments),1,'first') find(strncmp(teststr,'%% ',3),1,'first')]);
                if ~isempty(idcommend) && idcommend > 1
                    helpblock = teststr(1:idcommend-1);
                    teststr(1:idcommend-1)=[];
                    comments(1:idcommend-1)=[];
                    
                    % see also
                    % remove blanks
                    helpblock = helpblock(1:find(~cellfun(@isempty,strtrim(helpblock)),1,'last'));
                    % remove single % signs
                    helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                    
                    LastLengthMoreThanOne = length(helpblock{end})>1;
                    SeeAlsoReferencesPresent = strncmpi(strtrim(helpblock{end}(2:end)),'see also ',9);
                    if LastLengthMoreThanOne && SeeAlsoReferencesPresent
                        idbegin = min(strfind(lower(helpblock{end}),'see also'));
                        obj.seealso = strread(strtrim(helpblock{end}(idbegin+8:end)),'%s','delimiter',' ');
                        helpblock(end)=[];
                    end
                    
                    % desciption
                    % remove single % signs
                    helpblock = helpblock(1:find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'last'));
                    helpblock = helpblock(find(cellfun(@length,helpblock)>1 & strncmp(helpblock,'%',1),1,'first'):end);
                    obj.description = helpblock;
                end
                
                % Credentials 
                credid = find(strncmp(teststr,'%% Credentials',14) | strncmp(teststr,'%% Copyright',12));
                if ~isempty(credid)
                    credend = find(~comments);
                    credend = min(credend(credend>credid));
%                     credentialstr = teststr(credid:credend);
                    teststr(credid:credend)=[];
                    comments(credid:credend)=[];
                end
                
                % Version info
                versionid = find(strncmp(teststr,'%% Version',10));
                if ~isempty(versionid)
                    authorid = find(strncmp(teststr,'% $Author:',10), 1);
                    versionend = find(~comments)-1;
                    if ~isempty(authorid)
                        % last author
                        tmpstr = teststr{~cellfun(@isempty,strfind(teststr,'$Author:'))};
                        obj.author = strtrim(tmpstr(min(strfind(tmpstr,':'))+1:min([length(tmpstr)+1 max(strfind(tmpstr,'$'))])-1));
                        versionend = min(versionend(versionend>authorid));
                    else
                        versionend = min(versionend(versionend>versionid));
                    end
%                     versionstr = teststr(1:versionend);
                    teststr(1:versionend)=[];
%                     comments(1:versionend)=[];
                end
                
                iddescr = find(~cellfun(@isempty,strfind(teststr,'$Description')));
                if isempty(iddescr)
                    iddescr = nan;
                end
                idrun = find(~cellfun(@isempty,strfind(teststr,'$RunCode')));
                if isempty(idrun)
                    idrun = nan;
                end
                idpublish = find(~cellfun(@isempty,strfind(teststr,'$PublishResult')));
                if isempty(idpublish)
                    idpublish = nan;
                end
                clls = [iddescr, idrun, idpublish length(teststr)+1];
                                
                if sum(~isnan(clls))<2
                    obj.runcode = teststr;
                else
                    idused = false(size(teststr));
                    if ~isnan(iddescr)
                        tempid = min(clls(clls>iddescr));
                        % publishdescription
                        obj.descriptioncode = teststr(iddescr+1:tempid-1);
                        idused(iddescr:tempid-1) = true;
                        
                        % test attributes (Name, IncludeCode, EvaluateCode)
                        testdeclaration = strtrim(teststr{iddescr});
                        attrid = [min(strfind(testdeclaration,'('))+1, length(testdeclaration)-1];
                        if length(attrid)==2 && ~strcmp(testdeclaration(end),')')
                            disp('Attributes could be wrong..');
                            attrid = [strfind(testdeclaration,'(')+1, length(testdeclaration)];
                        end
                        if length(attrid)==2
                            attributes = strread(testdeclaration(attrid(1):attrid(2)),'%s','delimiter','&');
                            attr = {'name','includecode','evaluatecode'};
                            objname = {'name','descriptionincludecode','descriptionevaluatecode'};
                            for iattr = 1:length(attributes)
                                attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                                if ismember(lower(attrinfo{1}),attr)
                                    if strcmpi(attrinfo{1},'name')
                                        obj.testname = attrinfo{2};
                                    else
                                        obj.(objname{strcmpi(attrinfo{1},attr)}) = eval(strrep(attrinfo{2},'''',''));
                                    end
                                end
                            end
                        end
                    end
                    
                    if ~isnan(idpublish)
                        tempid = min(clls(clls>idpublish));
                        % publishdescription
                        obj.publishcode = teststr(idpublish+1:tempid-1);
                        idused(idpublish:tempid-1) = true;
                        
                        % attributes (IncludeCode, EvaluateCode)
                        publishheader = strtrim(teststr{idpublish});
                        attrid = [min(strfind(publishheader,'('))+1, length(publishheader)-1];
                        if length(attrid)==2 && ~strcmp(publishheader(end),')')
                            disp('Attributes could be wrong..');
                            attrid = [strfind(publishheader,'(')+1, length(publishheader)];
                        end
                        if length(attrid)==2
                            attributes = strread(publishheader(attrid(1):attrid(2)),'%s','delimiter','&');
                            attr = {'name','includecode','evaluatecode'};
                            objname = {'name','publishincludecode','publishevaluatecode'};
                            for iattr = 1:length(attributes)
                                attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                                if ismember(lower(attrinfo{1}),attr)
                                    if strcmpi(attrinfo{1},'name')
                                        obj.testname = attrinfo{2};
                                    else
                                        obj.(objname{strcmpi(attrinfo{1},attr)}) = eval(strrep(attrinfo{2},'''',''));
                                    end
                                end
                            end
                        end
                    end
                    
                    if isnan(idrun) && isempty(teststr)
                        warning('Mtest:NoRunCode','No runcode defined...');
                        % build runcode for all testcases. Todo if testcases are ready.
                    elseif isnan(idrun)
                        obj.runcode = teststr(~idused);
                    else
                        tempid =  min(clls(clls>idrun));
                        % runcode
                        obj.runcode = teststr(idrun+1:tempid-1);
                    end
                end
            else
                % No runcode as well
                obj.testname = obj.filename;
                obj.descriptioncode = {'% This test still has no general description. This can be placed on the first lines of the test description file (*_test.m).'};
            end
            %% -- Process testcases
            for icase = 1:length(testcasesstruct)
                str = testcasesstruct(icase).fullstring(2:end-1);
                
                testcasesstruct(icase).fullfunctioncall = testcasesstruct(icase).fullstring{1};
                testcasesstruct(icase).functioncall = strtrim(testcasesstruct(icase).fullstring{1}(strfind(testcasesstruct(icase).fullstring{1},'=')+1:end));
                % name of the testcase subfunction
                tmp = strfind(testcasesstruct(icase).functioncall,'(');
                if isempty(tmp)
                    tmp = length(testcasesstruct(icase).functioncall)+1;
                end
                % find the name of the testcase function in the base workspace code
                testcasesstruct(icase).functionname = testcasesstruct(icase).functioncall(1:tmp-1);
                testcasesstruct(icase).functionoutputname = mtest.argsinname(testcasesstruct(icase).fullfunctioncall,testcasesstruct(icase).functionname);
                
                % First find the celldividers between the description parts, the runtTest parts and the Publish part
                descrid = find(~cellfun(@isempty,strfind(str,'$Description')));
                runcodeid = find(~cellfun(@isempty,strfind(str,'$RunCode')));
                publishcodeid = find(~cellfun(@isempty,strfind(str,'$PublishResult')));
                
                % Error if there is no RunTest part (test code)
                if isempty(runcodeid)
                    continue
                    %                     error('MTest:NoTestDefinition',['The specified testcase (' strrep(fullfile(obj.filepath,[obj.filename '.m']),filesep,'/') ') does not contain a test definition cell']);
                end
                
                % list all celldividers that separate important parts
                celldividers = sort(cat(1,descrid,runcodeid,publishcodeid,length(str)+1));
                
                testcasesstruct(icase).caseNumber = icase;
                %% Isolate description
                if ~isempty(descrid)
                    % header
                    descrheader = str{descrid};
                    % body
                    idend = min(celldividers(celldividers>descrid))-1;
                    descstr = str(descrid+1:idend);
                    
                    % store body information
                    testcasesstruct(icase).description = descstr;
                    testcasesstruct(icase).descrIncludeCode = false;
                    testcasesstruct(icase).descrEvaluateCode = true;
                    
                    % isolate attributes
                    attributes = strread(descrheader(strfind(descrheader,'(')+1:strfind(descrheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'name'
                                testcasesstruct(icase).caseName = attrinfo{2};
                            case 'includecode'
                                testcasesstruct(icase).descrIncludeCode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                testcasesstruct(icase).descrEvaluateCode = eval(strrep(attrinfo{2},'''',''));
                        end
                    end
                end
                
                %% Isolate Run Codes
                if ~isempty(runcodeid)
                    % body
                    idend = min(celldividers(celldividers>runcodeid))-1;
                    testcasesstruct(icase).runcode = str(runcodeid+1:idend);
                else
                    %                     error('MTest:NoTestDefinition',['The specified testcase (' strrep(fullfile(obj.filepath,[obj.filename '.m']),filesep,'/') ') does not contain a test definition cell']);
                end
                
                %% Isolate publish codes
                if ~isempty(publishcodeid)
                    % header
                    publishheader = str{publishcodeid};
                    % body
                    idend = min(celldividers(celldividers>publishcodeid))-1;
                    publishstr = str(publishcodeid+1:idend);
                    
                    % store body
                    testcasesstruct(icase).publishcode = publishstr;
                    testcasesstruct(icase).publishIncludeCode = false;
                    testcasesstruct(icase).publishEvaluateCode = true;
                    
                    % isolate attributes
                    attributes = strread(publishheader(strfind(publishheader,'(')+1:strfind(publishheader,')')-1),'%s','delimiter','&');
                    for iattr = 1:length(attributes)
                        attrinfo = strtrim(strread(attributes{iattr},'%s','delimiter','='));
                        switch lower(attrinfo{1})
                            case 'includecode'
                                testcasesstruct(icase).publishIncludeCode = eval(strrep(attrinfo{2},'''',''));
                            case 'evaluatecode'
                                testcasesstruct(icase).publishEvaluateCode = eval(strrep(attrinfo{2},'''',''));
                        end
                    end
                end
            end
            %% -- check runcode
            % fill if it is empty (should not be necessary)
            if isempty(obj.runcode)
                tmp = '';
                for icase = 1:length(testcasesstruct)
                    tmp = cat(2,tmp,'tr(', num2str(icase), ') = ', testcasesstruct(icase).functioncall, ';', char(10));
                end
                tmp = cat(2,tmp,'testresult = all(tr);');
                obj.runcode = tmp;
            end
            
            if ischar(obj.runcode)
                obj.runcode = strread(obj.runcode,'%s',-1,'delimiter',char(10));
            end
            rncode = sprintf('%s\n',obj.runcode{~strncmp(obj.runcode,'%',1)});
            
            % subtract run code for individual testcases
            if ~isempty(rncode)
                for icase = length(testcasesstruct):-1:1
                    call = strfind(rncode,testcasesstruct(icase).functionname);
                    if isempty(call)
                        % No call to the testcase. This one is disabled. We do not have to remember it.
                        testcasesstruct(icase) = [];
                    end
                end
            end
            %% -- create mtestcase objects
            for itestcases = 1:length(testcasesstruct)
                
                % create outputfilenames
                obj.currentcase = itestcases;
                if isempty(testcasesstruct(itestcases).publishcode)
                    testcasesstruct(itestcases).publishEvaluateCode = true;
                    testcasesstruct(itestcases).publishIncludeCode = false;
                end
                if isempty(testcasesstruct(itestcases).description)
                    testcasesstruct(itestcases).descrIncludeCode = false;
                    testcasesstruct(itestcases).descrEvaluateCode = true;
                end
                
                descroutputfilen = [obj.filename '_description_case_' num2str(testcasesstruct(itestcases).caseNumber) '.html'];
                publishoutputfilen = [obj.filename '_results_case_' num2str(testcasesstruct(itestcases).caseNumber) '.html'];
                
                % create the object
                obj.testcases(itestcases) = mtestcase(...
                    testcasesstruct(itestcases).caseNumber,...
                    'casename',testcasesstruct(itestcases).caseName,...
                    'functionname',testcasesstruct(itestcases).functionname,...
                    'functionheader',testcasesstruct(itestcases).fullfunctioncall,... function header
                    'functionoutputname',testcasesstruct(itestcases).functionoutputname,...
                    'description',testcasesstruct(itestcases).description,... description code of the testcase
                    'descriptionoutputfile',descroutputfilen,... see property documentation of the mtestcase object
                    'descriptionincludecode',testcasesstruct(itestcases).descrIncludeCode,...
                    'descriptionevaluatecode',testcasesstruct(itestcases).descrEvaluateCode,...
                    'runcode',testcasesstruct(itestcases).runcode,...
                    'publishcode',testcasesstruct(itestcases).publishcode,...
                    'publishoutputfile',publishoutputfilen,...
                    'publishincludecode',testcasesstruct(itestcases).publishIncludeCode,...
                    'publishevaluatecode',testcasesstruct(itestcases).publishEvaluateCode);
            end
            if isempty(testcasesstruct)
                obj.testcases(1) = [];
            end
            %% add event listeners
            obj.eventlisteners = cat(1,...
                event.listener(obj.testcases,'NeedToInitialize',@obj.prepareTest),...
                event.listener(obj,'TestPerformed',@obj.storeRunWorkspace),...
                event.listener(obj,'RunWorkspaceSaved',@obj.fullPublish));
        end
        function publishDescription(obj,varargin)
            %publishDescription  Creates an html file from the test description with publish
            %
            %   This function publishes the code included in the first part of a test description
            %   file.
            %
            %   Syntax:
            %   publishDescripton(obj,'property','value')
            %   publishDescripton(...,'keepfigures');
            %   obj.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   'keepfigures'   - The publishTestDescription function automatically closes any figures
            %                     that was created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the test.
            %           'includeCode'-  Boolean overriding the mtestcase-property
            %                           descriptionincludecode. This property determines whether the
            %                           code parts of the description are included in the published
            %                           html file (see publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtestcase-property
            %                           descriptionevaluatecode. This property determines whether
            %                           the code parts of the description are executed before
            %                           publishing the code to html (see publish documentation for
            %                           more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtestcase mtest.run mtest.runAndPublish mtestengine
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.descriptionoutputfile = [nm '.html'];
                if ~isempty(pt)
                    obj.resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.includecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.evaluatecode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                obj.maxwidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                obj.maxheight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                obj.stylesheet = varargin{id+1};
            end
            %% createoutputname
            if isempty(obj.descriptionoutputfile)
                obj.descriptionoutputfile = [obj.filename '_main_description.html'];
            end
            [pt fn] = fileparts(obj.descriptionoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            obj.descriptionoutputfile = fullfile(pt,[fn '.html']);
            %% retrieve testname from input
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            end
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.stylesheet,...
                'outputDir',obj.resdir,...
                'maxHeight',obj.maxheight,...
                'maxWidth',obj.maxwidth,...
                'showCode',obj.descriptionincludecode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',obj.descriptionevaluatecode);
            %% Check open figures
            openfigures = findobj('Type','figure');
            %% check for empty description
            if isempty(obj.descriptioncode)
                obj.descriptioncode = {...
                    '% This test has no general description. The description can be included in the general part of the testdefinition function with a cell named "%% $Description" (*_test.m).'...
                    };
            end
            %% publish results to resdir
            mtestcase.publishCodeString(obj.descriptionoutputfile,...
                [],...
                [],...
                cat(1,{['%% Test description of "' obj.testname '"']},obj.descriptioncode),...
                opt);
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function run(obj,varargin)
            %run  Runs all testcases
            %
            % TODO update this function (with profiler etc.)
            
            %   This function runs the code specified in the RunTest cell of the test definition
            %   file for each testcase. Previous to running the test code, any results of the code
            %   specifying the description of the test are created in the workspace where the test
            %   is performed (this is all code that is not preceeded by a "%" sign).
            %
            %   Syntax:
            %   runTest(obj);
            %   runTest(obj,'keepfigures');
            %   obj.runTest;
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   See also mtest mtest.mtest mtestcase.runTest mtestcase mtestengine
            
            %% Make shure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.filepath);
            
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.testcases(icase).makeRunFunction(obj.rundir);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            obj.tmpobjname = ['mtest_test_function_' obj.filename];
            str = sprintf('%s\n',...
                strrep(obj.header,obj.filename,'mtest_testfunction'),...
                obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                obj.runcode{:},...
                ['notify(getappdata(0,''' obj.tmpobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',true));']);
            
            fid = fopen(fullfile(obj.rundir,'mtest_testfunction.m'),'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
            
            if ~exist(fullfile(obj.rundir,'mtest_testfunction.m'),'file')
                % Since Windows is slower in writing the file than the matlab fclose function..?
                % This is a workaround to let windos finish the file...
            end
            
            tic
            try
                obj.testresult = feval(@mtest_testfunction);
            catch
                obj.testresult = false;
            end
            obj.time = toc;
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
            
            %% Return the initial searchpath
            path(pt);
            
            %% set additional parameters
            if ~isempty(obj.testcases)
                totaltime = [obj.testcases(:).time];
                if ~isempty(totaltime)
                    obj.time = sum(totaltime);
                end
            end
            obj.date = now;
            
            %% Set flag
            obj.testperformed = true;
        end
        function publishCoverage(obj,varargin)
            %publishResult  Creates an html file with coverage information of this test
            %
            %   This function only creates an overview of the coverages. The coverage files for
            %   individual functions are linked to, but not generated.
            %
            %   Syntax:
            %   publishCoverage(obj,'property','value')
            %   obj.publisCoverage('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the test.
            %           'exclude'    -  Cell with strings indicating the functions that should be
            %                           excluded from the overview.
            %           'include'    -  Cell with strings indicating the functions that should be
            %                           included in the overview.
            %           'coveragedir'-  dirname (relative) of the referenced coverage files
            %           
            %
            %   See also mtestcase mtest.run mtest.runAndPublish mtestengine
            
            %% Run test if we do not have results
            if ~obj.testperformed
                obj.run;
            end
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get exclusions
            exclude = {};
            id = find(strcmp(varargin,'exclude'));
            if ~isempty(id)
                exclude = varargin{id+1};
            end
            
            coveragedir = {};
            id = find(strcmp(varargin,'coveragedir'));
            if ~isempty(id)
                coveragedir = varargin{id+1};
            end
            
            %% Get inclusions
            include = {};
            id = find(strcmp(varargin,'include'));
            if ~isempty(id)
                include = varargin{id+1};
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.coverageoutputfile = [nm '.html'];
                if ~isempty(pt)
                    obj.resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% createoutputname
            if isempty(obj.coverageoutputfile)
                obj.coverageoutputfile = [obj.filename '_main_coverage.html'];
            end
            [pt fn] = fileparts(obj.coverageoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            obj.coverageoutputfile = fullfile(pt,[fn '.html']);
            
            %% retrieve testname from input
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            end
            
            %% calculate coverage
            fcns = [];
            if ~isempty(obj.functioncalls)
                fcns = {obj.functioncalls.functionname}';
                
                if isempty(fcns{1})
                    fcns = [];
                else
                    fcnspath = cellfun(@fileparts,{obj.functioncalls.filename}','UniformOutput',false);
                    id = cellfun(@isempty,{obj.functioncalls.coverage});
                    cov = nan(size(obj.functioncalls,2),1);
                    cov(~id) = deal([obj.functioncalls(~id).coverage]);
                    id = true(size(fcns));
                    if ~isempty(include)
                        id = false(size(fcns));
                        for i = 1:length(include)
                            id(~cellfun(@isempty,strfind(lower(fcns),lower(include{i}))))=true;
                            id(~cellfun(@isempty,strfind(lower(fcnspath),lower(include{i}))))=true;
                        end
                    end
                    for i = 1:length(exclude)
                        id(~cellfun(@isempty,strfind(fcns,exclude{i})))=false;
                        id(~cellfun(@isempty,strfind(fcnspath,exclude{i})))=false;
                    end
                    fcns(~id)=[];
                    
                    cov(~id)=[];
                end
            end
            %% Create header
            s{1} = '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">';
            s{2} = '<html xmlns="http://www.w3.org/1999/xhtml">';
            
            s{3} = '<head>';
            s{end+1} = '<title>Coverage information</title>';
            s{end+1} = '</head>';
            s{end+1} = '<body>';
 
            if isempty(fcns)
                s{end+1} = 'This test did not address any function within the maindir';
            else
                %% Create table
                s{end+1} = '<table>';
                s{end+1} = '    <tr>';
                s{end+1} = '        <th>Function Name</th>';
                s{end+1} = '        <th>Coverage during test (%)</th>';
                s{end+1} = '    </tr>';
                for ifcn = 1:length(fcns)
                    [dummy fn] = fileparts(fcns{ifcn});
                    htmlfile = strrep(fullfile(coveragedir,mtestfunction.constructfilename([fn '_coverage.html'])),filesep,'/');
                    s{end+1} = '    <tr>';
                    s{end+1} = ['        <td><a class="RelFunctionRef" href="#" deltares:functioncoverageref="' htmlfile '">' code2html(fcns{ifcn}) '</a></td>']; %#ok<*AGROW>
                    s{end+1} = ['        <td>' num2str(cov(ifcn),'%0.0f') '</td>'];
                    s{end+1} = '    </tr>';
                end
                s{end+1} = '</table>';
            end
            %% end file
            s{end+1} = '</body>';
            s{end+1} = '</html>';
            
            %% save file
            fid = fopen(obj.coverageoutputfile,'w');
            fprintf(fid,'%s\n',s{:});
            fclose(fid);
        end
        function runAndPublish(obj,varargin)
            %runAndPublish  Runs the test and publishes the descriptions and results of all testcases.
            %
            %   This function runs the mtest object and publishes all case descriptions and results.
            %   The variables of the description and runcode of the test are stored in the hidden
            %   workspace, so that the publishResult function can directly be called after running
            %   the test.
            %
            %   Syntax:
            %   runAndPublish(obj,'property','value');
            %   obj.publisResults(...'property','value');
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (current dir is default).
            %           'outputfile' -  Main part of the name of the output file. The description is
            %                           output file appends _description to this name. The results
            %                           output file appends _results to it.
            %           'testname'   -  Name of the main test.
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtestcase mtestcase.mtestcase mtestcase.publishDescription mtest.publishResults mtestcase.runTest mtestengine mtest
            
            %% subtract result dir
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% Make shure the directory of the test is in the searchpath
            pt = path;
            addpath(obj.filepath);
            
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% subtract outputfilename
            id = find(strcmp(varargin,'outputfile'));
            caseoutputfile = [];
            if ~isempty(id)
                caseoutputfile = varargin{id+1};
                varargin(id:id+1)=[];
            end
            
            %% include testname
            if isempty(obj.testname)
                obj.testname = obj.filename;
            end
            id = find(strcmp(varargin,'testname'));
            if ~isempty(id)
                obj.testname = varargin{id+1};
                varargin(id:id+1)=[];
            end
            if isempty(caseoutputfile)
                caseoutputfile = obj.filename;
            end
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.currentcase = icase;
                
                % make runAndPublish files
                obj.testcases(icase).makeRunAndPublishFunction(obj.rundir);
                
                % set publish options
                for iargs = 1:2:length(varargin)
                    try
                        obj.testcases(icase).(varargin{iargs}) = varargin{iargs+1};
                    catch me %#ok<NASGU>
                        if ischar(varargin{iargs})
                            warning('Mtest:WrongInput',['The following property: "' varargin{iargs} '" could not be set and is not used.']);
                        else
                            warning('Mtest:WrongInput','Input must be valid property value pairs.');
                        end
                    end
                end
                obj.testcases(icase).testname = obj.testname;
                obj.testcases(icase).outputfile = caseoutputfile;
                obj.testcases(icase).descriptionoutputfile = fullfile(obj.resdir,[caseoutputfile '_case_' num2str(icase) '_description.html']);
                obj.testcases(icase).publishoutputfile = fullfile(obj.resdir,[caseoutputfile '_case_' num2str(icase) '_results.html']);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            if ~isempty(obj.header)
                obj.tmpobjname = ['mtest_test_function_' obj.filename];
                if isempty(obj.testcases)
                    str = sprintf('%s\n',...
                        strrep(obj.header,obj.filename,'mtest_testfunction'),...
                        'mtest_245y7e_tic = tic;',...
                        'profile clear',...
                        obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                        'profile on',...
                        obj.runcode{:},...
                        'profile off',...
                        ['notify(getappdata(0,''' obj.tmpobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false,''time'',toc(mtest_245y7e_tic)));'],...
                        ['notify(getappdata(0,''' obj.tmpobjname '''),''RunWorkspaceSaved'',mtesteventdata(whos,''remove'',true));']);
                else
                    str = sprintf('%s\n',...
                        strrep(obj.header,obj.filename,'mtest_testfunction'),...
                        obj.descriptioncode{~strncmp(obj.descriptioncode,'%',1)},...
                        obj.runcode{:},...
                        ['notify(getappdata(0,''' obj.tmpobjname '''),''TestPerformed'',mtesteventdata(whos,''remove'',false));'],...
                        ['notify(getappdata(0,''' obj.tmpobjname '''),''RunWorkspaceSaved'',mtesteventdata(whos,''remove'',true));']);
                end
                fid = fopen(fullfile(obj.rundir,'mtest_testfunction.m'),'w');
                fprintf(fid,'%s\n',str);
                fclose(fid);
                
                if ~exist(fullfile(obj.rundir,'mtest_testfunction.m'),'file')
                    % Since Windows is slower in writing the file than the matlab fclose function..?
                    % This is a workaround to let windows finish the file...
                end
                try
                    obj.testresult = feval(@mtest_testfunction);
                catch
                    obj.testresult = false;
                end
            else
                obj.testresult = false;
                error('Mtest:WrongTestdef','This test does not seem to be working due to a missing function declaration.');
            end
            
            if ~isnan(obj.testresult) && ~islogical(obj.testresult)
                obj.testresult = false;
            end
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
            
            %% set additional parameters
            if ~isempty(obj.testcases)
                totaltime = [obj.testcases(:).time];
                if ~isempty(totaltime)
                    obj.time = sum(totaltime);
                end
            end
            obj.date = now;
            
            %% Return the initial searchpath
            path(pt);
            
        end
        function publishResult(obj,varargin)
            %publishResult  Creates an html file from the test result with publish
            %
            %   This function publishes the code included in the "%% $PublishResult" cell of the
            %   testdefinition function
            %
            %   Syntax:
            %   publishResult(obj,'property','value')
            %   publishResult(...,'keepfigures');
            %   obj.publisResult('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtest object.
            %   'keepfigures'   - The publishTestDescription function automatically closes any figures
            %                     that was created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the test.
            %           'includeCode'-  Boolean overriding the mtest-property
            %                           publishincludecode. This property determines whether the
            %                           code parts of the publish section are included in the published
            %                           html file (see publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtest-property
            %                           publishevaluatecode. This property determines whether
            %                           the code parts of the publish section are executed before
            %                           publishing the code to html (see publish documentation for
            %                           more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtestcase mtest.run mtest.runAndPublish mtestengine
            
            %% Run test if we do not have results
            if ~obj.testperformed
                obj.run;
            end
            
            %% subtract result dir from input
            if isempty(obj.resdir)
                obj.resdir = cd;
            end
            id = find(strcmp(varargin,'resdir'));
            if ~isempty(id)
                obj.resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'filename'));
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                obj.descriptionoutputfile = [nm '.html'];
                if ~isempty(pt)
                    obj.resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                obj.includecode = varargin{id+1};
            end
            
            % evaluateCode
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                obj.evaluatecode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                obj.maxwidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                obj.maxheight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                obj.stylesheet = varargin{id+1};
            end
            
            %% createoutputname
            if isempty(obj.publishoutputfile)
                obj.publishoutputfile = [obj.filename '_main_results.html'];
            end
            [pt fn] = fileparts(obj.publishoutputfile);
            if isempty(pt)
                pt = obj.resdir;
            end
            obj.publishoutputfile = fullfile(pt,[fn '.html']);
            
            %% retrieve testname from input
            if any(strcmpi(varargin,'testname'))
                id = find(strcmpi(varargin,'testname'));
                obj.testname = varargin{id+1};
            end
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',obj.stylesheet,...
                'outputDir',obj.resdir,...
                'maxHeight',obj.maxheight,...
                'maxWidth',obj.maxwidth,...
                'showCode',obj.publishincludecode,...
                'useNewFigure',false,...
                'evalCode',obj.publishevaluatecode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% check for empty description
            if isempty(obj.publishcode)
                obj.publishcode = {...
                    '% This test has no publish section.'...
                    };
            end
            %% publish results to resdir
            mtestcase.publishCodeString(obj.publishoutputfile,...
                [],...
                obj.runworkspace,...
                cat(1,{['%% Test Results of "' obj.testname '"']},obj.publishcode),...
                opt);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function cleanUp(obj)
            %cleanUp  Cleans up the mtestcase objects of the mtest object
            %
            %   Some information is stored in hidden properties of an mtestcase object. For example
            %   the test testworkspace (workspace that is created during the test, including all
            %   variables) can take a lot of space. This function cleans these variables.
            %   Consequently after cleaning the mtestcase object, test results can not be published
            %   anymore without rerunning the test. Rerunning a test is done automatically when a
            %   call to publishResults is made without the object having test results. The property
            %   testresult stayes intact so that the test result is still there. Typically this
            %   function is run after publishing the results to remember the property testresult,
            %   but clear memory for other tests or testcases.
            %
            %   Syntax:
            %   cleanUp(obj);
            %   obj.cleanUp;
            %
            %   Input:
            %   obj  = An instance of an mtest object.
            %
            %   See also mtest mtest.mtest mtestcase mtestengine
            
            %% cleanup the mtestcase objects
            for itestcase = 1:length(obj.testcases);
                obj.currentcase = itestcase;
                obj.testcases(itestcase).cleanUp;
            end
            
            obj.runworkspace = [];
            obj.tmpobjname = [];
            %% Set flag
            obj.testperformed = false;
            
        end
        function edit(obj)
            edit(obj.filename);
        end
    end
    methods % set and get methods
        function set.tmpobjname(obj,varargin)
            if isempty(varargin{1})
                % rmappdata
                if ~isempty(obj.tmpobjname)
                    rmappdata(0,obj.tmpobjname);
                end
                obj.tmpobjname = varargin{1};
            else
                % setappdata
                if ~isempty(obj.tmpobjname)
                    rmappdata(0,obj.tmpobjname);
                end
                setappdata(0,varargin{1},obj);
                obj.tmpobjname = varargin{1};
            end
        end
    end
    methods (Hidden = true)
        function storeRunWorkspace(obj,varargin)
            %% get workspace
            data = varargin{2};
            ws = data.workspace;
            
            %% remove temp appdata
            if varargin{2}.removetempobj
                obj.tmpobjname = [];
            end
            
            %% store init workspace
            ws(strcmp(ws(:,1),'tmpobjname'),:)=[];
            obj.runworkspace = ws;
            
            %% time
            if ~isempty(varargin{2}.time)
                obj.time = varargin{2}.time;
            end
            
            %% Save profiler info
            if isempty(obj.testcases)
                obj.profinfo = profile('info');
            else
                obj.profinfo = mergeprofileinfo(obj.testcases.profinfo);
            end
            
            obj.functioncalls = mtestfunction;
            for i = 1:size(obj.profinfo.FunctionTable,1)
                obj.functioncalls(i) = mtestfunction(obj.profinfo,i);
            end
            
            %% Set flag
            obj.testperformed = true;
        end
        function prepareTest(obj,varargin)
            %% construct temp rundir
            obj.rundir = tempname;
            mkdir(obj.rundir);
            
            %% Prepare testcase functions
            for icase = 1:length(obj.testcases)
                obj.testcases(icase).makeInitFunction(obj.rundir);
            end
            
            %% go to rundir
            cdtemp = cd;
            cd(obj.rundir);
            
            %% run general part of the code
            try
                evalinemptyworkspace(sprintf('%s\n',obj.descriptioncode{:},obj.runcode{:}));
            catch me %#ok<NASGU>
                disp('There appears to be something wrong with the descriptioncode or runcode of the mtest object.');
            end
            
            %% cd back
            cd(cdtemp);
            
            %% remove tempdir
            rmdir(obj.rundir,'s');
        end
        function fullPublish(obj,varargin)
            % This function assumes the test has been run fully
            MoreThanTwoInputArgs = nargin>2;
            if MoreThanTwoInputArgs
                SecondVararginMtesteventData = strcmp(class(varargin{2}),'mtesteventdata');
                RemoveTemoObj = varargin{2}.removetempobj;
                if SecondVararginMtesteventData && RemoveTemoObj
                    obj.tmpobjname = [];
                end
            end
            
            %% publish description
            obj.publishDescription;
            
            %% publish result (to come)
            obj.publishResult;
        end
    end
    methods (Static=true)
        function outargs = argsinname(str,fn)
            %% fund function name in call
            str = strtrim(str(strfind(str,'function')+length('function'):end));
            fnid = strfind(str,fn);
            
            %% output arguments
            outargs = [];
            if ~isempty(strfind(str(1:fnid),'='))
                % There is output defined
                outargstemp = strtrim(strread(strrep(strrep(strtrim(str(1:min(strfind(str(1:fnid),'='))-1)),'[',''),']',''),'%s',-1,'delimiter',','));
                
                for iargs = 1:length(outargstemp)
                    outargs = cat(1,outargs,strtrim(strread(outargstemp{iargs},'%s',-1,'delimiter',' ')));
                end
            end
        end
    end
end