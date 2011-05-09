function Out=tekal(cmd,varargin),
% TEKAL File operations for Tekal files
%
%     FileInfo=TEKAL('open',FileName)
%        Reads the specified file.
%     Data=TEKAL('read',FileInfo,DataRecordNr)
%        Reads a data record from the specified file.
%
%     FileInfo=TEKAL('write',FileName,Data)
%        Writes the matrix Data to a Tekal file in a
%        block called 'DATA'.
%     NewFileInfo=TEKAL('write',FileName,FileInfo)
%        Writes a Tekal file based on the information
%        in the FileInfo. FileInfo should be a structure
%        with at least a field Field having two subfields
%        Name and Data. For example
%          FI.Field(1).Name='B001';
%          FI.Field(1).Data=Data1;
%          FI.Field(2).Name='B002';
%          FI.Field(2).Data=Data2;
%        An optional subfield Comments will also be processed
%        and written to file.
 
% (c) copyright 1997-2001 H.R.A.Jagers
%                         University of Twente / WL | Delft Hydraulics
%                         The Netherlands
%                         bert.jagers@wldelft.nl
 
% V1.00.** (  /  /1997): created and modified
% V1.01.00 ( 1/ 6/2001): added support for comments (* column i: xxx)
% V1.02.00 (17/ 6/2001): corrected and extended support for annotations,
%                        made reading more robust (accepts spaces, comma's,
%                        tabs as separators in the file)
% V1.03.00 (24/ 8/2001): Extended the help of the write option and
%                        implemented writing 3D matrices and Comments
 
if nargin==0,
   if nargout>0,
      Out=[];
   end;
   return;
end;
switch cmd,
case 'open',
   Out=Local_open_file(varargin{:});
