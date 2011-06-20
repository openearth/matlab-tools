function sdsconvert(FileName)

if nargin==0,
  [f,p]=uigetfile('SDS-*');
  if ~ischar(f), return; end
  FileName=[p f];
end

fid=fopen(FileName,'r','b');
Format='b';
X=fread(fid,[1 20],'int32'); % <-------- info
MaxNWriteProg=X(3);
if MaxNWriteProg<1 | MaxNWriteProg>100000,
  fclose(fid);
  fid=fopen(FileName,'r','l'); % might also be vaxd, vaxg, cray, ieee-le.l64, ieee-be.l64
  Format='l';
  fseek(fid,20480,-1);
  SequenceNrAdmin=fread(fid,1,'int32');
  fseek(fid,0,-1);
else
  fseek(fid,0,-1);
end

if strcmp(Format,'l') & isequal(SequenceNrAdmin,0), % PC version PC386 Icim
  fprintf('PC386 Icim\n');
  fid2=fopen(strcat(FileName,'.unix'),'w');
  while 1,
    X=fread(fid,[1 8192],'uchar');
    if isempty(X), break; end
    Str=Swap4byte(X(1,1:2048));
    fwrite(fid2,Str,'uchar');
  end
elseif strcmp(Format,'l') % "normal PC"
  fprintf('flipped UNIX\n');
  fid2=fopen(strcat(FileName,'.unix'),'w');
  while 1,
    X=fread(fid,[1 2048000],'uchar');
    if isempty(X), break; end
    Str=Swap4byte(X);
    fwrite(fid2,Str,'uchar');
  end
else % UNIX version
  fprintf('UNIX\n');
  fid2=fopen(strcat(FileName,'.pc'),'w');
  while 1,
    X=fread(fid,[1 2048000],'uchar');
    if isempty(X), break; end
    Str=Swap4byte(X);
    fwrite(fid2,Str,'uchar');
  end
%
%  To PC386 Icim:
%
%  fid2=fopen(strcat(FileName,'.pc'),'w');
%  Str=zeros(1,8192);
%  while 1,
%    X=fread(fid,[1 2048],'uchar');
%    if isempty(X), break; end
%    Str(1:2048)=Swap4byte(X);
%    fwrite(fid2,Str,'uchar');
%  end
end
fclose(fid);
fclose(fid2);


function Str=Swap4byte(Str1);
N=length(Str1);
if N~=round(N/4)*4, error('String length not multiple of 4 bytes. Cannot swap bytes.'); end
I=1:N;
I=flipud(reshape(I,[4 N/4]));
Str=Str1(I(:)');
