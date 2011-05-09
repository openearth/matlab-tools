function varargout=weir(cmd,varargin),
% WEIR read/write a weir file
%        WeirData=WEIR('read','filename')
%        WEIR('write','filename',WeirData) (not yet implemented)

% (c) copyright, Delft Hydraulics, 2000
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0
   if nargout>0
      varargout=cell(1,nargout);
   end
   return
end

switch cmd
   case 'read'
      Grid=Local_read_weir(varargin{:});
      varargout={Grid};
   case 'write'
      Out=Local_write_weir(varargin{:});
      if nargout>0
         varargout{1}=Out;
      end
   otherwise
      error('Unknown command')
end


function Out=Local_read_weir(filename)
% U        4   144     4   144     1.0  100.0 1
if (nargin==0) | strcmp(filename,'?'),
   [fname,fpath]=uigetfile('*.*','Select weir file');
   if ~ischar(fname)
      return
   end
   filename=fullfile(fpath,fname);
end

Out.FileName=filename;
Out.Check='OK';
OK=0;
%fid=fopen(filename,'r');
%Str=fgetl(fid);
%fclose(fid);
%StrSplit=multiline(Str,' \t','cell');
%StrSplit(cellfun('isempty',StrSplit))=[];
%Dir=upper(strtok(Str));
%u=strmatch('U',upper(StrSplit),'exact');
%v=strmatch('V',upper(StrSplit),'exact');
try
   Out.Type='rigidsheet';
   fid=fopen(filename,'r');
   [Data,N]=fscanf(fid,' %[uUvV] %i %i %i %i %i %i %f',[8 inf]);
   erryes=~feof(fid);
   fclose(fid);
   if erryes | round(N/8)~=N/8
      error('Error reading file.')
   end
   U=upper(Data(1,:))=='U';
   % The following "if isempty" statements are necessary for the standalone version
   Out.MNKu=Data(2:7,U)'; if isempty(Out.MNKu), Out.MNKu=zeros(0,6); end
   Out.CHARu=Data(8,U)'; if isempty(Out.CHARu), Out.CHARu=zeros(0,1); end
   Out.MNKv=Data(2:7,~U)'; if isempty(Out.MNKv), Out.MNKv=zeros(0,6); end
   Out.CHARv=Data(8,~U)'; if isempty(Out.CHARv), Out.CHARv=zeros(0,1); end
   kmax=max(1,max(max(Out.MNKu(:,5:6))));
   kmax=max(kmax,max(max(Out.MNKv(:,5:6))));
   Out.KMax=kmax;
   OK=1;
catch
end
if ~OK
   try
      Out.Type='3dgate';
      fid=fopen(filename,'r');
      [Data,N]=fscanf(fid,' %[uUvV] %i %i %i %i %i %i',[7 inf]);
      erryes=~feof(fid);
      fclose(fid);
      if erryes | round(N/7)~=N/7
         error('Error reading file.')
      end
      U=upper(Data(1,:))=='U';
      % The following "if isempty" statements are necessary for the standalone version
      Out.MNKu=Data(2:7,U)'; if isempty(Out.MNKu), Out.MNKu=zeros(0,6); end
      Out.CHARu=Data([],U)'; if isempty(Out.CHARu), Out.CHARu=zeros(0,0); end
      Out.MNKv=Data(2:7,~U)'; if isempty(Out.MNKv), Out.MNKv=zeros(0,6); end
      Out.CHARv=Data([],~U)'; if isempty(Out.CHARv), Out.CHARv=zeros(0,0); end
      kmax=max(1,max(max(Out.MNKu(:,5:6))));
      kmax=max(kmax,max(max(Out.MNKv(:,5:6))));
      Out.KMax=kmax;
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='weir';
      fid=fopen(filename,'r');
      [Data,N]=fscanf(fid,' %[uUvV] %i %i %i %i %f %f %f',[8 inf]);
      erryes=~feof(fid);
      fclose(fid);
      if erryes | round(N/8)~=N/8
         error('Error reading file.')
      end
      U=upper(Data(1,:))=='U';
      % The following "if isempty" statements are necessary for the standalone version
      Out.MNu=Data(2:5,U)'; if isempty(Out.MNu), Out.MNu=zeros(0,4); end
      Out.CHARu=Data(6:8,U)'; if isempty(Out.CHARu), Out.CHARu=zeros(0,3); end
      Out.MNv=Data(2:5,~U)'; if isempty(Out.MNv), Out.MNv=zeros(0,4); end
      Out.CHARv=Data(6:8,~U)'; if isempty(Out.CHARv), Out.CHARv=zeros(0,3); end
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='thindam';
      fid=fopen(filename,'r');
      [Data,N]=fscanf(fid,' %i %i %i %i %[uUvV]',[5 inf]);
      erryes=~feof(fid);
      fclose(fid);
      if erryes | round(N/5)~=N/5
         error('Error reading file.')
      end
      U=upper(Data(5,:))=='U';
      % The following "if isempty" statements are necessary for the standalone version
      Out.MNu=Data(1:4,U)'; if isempty(Out.MNu), Out.MNu=zeros(0,4); end
      Out.CHARu=Data([],U)'; if isempty(Out.CHARu), Out.CHARu=zeros(0,0); end
      Out.MNv=Data(1:4,~U)'; if isempty(Out.MNv), Out.MNv=zeros(0,4); end
      Out.CHARv=Data([],~U)'; if isempty(Out.CHARv), Out.CHARv=zeros(0,0); end
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='drypoint';
      fid=fopen(filename,'r');
      [Data,N]=fscanf(fid,' %i %i %i %i',[4 inf]);
      erryes=~feof(fid);
      fclose(fid);
      if erryes | round(N/4)~=N/4
         error('Error reading file.')
      end
      Out.MN=Data; if isempty(Out.MN), Out.MN=zeros(0,4); end
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='cross-sections';
      fid=fopen(filename,'r');
      i=0;
      while 1
         Line=fgetl(fid);
         if ~ischar(Line)
            break
         end
         i=i+1;
         Name{i,1}=deblank(Line(1:20));
         MNMN(i,1:4)=sscanf(Line(21:end),' %i %i %i %i',[1 4]);
      end
      fclose(fid);
      Out.Name=Name;
      Out.MNMN=MNMN;
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='discharge stations';
      fid=fopen(filename,'r');
      i=0;
      while 1
         Line=fgetl(fid);
         if ~ischar(Line)
            break
         end
         i=i+1;
         Name{i,1}=deblank(Line(1:20));
         [X,n,er,ni]=sscanf(Line(21:end),' %1s %i %i %i',[1 4]);
         Interpolation(i,1)=char(X(1));
         MNK(i,1:3)=X(2:4);
         MNK_out(i,1:3)=[NaN NaN NaN];
         [X,n,er]=sscanf(Line(20+ni:end),' %1s %i %i %i',[1 4]);
         if n==0
            DischType{i,1}='normal discharge';
         else
            switch char(X(1))
               case {'w','W'}
                  DischType{i,1}='walking discharge';
               case {'p','P'}
                  DischType{i,1}='power station';
                  if n<4
                     error('Missing outlet location');
                  end
                  MNK_out(i,1:3)=X(2:4);
               otherwise
                  error('Unknown discharge type');
            end
         end
      end
      fclose(fid);
      Out.Name=Name;
      Out.Interpolation=Interpolation;
      Out.MNK=MNK;
      Out.DischType=DischType;
      if any(~isnan(MNK_out(:)))
         Out.MNK_out=MNK_out;
      end
      OK=1;
   catch
   end