case 'read',
   if ischar(varargin{1}) % tekal('read','filename', ... : implicit open
      Out=Local_open_file(varargin{:});
   else
      Out=Local_read_file(varargin{:});
   end
case 'write',
   Out=Local_write_file(varargin{:});
otherwise,
   uiwait(msgbox('unknown command','modal'));
end;
 
 
function FileInfo=Local_open_file(varargin);
FileInfo.Check='NotOK';
TryToCorrect=0;
LoadData=0;
LoadField=0;
filename=varargin{1};
INP=varargin(2:end);
for i=1:length(INP)
   if strcmp(INP{i},'autocorrect')
      TryToCorrect=1;
   elseif strcmp(INP{i},'loaddata')
      LoadData=1;
   else
      LoadField=INP{i};
   end
end
if nargin==0,
   [fn,fp]=uigetfile('*.*');
   if ~ischar(fn),
      return;
   end;
   filename=[fp fn];
end;
 
variable=0;
fid=fopen(filename);
if fid<0,
   error('Cannot open file ...');
   return;
end;
 
FileInfo.FileName=filename;
ErrorFound=0;
Cmnt={};
 
while 1,
   line=fgetl(fid);
   % end of file check (or some other error such that no line was read)
   % fprintf(1,'>''%s''<\n',line);
   if ~ischar(line), break; end;
 
   % check if we are dealing with a non-Tekal binary file ...
   % Tabs (char 9) are acceptable!
   if any(line<32 & line~=9) & ~TryToCorrect
      error(sprintf('Invalid line: %s',line));
   end
 
   % remove empty spaces
   line=deblank(line);
 
   % is comment or empty line
   if isempty(line),
   elseif line(1)=='*', % comment
      Cmnt{end+1,1}=line;
   else
      % if not, it must be a variable name
      variable=variable+1;
      FileInfo.Field(variable).Name=deblank(line);
      FileInfo.Field(variable).Comments=Cmnt;
      % read data dimensions
      line=fgetl(fid);
      if ~ischar(line),
         dim=[];
      else,
         dim=sscanf(line,'%i',[1 inf]);
      end;
      if ~isempty(dim),
         FileInfo.Field(variable).Size=dim;
         if (length(dim)>2) & prod(FileInfo.Field(variable).Size(3:end))~=FileInfo.Field(variable).Size(1),
            % MN   n   M    should be interpreted as    MN   n   M   N (=MN/M)
            if rem(FileInfo.Field(variable).Size(1),prod(FileInfo.Field(variable).Size(3:end)))==0,
               FileInfo.Field(variable).Size(end+1)=FileInfo.Field(variable).Size(1)/prod(FileInfo.Field(variable).Size(3:end));
            else,
               warning(sprintf('Invalid reshape dimensions specified for field: %i.',variable));
            end;
         end;
         if length(dim)>1,
            dim=dim([2 1]);
         else
            dim=[1 dim];
         end
         FileInfo.Field(variable).ColLabels={}; % necessary for standalone version
         FileInfo.Field(variable).ColLabels(1:dim(1),1)={''};
         if ~isempty(Cmnt)
            for i=1:length(Cmnt)
               [Tk,Rm]=strtok(Cmnt{i}(2:end));
               if (length(Cmnt{i})>10) & strcmp(lower(Tk),'column')
                  [a,c,err,idx]=sscanf(Rm,'%i%*[ :=]%c',2);
                  if (c==2) & a(1)<=dim(1) & a(1)>0
                     FileInfo.Field(variable).ColLabels{a(1)}=deblank(Rm(idx-1:end));
                  end
               end
            end
         end
         FileInfo.Field(variable).Offset=ftell(fid);
 
         % create Data field but don't use it
         % This field is created to be compatible with the write statement
         FileInfo.Field(variable).Data=[];
         % skip data values
         if prod(FileInfo.Field(variable).Size)==0
            FileInfo.Field(variable).DataTp='numeric';
         else
            line=fgetl(fid);
            fseek(fid,FileInfo.Field(variable).Offset,-1);
            [X,N]=sscanf(line,['%f%*[ ,' char(9) ']']);
            FileInfo.Field(variable).DataTp='numeric';
            if dim(1)==N+1, % annotation mode
               FileInfo.Field(variable).DataTp='annotation';
               if LoadData
                  Data=[];
                  for i=1:dim(2),
                     line=fgetl(fid);
                     Tkn=find(diff([0 ~ismember(line,[' ,' char(9)])])==1);
                     Data{1}(:,i)=sscanf(line,'%f%*[ ,]',dim(1)-1);
                     Str=deblank(line(Tkn(dim(1)):end));
                     if Str(1)=='''' & Str(end)==''''
                        Str=Str(2:end-1);
                     end
                     Data{2}{i}=Str;
                  end;
                  FileInfo.Field(variable).Data=Data;
               else
                  for i=1:dim(2), fgetl(fid); end
               end
            else, % all numerics; use %f a bit faster than the scan-string above
               % check number of values per line,
               if (length(FileInfo.Field(variable).Size)>1) & (N~=dim(1)),
                  Msg=sprintf('Actual number of values per line %i does not match indicated number\nof values per line %i.',N,dim(1));
                  if ~TryToCorrect
                     error(Msg)
                  end
                  fprintf(1,'ERROR: %s\nUsing actual number and trying to continue ...\n',Msg);
                  dim(1)=N;
                  FileInfo.Field(variable).Size(2)=N;
               end;
               [Data,Nr]=fscanf(fid,['%f%*[ ,' char(9) char(13) char(10) ']'],dim);
%               for i=1:dim(2), fgets(fid,1); end
%               Nr=prod(dim);
%               variable
               if Nr<prod(dim), % number read less than number expected
                  if feof(fid),
                     Msg=sprintf('End of file reached while skipping data field %i.\nData is probably damaged.',variable);
                     if ~TryToCorrect
                        error(Msg)
                     end
                     fprintf(1,'ERROR: %s\n',Msg);
                  else,
                     floc=ftell(fid);
                     CanRead=fgetl(fid);
                     fseek(fid,floc,0);
                     Msg=sprintf('Instead of data encountered: %s\nData field %i is probably damaged.',CanRead,variable);
                     if ~TryToCorrect
                        error(Msg)
                     end
                     fprintf(1,'ERROR: %s\nTrying to continue ...\n',Msg);
                  end;
                  ErrorFound=1;
                  break;
               else
                  % replace 999999 by Not-a-Numbers
                  Data(Data(:)==999999)=NaN;
 
                  % transpose data if it has two dimensions
                  if length(dim)>1,
                     Data=Data';
                  end;
 
                  % reshape to match Size
                  if length(FileInfo.Field(variable).Size)>2,
                     Data=reshape(Data,[FileInfo.Field(variable).Size(3:end) FileInfo.Field(variable).Size(2)]);
                  end
                  FileInfo.Field(variable).Data=Data;
               end;
              % read closing end of line
              line=fgetl(fid);
            end;
         end;
      else,
         if ~isempty(line) & ischar(line) & ~TryToCorrect
            error(sprintf('Cannot determine field size from %s',line));
         end
         % remove field
         FileInfo.Field(variable)=[];
         variable=variable-1;
      end;
      Cmnt={};
   end;
end;
fclose(fid);
if ~ErrorFound,
   FileInfo.Check='OK';
end;
 
 
function Data=Local_read_file(FileInfo,var);
% check whether the data has been read
if ischar(var),
   Fields={FileInfo.Field.Name};
   varnr=ustrcmpi(var,Fields);
   if varnr<0,
      fprintf('Cannot determine which field to read.\n');
      Data=[];
      return;
   else,
      var=varnr;
   end;
end;
if ~isnan(FileInfo.Field(var).Offset),
   fid=fopen(FileInfo.FileName);
   fseek(fid,FileInfo.Field(var).Offset,-1);
   if length(FileInfo.Field(var).Size)>1,
      dim=FileInfo.Field(var).Size([2 1]);
   else,
      dim=FileInfo.Field(var).Size;
   end;
   switch FileInfo.Field(var).DataTp,
   case 'annotation'
      for i=1:dim(2),
         line=fgetl(fid);
         Tkn=find(diff([0 ~ismember(line,[' ,' char(9)])])==1);
         Data{1}(:,i)=sscanf(line,'%f%*[ ,]',dim(1)-1);
         Str=deblank(line(Tkn(dim(1)):end));
         if Str(1)=='''' & Str(end)==''''
            Str=Str(2:end-1);
         end
         Data{2}{i}=Str;
      end;
      fclose(fid);
   otherwise, %'numeric' % all numerics; use fscanf
      %Data=fscanf(fid,'%f',dim);
      [Data,n]=fscanf(fid,['%f%*[ ,' char(9) char(13) char(10) ']'],dim);
      fclose(fid);
 
      % replace 999999 by Not-a-Numbers
      Data(Data(:)==999999)=NaN;
 
      % transpose data if it has two dimensions
      if length(dim)>1,
         Data=Data';
      end;
 
      % reshape to match Size
      if length(FileInfo.Field(var).Size)>2,
         Data=reshape(Data,[FileInfo.Field(var).Size(3:end) FileInfo.Field(var).Size(2)]);
      end
   end;
else,
   Data=FileInfo.Field(var).Data;
end;
 
 
function NewFileInfo=Local_write_file(filename,FileInfo);
fid=fopen(filename,'w');
NewFileInfo.Check='NotOK';
if fid<0,
   error('invalid filename');
end;
 
if isstruct(FileInfo),
   %  uiwait(msgbox('Not yet implemented','modal'));
   % sprintf('%s',[FileInfo.Field(var).Name char(32*ones(1,4-length(FileInfo.Field(var).Name)))]) % Write a name of at least four characters
   NewFileInfo.FileName=filename;
   for i=1:length(FileInfo.Field),
      if isfield(FileInfo.Field(i),'Comments')
         if isempty(FileInfo.Field(i).Comments)
            NewFileInfo.Field(i).Comments={};
         elseif ischar(FileInfo.Field(i).Comments)
            NewFileInfo.Field(i).Comments{1}=FileInfo.Field(i).Comments;
         else
            NewFileInfo.Field(i).Comments=FileInfo.Field(i).Comments;
         end
         for c=1:length(NewFileInfo.Field(i).Comments)
            if isempty(NewFileInfo.Field(i).Comments{c}) | NewFileInfo.Field(i).Comments{c}(1)~='*'
               NewFileInfo.Field(i).Comments{c}=['*' NewFileInfo.Field(i).Comments{c}];
            end
            fprintf(fid,'%s\n',NewFileInfo.Field(i).Comments{c});
         end
      end
      NewFileInfo.Field(i).Name=FileInfo.Field(i).Name;
      fprintf(fid,'%s\n',FileInfo.Field(i).Name);
      NewFileInfo.Field(i).Size=size(FileInfo.Field(i).Data);
      if ndims(FileInfo.Field(i).Data)>2
         NewFileInfo.Field(i).Size=[prod(NewFileInfo.Field(i).Size(1:end-1)) NewFileInfo.Field(i).Size(end) NewFileInfo.Field(i).Size(1:end-1)];
         FileInfo.Field(i).Data=reshape(FileInfo.Field(i).Data,NewFileInfo.Field(i).Size(1:2));
      end
      fprintf(fid,' %i',NewFileInfo.Field(i).Size); fprintf(fid,'\n');
      NewFileInfo.Field(i).Offset=ftell(fid);
      fprintf(fid,[repmat(' %.15g',1,size(FileInfo.Field(i).Data,2)) '\n'],FileInfo.Field(i).Data');
      NewFileInfo.Field(i).Data=[];
      NewFileInfo.Field(i).DataTp='numeric';
   end;
   NewFileInfo.Check='OK';
else,
   NewFileInfo.FileName=filename;
   fprintf(fid,'* This was created by Matlab at %s.\n',datestr(now));
   fprintf(fid,'DATA\n');
   NewFileInfo.Field.Name='DATA';
   NewFileInfo.Field.Size=size(FileInfo);
   %  if size(FileInfo,2)>1, % if matrix (or row vector)
   %    FileInfo=FileInfo';
   %  end;
   if ndims(FileInfo)>2
      NewFileInfo.Field.Size=[prod(NewFileInfo.Field.Size(1:end-1)) NewFileInfo.Field.Size(end) NewFileInfo.Field.Size(1:end-1)];
      FileInfo=reshape(FileInfo,NewFileInfo.Field.Size(1:2));
   end
   fprintf(fid,' %i',NewFileInfo.Field.Size); fprintf(fid,'\n');
   NewFileInfo.Field.Offset=ftell(fid);
   NewFileInfo.Field.Data=[];
   NewFileInfo.Field.DataTp='numeric';
   fprintf(fid,[repmat(' %12g',1,size(FileInfo,2)) '\n'],FileInfo');
   NewFileInfo.Check='OK';
end;
 
fclose(fid);
