function varargout=unstruc_io_extfile(cmd,fname,varargin)

%  UNSTRUC_IO_extfile: write UNSTRUC extrnal forcing file
%% Switch read/write/new

switch lower(cmd)

case 'read'

   %
   %  to implement yet
   %

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
