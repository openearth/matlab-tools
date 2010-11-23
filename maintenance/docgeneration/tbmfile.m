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
                        keys = {'descriptiondummy';'syntax:';'input:';'output:';'see also '};
                        keysup = {'descriptiondummy';'Syntax:';'Input:';'Output:';'See also '};
                        keyid = nan(length(keys),2);
                        props = {'description','syntax','input','output','seealso'};
                        for ik = 1:length(keys)
                            id = find(~cellfun(@isempty,strfind(lower(hlpblock),lower(keys{ik}))),1,'first');
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
                            empt = false(size(ln));
                            for iline = 1:size(ln,1)
                                ln{iline} = strrep(ln{iline},keys{ik},'');
                                ln{iline} = strrep(ln{iline},keysup{ik},'');
                                ln{iline} = strtrim(strrep(ln{iline},upper(keys{ik}),''));
                                if isempty(ln{iline})
                                    empt(iline) = true;
                                end
                            end
                            ln(strcmp(strtrim(ln),'%'))=[];
                            ln = ln(find(~empt,1,'first'):find(~empt,1,'last'));
                            if ~isempty(ln)
                                obj(iargs).(fld) = ln;
                            end
                        end
                        % filter keywords
                        kwid = ~cellfun(@isempty,strfind(str,'$Keywords:'));
                        if sum(kwid)>0
                            kw = str{kwid};
                            endid = max(strfind(kw,'$'))-1;
                            if endid==min(strfind(kw,'$'))-1
                                endid = length(kw);
                            end
                            keywords = strtrim(kw(min(strfind(kw,':'))+1:endid));
                            if ~isempty(keywords)
                                obj(iargs).keywords = strread(keywords,'%s',-1,'delimiter',' ');
                            end
                        end
                    end
                    obj(iargs).helpcomments = hlpblock;
                    
                    %% store file properties
                    [obj(iargs).path obj(iargs).filename obj(iargs).ext] = fileparts(fname);
                    h1linetmp = strrep(hlpblock{1},upper(obj(iargs).filename),'');
                    h1linetmp = strrep(h1linetmp,lower(obj(iargs).filename),'');
                    h1linetmp = strtrim(strrep(h1linetmp,obj(iargs).filename,''));
                    if ~isempty(h1linetmp) && strcmp(h1linetmp(1),'-')
                        h1linetmp = strtrim(h1linetmp(2:end));
                    end
                    obj(iargs).h1line = h1linetmp;
                    
                    
                    %% calls
                    callinf = getcallinfo(which(fname));
                    % subfunctions are recognozed and stored in
                    % callind(2:n). We could do something with this....
                    % make another object and return for example....
                    id = cellfun(@exist,callinf(1).calls.fcnCalls.names)==5;
                    obj(iargs).builtincalls = callinf(1).calls.fcnCalls.names(id)';
                    obj(iargs).functioncalls = callinf(1).calls.fcnCalls.names(~id)';
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