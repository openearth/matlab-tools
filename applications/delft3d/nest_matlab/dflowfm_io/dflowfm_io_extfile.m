function varargout=dflowfm_io_extfile(cmd,fname,varargin)

%  DFLOWFM_IO_extfile: write D-Flow FM extrnal forcing file
%  (Wat een kut file!)
%% Switch read/write

switch lower(cmd)

    case 'read'
        i_forcing = 0;
        type      = 'old';
        
        try
            % New Format
            Info           = inifile('open',fname);
            ListOfChapters = inifile('chapters',Info);
            for i_chapter = 1: length(ListOfChapters);
                i_forcing = i_forcing + 1;
                i_val     = 0;
                ext_force(i_forcing).Chapter = ListOfChapters{i_chapter};
                ListOfKeywords=inifile('keywords',Info,i_chapter);
                for i_key = 1: length(ListOfKeywords)
                    if ~isempty(ListOfKeywords{i_key})
                        ext_force(i_forcing).Keyword.Name {i_key}  = ListOfKeywords{i_key};
                        ext_force(i_forcing).Keyword.Value{i_key} = inifile('get',Info,i_chapter,i_key);
                    else
                        i_val = i_val + 1;
                        ext_force(i_forcing).values(i_val,:) =  inifile('get',Info,i_chapter,i_key);
                    end
                end
            end
            type = 'ini';
            
        catch
            %Old Format
            
            fid     = fopen(fname  );
            line = strtrim(fgetl(fid));
            while ~feof(fid)
                if ~isempty(line) && ~(line(1) == '*') && ~(line(1)== '[')
                    if ~isempty(strfind(lower(line),'quantity'))
                        i_forcing = i_forcing + 1;
                        index = strfind(line,'=');
                        ext_force(i_forcing).quantity = strtrim(line(index(1) + 1:end));
                    else
                        index = strfind(line,'=');
                        if ~isempty(str2num(line(index(1) + 1: end)))
                            ext_force(i_forcing).(strtrim(lower(line(1:index(1) - 1)))) = str2num(line(index(1) + 1:end));
                        else
                            ext_force(i_forcing).(strtrim(lower(line(1:index(1) - 1)))) = strtrim(line(index(1) + 1:end));
                        end
                    end
                end
                line = strtrim(fgetl(fid));
            end
            
            fclose (fid);
        end
        varargout{1} = ext_force;
        varargout{2} = type;
        
    case 'write'
        OPT.Filcomments = '' ;
        OPT.ext_force   = [] ;
        OPT.type        = 'old';
        OPT = setproperty(OPT,varargin);
        
        if strcmp(OPT.type,'old')
            % Old format
            % Comment lines
            if ~isempty(OPT.Filcomments)
                fid      = fopen(fname,'w+');
                comments = simona2mdu_csvread(OPT.Filcomments);
                for i_com = 1: length(comments)
                    fprintf(fid,'%s \n',comments{i_com});
                end
                fclose (fid);
            end
            
            if ~isempty(OPT.ext_force)
                fid = fopen(fname,'a');
                fseek(fid,0,'eof');
                for i_force = 1: length(OPT.ext_force)
                    names = fieldnames(OPT.ext_force(i_force));
                    for i_name = 1: length(names)
                        fprintf(fid,'%-24s =%-12s \n', upper(names{i_name}),num2str(OPT.ext_force(i_force).(names{i_name})));
                        % Keywords are (FY) case sensitive!
                        % fprintf(fid,'%-24s =%-12s \n', names{i_name},num2str(OPT.ext_force(i_force).(names{i_name})));
                    end
                    fprintf(fid,' \n');
                end
                fclose(fid);
            end
        else
            % New format
            Info      = inifile('new');
            ext_force = OPT.ext_force;
            nr_force  = length(ext_force);
            for i_force = 1: nr_force
                Chapter  = ext_force(i_force).Chapter;      
                Keyword = ext_force(i_force).Keyword.Name;
                Value    = ext_force(i_force).Keyword.Value;
                Info.Data{i_force,1} = Chapter;
                for i_key = 2: length(Keyword)
                    tmp{i_key-1,1} = Keyword{i_key};
                    tmp{i_key-1,2} = Value  {i_key};
                end
                
                if isfield(ext_force(i_force),'values')
                    Value = ext_force(i_force).values;
                    no_row = size(Value,1);
                    no_col = size(Value,2);
                    format = ['%8i ' repmat('%12.6f ',1,no_col)];
                    for i_row = 1: no_row
                        tmp{end+1,2} = '';
                        tmp{end  ,2} = sprintf(format,Value(i_row,:));
                    end
                end
                Info.Data{i_force,2} = tmp;
                clear tmp
            end
            inifile('write',fname,Info);    
        end

end

