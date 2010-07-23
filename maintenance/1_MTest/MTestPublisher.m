classdef MTestPublisher < handle

    properties % General properties
        Publish = false;                     % Determines whether test results, coverage and description are published to html
        Verbose = false;
        TargetDir = cd;
        CopyMode = 'svnkeep';
        MaxWidth  = 600;                    % Maximum width of the published figures (in pixels). By default the maximum width is set to 600 pixels.
        MaxHeight = 600;                    % Maximum height of the published figures (in pixels). By default the maximum height is set to 600 pixels.
    end
    properties % Test Overview properties
        Template = 'default';
        StyleSheet = '';                    % Style sheet that is used for publishing (see publish documentation for more information).
    end
    properties (Hidden = true)
        templdir;
        tplfiles;
        TargetDirectoryPrepared = false;
    end
    properties
        CoverageTemplate = 'default';
    end
    properties %Former MTest
        OutputDir = [];                     % The output (published html) will be placed in this dir
    end
    
    methods 
        function this = MTestPublisher(varargin)
            this = MTestUtils.setproperty(this,varargin);
        end
    end
    %% Public functions
    methods
        function publishcoverage(this,profileInfo,varargin)
            if isempty(profileInfo)
                return;
            end
            
            this = MTestUtils.setproperty(this,varargin);
            
            TeamCity.postmessage('progressMessage', 'Calculating test coverage');
            if this.Verbose
                disp('Calculating test coverage');
            end
            
            %% create coverage dir
            if ~isdir(fullfile(this.TargetDir))
                mkdir(fullfile(this.TargetDir));
            end
            
            %% copy template te coverage dir
            covtempldir = fullfile(fileparts(mfilename('fullpath')),'templates','coverage',this.CoverageTemplate);
            if ~isdir(covtempldir)
                covtempldir = fullfile(fileparts(mfilename('fullpath')),'templates','coverage','default');
            end
            
            temptemplatedir = tempname;
            mkdir(temptemplatedir);
            copyfile(fullfile(covtempldir,'*.*'),temptemplatedir,'f');
            
            % remove all svn dirs from the template
            DirsInTemplateDir = strread(genpath(temptemplatedir),'%s',-1,'delimiter',';');
            SvnDirsInTemplateDir = DirsInTemplateDir(~cellfun(@isempty,strfind(DirsInTemplateDir,'.svn')));
            
            % remove all svn dirs from the template
            for i=1:length(SvnDirsInTemplateDir)
                if isdir(SvnDirsInTemplateDir{i})
                    rmdir(SvnDirsInTemplateDir{i},'s');
                end
            end
            
            % copy template to target dir
            copyfile(fullfile(temptemplatedir,'*.*'),fullfile(this.TargetDir),'f');
            rmdir(temptemplatedir,'s');
            
            %% publish coverage files
            fnames = {profileInfo.FunctionTable.FileName}';
            mainfnames = fnames(cellfun(@(in) ~isempty(in)&&in==2,regexpi(fnames,':')));
            
            functionsRun = struct(...
                'FileName',[],...
                'FunctionName',[],...
                'HTML',[],...
                'Coverage',[]);
            if this.Verbose
                h = waitbar(0);
            end
            for ifunc = 1:length(profileInfo.FunctionTable)
                if ismember(profileInfo.FunctionTable(ifunc).FileName,mainfnames) &&...
                        ismember(profileInfo.FunctionTable(ifunc).Type,{'M-subfunction','M-function'}) &&...
                        ~strncmp(profileInfo.FunctionTable(ifunc).FileName,matlabroot,length(matlabroot))    % Exclude all matlab functions
                    
                    if this.Verbose
                        waitbar(ifunc/length(profileInfo.FunctionTable),h,...
                            ['Processing coverage (function ' num2str(ifunc) ' of' num2str(length(profileInfo.FunctionTable)) ,')'])
                    end
                    
                    %% Create mtestfunction object
                    filename = profileInfo.FunctionTable(ifunc).FileName;
                    if ~exist(filename,'file')
                        [pt name ext] = fileparts(filename);
                        filename = which([name,ext]);
                        if isempty(filename)
                            continue;
                        end
                        profileInfo.FunctionTable(ifunc).CompleteName = strrep(profileInfo.FunctionTable(ifunc).CompleteName,profileInfo.FunctionTable(ifunc).FileName,fileparts(filename));
                        profileInfo.FunctionTable(ifunc).FileName = filename;
                    end
                    
                    functionsRun(ifunc).FileName = filename;
                    functionsRun(ifunc).FunctionName = profileInfo.FunctionTable(ifunc).FunctionName;

                    %% Convert coverage to html
                    try
                    [functionsRun(ifunc).HTML...
                        functionsRun(ifunc).Coverage] = this.coverage2html(profileInfo,ifunc);
                    catch 
                        % Never mind, this could be caused by a licence problem, but also by old
                        % filedefinitions. ust ignore the file
                        disp(['error with: ' functionsRun(ifunc).FileName]);
                        functionsRun(ifunc).FileName = [];
                    end
                end
            end
            if this.Verbose
                delete(h);
            end
            
            functionsRun(cellfun(@isempty,{functionsRun.FileName}))=[];
            functionsRun(isnan([functionsRun.Coverage]))=[];
            
            %% Publish coverage (tpl)
            covtplfiles = dir(fullfile(this.TargetDir,'*.tpl'));
            for i=1:length(covtplfiles)
                this.fillcoveragetpl(fullfile(this.TargetDir,covtplfiles(i).name),functionsRun);
            end
        end
        function outputname = publishtestdescription(this,mTest,functionname,varargin)
            %publishtestdescription  Creates an html file from the description code with publish
            %
            %   This function publishes the code included in the Description cell of the test file
            %   for this test(case) with the help of the publish function.
            %
            %   Syntax:
            %   publishDescripton(mTest,'property','value')
            %   publishDescripton(...,'keepfigures');
            %   mTest.publisDescription('property','value')
            %
            %   Input:
            %   obj             - An instance of an mtestpublishable object with the information of the
            %                     test description that has to be published.
            %   'keepfigures'   - The publishDescription function automatically closes any figures
            %                     that were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory (default is the current
            %                           directory)
            %           'filename'   -  Name of the output file. If the filename include a path,
            %                           this pathname overrides the specified resdir.
            %           'testname'   -  Name of the (main) test.
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
            %   See also mtest mtestcase mtestengine mtest.publishResults
            
            %% Do not publish if the object should be ignored
            if mTest.Ignore
                return;
            end

            %% Determine whether the publish code is a subfunction, function or script
            functionType = 'subfunction';
            if isa(functionname,'function_handle')
                functionname = func2str(functionname);
            end
            idfunction = strcmp({mTest.SubFunctions.name},functionname);

            if all(~idfunction)
                % function is not a subfunction
                if ~exist(which(functionname),'file')
                    % There is no external file with this name
                    error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function or script as first input argument');
                end
                % read the code of the external file to see if it is a function or a script
                fcncalls = getcallinfo(which(functionname));
                if datenum(version('-date')) > datenum(2010,1,1)
                    if fcncalls(1).type == internal.matlab.codetools.reports.matlabType.Function
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                else
                    if strcmp(fcncalls(1).type,'function')
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                end
            end

            %% subtract result dir from input
            resdir = this.OutputDir;
            id = find(strcmp(varargin,'outputdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            if isempty(resdir)
                resdir = cd;
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'outputfile'));
            outputfile = fullfile(resdir,[mTest.FileName, '_description.html']);
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                outputfile = [nm '.html'];
                if ~isempty(pt)
                    resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            includeCode = false;
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                includeCode = varargin{id+1};
            end
            
            % evaluateCode
            evaluateCode = true;
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                evaluateCode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                this.MaxWidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                this.MaxHeight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                this.StyleSheet = varargin{id+1};
            end
            
            %% createoutputname
            [pt fn] = fileparts(outputfile);
            if isempty(pt)
                pt = resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',this.StyleSheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',this.MaxHeight,...
                'maxWidth',this.MaxWidth,...
                'showCode',includeCode,...
                'useNewFigure',false,... % Maybe add mTest to the input of properties?
                'evalCode',evaluateCode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            switch functionType
                case 'subfunction'
                    idPublishString = mTest.SubFunctions(idfunction).linemask;
                    if strncmp(mTest.FullString(mTest.SubFunctions(idfunction).firstline),'function ',9)
                        idPublishString(mTest.SubFunctions(idfunction).firstline) = false;
                    end
                    
                    % ==> This can lead to errors if someone somehow does not end the subfunction with end end
                    % also begins the last line with end....
                    if strncmp(mTest.FullString(mTest.SubFunctions(idfunction).lastline),'end',3)
                        idPublishString(mTest.SubFunctions(idfunction).lastline) = false;
                    end
                    
                    descrstr = mTest.FullString(idPublishString);
                otherwise
                    fid = fopen(which(functionname),'r');
                    str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
                    functioncontent = str{1};
                    fclose(fid);
                    if strcmp(functionType,'script')
                        descrstr = sprintf('%s\n',functioncontent{:});
                    else
                        if length(fcncalls)>1
                            descrstr = sprintf('%s\n',functioncontent{:});
                        else
                            functioncontent(fcncalls.firstline) = [];
                            descrstr = sprintf('%s\n',functioncontent{:});
                        end
                    end
            end
            
            %% Publish
            MTestPublisher.publishcodestring(outputname,...
                [],...
                descrstr,...
                opt,...
                true);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function outputname = publishtestresult(this,mTest,functionname,varargin)
            %publishResults  Creates an html file from the test result with publish
            %
            %   This function publishes the code included in the Publish(Result) cell of the test file
            %   with the help of the publish function. All variables created by running the test are
            %   still in the workspace and can therefore be used while publishing the results.
            %
            %   Syntax:
            %   publishResults(obj,'property','value')
            %   publishResults(...,'keepfigures');
            %   obj.publisResults(...)
            %
            %   Input:
            %   obj             - An instance of an mtestpublishable object with the information of the
            %                     test results that has to be published.
            %   'keepfigures'   - The publishResults function automatically closes any figures that
            %                     were created during publishing and were not already there.
            %                     The optional argument 'keepfigures' prevents these figures from
            %                     being closed (unless stated in the test code somewhere).
            %
            %   property value pairs:
            %           'resdir'     -  Specifies the output directory
            %           'filename'   -  Name of the output file. If the filename includes a path,
            %                           this pathname overrides the specified resdir.
            %           'name'       -  Name of the test.
            %           'includeCode'-  Boolean overriding the mtest-property publishincludecode.
            %                           This property determines whether the code parts of the
            %                           publication part are included in the published html file (see
            %                           publish documentation for more info).
            %           'evaluateCode'- Boolean overriding the mtest-property publishevaluatecode.
            %                           This property determines whether the code parts of the
            %                           publishresult are executed before publishing the code to html
            %                           (see publish documentation for more info).
            %           'maxwidth'  -   Maximum width of the published figures (in pixels). By
            %                           default the maximum width is set to 600 pixels.
            %           'maxheight' -   Maximum height of the published figures (in pixels). By
            %                           default the maximum height is set to 600 pixels.
            %           'stylesheet'-   Style sheet that is used for publishing (see publish
            %                           documentation for more information).
            %
            %   See also mtest mtestcase mtestengine mtestpublishable.publishDescription mtestpublishable.publishCoverage
            
            %% Do not publish if the object should be ignored
            if mTest.Ignore
                return;
            end

            %% Determine whether the publish code is a subfunction, function or script
            functionType = 'subfunction';
            if isa(functionname,'function_handle')
                functionname = func2str(functionname);
            end
            idfunction = strcmp({mTest.SubFunctions.name},functionname);

            if all(~idfunction)
                % function is not a subfunction
                if ~exist(which(functionname),'file')
                    % There is no external file with this name
                    error('TeamCity:Publish','TeamCity.publishdescription should have the name or handle of a function or script as first input argument');
                end
                % read the code of the external file to see if it is a function or a script
                fcncalls = getcallinfo(which(functionname));
                if datenum(version('-date')) > datenum(2010,1,1)
                    if fcncalls(1).type == internal.matlab.codetools.reports.matlabType.Function
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                else
                    if strcmp(fcncalls(1).type,'function')
                        functionType = 'function';
                    else
                        functionType = 'script';
                    end
                end
            end
                
            %% subtract result dir from input
            resdir = this.OutputDir;
            id = find(strcmp(varargin,'outputdir'));
            if ~isempty(id)
                resdir = varargin{id+1};
                varargin(id:id+1) = [];
            end
            if isempty(resdir)
                resdir = cd;
            end
            
            %% Get filename from input
            id = find(strcmp(varargin,'outputfile'));
            outputfile = fullfile(resdir,[mTest.FileName, 'publish.html']);
            if ~isempty(id)
                [pt nm] = fileparts(varargin{id+1});
                outputfile = [nm '.html'];
                if ~isempty(pt)
                    resdir = pt;
                end
                varargin(id:id+1) = [];
            end
            
            %% Process other input arguments
            % includeCode
            includeCode = false;
            if any(strcmpi(varargin,'includecode'))
                id = find(strcmpi(varargin,'includecode'));
                includeCode = varargin{id+1};
            end
            
            % evaluateCode
            evaluateCode = true;
            if any(strcmpi(varargin,'evaluatecode'))
                id = find(strcmpi(varargin,'evaluatecode'));
                evaluateCode = varargin{id+1};
            end
            
            % Maxwidth
            if any(strcmpi(varargin,'maxwidth'))
                id = find(strcmpi(varargin,'maxwidth'));
                this.MaxWidth = varargin{id+1};
            end
            
            % maxheight
            if any(strcmpi(varargin,'maxheight'))
                id = find(strcmpi(varargin,'maxheight'));
                this.MaxHeight = varargin{id+1};
            end
            
            % stylesheet
            if any(strcmpi(varargin,'stylesheet'))
                id = find(strcmpi(varargin,'stylesheet'));
                this.StyleSheet = varargin{id+1};
            end
            
            %% createoutputname
            [pt fn] = fileparts(outputfile);
            if isempty(pt)
                pt = resdir;
            end
            outputname = fullfile(pt,[fn '.html']);
            
            %% set publish options
            opt = struct(...
                'format','html',...
                'stylesheet',this.StyleSheet,...
                'outputDir',fileparts(outputname),...
                'maxHeight',this.MaxHeight,...
                'maxWidth',this.MaxWidth,...
                'showCode',includeCode,...
                'useNewFigure',false,... % Maybe add this to the input of properties?
                'evalCode',evaluateCode);
            
            %% Check open figures
            openfigures = findobj('Type','figure');
            
            %% publish results to resdir
            % Todo: in future it should be possible to call a script outside the function
            switch functionType
                case 'subfunction'
                    idPublishString = mTest.SubFunctions(idfunction).linemask;
                    if strncmp(mTest.FullString(mTest.SubFunctions(idfunction).firstline),'function ',9)
                        idPublishString(mTest.SubFunctions(idfunction).firstline) = false;
                    end
                    
                    % ==> This can lead to errors if someone somehow does not end the subfunction with end end
                    % also begins the last line with end....
                    if strncmp(mTest.FullString(mTest.SubFunctions(idfunction).lastline),'end',3)
                        idPublishString(mTest.SubFunctions(idfunction).lastline) = false;
                    end
                    
                    publishstr = mTest.FullString(idPublishString);
                otherwise
                    fid = fopen(which(functionname),'r');
                    str = textscan(fid,'%s','delimiter','\n','whitespace','','bufSize',10000);
                    functioncontent = str{1};
                    fclose(fid);
                    if strcmp(functionType,'script')
                        publishstr = sprintf('%s\n',functioncontent{:});
                    else
                        if length(fcncalls)>1
                            publishstr = sprintf('%s\n',functioncontent{:});
                        else
                            functioncontent(fcncalls.firstline) = [];
                            publishstr = sprintf('%s\n',functioncontent{:});
                        end
                    end
            end
            
            MTestPublisher.publishcodestring(outputname,...
                [],...
                publishstr,...
                opt,...
                true);
            
            %% Close all remaining open figures from the test
            newopenfigures = findobj('Type','figure');
            id = ~ismember(newopenfigures,openfigures);
            if any(id) && isempty(find(strcmpi(varargin,'keepfigures'), 1))
                close(newopenfigures(id));
            end
        end
        function publishtestsoverview(this,mTestRunner,varargin)
            MTestUtils.setproperty(this,varargin);
            
            %% clear and prepare target dir
            TeamCity.postmessage('progressMessage', 'Preparing output files');
            this.preparetargetdir('Verbose',mTestRunner.Verbose);
            
            %% loop all tpl files and fill keywords
            this.publishtemplate(mTestRunner);
        end
    end
    
    %% Publish Coverage helper functions
    methods (Hidden=true)
        function obj = fillcoveragetpl(obj,tplfilename,functionsRun)
            %fillTemplate  Replaces keywords in a template file with information from an mtestengine obj.
            %
            %   This function reads the string from a template file and replaces keywords with
            %   values from the mtestengine object. Allowed keywords:
            %
            %       keywords defining a loop:
            %       <!-- ##BEGINFUNCTIONS -->/<!-- ##ENDFUNCTIONS -->
            %                               All code between these two keywords is copied and
            %                               filled (keywords are replaced by the correct
            %                               information) for each individual test. The resulting
            %                               strings are pasted successive.
            %
            %       coverage keywords:
            %       #FUNCTIONNAME       -   Is replaced by the name of the function
            %       #COVERAGEHTML       -   Is replaced by the html coverage report.
            %       #COVERAGEPERCENTAGE -   Is replaced by the percentage of lines that was run
            %
            %   Syntax:
            %   outobj = this.fillTemplate(tplfilename,functionsRun);
            %   fillTemplate(this,tplfilename,functionsRun)
            %
            %   Input:
            %   this         -   an MTestPublisher object.
            %   tplfilename  -   Full path to the tpl file in the target dir.
            %   functionsRun -   an MTestFunction object (of multiple functions)
            %
            %   Output:
            %   outobj  -   The same mtestengine object that entered the function.
            %
            %   See also MTest MTestExplorer MTestRunner
            
            %% Check if the file is there
            if ~exist(tplfilename,'file')
                return;
            end
            
            %% Acquire template string
            fid = fopen(tplfilename);
            str = fread(fid,'*char')';
            fclose(fid);
            
            %% Loop all functions
            str = MTestPublisher.loopandfillcoveragefunctions(str,...
                functionsRun);
            
            %% Write output file (replace .tpl with .html)
            [pt fname] = fileparts(tplfilename);
            [emptydummy fname ext] = fileparts(fname); %#ok<*ASGLU>
            if ~isempty(ext)
                fullfname = fullfile(pt,[fname ext]);
            else
                fullfname = fullfile(pt,[fname '.html']);
            end
            fid = fopen(fullfname,'w');
            fprintf(fid,'%s',str);
            fclose(fid);
            
            %% Remove tpl file from target dir
            delete(tplfilename);
        end
    end
    methods (Static = true, Hidden = true)
        function [html coverage] = coverage2html(profileInfo,ifunc)
            setpref('profiler','sortMode','coverage');
            warning('off','MATLAB:sprintf:InputForPercentSIsNotOfClassChar');
            str = profview(ifunc,profileInfo);
            warning('on','MATLAB:sprintf:InputForPercentSIsNotOfClassChar');

            str = regexprep(str,'<a href="matlab: profview\((\d+)\);">','');
            % The question mark makes the .* wildcard non-greedy
            str = regexprep(str,'<a href="matlab:.*?>(.*?)</a>','$1');
            % Remove all the forms
            str = regexprep(str,'<form.*?</form>','');
            
            [ind1 ind2]=regexp(str,'<strong>Coverage.*?</table>');
            strCoverage = str(ind1:ind2);
            strCoverage = strrep(strCoverage,'<br/>[ Show coverage for parent directory ]<br/>','');
            
            idend = max(strfind(strCoverage,'%'))-1;
            if isempty(idend)
                coverage = nan;
            else
                ids = strfind(strCoverage,'>');
                idbegin = max(ids(ids<idend))+1;
                coverage = str2double(strCoverage(idbegin:idend));
            end
            
            [ind3 ind4]=regexp(str,'<b>Function listing.*?</body>');
            strFunctionListing = str(ind3:ind4);
            strFunctionListing = strrep(strFunctionListing,'</body>','');
            html = cat(2,strCoverage,strFunctionListing);
        end
        function str = loopandfillcoveragefunctions(str,functionsRun)
            ends = strfind(str,'-->');
            if ~isempty(strfind(str,'##BEGINFUNCTIONS'))
                begstrids = strfind(str,'##BEGINFUNCTIONS');
                idteststrends = strfind(str,'##ENDFUNCTIONS')-6;
                for istr = length(begstrids):-1:1
                    idteststrbegin = min(ends(ends>begstrids(istr)))+4;
                    idteststrend = idteststrends(istr);
                    funcstr = str(idteststrbegin:idteststrend);
                    str = strrep(str,funcstr,'#@#FUNCTIONSTRING');
                    %% Loop tests
                    finalstr = '';
                    for icall = 1:length(functionsRun)
                        %% create functionstring and replace keywords
                        % #FUNCTIONNAME
                        % #FUNCTIONHTML
                        % #FUNCTIONCOVERAGE
                        
                        id = regexp(functionsRun(icall).FileName,':');
                        if isempty(id) && min(id)~=2
                            continue
                        end
                        tempstr = funcstr;
                        
                        % #FUNCTIONFULLNAME
                        tempstr = strrep(tempstr,'#FUNCTIONNAME',code2html(functionsRun(icall).FunctionName));
                        
                        % #FUNCTIONHTML
                        tempstr = strrep(tempstr,'#COVERAGEHTML',sprintf('%s\n',functionsRun(icall).HTML));
                        
                        % #FUNCTIONCOVERAGE
                        tempstr = strrep(tempstr,'#COVERAGEPERCENTAGE',num2str(functionsRun(icall).Coverage,'%0.0f'));
                        
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#FUNCTIONSTRING',finalstr);
                    
                end
            end
        end
    end

    %% Publish test description and result helper functions
     methods (Hidden = true, Static = true)
        function publishcodestring(outputname,tempdir,string2publish,publishoptions,saveWorkSpace)
            %PUBLISHCODESTRING  publishes a string to a html page
            %
            %   This function publishes a string to a html page. it uses the UserData of the matlab
            %   root to store any variables that are used as input.
            %
            %   Syntax:
            %   publishCodeString(...
            %       outputname,...
            %       tempdir,...
            %       workspace,...
            %       string2publish,...
            %       publishoptions)
            %
            %   Input:
            %   outputname    -   Name of the html output file. If this is
            %   tempdir       -   Name of the temp dir where the file can be created. If this
            %                     variable is left empty the file is published in the output
            %                     directory (filepath of mtest_outputname).
            %   workspace     -   Variables that should be in the workspace to be able to
            %                     publish the code string. This variable should be an Nx2 cell
            %                     array. The first column should contain a string with the
            %                     name of the variable. The second column stores the content
            %                     of that variable.
            %   string2publish-   String that has to be published
            %   publishoptions-   A struct with publish options as described in the help
            %                     documentation of the matlab function "publish".
            %
            %   See also mtest publish mtest.mtest mtest.runTest
            
            %% create temp file with code that needs to be executed
            publishInOutputDir = false;
            if isempty(tempdir)
                tempdir = fileparts(outputname);
                publishInOutputDir = true;
            end
            
            tempfilename = MTestPublisher.makeTempFile(tempdir,string2publish,outputname);
            
            [ newdir newname ] = fileparts(outputname);
            fileNamesIdentical = strcmp(tempfilename,fullfile(newdir,[newname '.m']));
            
            if publishInOutputDir && ~fileNamesIdentical
                % move the tempfile to the correct name (to have sensible names for the figures) and
                % the correct directory
                
                movefile(tempfilename,fullfile(newdir,[newname '.m']));
                % renew filename
                tempfilename = fullfile(newdir,[newname '.m']);
            end
            % split output dir and filename
            [tempdir tempfileshortname] = fileparts(tempfilename);
            
            %% fill workspace
            % store mtest_workspace in UserData of the matlab root. The publish function is preceded
            % by code to retrieve the variables from the root UserData.
            % Build a string that restores the variables and executes the tempfile.
            string2evaluate = ['TeamCity.restoreworkspace; profile on;', tempfileshortname, ';'];
            if saveWorkSpace
                string2evaluate = cat(2,string2evaluate,' profile off; TeamCity.storeworkspace;');
            end
            
            % Now specify the code to evaluate. The string constructed above should be evaluated in
            % an empty workspace. Therefore in the base workspace we only call evalinemptyworkspace,
            % with the string we just constructed as input.
            publishoptions.codeToEvaluate = ['MTestUtils.evalinemptyworkspace(''' string2evaluate ''');'];
            
            %% publish file
            tempcd = cd;
            cd(tempdir)
            if datenum(version('-date')) >= datenum(2009,08,12) && datenum(version('-date')) < datenum(2010,01,01)
                intwarning('off');
            end
            publish(tempfilename,publishoptions);
            cd(tempcd);
            
            %% delete the temp file
            delete(tempfilename);
            
            %% move output file
            [dr fname] = fileparts(tempfilename); %#ok<*ASGLU>
            if ~strcmp(fullfile(publishoptions.outputDir,[fname '.html']),outputname)
                movefile(fullfile(publishoptions.outputDir,[fname '.html']),outputname);
            end
        end
        function fname = makeTempFile(tempdir,str,fn)
            if ~ischar(str)
                str = sprintf('%s\n',str{:});
            end
            
            if nargin==2
                fn = tempname;
            end
            [dum fn] = fileparts(fn);
            fname = fullfile(tempdir,[fn '.m']);
            fid = fopen(fname,'w');
            fprintf(fid,'%s\n',str);
            fclose(fid);
        end
    end
    
    %% Publish tests overview helper functions
    methods (Hidden=true)
        function publishstylesheet = preparetargetdir(this,varargin)
            this = MTestUtils.setproperty(this,varargin);
            
            if this.TargetDirectoryPrepared
                return;
            end
            
            if this.Verbose
                disp('Preparing output files');
            end

            if ~isdir(this.TargetDir)
                mkdir(this.TargetDir);
            else
                % list all files not being svn related or dirs.
                fls = MTestUtils.listfiles(this.TargetDir,'*',true);
                fls(~cellfun(@isempty,strfind(fls(:,1),'.svn')) | strcmp(fls(:,2),'.') | strcmp(fls(:,2),'..'),:)=[];
                if ~isempty(fls)
                    if ~isempty(this.CopyMode)
                        button = this.CopyMode;
                    else
                        button = questdlg({['The target directory is set to: ' this.TargetDir];'There are already files in this directory. What do you want to do with them?'},'Target dir not empty','Remove all files and dirs','Only remove files and keep svn information','Leave all my files there','Leave all my files there');
                        if isempty(button)
                            return
                        end
                    end
                    switch button
                        case {'Leave all my files there','keep'}
                            % Do nothing
                        case {'Only remove files and keep svn information','svnkeep'}
                            % delete all files that are not svn.
                            % Do not delete dirs. (could have svn content..).
                            for ifls = 1:size(fls,1)
                                if exist(fullfile(fls{ifls,1},fls{ifls,2}),'file') && ~isdir(fullfile(fls{ifls,1},fls{ifls,2}))
                                    delete(fullfile(fls{ifls,1},fls{ifls,2}));
                                end
                            end
                        case {'Remove all files and dirs','remove'}
                            rmdir(this.TargetDir,'s');
                            mkdir(this.TargetDir);
                        otherwise
                            % also do nothing
                    end
                end
            end
            tc = TeamCity;
            tc.PublishDirectory = fullfile(this.TargetDir,'html'); % sdame as this.OutputDir
            
            %% copy template files and dirs
            templatedir = fullfile(fileparts(mfilename('fullpath')),'templates','testoverview');
            if ~isdir(templatedir)
                error('MtestEngine:MissingTemplates','There are no templates.');
            end
            if ~isdir(fullfile(templatedir,'default'))
                error('MtestEngine:MissingTemplates','The default template was not found.');
            end
            dirs = dir(templatedir);
            templatenames = {dirs([false false dirs(3:end).isdir]).name}';
            if ~strcmp(templatenames,this.Template)
                warning('MtestEngine:TemplateNotFound',['Template with the name: "' this.Template '" was not found. Default is used instead']);
                this.Template = 'default';
            end
            this.templdir = fullfile(templatedir,this.Template);
            
            % check the existance of template files (*.tpl)
            this.tplfiles = MTestUtils.listfiles(this.templdir,'tpl',true);
            this.tplfiles(:,1) = cellfun(@fullfile,...
                repmat({this.TargetDir},size(this.tplfiles,1),1),...
                strrep(this.tplfiles(:,1),this.templdir,''),...
                'UniformOutput',false);
            
            if isempty(this.tplfiles)
                error('MtestEngine:WrongTemplate','There is no template file (*.tpl) in the template directory');
            end
            
            temptemplatedir = tempname;
            mkdir(temptemplatedir);
            copyfile(fullfile(this.templdir,'*.*'),temptemplatedir,'f');
            
            % remove all svn dirs from the template
            DirsInTemplateDir = strread(genpath(temptemplatedir),'%s',-1,'delimiter',';');
            SvnDirsInTemplateDir = DirsInTemplateDir(~cellfun(@isempty,strfind(DirsInTemplateDir,'.svn')));
            
            % remove all svn dirs from the template
            for i=1:length(SvnDirsInTemplateDir)
                if isdir(SvnDirsInTemplateDir{i})
                    rmdir(SvnDirsInTemplateDir{i},'s');
                end
            end
            
            % copy template to target dir
            copyfile(fullfile(temptemplatedir,'*.*'),this.TargetDir,'f');
            rmdir(temptemplatedir,'s');
            
            publishstylesheet = dir(fullfile(this.templdir,'*.xsl'));
            if ~isempty(publishstylesheet)
                this.StyleSheet = fullfile(this.templdir,publishstylesheet.name);
            else
                this.StyleSheet = '';
            end
            
            if ~isdir(fullfile(this.TargetDir,'html'))
                mkdir(fullfile(this.TargetDir,'html'));
            end
            
            this.TargetDirectoryPrepared = true;
        end
        function publishtemplate(this,obj,varargin)
            this = setproperty(this,varargin);
            
            if ~this.TargetDirectoryPrepared
                this.preparetargetdir;
            end
            
            TeamCity.postmessage('progressMessage', 'Printing test result and documentation to html');
            if obj.Verbose
                disp('Printing test result and documentation to html');
            end
            for itpl = 1:size(this.tplfiles,1)
                tplfilename = fullfile(this.tplfiles{itpl,1},this.tplfiles{itpl,2});
                
                this.filltemplate(obj,tplfilename);
            end
                
            %% run any code that is in the targetdir
            mfiles = MTestUtils.listfiles(this.templdir,'m',true);
            if ~isempty(mfiles)
                mfiles(:,1) = cellfun(@fullfile,...
                    repmat({obj.TargetDir},size(mfiles,1),1),...
                    strrep(mfiles(:,1),this.templdir,''),...
                    'UniformOutput',false);
                for ifiles = 1:size(mfiles,1)
                    run(fullfile(mfiles{ifiles,1},mfiles{ifiles,2}));
                end
            end
            
            %% try opening index.html or home.html
            if ~TeamCity.running && this.Verbose
                if exist(fullfile(this.TargetDir,'index.html'),'file')
                    winopen(fullfile(this.TargetDir,'index.html'));
                elseif exist(fullfile(this.TargetDir,'home.html'),'file')
                    winopen(fullfile(this.TargetDir,'home.html'));
                end
            end
        end
    end
    methods (Static = true, Hidden = true)
        function obj = filltemplate(obj,tplfilename)
            %fillTemplate  Replaces keywords in a template file with information from an mtestengine obj.
            %
            %   This function reads the string from a template file and replaces keywords with
            %   values from the mtestengine object. Allowed keywords:
            %
            %       keywords defining a loop:
            %       <!-- ##BEGINTESTS -->/<!-- ##ENDTESTS -->
            %                               All code between these two keywords is copied and
            %                               filled (keywords are replaced by the correct
            %                               information) for each individual test. The resulting
            %                               strings are pasted successive.
            %       <!-- ##BEGINTESTCASE -->/<!-- ##ENDTESTCASE -->
            %                               In between the ##BEGINTESTS/##ENDTESTS keywords these
            %                               keywords can be placed. The ##BEGINTESTCASE and
            %                               ##ENDTESTCASE keywords are treated in the same manner as
            %                               the loop definition of the tests, but now with
            %                               the correct information of the testcases within a test.
            %       <!-- ##BEGINSUCCESSFULLTESTS -->/<!-- ##ENDSUCCESSFULLTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINUNSUCCESSFULLTESTS -->/<!-- ##ENDUNSUCCESSFULLTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINNEUTRALTESTS -->/<!-- ##ENDNEUTRALTTESTS -->
            %                               TODO - write help
            %       <!-- ##BEGINFUNCTIONCALLS -->/<!-- ##ENDFUNCTIONCALLS -->
            %                               TODO - write help
            %
            %       Including test results and results of testcases, part of a template file can
            %       look like this:
            %
            %       <!-- ##BEGINTESTS -->
            %           "Some html code that must be repeated for each test (including test keywords)
            %           <p>The name of this test is: #TESTNAME</p>
            %           <!-- ##BEGINTESTCASE -->
            %               "Some html code that must be repeated for each testcase (including testcase keywords)
            %               <p>The name of this testcase is: #TESTCASENAME</p>
            %           <!-- ##ENDTESTCASE -->
            %       <!-- ##ENDTESTS -->
            %
            %       General keywords:
            %       #POSITIVEICON           -   Is replaced by a reference to the positive icon.
            %       #NEGATVIEICON           -   Is replaced by a reference to the negative icon.
            %       #NEUTRALICON            -   Is replaced by a reference to the neutral icon.
            %       #NRTESTSTOTAL           -   Is replaced by the total number of tests in the
            %                                   mtestengine object.
            %       #NRTESTCASESTOTAL       -   Is replaced by the total number of testcases in the
            %                                   tests that are part of the mtestengine object.
            %       #NRSUCCESSFULLTESTS     -   Is replaced by the number of successfull tests
            %                                   (testresult = true).
            %       #NRUNSUCCESSFULLTESTS   -   Is replaced by the number of unsuccessfull tests
            %                                   (testresult = false).
            %       #NRNEUTRALTESTS         -   Is replaced by the number of tests that had no test
            %                                   results (testresult = NaN).
            %
            %       test keywords:
            %       #TESTDATE           -   TODO
            %       #TESTAUTHOR         -   TODO
            %       #TESTNUMBER         -   Is replaced by the location (number) of the test within
            %                               the mtestengine object. This keyword can be used to
            %                               reference a certain object or location in the file.
            %       #DESCRIPTIONHTML    -   This keyword is replaced by the location of the html
            %                               file of the test description that was created with the
            %                               publish function. The location is relative to the
            %                               targetdir.
            %       #RESULTHTML         -   This keyword is replaced by the location of the html
            %                               file of the published results that was created with the
            %                               publish function. The location is relative to the
            %                               targetdir.
            %       #TESTNAME           -   This keyword is replaced by the name of the test.
            %
            %       testcase keywords:
            %       #TESTCASENAME       -   This keyword is replaced by the name of the testcase.
            %       #TESTCASENUMBER     -   This keyword is replaced by the number of the testcase.
            %       #DESCRIPTIONHTML    -   This keyword is replaced by the location of the
            %                               published html file of the testcase description. The
            %                               location is relative to the target dir.
            %       #RESULTHTML         -   This keyword is replaced by the location of the
            %                               published html file of the test results. The
            %                               location is relative to the target dir.
            %
            %       specifying variable icons:
            %       #ICON               -   This keyword is replaced with the reference to an icon
            %                               specifying whether the current test or testcase was
            %                               successfull, unsuccessfull or did not produce a
            %                               testresult.
            %       The relative paths to these three icons can be specified in the template with
            %       the following phrase (usually placed at the end of a tpl file):
            %
            %       <!-- ##ICONS -->
            %       <!-- #POSITIVE='relative path to the icon indicating a positive result' -->
            %       <!-- #NEUTRAL='relative path to the icon indicating no testresult' -->
            %       <!-- #NEGATIVE='relative path to the icon indicating a negative result' -->
            %       <!-- ##ENDICONS -->
            %
            %   Syntax:
            %   outobj = obj.fillTemplate(tplfilename);
            %   fillTemplate(obj,tplfilename)
            %
            %   Input:
            %   obj         -   an mtestengine object.
            %   tplfilename -   Full path to the tpl file in the target dir.
            %
            %   Output:
            %   outobj  -   The same mtestengine object that entered the function.
            %
            %   See also mtestengine mtestengine.mtestengine mtestengine.run mtestengine.runAndPublish mtest mtestcase
            
            %% Check if the file was there
            if ~exist(tplfilename,'file')
                return
            end
            
            %% Acquire template string
            fid = fopen(tplfilename);
            str = fread(fid,'*char')';
            fclose(fid);
            
            ends = strfind(str,'-->');
            
            %% Get icons (positive and negative result)
            idbeg = strfind(str,'#ICONS');
            idend = strfind(str,'#ENDICONS');
            idPos = strfind(str,'#POSITIVE');
            idPos(idPos>idend | idPos<idbeg) = [];
            
            positiveIm = '';
            if ~isempty(idPos)
                positiveIm = strtrim(str(idPos+10:min(ends(ends>idPos))-1));
            else
                % copy and reference default icon?
            end
            
            idNeg = strfind(str,'#NEGATIVE');
            idNeg(idNeg>idend | idNeg<idbeg) = [];
            negativeIm = '';
            if ~isempty(idNeg)
                negativeIm = strtrim(str(idNeg+10:min(ends(ends>idNeg))-1));
            else
                % copy and reference default icon?
            end
            
            idNeutral = strfind(str,'#NEUTRAL');
            idNeutral(idNeutral>idend | idNeutral<idbeg) = [];
            neutralIm = '';
            if ~isempty(idNeutral)
                neutralIm = strtrim(str(idNeutral+9:min(ends(ends>idNeutral))-1));
            else
                % copy and reference default icon?
            end
            
            %% replace general keywords
            % #POSITIVEICON
            % #NEGATVIEICON
            % #NEUTRALICON
            % #NRSUCCESSFULLTESTS
            % #NRUNSUCCESSFULLTESTS
            % #NRNEUTRALTESTS
            % #NRTESTSTOTAL
            % #NRTESTCASESTOTAL
            
            str = strrep(str,'#POSITIVEICON',positiveIm);
            str = strrep(str,'#NEGATIVEICON',negativeIm);
            str = strrep(str,'#NEUTRALICON',neutralIm);
            tr = cat(1,obj.Tests(:).TestResult);
            str = strrep(str,'#NRSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr)))));
            str = strrep(str,'#NRUNSUCCESSFULLTESTS',num2str(sum(tr(~isnan(tr))==0)));
            str = strrep(str,'#NRNEUTRALTESTS',num2str(sum(isnan(tr))));
            str = strrep(str,'#NRTESTSTOTAL',num2str(length(obj.Tests)));
            
            %% Loop all tests
            str = MTestPublisher.loopandfilltests(obj,...
                str,...
                '##BEGINTESTS',...
                '##ENDTESTS',...
                true(size(obj.Tests)),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop successfulltests
            str = MTestPublisher.loopandfilltests(obj,...
                str,...
                '##BEGINSUCCESSFULLTESTS',...
                '##ENDSUCCESSFULLTESTS',...
                ~(isnan([obj.Tests.TestResult]) | [obj.Tests(:).TestResult]==false),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop unsuccessfulltests
            str = MTestPublisher.loopandfilltests(obj,...
                str,...
                '##BEGINUNSUCCESSFULLTESTS',...
                '##ENDUNSUCCESSFULLTESTS',...
                ~(isnan([obj.Tests.TestResult]) | [obj.Tests(:).TestResult]==true),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Loop neutral test
            str = MTestPublisher.loopandfilltests(obj,...
                str,...
                '##BEGINNEUTRALTESTS',...
                '##ENDNEUTRALTESTS',...
                isnan([obj.Tests(:).TestResult]),...
                positiveIm,...
                negativeIm,...
                neutralIm);
            
            %% Write output file (replace .tpl with .html)
            [pt fname] = fileparts(tplfilename);
            [emptydummy fname ext] = fileparts(fname); %#ok<*ASGLU>
            if ~isempty(ext)
                fullfname = fullfile(pt,[fname ext]);
            else
                fullfname = fullfile(pt,[fname '.html']);
            end
            fid = fopen(fullfname,'w');
            fprintf(fid,'%s',str);
            fclose(fid);
            
            %% Remove tpl file from target dir
            delete(tplfilename);
        end
        function str = loopandfilltests(obj,str,beginstring,endstring,testid,positiveIm,negativeIm,neutralIm)
            %% Find string that must be looped (replace with '#@#TESTSTRTING')
            ends = strfind(str,'-->');
            
            if ~isempty(strfind(str,beginstring))
                begstrids = strfind(str,beginstring);
                idteststrends = strfind(str,endstring)-6;
                for istr = length(begstrids):-1:1
                    idteststrbegin = min(ends(ends>begstrids(istr)))+4;
                    idteststrend = idteststrends(istr)-6;
                    teststr = str(idteststrbegin:idteststrend);
                    str = strrep(str,teststr,'#@#TESTSTRING');
                    
                    %% Loop tests
                    finalstr = '';
                    testid = find(testid);
                    for itest = 1:length(testid)
                        %% create teststring and replace keywords
                        % #TESTNUMBER
                        % #ICON
                        % #TESTNAME
                        % #DESCRIPTIONHTML
                        % #COVERAGEHTML
                        % #RESULTHTML
                        % #TESTDATE
                        % #TESTAUTHOR
                        % #TESTTIME
                        
                        id = testid(itest);
                        
                        tempstr = teststr;
                        % #TESTNUMBER
                        tempstr = strrep(tempstr,'#TESTNUMBER',num2str(id));
                        
                        % #ICON
                        if obj.Tests(id).Ignore
                            tempstr = strrep(tempstr,'#ICON',neutralIm);
                        elseif obj.Tests(id).TestResult
                            tempstr = strrep(tempstr,'#ICON',positiveIm);
                        else
                            tempstr = strrep(tempstr,'#ICON',negativeIm);
                        end
                        
                        % #TESTNAME
                        if ~isempty(obj.Tests(id).Name)
                            tempstr = strrep(tempstr,'#TESTNAME',obj.Tests(id).Name);
                        else
                            tempstr = strrep(tempstr,'#TESTNAME',obj.Tests(id).FileName);
                        end
                        
                        
                        % #TESTHTML (backwards compatibility)
                        % #DESCRIPTIONHTML
                        tc = TeamCity;
                        fNameDescription = fullfile(tc.PublishDirectory,[obj.Tests(id).FileName,'_description.html']);
                        if exist(fNameDescription,'file')
                            [dum fn ext] = fileparts(fNameDescription);
                            tempstr = strrep(tempstr,'#TESTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                            tempstr = strrep(tempstr,'#DESCRIPTIONHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        else
                            tempstr = strrep(tempstr,'#TESTHTML','');
                            tempstr = strrep(tempstr,'#DESCRIPTIONHTML','');
                        end
                        
                        %                         % #COVERAGEHTML
                        %                         if ~isempty(obj.tests(id).coverageoutputfile)
                        %                             [dum fn ext] = fileparts(obj.tests(id).coverageoutputfile);
                        %                             tempstr = strrep(tempstr,'#COVERAGEHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        %                         else
                        %                             tempstr = strrep(tempstr,'#COVERAGEHTML','');
                        %                         end
                        
                        % #RESULTHTML
                        fNamePublish = fullfile(tc.PublishDirectory,[obj.Tests(id).FileName,'_publish.html']);
                        if exist(fNamePublish,'file')
                            [dum fn ext] = fileparts(fNamePublish);
                            tempstr = strrep(tempstr,'#RESULTHTML',strrep(fullfile('html',[fn ext]),filesep,'/'));
                        else
                            tempstr = strrep(tempstr,'#RESULTHTML','');
                        end
                        
                        
                        % #TESTDATE
                        if isempty(obj.Tests(id).Date)
                            obj.Tests(id).Date = NaN;
                        end
                        if isnan(obj.Tests(id).Date)
                            tempstr = strrep(tempstr,'#TESTDATE','Never');
                        else
                            tempstr = strrep(tempstr,'#TESTDATE',datestr(obj.Tests(id).Date,'yyyy-mm-dd (HH:MM:ss)'));
                        end
                        
                        % #TESTAUTHOR
                        if isempty(obj.Tests(id).Author)
                            tempstr = strrep(tempstr,'#TESTAUTHOR','Unknown');
                        else
                            tempstr = strrep(tempstr,'#TESTAUTHOR',obj.Tests(id).Author);
                        end
                        
                        % #TESTTIME
                        tempstr = strrep(tempstr,'#TESTTIME',num2str(obj.Tests(id).Time,'%0.1f (s)'));
                        
                        %% concatenate teststrings
                        finalstr = cat(2,finalstr,tempstr);
                    end
                    
                    %% replace the test loop with the teststring.
                    str = strrep(str,'#@#TESTSTRING',finalstr);
                end
            else
                return
            end
        end
    end
end