function Out=mike(cmd,varargin),
% MIKE   File operations for Mike files
%
%        FileInfo=MIKE('open',filename)
%        Open a MIKE DFS? file or a pair of CT?/DT? files.
%
%        Data=MIKE('read',FileInfo,Item,TimeStep)
%        Read data from a Mike file. If no timestep is specified then
%        the last timestep in the file is read. If the data files
%        contains just one dataset, the Item number is not required.
%
%        Data=MIKE('read',FileInfo,Item,-1) % read grid
%        Read the grid from the data file.
%
%        ...,{M})           % 1D
%        ...,{M N})         % 2D
%        ...,{M N K})       % 3D
%        Read only the selected m,n,k-indices. The number of indices
%        should match the dimension of the data file.

% (c) 2000 H.R.A.Jagers, WL | Delft Hydraulics, The Netherlands
%          bert.jagers@wldelft.nl

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;

switch cmd,
case 'open',
  Out=Local_open_mike(varargin{:});
case 'read',
  switch lower(varargin{1}.FileType),
  case 'mikectdt'
    Out=Local_read_mike(varargin{:});
  case 'mikedfs'
    Out=Local_read_mike_new(varargin{:});
  end
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function S=Local_open_mike(filename),
S.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('*.ct?');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;

% Filename: has it an extension?
lastdot=max(findstr(filename,'.'));
lastsep=max(findstr(filename,filesep));
if ~isempty(lastdot) & (isempty(lastsep) | (lastdot>lastsep)), % has extension!
  file_ext=filename(lastdot:end);
  filename=filename(1:(lastdot-1));
else,
  error('Missing extension? Could not determine filetype.'),
end;

S.FileName=filename;
S.FileType='MikeCTDT';
S.Format='l';
switch file_ext,
case {'.ct2','.dt2'},
  S.Def='.ct2';
  S.Dat='.dt2';
case {'.ct1','.dt1'},
  S.Def='.ct1';
  S.Dat='.dt1';
case {'.ct0','.dt0'},
  S.Def='.ct0';
  S.Dat='.dt0';
case {'.dfs0','.dfs1','.dfs2','.dfs3'},
  S.FileType='MikeDFS';
  S.Dat=file_ext;
  S.Def='';
otherwise,
  error('Invalid filename or unknown MIKE file type');
end;

if isunix,
  if ~isequal(filename(1),'/'),
    filename=[pwd '/' filename];
    S.FileName=filename;
  end;
