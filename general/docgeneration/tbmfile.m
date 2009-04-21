classdef tbmfile
    properties
        path = '';
        filename = '';
        ext = '.m';

        helpcomments = '';
        h1line = '';
        description = '';
        syntax = '';
        input = '';
        output = '';
        keywords = '';
        seealso = '';
        code = '';

        builtincalls = '';
        functioncalls = '';
        functioncallsinhtml = [];
        functioncalledby = '';
        functioncalledinhtml = [];

        htmltemplate = fullfile(fileparts(mfilename('fullpath')),'templates','default','fcnhtml','mfile.tpl');
        targetdir = '';
    end
    methods
        function obj = tbmfile(varargin)
            if nargin==1
                fnames = varargin{1};
                if ischar(fnames)
                    fnames = {fnames};
                end
                obj = tbmfile(size(fnames,1),size(fnames,2));
                found = true(size(obj));
                for iargs = 1:length(fnames)
                    if ~exist(fnames{iargs},'file')
                        warning('Toolbox:NoFile','One of the files is not found.');
                        found(iargs) = false;
                        continue
                    end
                    fname = which(fnames{iargs});
                    %% open function
                    fid = fopen(fname,'r');
                    str = strread(fread(fid,'*char')','%s','delimiter','\n');
                    fclose(fid);
                    
                    iscomment = cellfun(@strncmp,cellfun(@strtrim,str,'UniformOutput',false),repmat({'%'},size(str)),repmat({1},size(str)));
                    isemptyline = cellfun(@isempty,cellfun(@strtrim,str,'UniformOutput',false));
                    iscodeline = ~iscomment & ~isemptyline;
                    ishelpblock = false(size(iscomment));
                    ishelpblock(2:find(~iscomment(2:end),1,'first')-1) = true;
                    
                    %% determine if it is a function
                    if ~any(strmatch('function',str{1}))
                        warning([fname ' is not recognised as a function and will be excluded.']); %#ok<WNTAG>
                        continue
                    end
                    
                    %% isolate help block
                    hlpblockold = str(ishelpblock);
                    hlpblock = cellfun(@strrep,hlpblockold,repmat({'%'},size(hlpblockold)),repmat({' '},size(hlpblockold)),'UniformOutput',false);
                    if isempty(hlpblock)
                        hlpblock = {'No help defined!!!'};
                    else
                        %% filter important lines / text
                        keys = {'descriptiondummy';'syntax:';'input:';'output:';'keywords';'% See also'};
                        keyid = nan(length(keys),2);
                        props = {'description','syntax','input','output','keywords','seealso'};
                        for ik = 1:length(keys)
                            id = find(~cellfun(@isempty,strfind(lower(hlpblock),lower(keys{ik}))));
                            if ~isempty(id)
                                keyid(ik,1) = id;
                            end
                        end
                        keyid(1,1) = 2;
                        keyid(1:end-1,2) = keyid(2:end,1)-1;
                        keyid(end,2) = size(hlpblock,1);
                        for ik = 1:size(keyid,1)
                            if isnan(keyid(ik,1))
                                keyid(ik-1,2) = min([keyid(ik:end,1); size(hlpblock,1)+1])-1;
                                keyid(ik,2) = nan;
                            end
                        end
                        for ik = 1:length(keys)
                            fld = props{ik};
                            if isnan(keyid(ik,1))
                                continue
                            end
                            ln = hlpblock(keyid(ik,1):keyid(ik,2),1);
                            ln(strcmp(strtrim(ln),'%'))=[];
                            if ~isempty(ln)
                                obj(iargs).(fld) = ln;
                            end
                        end
                    end
                    obj(iargs).helpcomments = hlpblock;
                    
                    %% store file properties
                    obj(iargs).h1line = hlpblock{1};
                    [obj(iargs).path obj(iargs).filename obj(iargs).ext] = fileparts(fname);
                    
                    %% get keywords
                    TODO('determine keywords');
                    
                    %% calls
                    callinf = getcallinfo(which(fname));
                    % subfunctions are recognozed and stored in
                    % callind(2:n). We could do something with this....
                    % make another object and return for example....
                    id = cellfun(@exist,callinf(1).calls)==5;
                    obj(iargs).builtincalls = callinf(1).calls(id)';
                    obj(iargs).functioncalls = callinf(1).calls(~id)';
                    obj(iargs).functioncallsinhtml = false(size(obj(iargs).functioncalls));
                    obj(iargs).functioncalledinhtml = false(size(obj(iargs).functioncalledby));
                end
                obj(~found)=[];
            end
            if nargin==2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
                obj(varargin{1},varargin{2}).path = '';
            end
        end
        function edit(obj)
           edit(fullfile(obj.path,[obj.filename,obj.ext]));
        end
    end
end