end
if ~OK
   try
      Out.Type='observation points';
      fid=fopen(filename,'r');
      i=0;
      while 1
         Line=fgetl(fid);
         if ~ischar(Line)
            break
         end
         i=i+1;
         Name{i,1}=deblank(Line(1:20));
         MN(i,1:2)=sscanf(Line(21:end),' %i %i',[1 2]);
      end
      fclose(fid);
      Out.Name=Name;
      Out.MN=MN;
      OK=1;
   catch
   end
end
if ~OK
   if ~isempty(fopen(fid))
      fclose(fid);
   end
   Out.Check='NotOK';
end

function OK=Local_write_weir(filename,Out),
if ~isfield(Out,'Type')
   Out.Type='weir';
end
fid=fopen(filename,'w');
switch Out.Type
   case 'rigidsheet'
      Data=[repmat(abs('U'),size(Out.MNKu,1),1) Out.MNKu Out.CHARu
         repmat(abs('V'),size(Out.MNKv,1),1) Out.MNKv Out.CHARv]';
      fprintf(fid,' %c %5i %5i %5i %5i %5i %5i %12f\n',Data);
   case '3dgate'
      Data=[repmat(abs('U'),size(Out.MNKu,1),1) Out.MNKu
            repmat(abs('V'),size(Out.MNKv,1),1) Out.MNKv]';
      fprintf(fid,' %c %5i %5i %5i %5i %5i %5i\n',Data);
   case 'weir'
      Data=[repmat(abs('U'),size(Out.MNu,1),1) Out.MNu Out.CHARu
         repmat(abs('V'),size(Out.MNv,1),1) Out.MNv Out.CHARv]';
      fprintf(fid,' %c %5i %5i %5i %5i %12f %12f %12f\n',Data);
   case 'thindam'
      Data=[Out.MNu repmat(abs('U'),size(Out.MNu,1),1)
            Out.MNv repmat(abs('V'),size(Out.MNv,1),1)]';
      fprintf(fid,' %5i %5i %5i %5i %c\n',Data);
   case 'drypoint'
      fprintf(fid,' %5i %5i %5i %5i %c\n',Out.MN');
   case 'discharge stations'
      for i=1:length(Out.Name)
         fprintf(fid,'%-20s %c %5i %5i %5i',Out.Name{i},Out.Interpolation(i),Out.MNK(i,:));
         switch Out.DischType{i}
            case 'normal discharge'
               fprintf(fid,'\n');
            case 'walking discharge'
               fprintf(fid,' W\n');
            case 'power station'
               fprintf(fid,' P %5i %5i %5i\n',Out.MNK_out(i,:));
            otherwise
               fclose(fid);
               error(sprintf('Don''t know how to write %s',Out.DischType{i}))
         end
      end
   case 'cross-sections'
      for i=1:length(Out.Name)
         fprintf(fid,'%-20s %5i %5i %5i %5i\n',Out.Name{i},Out.MNMN(i,:));
      end
   case 'observation points'
      for i=1:length(Out.Name)
         fprintf(fid,'%-20s %5i %5i\n',Out.Name{i},Out.MN(i,:));
      end
   otherwise
      fclose(fid);
      error(sprintf('Write command does not support type: %s.',Out.Type))
end
fclose(fid);
OK=1;
