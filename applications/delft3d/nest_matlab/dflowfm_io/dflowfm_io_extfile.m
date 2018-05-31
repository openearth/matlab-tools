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
                ext_force(i_forcing).Chapter = ListOfChapters{i_chapter};
                ListOfKeywords=inifile('keywords',Info,i_chapter);
                for i_key = 1: length(ListOfKeywords)
                    ext_force(i_forcing).(ListOfKeywords{i_key}) = inifile('get',Info,i_chapter,ListOfKeywords{i_key});
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
                Keywords = fieldnames(ext_force(i_force));
                for i_key = 2: length(Keywords)
                    Info     = inifile('set',Info,[Chapter '_tmp' num2str(i_force,'%2.2i')],Keywords{i_key},ext_force(i_force).(Keywords{i_key}));
                end
            end
            
            % Remove tmp part from chapter names (needed because chapters need a unique name)
            for i_force = 1: nr_force
                index = strfind(Info.Data{i_force,1},'_tmp') - 1;
                Info.Data{i_force,1} = Info.Data{i_force,1}(1:index);
            end
            
            inifile('write',fname,Info);
        end
end

