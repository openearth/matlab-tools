function ndisp=binary(file,nread,nskip)
% BINARY displays the binary contents of a file
%     BINARY(FILE) displays FILE completely. If no file is given, BINARY
%     will ask for one. BINARY(FILE,N) displays the first N bytes of the
%     FILE. BINARY(FILE,N,NSKIP) skips the first NSKIP bytes and displays
%     the next N.
%     Instead of a filename, a file identifier (FID) can be entered. Then
%     BINARY will start reading at the current position locator in that
%     file (or after skipping NSKIP bytes).
%     NREAD=BINARY(...) returns the number of bytes that were actually
%     read and displayed by the function.

% (c) Copyright 1997 H.R.A. Jagers, University of Twente, The Netherlands

if nargout>0,
  ndisp=-1;
end;

if nargin<3,
  nskip=0;
  if nargin<2,
    nread=inf;
    if nargin<1,
      [file,fpath]=uigetfile('*.*');
      file=[fpath file];
      if ~isstr(file),
        fprintf(1,'* No file selected.\n');
        return;
      end;
    end;
  end;
end;

if isempty(nread),
  fprintf(1,'* Second argument is invalid.\n');
  return;
elseif size(nread)~=[1 1],
  fprintf(1,'* Second argument is invalid.\n');
  return;
elseif (nread<=0) | (isnan(nread)),
  fprintf(1,'* Second argument is invalid.\n');
  return;
end;

if isempty(nskip),
  fprintf(1,'* Third argument is invalid.\n');
  return;
elseif (prod(size(nskip))~=1),
  fprintf(1,'* Third argument is invalid.\n');
  return;
elseif isnan(nskip),
  fprintf(1,'* Third argument is invalid.\n');
  return;
end;

if isstr(file),
  fid=fopen(file);
  if fid<0,
    fprintf(1,'* Could not open file.\n');
    return;
  end;
else,
  fid=file;
end;

if isfinite(nskip),
  if fseek(fid,nskip,0)<0,
    fprintf(1,'* Skipping indicated number of bytes would\n');
    fprintf(1,'  result in a position outside the file.\n');
    return;
  end;
else, % ~isfinite(nskip),
  if nskip<0, % -inf
    fseek(fid,0,-1);
  else, % +inf
    if ~isfinite(nread), % read an unlimited amount of bytes
      fseek(fid,0,-1);   % start at begin of file, i.e. read whole file.
    else,
      if fseek(fid,-nread,1)<0, % if more bytes required than in file
        fseek(fid,0,-1);        % read whole file.
      end;
    end;
  end;
end;

% check where the reading starts to create byte labels.
pos=ftell(fid);
i0=floor(pos/16);
Rem=pos-16*i0;

[M,Count]=fread(fid,nread,'uint8');
if nargout>0,
  ndisp=M;
end;

N=zeros(16,ceil((Rem+Count)/16));
N(Rem+(1:Count))=M(1:Count);
NumStr='0123456789ABCDEF';

t=-Rem;
tcopy=t;
for i=1:size(N,2),
  temp=i+i0-1;
  n=zeros(1,7);
  for j=1:7,
    temp2=floor(temp/16);
    n(j)=temp-temp2*16;
    temp=temp2;
  end;
  s=NumStr(fliplr(n)+1);
  fprintf('%s0:  ',s);
  for j=1:16,
    n=N(j,i);
    n1=floor(n/16);
    n2=n-n1*16;
    t=t+1;
    if (t>Count) | (t<1),
      s='   ';
    else,
      s=[NumStr(n1+1) NumStr(n2+1) ' '];
    end;
    if j==8;
      s=[s '- '];
    end;
    fprintf('%s',s);
  end;
  n=N(:,i);
  for j=1:16,
    tcopy=tcopy+1;
    if (tcopy>Count) | (tcopy<1),
      n(j)=32;
    else,
      if any(n(j)==[0:31 126:159]),
        n(j)=124;
      end;
    end;
  end;
  fprintf(' %s\n',n);
end;

if isstr(file),
  fclose(fid);
end;
