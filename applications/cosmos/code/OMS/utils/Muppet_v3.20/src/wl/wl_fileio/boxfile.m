function varargout=boxfile(cmd,varargin),
% BOXFILE read/write SIMONA box files
%    BOXFILE can be used to read and write Waqua/Triwaq
%    field files used for depth and roughness data.
%
%    DEPTH=BOXFILE('read',FILENAME)
%    read the data from the boxfile. This call uses
%    creates a matrix that tightly fits the data.
%    Use ...,SIZE) or ...,GRID) where GRID was generated
%    by WLGRID to get a depth array corresponding to the
%    indicated grid (or larger when the grid indices in
%    the datafile indicate that).
%
%    BOXFILE('write',FILENAME,MATRIX)
%    write the MATRIX to the file in boxfile format.
%    Missing values (NaN's) are replaced by 999.999.

% (c) copyright, Delft Hydraulics, 2001
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch cmd,
case 'read',
  varargout={Local_depread(varargin{:})};
case 'write',
  Out=Local_depwrite(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  error('Unknown command');
end;


function DP=Local_depread(filename,dimvar),
%    DEPTH=BOXFILE('read',FILENAME)
%    read the data from the boxfile. This call uses
%    creates a matrix that tightly fits the data.
%    Use ...,SIZE) or ...,GRID) where GRID was generated
%    by WLGRID to get a depth array corresponding to the
%    indicated grid (or larger when the grid indices in
%    the datafile indicate that).

DP=[];

dim=[];
if nargin==2
  if isstruct(dimvar), % new grid format G.X, G.Y, G.Enclosure
    dim=size(dimvar.X)+1;
  elseif iscell(dimvar), % old grid format {X Y Enclosure}
    dim=size(dimvar{1})+1;
  else,
    dim=dimvar;
  end;
end

if strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.*','Select depth file');
  if ~ischar(fname),
    return;
  end;
  filename=[fpath,fname];
end;

fid=fopen(filename,'r');
if fid<0,
  error(['Cannot open ',filename,'.']);
end;

% BOX: MNMN  =  (   2,    2 ;   38,    6) Variable_var =
S='#';
while isequal(S,'#')
  S=fscanf(fid,' %c',1);
  if isequal(S,'#'), fgetl(fid); end
end

if ~isequal(upper(S),'B'),
  error('BOX keyword not found.');
end
BOX=fscanf(fid,'%[Oo]%[Xx]',2);
i=0;
while isequal(upper(BOX),'OX')
  i=i+1;
  fscanf(fid,'%[^Mm]',inf);
  fscanf(fid,' %[Mm]%[Nn]%[Mm]%[Nn]',4);
  fscanf(fid,' %[=(]',inf);
  MNMN=fscanf(fid,' %i %*[;,]',[1 4]);
  if ~isequal(size(MNMN),[1 4])
    error('MNMN indices not found.');
  end
  fscanf(fid,'%[^=]',inf);
  fscanf(fid,'%[=]',1);
  data{i,1}=MNMN;
  data{i,2}=fscanf(fid,'%f',[MNMN(4)-MNMN(2)+1 MNMN(3)-MNMN(1)+1])';
  S='#';
  while isequal(S,'#')
    S=fscanf(fid,' %c',1);
    if isequal(S,'#'), fgetl(fid); end
  end
  BOX=fscanf(fid,'%[Oo]%[Xx]',2);
end
fclose(fid);

if isempty(dim)
  maxM=0;
  maxN=0;
  for i=1:size(data,1)
    MNMN=data{i,1};
    maxM=max(maxM,max(MNMN([1 3])));
    maxN=max(maxN,max(MNMN([2 4])));
  end
  dim=[maxM maxN];
end
DP=repmat(NaN,dim);
for i=1:size(data,1)
  MNMN=data{i,1};
  DP(MNMN(1):MNMN(3),MNMN(2):MNMN(4))=data{i,2};
end


function OK=Local_depwrite(filename,DP),
%    BOXFILE('write',FILENAME,MATRIX)
%    write the MATRIX to the file in boxfile format.
%    Missing values (NaN's) are replaced by 999.999.

OK=0;
fid=fopen(filename,'w');
if fid<0,
  error(['Cannot open ',filename,'.']);
end;

% BOX: MNMN  =  (   2,    2 ;   38,    6) Variable_var = 
NpL=5;
Mmax=size(DP,1);
Nmax=size(DP,2);
offset=0;
DP(isnan(DP))=999.999;
for i=1:ceil(Nmax/NpL)
  fprintf(fid,' BOX: MNMN  =  ( %4i, %4i ; %4i, %4i) Variable_var = \n',1,offset+1,Mmax,min(offset+NpL,Nmax));
  NtL=min(offset+NpL,Nmax)-offset;
  Format=[repmat(' %13.6f',1,NtL) '\n'];
  fprintf(fid,Format,DP(:,offset+(1:NtL))');
  offset=offset+NpL;
end
fclose(fid);
OK=1;
