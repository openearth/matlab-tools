function varargout=dflowfm_io_extfile(cmd,fname,varargin)

%  DFLOWFM_IO_extfile: write D-Flow FM extrnal forcing file
%  (Wat een kut file!)
%% Switch read/write

switch lower(cmd)

case 'read'
   i_forcing = 0;

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

   varargout = {ext_force};

case 'write'
   OPT.Filcomments = '' ;
   OPT.ext_force   = [] ;
   OPT = setproperty(OPT,varargin);

   %Comment lines
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
                fprintf(fid,'%-12s =%-12s \n', upper(names{i_name}),num2str(OPT.ext_force(i_force).(names{i_name})));
            end
           fprintf(fid,' \n');
        end
        fclose(fid);
   end
end