else, % PCWIN
  if (length(filename)<2) | (~isequal(filename(1:2),'\\') & ~isequal(filename(2),':')),
    filename=[pwd '\' filename];
    S.FileName=filename;
  end;
end;

if isempty(S.Def)
  S=Local_open_mike_new(S,filename);
  return;
end

dat_file=[filename S.Dat];
def_file=[filename S.Def];


% -----------------------------------------------------
% Reading the dat and def files
% -----------------------------------------------------

% =====================================================
% Check existence of dat file
% =====================================================
if exist(dat_file)~=2,
  fprintf('Datafile "%s" does not exist.\n',dat_file);
  return;
end;

% =====================================================
% Start reading the def file
% =====================================================
fidef=fopen(def_file,'r','l');
if fidef<0,
  fprintf('Cannot open definition file.\n');
  return;
end;

BS=fread(fidef,1,'int32'); % 600
if ~isequal(BS,600),
  fidef=fopen(def_file,'r','b');
  S.Format='b';
  BS=fread(fidef,1,'int32'); % 600
  if ~isequal(BS,600),
    S.Format='unknown';
    fclose(fidef);
    return;
  end;
end;
X=fread(fidef,[1 600/4],'float32');
BS=fread(fidef,1,'int32'); % 600

S.RefDate=X(1)+694020+X(5)/(24*3600);
S.StartTimeStep=X(2);
S.NumTimeSteps=X(4);
%if S.NumTimeSteps>0,
S.TimeStep=X(6)/(60*60*24);
%end
S.NumItems=X(7);
%S.DataDim=X(20:21);
%S.Origin=X(24:25); % latitude, longitude in degrees
%S.GridCell=X(28:29); % in meters
S.NumCoords=X(8); % 0 t/m 4
if S.NumCoords==0,
  S.DataDim=0; % 1 added while reading!
else,
  S.DataDim=X(19+(1:S.NumCoords)); % 1 added while reading!
  S.Origin=X(23+(1:S.NumCoords));
  S.GridCell=X(27+(1:S.NumCoords));
  if S.NumCoords==2,
    S.Orientation=X(144); % in degrees
    S.Land=X(147);
  end;
end;

i=1;
S.Item=[];
for i=1:S.NumItems,
  Min=X(31+7*(i-1)+1);
  Max=X(31+7*(i-1)+2);
  %if Min>Max, break; end
  S.Item(i).Min=Min;
  S.Item(i).Max=Max;
  S.Item(i).Mean=X(31+7*(i-1)+3);
%  S.Item(i).X=X(31+7*(i-1)+4);
end;
%S.NumItems=length(S.Item)
S.DataField(1).Data=X;

BS=fread(fidef,1,'int32'); % 436
X=char(fread(fidef,[1 436],'uchar'));
BS=fread(fidef,1,'int32'); % 436

S.Description=deblank(X(1:40));
if any(S.Description==0)
  S.Description=S.Description(1:min(find(S.Description==0))-1);
end
S.DataField(1).Description=X;
fclose(fidef);

for i=1:S.NumItems,
  S.Item(i).Name=X(96+20*(i-1)+(1:20));
  if any(S.Item(i).Name==0)
    S.Item(i).Name=S.Item(i).Name(1:min(find(S.Item(i).Name==0))-1);
  end
end;

S.Check='OK';


function S=Local_open_mike_new(Sin,filename),
S=Sin;
file=[filename S.Dat];

% =====================================================
% Check existence of file
% =====================================================
if exist(file)~=2,
  error(sprintf('File "%s" does not exist.',file));
end;

% =====================================================
% Start reading the file
% =====================================================
fid=fopen(file,'r','l');
if fid<0,
  error(sprintf('Cannot open file: %s.',file));
end;

X=char(fread(fid,[1 64],'uchar'));
if ~strcmp(X,'DHI_DFS_ MIKE Zero - this file contains binary data, do not edit'),
  error('Invalid start of MIKE Zero file.');
end;

X=char(fread(fid,[1 17],'uchar')); %  FOpenFileCreate

X=fread(fid,1,'uchar'); %<end of text>

V=fread(fid,[1 6],'int16'); % FileCreationDate
S.Date=datenum(V(1),V(2),V(3),V(4),V(5),V(6));

X=fread(fid,2,'int32'); %104, 206

V=fread(fid,[1 6],'int16'); % FileCreationDate

X=fread(fid,4,'int32'); %104, 206, 0, 0

S.Data={};
S.NumCoords=S.Dat(end)-'0';
S=read_info(fid,S,0);
fclose(fid);


function Info=read_info(fid,Info,loaddata);
it=0;
static=0;
fld=0;
while 1,
  Typ=fread(fid,1,'uchar');
  if isempty(Typ) % End of File
    break
  end
  switch Typ,
  case 1,
    N=fread(fid,1,'int32');
    if loaddata==1
      i2=fread(fid,[1 N],'float32');
      Info.Data{end+1}=i2;
    else
      it=it+1;
      while Info.Item(it).Static, it=it+1; end
      Info.Item(it).Data(fld)=ftell(fid);
      fread(fid,[1 N],'float32');
    end
  case 2,
    N=fread(fid,1,'int32');
    Info.Data{end+1}=fread(fid,[1 N],'float64');
  case 3,
    N=fread(fid,1,'int32');
    Info.Data{end+1}=char(fread(fid,[1 N],'uchar'));
  case {4,5}
    N=fread(fid,1,'int32');
    Info.Data{end+1}=fread(fid,[1 N],'int32');
  case 6
    N=fread(fid,1,'int32');
    Info.Data{end+1}=fread(fid,[1 N],'int16');
  case 254
    Opt=fread(fid,1,'uchar');
    X=fread(fid,1,'uchar');
    i2.Data={};
    i2=read_info(fid,i2,1);
    switch Opt,
    case 16, %39  {}
    case 17, %39
      Info.FileTitle=deblank(i2.Data{1});
    case 18, %39
      Info.CreatingProgram=deblank(i2.Data{1});
    case 19, %39
     %  [0]  : 0D,1D,2D
     %  [1]  : 3D
    case 20, %39
     %  [1]
    case {21,23,24,25,26} %39
     %  [2]    [-1.0000e-077]    ' '    [-9876789]    [9876789]
     %  [1]    [-1.0000e-255]    ' '    [2.1475e+009] [2.1475e+009]
    case 22, %39
      Info.Clipping=i2.Data{1};
    case 27, %39
      Info.ProjectionName=deblank(i2.Data{1});
      Info.ProjectionData=i2.Data{2};
    case 28, %39
      Info.NumItems=i2.Data{1}+1;
    case 32, %78  {}
    case 48, %117 {}
    case 49,
      Info.NumTimDepItems=i2.Data{1};
    case 53,
      % {[100000]  'P(25,10): H Water Depth m '  [1000]  [1]  [10.0085 10.0000 0]  [0 0 0]  [0 0 0]}
      % {[999]  'P(0,10)-P(50,10): Component 1 '  [0]  [1]  [4.5768 -2.3594e-005 1083]  [0 0 0]  [0 0 0]}
      % {[100000]  'naam '  [1000] [1]  [-1.0000e-255 -1.0000e-255 30000]  [0 0 0]  [0 0 0]}
      % {[999]  'Static item '  [0]  [1]  [0 0 0]  [0 0 0]  [0 0 0]}
      % {[999]  'Dummy '  [0]  [1]  [0 0 1589]  [0 0 0]  [0 0 0]}
      % {[999]  'E-coli '  [0]  [1]  [0 0 1589]  [0 0 0]  [0 0 0]}
      it=it+1;
      Info.Item(it).Name=deblank(i2.Data{2});
      Info.Item(it).Static=static;
      Info.Item(it).Max=i2.Data{5}(1);
      Info.Item(it).Min=i2.Data{5}(2);
      Info.Item(it).NumClip=i2.Data{5}(3);
      if ~static
        Info.Item(it).Data=repmat(-1,1,Info.NumTimeSteps);
      end
      Info.Item(it).MatrixSize=1;
      Info.Item(it).CellSize=0;
    case 54, %117 per item
      % [0] : 1D,2D,3D
      % [1] : 0D
    case 64, %156
      static=1;
    case 65, %156
      sz=[Info.Item(it).MatrixSize 1];
      Info.Item(it).Data=reshape(i2.Data{1},sz);
    case {76,79,82} %121
      % 0: -
      % 1: 76: {[1000 51]  [0 100]}
      % 2: 79: {[1000 44 78]  [0 0 150 150]}
      % 3: 82: {[1000 10 20 5]  [0 0 0 10 10 1]}
      NDim=length(i2.Data{1})-1;
      Info.Item(it).MatrixSize=i2.Data{1}(2:end);
      %Info.Item(it).Offset=i2.Data{2}(1:NDim);
      Info.Item(it).CellSize=i2.Data{2}((NDim+1):end);
    case 80, %195 {} start time dependent data
      it=0;
    case 81, %195 {} markers between time dependent datasets
      fld=fld+1;
      it=0;
    case 85, %78
      %  {'1990-01-01 '  '12:00:00 '  [1400]  [0 20]  [361 0]}
      %  {'1990-01-01 '  '12:00:00 '  [1400]  [0 20]  [361 0]}
      %  {'1990-01-01 '  '12:00:00 '  [1400]  [0 1800]  [1 0]}
      %  {'1990-01-01 '  '00:00:00 '  [1400]  [0 30]  [30 0]}
      V=sscanf([i2.Data{1}(1:end-1),' ',i2.Data{2}],'%d-%d-%d %d:%d:%d');
      Info.RefDate=datenum(V(1),V(2),V(3),V(4),V(5),V(6));
      Info.TimeStep=i2.Data{4}(2)/(3600*24);
      Info.NumTimeSteps=i2.Data{5}(1);
    otherwise
      Fld=sprintf('Fld%i_%i',Opt,X);
      if isfield(Info,Fld)
        Fld1=Fld; i=1;
        while isfield(Info,Fld1)
          i=i+1;
          Fld1=sprintf('%s_%i',Fld,i);
        end
        Fld=Fld1;
      end
      Info=setfield(Info,Fld,i2);
    end
  case 255
    return
  otherwise
    error(sprintf('Unknown type %i',Typ));
  end
end
Info.Check='OK';


function Data=Local_read_mike(S,varargin),
Data=[];

IN=varargin;
if length(IN)>0 & iscell(IN{end})
  subscr=IN{end};
  if length(subscr)~=S.NumCoords,
    error('Invalid number of indices.');
  end
  IN=IN(1:end-1);
else
  subscr={};
end

switch length(IN)
case 0
  if S.NumItems==1,
    Item=1;
    Info=S.Item(Item);
    TimeStep=max(1,S.NumTimeSteps);
  else,
    error('No item specified.');
  end;
case 1 % TimeStep or Item
  if S.NumItems==1
    Item=1;
    Info=S.Item(Item);
    TimeStep=IN{1};
  else
    Item=IN{1};
    if ischar(Item)
      Item=ustrcmpi(Item,{S.Item.Name});
      if isempty(Item)
        error('Invalid item name')
      end
    end
    Info=S.Item(Item);
    TimeStep=max(1,S.NumTimeSteps);
  end
case 2
  Item=IN{1};
  if ischar(Item)
    Item=ustrcmpi(Item,{S.Item.Name});
    if isempty(Item)
      error('Invalid item name')
    end
  end
  Info=S.Item(Item);
  TimeStep=IN{2};
otherwise
  error('Too many input arguments.')
end

if isempty(subscr)
  Size=S.DataDim+1;
else
  Size=zeros(1,S.NumCoords);
  for i=1:S.NumCoords
    if isequal(subscr{i},0)
      subscr{i}=1:(S.DataDim(i)+1);
      Size(i)=S.DataDim(i)+1;
    else
      Size(i)=length(subscr{i});
    end
  end
end

if isequal(TimeStep,-1),
  if S.GridCell(1)==0, % 0D
    Data=[];
  else
    switch length(S.DataDim)
    case 1,
      Data.X=(0:S.DataDim(1))*S.GridCell(1);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
    case 2,
      Data.X=repmat(transpose(0:S.DataDim(1))*S.GridCell(1), ...
                    1,S.DataDim(2)+1);
      Data.Y=repmat((0:S.DataDim(2))*S.GridCell(2), ...
                    S.DataDim(1)+1,1);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
      if ~isempty(subscr)
        Data.Y=Data.Y(subscr{:});
      end
    case 3,
      Data.X=repmat(transpose(0:S.DataDim(1))*S.GridCell(1), ...
                    [1,S.DataDim(2)+1,S.DataDim(3)+1]);
      Data.Y=repmat((0:S.DataDim(2))*S.GridCell(2), ...
                    [S.DataDim(1)+1,1,S.DataDim(3)+1]);
      Data.Z=repmat(reshape((0:S.DataDim(3))*S.GridCell(3), ...
                            [1 1 S.DataDim(3)+1]), ...
                    [S.DataDim(1)+1,S.DataDim(2)+1,1]);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
      if ~isempty(subscr)
        Data.Y=Data.Y(subscr{:});
      end
      if ~isempty(subscr)
        Data.Z=Data.Z(subscr{:});
      end
    end
  end
  return;
end;

dat_file=[S.FileName S.Dat];
fidat=fopen(dat_file,'r',S.Format);
if isequal(TimeStep,0)
  TimeStep=1:max(1,S.NumTimeSteps);
end
if length(TimeStep)~=1
  Data=zeros([length(TimeStep) Size]);
  for i=1:length(TimeStep)
    fseek(fidat,(S.NumItems*(TimeStep(i)-1)+Item-1)*prod(S.DataDim+1)*4,-1);
    Tmp=fread(fidat,[1 prod(S.DataDim+1)],'float32');
    if ~isempty(subscr)
      Tmp=Tmp(1,subscr{:});
    end
    Data(i,:)=Tmp;
  end
else
  fseek(fidat,(S.NumItems*(TimeStep-1)+Item-1)*prod(S.DataDim+1)*4,-1);
  Data=fread(fidat,[1 prod(S.DataDim+1)],'float32');
  Data=reshape(Data,[S.DataDim+1 1]);
  if ~isempty(subscr)
    Data=Data(subscr{:});
  end
end

fclose(fidat);


function Data=Local_read_mike_new(S,varargin),
Data=[];

IN=varargin;
if iscell(IN{end})
  subscr=IN{end};
  if length(subscr)~=S.NumCoords,
    error('Invalid number of indices.');
  end
  IN=IN(1:end-1);
else
  subscr={};
end

switch length(IN)
case 0
  if S.NumItems==1,
    Item=1;
    Info=S.Item(Item);
    if Info.Static
      TimeStep=1;
    else
      TimeStep=S.NumTimeSteps;
      if TimeStep==0 % Doesn't mean all timesteps. Well, it would give the same result since there are none.
        TimeStep=[];
      end
    end
  else,
    error('No item specified.');
  end;
case 1 % TimeStep or Item
  if S.NumItems==1
    Item=1;
    Info=S.Item(Item);
    TimeStep=IN{1};
  else
    Item=IN{1};
    if ischar(Item)
      Item=ustrcmpi(Item,{S.Item.Name});
      if isempty(Item)
        error('Invalid item name')
      end
    end
    Info=S.Item(Item);
    if Info.Static
      TimeStep=1;
    else
      TimeStep=S.NumTimeSteps;
      if TimeStep==0 % Doesn't mean all timesteps. Well, it would give the same result since there are none.
        TimeStep=[];
      end
    end
  end
case 2
  Item=IN{1};
  if ischar(Item)
    Item=ustrcmpi(Item,{S.Item.Name});
    if isempty(Item)
      error('Invalid item name')
    end
  end
  Info=S.Item(Item);
  TimeStep=IN{2};
otherwise
  error('Too many input arguments.')
end

if isempty(subscr)
  Size=Info.MatrixSize;
else
  Size=zeros(1,S.NumCoords);
  for i=1:S.NumCoords
    if isequal(subscr{i},0)
      subscr{i}=1:Info.MatrixSize(i);
      Size(i)=Info.MatrixSize(i);
    else
      Size(i)=length(subscr{i});
    end
  end
end

if isequal(TimeStep,-1),
  if Info.CellSize(1)==0, % 0D
    Data=[];
  else
    switch length(Info.MatrixSize)
    case 1,
      Data.X=(0:Info.MatrixSize(1))*Info.CellSize(1);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
    case 2,
      Data.X=repmat(transpose(0:Info.MatrixSize(1))*Info.CellSize(1), ...
                    1,Info.MatrixSize(2)+1);
      Data.Y=repmat((0:Info.MatrixSize(2))*Info.CellSize(2), ...
                    Info.MatrixSize(1)+1,1);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
      if ~isempty(subscr)
        Data.Y=Data.Y(subscr{:});
      end
    case 3,
      Data.X=repmat(transpose(0:Info.MatrixSize(1))*Info.CellSize(1), ...
                    [1,Info.MatrixSize(2)+1,Info.MatrixSize(3)+1]);
      Data.Y=repmat((0:Info.MatrixSize(2))*Info.CellSize(2), ...
                    [Info.MatrixSize(1)+1,1,Info.MatrixSize(3)+1]);
      Data.Z=repmat(reshape((0:Info.MatrixSize(3))*Info.CellSize(3), ...
                            [1 1 Info.MatrixSize(3)+1]), ...
                    [Info.MatrixSize(1)+1,Info.MatrixSize(2)+1,1]);
      if ~isempty(subscr)
        Data.X=Data.X(subscr{:});
      end
      if ~isempty(subscr)
        Data.Y=Data.Y(subscr{:});
      end
      if ~isempty(subscr)
        Data.Z=Data.Z(subscr{:});
      end
    end
  end
  return;
end

if Info.Static
  Data=S.Item(Item).Data;
  if ~isempty(subscr)
    Data=Data(subscr{:});
  end
else
  dat_file=[S.FileName S.Dat];
  fidat=fopen(dat_file,'r',S.Format);
  if isequal(TimeStep,0)
    TimeStep=1:S.NumTimeSteps;
  end
  if length(TimeStep)~=1
    Data=zeros([length(TimeStep) Size]);
    for i=1:length(TimeStep)
      fseek(fidat,Info.Data(TimeStep(i)),-1);
      Tmp=fread(fidat,[1 prod(Info.MatrixSize)],'float32');;
      if ~isempty(subscr)
        Tmp=Tmp(1,subscr{:});
      end
      Data(i,:)=Tmp;
    end
  else
    fseek(fidat,Info.Data(TimeStep),-1);
    Data=fread(fidat,prod(Info.MatrixSize),'float32');
    Data=reshape(Data,[Info.MatrixSize 1]);
    if ~isempty(subscr)
      Data=Data(subscr{:});
    end
  end
  fclose(fidat);
end
Data(Data==S.Clipping)=NaN;