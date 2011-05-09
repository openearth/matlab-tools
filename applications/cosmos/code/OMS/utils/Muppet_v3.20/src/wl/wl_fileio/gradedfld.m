function varargout=gradedfld(cmd,varargin),
% GRADEDFLD read/write Delft3D graded sediment field files.
%    GRADEDFLD can be used to read and write the field
%    files used by the graded sediment version of
%    Delft3D-MOR.
%
%    FIELD=GRADEDFLD('read',FILENAME)
%
%    GRADEDFLD('write',FILENAME,FIELD)

% (c) copyright, Delft Hydraulics, 2002
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch cmd,
case 'read',
  Fld=Local_fldread(varargin{:});
  varargout={Fld};
case 'write',
  Out=Local_fldwrite(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  error('Unknown command');
end;


function FLD=Local_fldread(filename),

FLD=[];

if strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.*','Select Delft3D-GRA field file');
  if ~ischar(fname),
    return;
  end;
  filename=[fpath,fname];
end;

fid=fopen(filename);
if fid<0,
  error(['Cannot open ',filename,'.']);
end;
%
% scan file ...
%
fgetl(fid); % comment line
%
Line=fgetl(fid); % 29 215 13 20 ... or ... 29 215 13
Sz=sscanf(Line,'%i',[1 inf]);
if length(Sz)<3 | length(Sz)>4
  error(fprintf('Line 2 is an invalid dimension line in file: ''%s''.',filename));
else
  NMKF=[Sz(1:2) 1 Sz(3)];
  nVal=Sz(3);
  NM=Sz(1:2);
  if length(Sz)==4
    NMKF(3)=Sz(4);
  end
end
%
% Loop
%
LayDef=logical(zeros(1,NMKF(3)));
Fld=zeros(NMKF); Fld(:,:,:,end)=1; % default 100% last fraction
%
%SKCOMB
Line=fgetl(fid);
NL=sscanf(Line,'%i',[1 inf]);
%
if NMKF(3)==1
  np=NL(1);
  %
  Fld(:,:,1,:)=readfld(fid,np,Fld(:,:,1,:));
else
  while isequal(size(NL),[1 2]) & ~isequal(NL,[-1 -1])
    %
    k=NL(1);
    np=NL(2);
    %
    if k>NMKF(3) | k<1
      error(sprintf('Invalid layer number %i.',k));
    elseif LayDef(k),
      error(sprintf('Layer %i specified twice.',k));
    end
    %
    Fld(:,:,k,:)=readfld(fid,np,Fld(:,:,k,:));
    LayDef(k)=1;
    %
    %SKCOMB
    Line=fgetl(fid);
    NL=sscanf(Line,'%i',[1 inf]);
  end
end
%
kdef=0;
for k=1:NMKF(3)
  if LayDef(k)
    kdef=k;
    break;
  end
end
%
fclose(fid);
%
if kdef<0
  error('Values defined for no layer.');
end
%
for k=1:NMKF(3)
  if LayDef(k)
    kdef=k;
  end
  Fld(:,:,k,:)=Fld(:,:,kdef,:);
end
%
FLD=Fld;


function Fld=readfld(fid,np,Fld0)
Fld=Fld0;
Sz=size(Fld0);
nVal=Sz(4);
NM=Sz(1:2);
N=NM(1);
M=NM(2);
switch np
case 1 % constant field
  %SKCOMB
  Vals=fscanf(fid,'%f',[1 nVal]);
  Vals=reshape(Vals,[1 1 1 nVal]);
  Fld=repmat(Vals,NM);
case 2 % varying field from standard input file
  %SKCOMB
  params=fscanf(fid,'%i',[1 5]);
  while ~isequal(params(1:4),[-1 -1 -1 -1])
    NMrange=params(1:4);
    opt=params(5);
    if isequal(NMrange,[0 0 0 0])
      NMrange=[1 1 NM];
    end
    Nrange=NMrange(1):NMrange(3); Nr=length(Nrange);
    Mrange=NMrange(2):NMrange(4); Mr=length(Mrange);
    %SKCOMB
    if opt==0 % uniform on block
      Vals=fscanf(fid,'%f',[1 nVal]);
      Vals=reshape(Vals,[1 1 1 nVal]);
      Fld(Nrange,Mrange,1,:)=repmat(Vals,[Nr Mr]);
    else
      Vals=fscanf(fid,'%f',[nVal Nr*Mr]);
      Vals=reshape(Vals,[nVal Nr Mr]);
      Vals=permute(Vals,[2 3 4 1]);
      Fld(Nrange,Mrange,1,:)=Vals;
    end
    %SKCOMB
    params=fscanf(fid,'%i',[1 5]);
  end
case 3 % varying in m direction, constant in n direction
  %SKCOMB
  Vals=fscanf(fid,'%f',[nVal M]);
  Vals=permute(Vals,[3 2 4 1]);
  Fld(:,:,1,:)=repmat(Vals,[N 1]); 
case 4 % varying in n direction, constant in m direction
  %SKCOMB
  Vals=fscanf(fid,'%f',[nVal N]);
  Vals=permute(Vals,[2 3 4 1]);
  Fld(:,:,1,:)=repmat(Vals,[1 M]); 
case 5 % varying field (((F)N)M)
  %SKCOMB
  Vals=fscanf(fid,'%f',[nVal N*M]);
  Vals=reshape(Vals,[nVal N M]);
  Fld=permute(Vals,[2 3 4 1]);
case 6 % varying field  ( ((N)M) F)
  for i=1:nFrac
    %SKCOMB
    ii=fscanf(fid,'%i',1);
    if ~isequal(i,ii),
      error(sprintf('Sequence number of values out of order %i expected %i',ii,i));
    end
    Vals=fscanf(fid,'%f',[N M]);
    Fld(:,:,1,i)=Vals;
  end
end
Line=fgetl(fid);


function OK=Local_fldwrite(filename,Fld),
Sz=size(Fld);
N=Sz(1);
M=Sz(2);
K=Sz(3);
NFrac=Sz(4);
LayDef=logical(zeros(1,size(Fld,3)));
LayDef(1)=1;
kdef=1;
for k=2:K
  if ~isequal(Fld(:,:,k,:),Fld(:,:,kdef,:))
    LayDef(k)=1;
    kdef=k;
  end
end

fid=fopen(filename,'w');
fprintf(fid,'* %s\n',filename);
if K>1
  fprintf(fid,'%i %i %i %i\n',N,M,NFrac,K);
else
  fprintf(fid,'%i %i %i\n',N,M,NFrac);
end
Str=[repmat(' %.8f',1,NFrac),'\n'];
for k=1:K
  if LayDef(k)
    Vals=Fld(:,:,k,:);
    pVals=permute(Vals,[4 1 2 3]);
    pVals=reshape(pVals,[NFrac N*M]);
    pVals=unique(pVals','rows');
    if isequal(size(pVals,1),1)
      fprintf(fid,'%i 1\n',k);
      fprintf(fid,Str,pVals);
    else
      fprintf(fid,'%i 5\n',k);
      Vals=permute(Vals,[4 1 2 3]);
      Vals=Vals(:,:);
      fprintf(fid,Str,Vals);
    end
  end
end
fprintf(fid,'-1 -1\n',k);
fclose(fid);
OK=1;

