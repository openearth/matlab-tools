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
       if ~(line(1) == '*')
           if ~isempty(strfind(lower(line),'quantity'))
               i_forcing = i_forcing + 1;
               index = strfind(line,'=');
               ext_force(i_forcing).quantity = line(index(1) + 1:end);
           elseif ~isempty(strfind(lower(line),'filename'))
               index = strfind(line,'=');
               ext_force(i_forcing).filename = line(index(1) + 1:end);
           elseif ~isempty(strfind(lower(line),'filetype'))
               index = strfind(line,'=');
               ext_force(i_forcing).filetype = str2num(line(index(1) + 1:end));
           elseif ~isempty(strfind(lower(line),'method'))
               index = strfind(line,'=');
              ext_force(i_forcing).method   = str2num(line(index(1) + 1:end));
           elseif ~isempty(strfind(lower(line),'operand'))
               index = strfind(line,'=');
               ext_force(i_forcing).operand  = line(index(1) + 1:end);
           end
       end
       line = strtrim(fgetl(fid));
   end
   
   fclose (fid);
   
   varargout = ext_force;

case 'write'
   OPT.Filcomments = '' ;
   OPT.Quantity    = '' ;
   OPT.Filename    = '' ;
   OPT.Filetype    = 9  ; % xyz data
   OPT.Method      = 4  ;
   OPT.Operand     = 'O';
   OPT             = setproperty(OPT,varargin);

   %Comment lines
   if ~isempty(OPT.Filcomments)
       fid      = fopen(fname,'w+');
       comments = simona2mdu_csvread(OPT.Filcomments);
       for i_com = 1: length(comments)
           fprintf(fid,'%s \n',comments{i_com});
       end
       fclose (fid);
    end

    if ~isempty(OPT.Quantity)
        fid = fopen(fname,'a');
        fseek(fid,0,'eof');
        fprintf(fid,['QUANTITY=' OPT.Quantity          '\n']);
        fprintf(fid,['FILENAME=' OPT.Filename          '\n']);
        fprintf(fid,['FILETYPE=' num2str(OPT.Filetype) '\n']);
        fprintf(fid,['METHOD=  ' num2str(OPT.Method  ) '\n']);
        fprintf(fid,['OPERAND= ' OPT.Operand           '\n']);
        fprintf(fid,' \n');
        fclose(fid);
   end
end
