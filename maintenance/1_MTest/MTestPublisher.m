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
                    catch  me
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
end