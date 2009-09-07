classdef tbtoolbox
    % TBTOOLBOX is an object that contains information about a toolbox
    %
    % This object can be part of a tbdocumentation. It is used to store
    % functions, directory structures and function calls.
    %
    % methods:
    %   analyze:        analyze the toolbox, cross references etc.
    %   structuredirs:  build a struc comparable to the directory structure.
    %   gettemplate:    routine to identify the template and justify the
    %                   location of the template.
    %   ready:          returns a logical that indicates whether the toolbox is
    %                   ready to be documented (or it still has to be
    %                   analyzed).
    % Static methods:
    %   listallmfile:   lists all mfiles in the toolbox.
    %   ismfile:
    %   getfilenamefromfile:
    %   dirlisting:     list directories.
    %
    % See also tbdocumentation tbmfile tbcontentitem tbindexitem
    
    %% Begin properties
    properties
        maindirs = '';
        dirs = '';
        dirstructure = struct(...
            'dirname','',...
            'filerefs',[],...
            'subdirs',[]);
        exclusions = '';
        functions = [];
        calls = {};
        called = {};
        template = 'default';
    end

    %% Begin methods
    methods
        %% Constructor method
        function obj = tbtoolbox(varargin)
            if nargin==0
                return
            end
            obj.maindirs = varargin{1};
            if nargin>1
                obj.exclusions = varargin{2};
            end
        end
        %% Other methods
        function obj = analyze(obj)
            % ANALYZE analyzed the toolbox functions and directory structure
            %
            % Analyse lists all directories and functions in a toolbox. All
            % functions are stored as a tbmfile object in the tbtoolbox
            % object on which the function was applied.
            %
            % Syntax: obj = analyze(obj)
            % 
            % Input:
            %   obj     =   tbtoolbox object
            %
            % Output:
            %   obj     =   tbtoolbox object
            % 
            % See also tbtoolbox
            
            %% list files
            [drs mfiles] = tbtoolbox.listallmfiles(obj.maindirs,obj.exclusions);
            mfilesuni = unique(mfiles);
            obj.dirs = drs;
            if any(size(mfiles)~=size(mfilesuni))
                warning('Toolbox:DoubleFiles','Double filenames were encountered in the toolbox. Just one of the functions is taken. This could cause referencing problems in the documentation');
            end
            for iexcl = 1:length(obj.exclusions)
                mfilesuni(~cellfun(@isempty,strfind(mfilesuni,obj.exclusions{iexcl})))=[];
            end

            %% make function objects from functions
            obj.functions = tbmfile(mfilesuni);

            %% order calls and calleds
            obj.functions(cellfun(@isempty,{obj.functions.filename}'))=[]; % removes all scripts (use only functions)
            functionnames = {obj.functions.filename}';
            callsstr = {obj.functions.functioncalls}';
            [obj.calls obj.called] = deal(cell(size(functionnames)));
            for iff = 1:length(obj.functions)
                for ic = 1:length(callsstr{iff,1})
                    id = find(strcmp(functionnames,callsstr{iff,1}{ic}));
                    if ~isempty(id)
                        obj.calls{iff} = cat(2,obj.calls{iff}, id);
                        obj.called{id} = cat(2,obj.called{id},iff);
                        obj.functions(iff).functioncallsinhtml(ic) = true;
                        obj.functions(id).functioncalledby =  cat(1,obj.functions(id).functioncalledby,functionnames(iff));
                        obj.functions(id).functioncalledinhtml = true(size(obj.functions(id).functioncalledby));
                    end
                end
            end
        end
        function obj = structuredirs(obj,mergemaindirs)
            maindirs = obj.maindirs;
            dirnames = obj.dirs;
            filepaths = {obj.functions(:).path}';
            filenames = {obj.functions(:).filename}';
            fileh1lines = {obj.functions(:).h1line}';
            maindirs = sort(maindirs);

            % prepare dirs and files
            [dirnames] = sort(dirnames);
            dirsrel = dirnames;
            filepathsrel = filepaths;
            maindirid = nan(size(dirnames,1),1);
            maindirfileid = nan(size(filepaths,1),1);
            for imd = 1:length(maindirs)
                if strcmp(maindirs{imd}(end),filesep)
                    maindirs{imd}(end) = [];
                end
                maindirid(~cellfun(@isempty,strfind(dirnames,maindirs{imd})))=imd;
                maindirfileid(~cellfun(@isempty,strfind(filepaths,maindirs{imd}))) = imd;
                dirsrel = cellfun(@strrep,dirsrel,repmat({[maindirs{imd} filesep]},size(dirnames)),repmat({''},size(dirnames)),'Uniformoutput',false); %#ok<PROP>
                filepathsrel = cellfun(@strrep,filepathsrel,repmat({[maindirs{imd} filesep]},size(filepathsrel)),repmat({''},size(filepathsrel)),'Uniformoutput',false); %#ok<PROP>
                filepathsrel = cellfun(@strrep,filepathsrel,repmat(maindirs(imd),size(filepathsrel)),repmat({''},size(filepathsrel)),'Uniformoutput',false); %#ok<PROP>
            end
            dirs = cellfun(@strread,dirsrel,repmat({'%s'},size(dirnames)),repmat({'delimiter'},size(dirnames)),repmat({'\\'},size(dirnames)),'UniformOutput',false);
            emptdirid = cellfun(@isempty,dirs);
            dirs(emptdirid)=[];
            maindirid(emptdirid)=[];
            dircell = repmat({''},size(dirs,1),max(cellfun(@length,dirs)));
            for idirs = 1:size(dirs,1)
                dircell(idirs,1:length(dirs{idirs})) = dirs{idirs};
            end
            filepathstemp = cellfun(@strread,filepathsrel,repmat({'%s'},size(filepaths)),repmat({'delimiter'},size(filepaths)),repmat({'\\'},size(filepaths)),'UniformOutput',false);
            pathcell = repmat({''},size(filepathstemp,1),max(cellfun(@length,filepathstemp)));
            for ifiles = 1:size(pathcell,1)
                pathcell(ifiles,1:length(filepathstemp{ifiles})) = filepathstemp{ifiles};
            end

            % construct dirstruct
            dirstruct = tbtoolbox.createdirstruct;
            for imain = 1:length(maindirs)
                maindir = strread(maindirs{imain},'%s','delimiter',[filesep filesep]);
                if mergemaindirs
                    indirid = cellfun(@isempty,pathcell(:,1));
                    if isempty(dirstruct)
                        dirstruct(1).fulldirname = maindir(end);
                    else
                        dirstruct.fulldirname = strrep([dirstruct.fulldirname{:}, ' ', maindir{end}],' ','_');
                    end
                    dirstruct.originaldirname = cat(1,dirstruct.originaldirname,maindir(end));
                    dirstruct.dirname = strrep(fullfile(dirstruct.dirname,maindir{end}),filesep,'/');
                    dirstruct.fcnref = cat(1,dirstruct.fcnref,filenames(indirid & maindirfileid==imain));
                    dirstruct.fcnh1line = cat(1,dirstruct.fcnh1line,fileh1lines(indirid & maindirfileid==imain));
                    if imain==length(maindirs)
                        dirstruct.subdirs = tbtoolbox.adddirstodirstruct([],dircell,pathcell(~indirid,:),filenames(~indirid),dirstruct.fulldirname,fileh1lines(~indirid),maindir{end});
                    end
                else
                    dirstruct(imain).dirname = maindir{end};
                    dirstruct(imain).fulldirname = maindir{end};
                    indirid = cellfun(@isempty,pathcell(:,1));
                    dirstruct(imain).fcnref = filenames(indirid & maindirfileid==imain);
                    dirstruct(imain).fcnh1line = fileh1lines(indirid & maindirfileid==imain);
                    pathname = maindir{end};
                    dirstruct(imain).subdirs = tbtoolbox.adddirstodirstruct([],dircell(maindirid==imain,:),pathcell(maindirfileid==imain & ~indirid,:),filenames(maindirfileid==imain & ~indirid),pathname,fileh1lines(maindirfileid==imain & ~indirid));
                end
            end
            obj.dirstructure = dirstruct;
        end
        function tf = ready(obj)
            % check if necessary info is there
            tf = ~isempty(obj);
        end
        %% set functions
        function obj = set.maindirs(obj,inp)
            if ischar(inp) && isdir(inp)
                % input is only one dir. Store as cell
                obj.maindirs = {inp};
            end
            if iscell(inp)
                % multiple dirs ==> check each dir seperately
                for i=length(inp):-1:1
                    if ~ischar(inp{i}) || ~isdir(inp{i})
                        % this is not a dir ==> remove from list
                        warning('Toolbox:NoDir','One of the input arguments is not a directory. This input will be ignored.');
                        inp(i)=[];
                    end
                end
                if ~isempty(inp)
                    % The remaining list is nog empty ==> store the dirs.
                    obj.maindirs = inp;
                end
            end
        end
        function obj = set.template(obj,tpl)
            obj.template = 'default';
            if exist(fullfile(fileparts(mfilename('fullpath')),'templates',obj.template),'dir')
                obj.template = tpl;
            end
        end
    end
    methods (Static = true)
        function [alldirs allmfiles allmfilenames allmfiledirnames] = listallmfiles(dirs,exc)
            mdrs = struct(...
                'dirs',{},...
                'files',{},...
                'mfiles',{});
            for idir = 1:length(dirs)
                [mdrs(idir).dirs dum mdrs(idir).files] = tbtoolbox.dirlisting(dirs{idir},exc);
                mdrs(idir).files = mdrs(idir).files';
                mdrs(idir).mfiles = mdrs(idir).files(cellfun(@tbtoolbox.ismfile,mdrs(idir).files));
            end
            alldirs = cat(1,mdrs(:).dirs);
            allmfiles = cat(1,mdrs(:).mfiles);
            allmfilenames = cellfun(@tbtoolbox.getfilenamefromfile,allmfiles,'UniformOutput',false);
            allmfiledirnames = cellfun(@fileparts,allmfiles,'UniformOutput',false);
        end
        function tf = ismfile(file)
            tf = strncmp(fliplr(file),'m.',2);
        end
        function fname = getfilenamefromfile(file)
            % GETFILENAMEFROMFILE gives name of the file
            %
            % isolates the filename from a full filename (with the use of
            % fileparts).
            %
            % Syntax: 
            %   fname = getfilenamefromfile(file)
            %
            % Input:
            %   file:   full file name (including path and ext.)
            %
            % Output:
            %   fname:  filename stript from the path and ext.
            %
            % See also fileparts
            
            %% strip filename
            [dum fname] = fileparts(file);
        end
        function [dirs dircont files] = dirlisting(maindir,exc)
            % DIRLISTING returns subdirectory names
            %
            % This function gives the names of all subdirs given a certain
            % directory name.
            %
            % syntax:
            %           [dirs dircont files] = dirlisting(maindir,exc)
            %
            % input:
            %   maindir         -   dirname of main directory (char).
            %   exc             -   exceptions (given as char or as a cell of character
            %                       arrays). All subdirectory names that contain one of
            %                       the exceptions specified will not be included in
            %                       the output.
            %
            % output:
            %   dirs            -   cell array of strings with all names of the
            %                       subdirs.
            %   dircont         -   structure the same length as dirs with for each dir
            %                       a field name (that includes the same name as in
            %                       dirs) and content (which is a listing of the files
            %                       and their properties in that dir. this is the
            %                       output structure of the command "dir").
            %   files           -   All filenames that are listed in the subdirs
            %
            % See also dir

            %   --------------------------------------------------------------------
            %   Copyright (C) 2008 Deltares
            %       C.(Kees) den Heijer / Pieter van Geer
            %
            %       Kees.denHeijer@deltares.nl / Pieter.vanGeer@deltares.nl
            %
            %       Deltares
            %       P.O. Box 177
            %       2600 MH Delft
            %       The Netherlands
            %
            %   This library is free software; you can redistribute it and/or
            %   modify it under the terms of the GNU Lesser General Public
            %   License as published by the Free Software Foundation; either
            %   version 2.1 of the License, or (at your option) any later version.
            %
            %   This library is distributed in the hope that it will be useful,
            %   but WITHOUT ANY WARRANTY; without even the implied warranty of
            %   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
            %   Lesser General Public License for more details.
            %
            %   You should have received a copy of the GNU Lesser General Public
            %   License along with this library; if not, write to the Free Software
            %   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307
            %   USA
            %   or http://www.gnu.org/licenses/licenses.html, http://www.gnu.org/, http://www.fsf.org/
            %   --------------------------------------------------------------------% --------------------------------------------------------------------------

            %% check input
            if nargin == 0
                return
            end

            %% create cell with dirnames
            dirs = strread(genpath(maindir), '%s', 'delimiter', pathsep);

            %% check exceptions
            if nargin > 1
                if ischar(exc)
                    exc = {exc};
                end
                for iexc = 1: length(exc)
                    % find dirs containing exc in their name
                    id = ~cellfun(@isempty, strfind(dirs, exc{iexc}));
                    % remove dirs containing exc in their name
                    dirs(id) = [];
                end
            end

            %% file contents for each dir; cell dircont corresponds to dirs
            if nargout > 1
                dircont = struct(...
                    'name', '',...
                    'content', '');
                if nargout > 2
                    files = cell(0);
                end
                % get file info
                for i = 1:length(dirs)
                    cnt = dir(dirs{i});
                    dircont(i).name = dirs{i};
                    dircont(i).content = cnt(~[cnt.isdir]);
                    if nargout > 2
                        for j = 1:length(dircont(i).content)
                            files{end+1} = fullfile(dirs{i}, dircont(i).content(j).name); %#ok<AGROW>
                        end
                    end
                end
            end
        end
    end
    methods (Access = 'private', Static = true)
        function dirstruct = adddirstodirstruct(dirstruct,dirs,filepaths,filenames,pathname,fileh1lines,originaldirname)
            if isempty(dirstruct)
                dirstruct = tbtoolbox.createdirstruct;
            end
            newdirs = unique(dirs(:,1)); %#ok<PROP>
            for idr = 1:length(newdirs)
                dirstruct(idr).dirname = newdirs{idr};
                dirpathname = fullfile(pathname,newdirs{idr});
                dirstruct(idr).fulldirname = dirpathname;
                originaldirpathname = fullfile(originaldirname,newdirs{idr});
                dirstruct(idr).originaldirname = originaldirpathname;
                % files ref
                indirid = strcmp(filepaths(:,1),newdirs{idr});
                subdirspresent = size(filepaths,2)>1;
                insubdirid = nan(size(filenames));
                if subdirspresent
                    indirid = strcmp(filepaths(:,1),newdirs{idr}) & cellfun(@isempty,filepaths(:,2));
                    insubdirid = strcmp(filepaths(:,1),newdirs{idr}) & ~cellfun(@isempty,filepaths(:,2));
                end
                dirstruct(idr).fcnref = filenames(indirid);
                dirstruct(idr).fcnh1line = fileh1lines(indirid);
                if subdirspresent && size(dirs,2)>1
                    % subdirs
                    subdirs = dirs(strcmp(dirs(:,1),newdirs{idr}) & ~cellfun(@isempty,dirs(:,2)),2:end); %#ok<PROP>
                    if ~isempty(subdirs)
                        if size(filepaths,2)==1
                            fp = {};
                            fils = {};
                            fh1lines = {};
                        else
                            fp = filepaths(insubdirid,2:end);
                            fils = filenames(insubdirid,:);
                            fh1lines = fileh1lines(insubdirid);
                        end
                        dirstruct(idr).subdirs = tbtoolbox.adddirstodirstruct([],subdirs,fp,fils,dirpathname,fh1lines,originaldirpathname);
                    end
                end
            end
        end
        function str = createdirstruct(dirnames)
            if nargin==0
                dirnames= [];
            end
            str = struct(...
                'dirname',dirnames,...
                'originaldirname',dirnames,...
                'fulldirname',dirnames,...
                'fcnref',{},...
                'fcnh1line',{},...
                'subdirs',[]);
        end
    end
end