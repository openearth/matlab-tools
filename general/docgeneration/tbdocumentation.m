classdef tbdocumentation
    properties
        % general properties of documentation
        targetdir = '';
        help_location = 'helpdocs';
        matlabrelease = '2008a';
        name = 'Test';
        verbose = true;
        templatename = 'default';
        graphoptions = struct(...
            'color','black',...
            'fillcolor','lightskyblue',...
            'fontcolor','black',...
            'fontname','Arial',...
            'fontsize','6',...
            'fixedsize','false',...
            'height','0.1',...
            'width','0.8',...
            'orientation','0',...
            'shape','ellipse',...
            'style','filled',...
            'size','"5,6"',... in inches (page size)
            'dpi','200',...
            'aspect','"0.2,20"',...
            'viewport','"400,800"',...
            'extension','.html');

        % toolboxes
        toolbox = tbtoolbox;
        toolboxanalyzed = false;
        allfunctions = {}; %{naam, toolboxid, functionid, relpath}

        % start menu
        icon = [fileparts(mfilename('fullpath')) filesep 'templates\default\DeltaresLogo16.PNG'];
        listitems = tblistitem;
        type = 'toolbox';

        % html documentation
        excludeinmaster = {};
        includemastergraph = true;
        includefunctiongraphs = true;
        tpldir_dir = {};
        tpldir_maindir = {};
        tpldir_fcn = {};

        % help contents
        helpcontentmainpage = '';
        contentitems = tbcontentitem;
        includecontents = true;

        % help index
        indexitems = tbindexitem;
        includeindex = true;

        % help search
        includesearch = true;
    end
    methods
        %% constructor method
        function obj = tbdocumentation(varargin)
            % process input
            % find specification for template
            tmpid = find(strcmpi(varargin,'template'));
            if ~isempty(tmpid)
                tmp = varargin{tmpid+1};
                varargin(tmpid:tmpid+1)=[];
                % lees template dir en vul properties
            end

            % find maindir if present
            maindrid = find(strcmpi(varargin,'maindir'));
            if ~isempty(maindrid)
                maindr = varargin{maindrid+1};
                varargin(maindrid:maindrid+1)=[];
                % lees template dir en vul properties
            end

            % find exclded dirs if present
            exclid = find(strcmpi(varargin,'exclude'));
            if ~isempty(exclid)
                excl = varargin{exclid+1};
                varargin(exclid:exclid+1)=[];
                % lees template dir en vul properties
            end

            % set all properties that are left in varargin
            obj = setProperty(obj,varargin);

            % load template
            if ~isempty(tmpid)
                obj = obj.loadtemplate(tmp);
            end

            % set maindir(s) of toolbox(es)
            if ~isempty(maindrid)
                if ischar(maindr)
                    maindr = {maindr};
                end
                if all(cellfun(@ischar,maindr))
                    maindr = {maindr};
                end
                for im = 1:length(maindr)
                    obj.toolbox(im).maindirs = maindr{im};
                end
            end

            % set exclusion dirs
            if ~isempty(exclid)
                for itb = 1:length(obj.toolbox)
                    obj.toolbox(itb).exclusions = excl;
                end
            end
        end
        %% functions to make documentation
        function makedocumentation(obj)
            % check target dir (and create if necessary)
            if obj.verbose
                disp(' ');
                disp('Generation of toolbox documentation started');
                disp(' ');
                disp('*** Creating target directory');
            end
            targetdir = obj.targetdir;
            if isempty(targetdir) ||  ~ischar(targetdir)
                if obj.verbose
                    disp('    Target dir is empty or not identified as a dir.');
                end
                return % error
            end
            if  ~isdir(targetdir)
                mkdir(targetdir);
            elseif obj.verbose
                disp(['    Directory ("' targetdir '") already exists']);
            end
            if obj.verbose
                disp('*** Creating target icons directory');
            end
            if ~isdir([targetdir filesep 'icons'])
                mkdir([targetdir filesep 'icons']);
            elseif obj.verbose
                disp(['    Directory ("' targetdir filesep 'icons' '") already exists']);
            end

            % prepare directory structure
            if obj.includecontents
                % create help doc dir
                if obj.verbose
                    disp('*** Creating help contents');
                end
                if isempty(obj.help_location)
                    obj.help_location = 'helpdocs';
                end
                if obj.verbose
                    disp(['    # Create help location ("' obj.help_location '")']);
                end
                if ~isdir(fullfile(obj.targetdir,obj.help_location))
                    mkdir(fullfile(obj.targetdir,obj.help_location));
                elseif obj.verbose
                    disp('       help location already ecists');
                end
                if ~isdir(fullfile(obj.targetdir,obj.help_location,'html'))
                    mkdir(fullfile(obj.targetdir,obj.help_location,'html'));
                    % create blank.htm This file is used in case no target
                    % is specified.
                    fid = fopen(fullfile(obj.targetdir,obj.help_location,'html','blank.htm'),'w');
                    fprintf(fid,'Specify a html document for this item...');
                    fclose(fid);
                end
                if obj.verbose
                    disp('*** Copying templates');
                end
                obj = obj.copytemplates;
            end

            % write info.xml in main dir
            if obj.verbose
                disp('*** Writing info.xml');
            end
            writeinfoxml(obj);

            % for help functionality a help dir must be created that has a
            % helptoc.xml document
            if obj.includecontents
                % write table of contents (help)
                if obj.verbose
                    disp('*** Writing helptoc.xml');
                end
                writehelptocxml(obj);
                
                if obj.includeindex
                    disp('Help index is not implemented yet. Therefore use has to be made of keywords for example');
                    %{
                   % construct indexitems from function keywords
                   if obj.verbose
                       disp('*** Writing helpindex.xml');
                   end
                   obj = constructindex(obj);
                   writehelpindexxml(obj);
                    %}
                end
                
                if obj.includesearch
                   % construct search database from documentation
                   if obj.verbose
                       disp('*** Writing search database');
                   end
                   writesearchdb(obj);
                end
            end
            if obj.verbose
                disp('*** Finished writing the documentation');
                disp('  ');
            end
        end
        function writeinfoxml(obj)
            %% write main info.xml
            infoxml = [obj.targetdir filesep 'info.xml'];
            finfo = fopen(infoxml,'w');

            % write header
            fprintf(finfo,'%s',char(tbdocumentation.xmlheader('info')'));

            % write main properties toolbox
            if obj.verbose
                disp('    # main properties of the toolbox');
            end
            fprintf(finfo,['<matlabrelease>' obj.matlabrelease '</matlabrelease>\n']);
            fprintf(finfo,['<name>',obj.name,'</name>\n']);
            if ischar(obj.type) && ismember(obj.type,{'matlab','toolbox'})
                fprintf(finfo,['<type>',obj.type,'</type>\n']);
            else
                warning('Type is not recognized. Toolbox used as default'); %#ok<WNTAG>
                fprintf(finfo,'<type>toolbox</type>\n');
            end
            if exist(obj.icon,'file')
                if obj.verbose
                    disp('    # Copying icons');
                end
                [path fname ext] = fileparts(obj.icon);
                copyfile(obj.icon,fullfile(obj.targetdir,'icons',[fname,ext]));
                fprintf(finfo,['<icon>icons\\' fname ext '</icon>\n']);
            else
                warning('Icon not found.'); %#ok<WNTAG>
            end
            % help location
            if ~isempty(obj.help_location) && obj.includecontents
                if obj.verbose
                    disp('    # Creating help location');
                end
                fprintf(finfo,['<help_location>' obj.help_location '</help_location>\n']);
            end
            fprintf(finfo,'\n');

            % write list for start menu
            if ~isempty(obj.listitems)
                if obj.verbose
                    disp('    # Writing items of start menu');
                end
                fprintf(finfo,'<list>\n\n');
                for ili = 1:length(obj.listitems)
                    obj.listitems(ili).targetdir = obj.targetdir;
                    % copy icon and check callback for url references.
                    obj.listitems(ili) = obj.listitems(ili).prepare;
                    str = obj.listitems(ili).toString;
                    for ii = 1:size(str,1)
                        fprintf(finfo,[str{ii,1} '\n']);
                    end
                    fprintf(finfo,'\n');
                end
                fprintf(finfo,'</list>\n\n');
            end

            fprintf(finfo,'</productinfo>\n');
            fclose(finfo);
            if obj.verbose
                disp('    # Finished info.xml');
            end
        end
        function writehelptocxml(obj)
            % open file
            fid = fopen(fullfile(obj.targetdir,obj.help_location,'helptoc.xml'),'w');

            %write header
            if obj.verbose
                disp('    # writing header');
            end
            fprintf(fid,char(tbdocumentation.xmlheader('contents')'));

            % write toolbox home page
            if isempty(obj.helpcontentmainpage)
                obj.helpcontentmainpage = 'html/blank.htm';
            end
            fprintf(fid,...
                ['<tocitem target="' obj.helpcontentmainpage '">\n']);

            % print table of content items
            for ili = 1:length(obj.contentitems)
                objit = obj.contentitems(ili).prepare;
                if ischar(objit) && any(strfind(objit,'#tb_fcnref'))
                    if obj.verbose
                        disp('    # Toolbox reference found.');
                        disp('      --> Analyzing toolboxes.');
                    end
                    %% insert function references
                    %analyze all toolboxes (all functions must be known)
                    obj = obj.analyzetoolboxes;

                    if obj.verbose
                        disp('      --> Creating html from toolbox');
                    end
                    [obj tbnr objit] = tb2html(obj,objit);
                end
                % create string and insert in helpindex.xlm
                temp = struct('str','');
                for iobj=1:length(objit)
                    temp(iobj).str = objit(iobj).toString;
                end
                str = cat(1,temp(:).str);
                for ii = 1:size(str,1)
                    fprintf(fid,[str{ii,1} '\n']);
                end
                fprintf(fid,'\n');
            end

            % footer
            fprintf(fid,'</tocitem>\n');
            fprintf(fid,'\n');
            fprintf(fid,'</toc>');
            fclose(fid);
            if obj.verbose
                disp('    # Finished helptoc.xml');
            end
        end
        function createtoolboxgraph(obj,nr,name)
            % check help location
            if isempty(obj.help_location)
                error('TbToolbox:NoHelpLocation','No help location is specified. This function can not be executed.');
            end
            if nargin<2
                nr = 1:length(obj.toolbox);
            end
            % construct and make dir in which graph has to be stored
            graphdir = fullfile(obj.targetdir,obj.help_location,'toolboxgraphs');
            if ~isdir(graphdir)
                mkdir(graphdir);
            end

            % loop toolboxes
            for itb = 1:length(nr)
                tbnr = nr(itb);

                % if toolboxes are not analyzed, analyze
                if ~obj.toolboxanalyzed(tbnr)
                    obj.toolbox(tbnr) = obj.toolbox(tbnr).analyze;
                end
                href = obj.toolbox(tbnr).calls;
                href2 = nan(size(href,1),size(href,1));
                for i=1:size(href,1)
                    href2(i,href{i}) = 1;
                end
                paths = {obj.toolbox(tbnr).functions(:).path}';
                for imp = 1:length(obj.toolbox(tbnr).maindirs)
                    md = obj.toolbox(tbnr).maindirs{imp};
                    if strcmp(md(end),filesep)
                        md = md(1:end-1);
                    end
                    paths = cellfun(@strrep,paths,repmat({cat(2,md,filesep)},size(paths)),repmat({''},size(paths)),'UniformOutput',false);
                    paths = cellfun(@strrep,paths,repmat({md},size(paths)),repmat({''},size(paths)),'UniformOutput',false);
                end
                names = {obj.toolbox(tbnr).functions(:).filename}';
                references = {obj.toolbox(tbnr).functions(:).filename}';
                for inames = 1:size(names,1)
                    tempname = [strrep(paths{inames},filesep,'/') '/' names{inames,1}];
                    if strcmp(tempname(1),'/')
                        tempname = tempname(2:end);
                    end
                    references{inames,1} = ['#TOMAIN' tempname];
                end
                tgdir = fullfile(obj.targetdir,obj.help_location,'toolboxgraphs');
                tbdocumentation.makedotgraph(href2,references,names,obj.graphoptions,tgdir,name);
            end
        end
%         function writehelpindexxml(obj)
%             TODO('index functionality');
%         end
        function writesearchdb(obj)
            % This is a matlab function
            builddocsearchdb(fullfile(obj.targetdir,obj.help_location));
        end
        function [obj tbnr objit] = tb2html(obj,objit)
            % retrieve toolbox number to plot
            tbid = num2str(objit(strfind(objit,'#tb_fcnref')+10:end));
            tbnr = [1 length(obj.toolbox)];
            if ~isempty(tbid)
                tbnr = [tbid tbid];
            end

            % list all mfiles including properties
            mfiles = {};
            for itb = 1:length(obj.toolbox)
                mfilepaths ={obj.toolbox(itb).functions(:).path}';
                basepaths = cell(size(mfilepaths));
                for imain = 1:length(obj.toolbox(itb).maindirs)
                    md = obj.toolbox(itb).maindirs{imain};
                    if strcmp(md(end),filesep)
                        md = md(1:end-1);
                        fsid = strfind(md,filesep);
                        if isempty(fsid)
                            fsid = 0;
                        end
                        basename =md(max(fsid)+1:end);
                    end
                    id = ~cellfun(@isempty,strfind(mfilepaths,md)) | ~cellfun(@isempty,strfind(mfilepaths,[md filesep]));
                    basepaths(id) = {basename};
                    mfilepaths = cellfun(@strrep,mfilepaths,repmat({cat(2,md,filesep)},size(mfilepaths)),repmat({''},size(mfilepaths)),'UniformOutput',false);
                    mfilepaths = cellfun(@strrep,mfilepaths,repmat({md},size(mfilepaths)),repmat({''},size(mfilepaths)),'UniformOutput',false);
                end
                mfileinfo = cat(2,basepaths,mfilepaths,obj.allfunctions);
                mfiles = cat(1,mfiles,mfileinfo);
            end
            dirpath = fullfile(obj.targetdir,obj.help_location,'html');

            % loop toolboxes
            objit = [];
            for itb = tbnr(1):tbnr(2)
                if obj.verbose
                    disp('          Make content items from directory structure');
                end
                objit = cat(2,objit,tbdocumentation.dirstruct2contentitems(obj.toolbox(itb).dirstructure));

                % create documentation
                if obj.verbose
                    disp('          Create toolbox directory structure');
                end
                
                % make mastergraph if necessary
                graphname = '';
                if obj.includemastergraph
                    if obj.verbose
                        disp(['          Creating graph of Toolbox ' num2str(itb)]);
                    end
                    graphname = ['Toolbox_' num2str(itb)];
                    createtoolboxgraph(obj,itb,graphname);
                end
                if obj.verbose
                    disp('          Creating html for directories:');
                end
                for imain = 1:length(obj.toolbox(itb).dirstructure)
                    if obj.verbose
                        disp(['           ' obj.toolbox(itb).dirstructure(imain).fulldirname]);
                    end
                    if ~isdir(fullfile(dirpath,obj.toolbox(itb).dirstructure(imain).fulldirname));
                        mkdir(fullfile(dirpath,obj.toolbox(itb).dirstructure(imain).fulldirname));
                    elseif obj.verbose
                        disp(['            Warning: "' fullfile(dirpath,obj.toolbox(itb).dirstructure(imain).fulldirname) '" already exists']);
                    end
                    dirstructemp = obj.toolbox(itb).dirstructure(imain);
                    dirstructemp.subdirs = [];
                    tbdocumentation.dir2html(dirstructemp,...
                        dirpath,... % target dir
                        fullfile(obj.tpldir_maindir,'maindir.tpl'),... % template dir
                        obj.includemastergraph,...% include graph
                        graphname,...
                        obj.verbose); % name of the graph

                    % create subdir htmls (and functions)
                    for isub = 1:length(obj.toolbox(itb).dirstructure(imain).subdirs)
                        tbdocumentation.dir2html(obj.toolbox(itb).dirstructure(imain).subdirs(isub),...
                            dirpath,...
                            fullfile(obj.tpldir_dir,'dir.tpl'),...
                            false,...
                            [],...
                            obj.verbose);
                    end
                end

                % list all functions

                % create html of functions
                if obj.verbose
                    disp('         Creating html of function files:');
                end
                docdir = dirpath;
                for ifcn = 1:length(obj.toolbox(itb).functions)
                    % create full name
                    if obj.verbose
                        disp(['           ' obj.toolbox(itb).functions(ifcn).filename]);
                    end
                    trgdirname = fullfile(docdir,mfiles{ifcn,1},mfiles{ifcn,2});

                    obj.toolbox(itb).functions(ifcn).targetdir = trgdirname;
                    obj.toolbox(itb).functions(ifcn).htmltemplate = obj.tpldir_fcn;

                    % create html
                    tbdocumentation.mfile2html(obj.toolbox(itb).functions(ifcn),... % mfile object
                        dirpath,...
                        mfiles,...
                        obj.includefunctiongraphs,...
                        obj.graphoptions);
                end
            end
        end
        %% set functions
        function obj = set.templatename(obj,tmpname)
            m2htmldocdir = fileparts(mfilename('fullpath'));
            tmpdir = [m2htmldocdir filesep 'templates' filesep tmpname];
            if exist(tmpdir,'dir')
                obj.templatename = tmpname;
            else
                warning('tbtoolbox:NoTpl','Template could not be found');
                obj.templatename = 'default';
            end
        end
        function obj = set.targetdir(obj,trg)
            if ~ischar(trg)
                error('dir should be specified as a char');
            end
            obj.targetdir = trg;
            for i=1:length(obj.listitems)
                obj.listitems(i).targetdir = trg;
            end
        end
        function obj = analyzetoolboxes(obj)
            obj.allfunctions = {};
            for itb = 1:length(obj.toolbox)
                obj.toolbox(itb) = obj.toolbox(itb).analyze;
                obj.toolboxanalyzed(itb) = true;
                obj.toolbox(itb) = obj.toolbox(itb).structuredirs;
                fcns = cat(2,{obj.toolbox(itb).functions.filename}',...
                    repmat({itb},size(obj.toolbox(itb).functions,1),1),...
                    num2cell(permute(1:size(obj.toolbox(itb).functions,1),[2,1]))); % add relative path
                obj.allfunctions = cat(1,obj.allfunctions,fcns);
            end
        end
    end
    methods (Static = true)
        function dir2html(dirstruct,mainpath,tpl,includedirrgraph,graphname,verbose)
            % first process subdirs
            for isub = 1:length(dirstruct.subdirs)
                if verbose
                    disp(['           ' dirstruct.subdirs(isub).fulldirname]);
                end
                if ~isdir(fullfile(mainpath,dirstruct.subdirs(isub).fulldirname));
                    mkdir(fullfile(mainpath,dirstruct.subdirs(isub).fulldirname));
                elseif nargin==6 && verbose
                    disp(['            Warning: "' fullfile(mainpath,dirstruct.subdirs(isub).fulldirname) '" already exists']);
                end
                tbdocumentation.dir2html(dirstruct.subdirs(isub),...
                    mainpath,...
                    tpl,...
                    includedirrgraph);
            end

            % name target file
            htmlname = fullfile(mainpath,dirstruct.fulldirname,['dir_' dirstruct.dirname,'.html']);
            if ~isdir(fileparts(htmlname))
                mkdir(fileparts(htmlname));
            end

            % open origin and destination file
            fitpl = fopen(tpl,'r');
            tplstr = fread(fitpl,'*char')';
            fclose(fitpl);

            % first replace graph references

            if includedirrgraph
                graphdir = fullfile(mainpath(1:max(strfind(mainpath,filesep))-1),'toolboxgraphs');
                if ~exist(fullfile(graphdir,[graphname '.png']),'file')
                    warning('TbDocumentation:NoGRaph','Graph could not be found');
                else
                    figraph = fopen(fullfile(graphdir,[graphname '.map']),'r');
                    maptext = fread(figraph,'*char')';
                    fclose(figraph);
                    tplstr = strrep(tplstr,'#GRAPHMAP',maptext);

                    relgraphlocation = [repmat('../',1,numel(strfind(dirstruct.fulldirname,filesep))+2), 'toolboxgraphs','/', graphname, '.png'];
                    tplstr = strrep(tplstr,'#GRAPH',relgraphlocation);
                end
            end

            % then replace simple keywords
            tomain = repmat('../',1,numel(strfind(strrep(dirstruct.fulldirname,mainpath,''),filesep))+1);
            totpl = cat(2,tomain,strrep(strrep(fileparts(tpl),[mainpath filesep],''),filesep,'/'));
            tplstr = strrep(tplstr,'#TOTPL',totpl);
            tplstr = strrep(tplstr,'#NAME',dirstruct.dirname);
            tplstr = strrep(tplstr,'#TOMAIN',repmat('../',1,numel(strfind(strrep(dirstruct.fulldirname,mainpath,''),filesep))));


            idbeg = strfind(tplstr,'#BEGINCONTENT');
            idend = strfind(tplstr,'#ENDCONTENT');
            if ~isempty(idbeg) && ~isempty(idend) && idend-6 > idbeg+18
                % build string function references (including char(10))
                callstr = tplstr(idbeg+18:idend-6);
                newcallstr = '';
                for ifcn = 1:length(dirstruct.fcnref)
                    str = callstr;
                    str = strrep(str,'#FCNHTML',[dirstruct.fcnref{ifcn} '.html']);
                    str = strrep(str,'#FCNNAME',dirstruct.fcnref{ifcn});
                    str = strrep(str,'#FCNH1LINE',dirstruct.fcnh1line{ifcn});
                    newcallstr = cat(2,newcallstr,str);
                end
                tplstr = cat(2,tplstr(1:idbeg+17),newcallstr,tplstr(idend-5:end));
            end

            fihtml = fopen(htmlname,'w');
            fwrite(fihtml,tplstr,'char');
            fclose(fihtml);
        end
        function mfile2html(mfileobj,mainpath,functioncalls,includegraph,graphoptions)
            %             TODO('Include making graphs if specified');
            tpl = fullfile(mfileobj.htmltemplate,'mfile.tpl');
            if isempty(tpl) || ~exist(tpl,'file')
                warning('Template could not be found, default used.'); %#ok<WNTAG>
                obj.htmltemplate = fullfile(fileparts(mfilename('fullpath')),'templates','default','funchtml','mfile.tpl');
                tpl = obj.htmltemplate;
            end

            % read template
            fid = fopen(tpl,'r');
            tplstr = fread(fid,'*char')';
            fclose(fid);

            % determine whether graph has to be produced
            graphasked = any(strfind(tplstr,'#GRAPH'));
            if graphasked
                if includegraph
                    trgdir = mfileobj.targetdir;
                    trgname = mfileobj.filename;

                    calls = mfileobj.functioncalls(mfileobj.functioncallsinhtml);
                    called = mfileobj.functioncalledby(mfileobj.functioncalledinhtml);
                    names = unique(cat(1,calls,called,mfileobj.filename));
                    selfid = strcmp(names,mfileobj.filename);
                    references = cell(size(names));
                    references{selfid} = trgname;
                    
                    href = nan(numel(names),numel(names));
                    callid = false(length(names),2);
                    callid(selfid,1:end)=true;
                    for icalls = 1:length(calls)
                        id = strcmp(functioncalls(:,3),calls{icalls});
                        namesid = strcmp(names,calls{icalls});
                        if any(id)
                            callid(namesid,2) = true;
                            refid = strcmp(names,functioncalls{id,3});
                            href(selfid,refid) = 1;
                            references(refid) = {['#TOMAIN',strrep(fullfile(functioncalls{id,1:3}),filesep,'/')]};
                        end
                    end
                    for icalled = 1:length(called)
                        id = strcmp(functioncalls(:,3),called{icalled});
                        namesid = strcmp(names,called{icalled});
                        if any(id)
                            callid(namesid,2) = true;
                            refid = strcmp(names,functioncalls{id,3});
                            href(refid,selfid) = 1;
                            references(refid) = {['#TOMAIN',strrep(fullfile(functioncalls{id,1:3}),filesep,'/')]};
                        end
                    end
                    idclear = sum(callid,2)==0;
                    references(idclear)=[];
                    href(idclear,:)=[];
                    href(:,idclear)=[];
                    names(idclear)=[];
                    noproblem = tbdocumentation.makedotgraph(href,references,names,graphoptions,trgdir,trgname);
                    if noproblem
                        figraph = fopen(fullfile(trgdir,[trgname '.map']),'r');
                        maptext = fread(figraph,'*char')';
                        fclose(figraph);
                        tplstr = strrep(tplstr,'#GRAPHMAP',maptext);

                        graphlocation = [trgname, '.png'];
                        tplstr = strrep(tplstr,'#GRAPH',graphlocation);
                    end
                    % Make graph and include (see dir2html)
                else
                    warning('TbDocumentation:NoGraph','Template includes a function graph.');
                    tplstr = strrep(tplstr,'#GRAPHMAP','');
                    tplstr = strrep(tplstr,'#GRAPH','');
                end
            end

            % first replace simple keywords
            tplstr = strrep(tplstr,'#NAME',mfileobj.filename);
            tplstr = strrep(tplstr,'#H1LINE',mfileobj.h1line);
            tplstr = strrep(tplstr,'#DATE',datestr(now,'dd-mmm-yyyy'));
            

            funcpath = functioncalls{strcmp(functioncalls(:,3),mfileobj.filename),2};
            if isempty(funcpath)
                tomain = '../';
            else
                tomain = repmat('../',1,numel(strfind(funcpath,filesep))+2);
            end
            totpl = cat(2,tomain,strrep(strrep(fileparts(tpl),[mainpath filesep],''),filesep,'/'));
            tplstr = strrep(tplstr,'#TOMAIN',tomain);
            tplstr = strrep(tplstr,'#TOTPL',totpl);

            % concat strings vertically
            sntx = {''};
            if ~isempty(mfileobj.syntax)
                sntx = cellfun(@cat,repmat({2},size(mfileobj.syntax)),mfileobj.syntax,repmat({char(10)},size(mfileobj.syntax)),'UniformOutput',false);
            end
            tplstr = strrep(tplstr,'#SYNTAX',cat(2,sntx{:}));
            dscr = {''};
            if ~isempty(mfileobj.description)
                dscr = cellfun(@cat,repmat({2},size(mfileobj.description)),mfileobj.description,repmat({char(10)},size(mfileobj.description)),'UniformOutput',false);
            end
            tplstr = strrep(tplstr,'#DESCRIPTION',cat(2,dscr{:}));
            hlpbl = {''};
            if ~isempty(mfileobj.helpcomments)
                hlpbl = cellfun(@cat,repmat({2},size(mfileobj.helpcomments)),mfileobj.helpcomments,repmat({char(10)},size(mfileobj.helpcomments)),'UniformOutput',false);
            end
            tplstr = strrep(tplstr,'#HELPBLOCK',cat(2,hlpbl{:}));
            
            idbeg = strfind(tplstr,'#BEGINCALLED');
            idend = strfind(tplstr,'#ENDCALLED');
            if ~isempty(idbeg) && ~isempty(idend) && idend-6 > idbeg+17
                % build string function references (including char(10))
                callstr = tplstr(idbeg+17:idend-6);
                newcallstr = '';
                for icalls = 1:length(mfileobj.functioncalledby)
                    if mfileobj.functioncalledinhtml(icalls)
                        callfcn = mfileobj.functioncalledby{icalls};
                        callfcnid = strcmp(functioncalls(:,3),callfcn);
                        fcnref = cat(2,tomain,strrep(fullfile(functioncalls{callfcnid,1:2},[callfcn,'.html']),filesep,'/'));
                        str = strrep(callstr,'#CALLEDHTML',fcnref);
                        str = strrep(str,'#CALLEDNAME',callfcn);
                        str = strrep(str,'#CALLEDH1LINE','mfileobj.callh1line...');
                        newcallstr = cat(2,newcallstr,str);
                    end
                end
                tplstr = cat(2,tplstr(1:idbeg+16),newcallstr,tplstr(idend-5:end));
            end
            tplstr = strrep(tplstr,'#BEGINCALLED','#BGCALLED');
            tplstr = strrep(tplstr,'#ENDCALLED','#NDCALLED');

            idbeg = strfind(tplstr,'#BEGINCALL');
            idend = strfind(tplstr,'#ENDCALL');
            if ~isempty(idbeg) && ~isempty(idend) && idend-6 > idbeg+15
                % build string function references (including char(10))
                callstr = tplstr(idbeg+15:idend-6);
                newcallstr = '';
                for icalls = 1:length(mfileobj.functioncalls)
                    if mfileobj.functioncallsinhtml(icalls)
                        callfcn = mfileobj.functioncalls{icalls};
                        callfcnid = strcmp(functioncalls(:,3),callfcn);
                        fcnref = cat(2,tomain,strrep(fullfile(functioncalls{callfcnid,1:2},[callfcn,'.html']),filesep,'/'));
                        str = strrep(callstr,'#CALLHTML',fcnref);
                        str = strrep(str,'#CALLNAME',callfcn);
                        str = strrep(str,'#CALLH1LINE','mfileobj.callh1line...');
                        newcallstr = cat(2,newcallstr,str);
                    end
                end
                tplstr = cat(2,tplstr(1:idbeg+14),newcallstr,tplstr(idend-5:end));
            end
            
            fid = fopen(fullfile(trgdir,[trgname,'.html']),'w');
            fwrite(fid,tplstr,'char');
            fclose(fid);
        end
        function objit = dirstruct2contentitems(dirstructure)
            objit = tbcontentitem('name','dummy');
            for i=1:length(dirstructure)
                objit(i) = tbcontentitem(...
                    'name',dirstructure(i).dirname,...
                    'target',fullfile('html',dirstructure(i).fulldirname,['dir_' dirstructure(i).dirname,'.html']),...
                    'icon','foldericon');
                % create subdirs as children
                chid = 0;
                objit(i).children = tbcontentitem('name','dummy');
                if ~isempty(dirstructure(i).subdirs)
                    objit(i).children = tbdocumentation.dirstruct2contentitems(dirstructure(i).subdirs);
                    chid = length(objit(i).children);
                end
                % create children entries
                for ifile = 1:length(dirstructure(i).fcnref)
                    objit(i).children(chid+ifile) = tbcontentitem(...
                        'name',dirstructure(i).fcnref{ifile},...
                        'target',fullfile('html',dirstructure(i).fulldirname,[dirstructure(i).fcnref{ifile} '.html']),...
                        'icon','pageicon');
                end
            end
        end
    end
    methods (Access = 'private')
        function obj = copytemplates(obj)
            % create main template dir
            tpldir = fullfile(obj.targetdir,obj.help_location,'html','templates');
            if ~isdir(tpldir)
                mkdir(tpldir);
            end
            defaulttpldir = fullfile(fileparts(mfilename('fullpath')),'templates','default');
            origtpldir = fullfile(fileparts(mfilename('fullpath')),'templates',obj.templatename);

            % find maindir template and copy
            maindir_tpl = fullfile(defaulttpldir,'maindirhtml');
            if isdir(fullfile(origtpldir,'maindirhtml'))
                maindir_tpl = fullfile(origtpldir,'maindirhtml');
            end
            obj.tpldir_maindir = fullfile(tpldir,'maindirhtml');
            if ~isdir(obj.tpldir_maindir)
                mkdir(obj.tpldir_maindir);
            end
            mainfiles = dir(maindir_tpl);
            for ifiles = 1:length(mainfiles)
                if ~mainfiles(ifiles).isdir
                    copyfile(fullfile(maindir_tpl,mainfiles(ifiles).name),...
                        obj.tpldir_maindir);
                end
            end

            % find dir template and copy
            dir_tpl = fullfile(defaulttpldir,'dirhtml');
            if isdir(fullfile(origtpldir,'dirhtml'))
                dir_tpl = fullfile(origtpldir,'dirhtml');
            end
            obj.tpldir_dir = fullfile(tpldir,'dirhtml');
            if ~isdir(obj.tpldir_dir)
                mkdir(obj.tpldir_dir);
            end
            dirfiles = dir(dir_tpl);
            for ifiles = 1:length(dirfiles)
                if ~dirfiles(ifiles).isdir
                    copyfile(fullfile(dir_tpl,dirfiles(ifiles).name),...
                        obj.tpldir_dir);
                end
            end

            % find function template and copy
            fcn_tpl = fullfile(defaulttpldir,'fcnhtml');
            if isdir(fullfile(origtpldir,'fcnhtml'))
                fcn_tpl = fullfile(origtpldir,'fcnhtml');
            end
            obj.tpldir_fcn = fullfile(tpldir,'fcnhtml');
            if ~isdir(obj.tpldir_fcn)
                mkdir(obj.tpldir_fcn);
            end
            files = dir(fcn_tpl);
            for ifiles = 1:length(files)
                if ~files(ifiles).isdir
                    copyfile(fullfile(fcn_tpl,files(ifiles).name),...
                        obj.tpldir_fcn);
                end
            end
        end
        function obj = addlistitem(obj,item)
            if ~strcmp(class(item),'tblistitem')
                error('listitems must be of class tblistitem');
            end
            item.targetdir = obj.targetdir;
            if isempty(obj.listitems)
                obj.listitems = item;
            else
                obj.listitems(end+1) = item;
            end
        end
        function obj = constructindex(obj)
           TODO('Construct index'); 
        end
    end
    methods (Access = 'private', Static = true)
        function head = xmlheader(type)
            switch type
                case 'info'
                    head = [60;112;114;111;100;117;99;116;105;110;102;111;10;32;32;120;109;108;110;115;58;120;115;105;61;34;104;116;116;112;58;47;47;119;119;119;46;119;51;46;111;114;103;47;50;48;48;49;47;88;77;76;83;99;104;101;109;97;45;105;110;115;116;97;110;99;101;34;10;32;32;120;115;105;58;110;111;78;97;109;101;115;112;97;99;101;83;99;104;101;109;97;76;111;99;97;116;105;111;110;61;34;104;116;116;112;58;47;47;119;119;119;46;109;97;116;104;119;111;114;107;115;46;99;111;109;47;110;97;109;101;115;112;97;99;101;47;105;110;102;111;47;118;49;47;105;110;102;111;46;120;115;100;34;62;10;10;60;63;120;109;108;45;115;116;121;108;101;115;104;101;101;116;32;116;121;112;101;61;34;116;101;120;116;47;120;115;108;34;32;104;114;101;102;61;34;104;116;116;112;58;47;47;119;119;119;46;109;97;116;104;119;111;114;107;115;46;99;111;109;47;110;97;109;101;115;112;97;99;101;47;105;110;102;111;47;118;49;47;105;110;102;111;46;120;115;108;34;63;62;10;10];
                    % <productinfo>
                    %   xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                    %   xsi:noNamespaceSchemaLocation="http://www.mathworks.com/namespace/info/v1/info.xsd">
                    %
                    % <?xml-stylesheet type="text/xsl"href="http://www.mathworks.com/namespace/info/v1/info.xsl"?>
                    %
                case 'contents'
                    head = [60;63;120;109;108;32;118;101;114;115;105;111;110;61;34;49;46;48;34;32;101;110;99;111;100;105;110;103;61;34;73;83;79;45;56;56;53;57;45;49;34;63;62;10;10;60;116;111;99;32;118;101;114;115;105;111;110;61;34;49;46;48;34;62;10;10;];
                    % <?xml version="1.0" encoding="ISO-8859-1"?>
                    %
                    % <toc version="1.0">
                    %
                otherwise
                    head = [];
            end
        end
        function noproblem = makedotgraph(href2,references,names,options,targetdir,filename)
            % make dotfile (input file for dot.exe).
            mdotfile = [filename '.dot'];
            if false %options.verbose
                disp(['Creating dependency graph ' mdotfile '...']);
            end
            mdot({href2,references,names,options},fullfile(targetdir,mdotfile));
            noproblem = true;
            try
                %- see <http://www.research.att.com/sw/tools/graphviz/>
                %  <dot> must be in your system path:
                %    - on Linux, modify $PATH accordingly
                %    - on Windows, modify the environment variable PATH like this:

                % From the Start-menu open the Control Panel, open 'System' and activate the
                % panel named 'Extended'. Open the dialog 'Environment Variables'. Select the
                % variable 'Path' of the panel 'System Variables' and press the 'Modify button.
                % Then add 'C:\GraphViz\bin' to your current definition of PATH, assuming that
                % you did install GraphViz into directory 'C:\GraphViz'. Note that the various
                % paths in PATH have to be separated by a colon. Her is an example how the final
                % Path should look like:  ...;C:\WINNT\System32;...;C:\GraphViz\bin
                % (Note that this should have been done automatically during GraphViz installation)
                dot_exec = which('dot.exe');
                if isempty(dot_exec)
                    if exist('C:\Program Files\Graphviz2.16\bin\dot.exe','file')
                        dot_exec = '"C:\Program Files\Graphviz2.16\bin\dot.exe"';
                    else
                        answ = questdlg('"dot.exe" is not found on this computer. This external programm (http://www.graphviz.org) is needed tot create a dependency graph. Would you like to install the free programm?','Install graphviz?','Yes','No','Yes');
                        if strcmp(answ,'No')
                            return
                        else
                            graphvizinst = fullfile(fileparts(mfilename('fullpath')),'GraphViz','graphviz-2.18.msi');
                            try
                                system(graphvizinst);
                                [exe path] = uigetfile({'*.exe','executables';'*.*','All files'},'Locate dot.exe','C:\Program Files\Graphviz2.16\bin\dot.exe');
                                dot_exec = ['"' fullfile(path, exe) '"'];
                            catch err
                                rethrow(err);
                            end
                        end
                    end
                end

                eval(['!' dot_exec ' -Tcmap -Tpng ' '"' fullfile(targetdir,mdotfile) '"' ...
                    ' -o ' '"' fullfile(targetdir,[filename '.map']) '"' ...
                    ' -o ' '"' fullfile(targetdir,[filename '.png']) '"'])
                % use '!' rather than 'system' for backward compability
            catch %#ok<CTCH>
                noproblem = false;
            end
        end
    end
end