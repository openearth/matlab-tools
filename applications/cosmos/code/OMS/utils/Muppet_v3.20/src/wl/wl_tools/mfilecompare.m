function AnyDiff=mfilecompare(fid,dir1,dir2,lvl),
% MFILECOMPARE compare mfiles in different locations
%       MFILECOMPARE('directory1','directory2')
%       output send to screen.
%       MFILECOMPARE(fid,'directory1','directory2')
%       output send to screen and specified file.

N=0;
if ischar(fid),
  if nargin==2, lvl=0; end;
  dir2=dir1;
  dir1=fid;
  fid=1;
else, % fid
  if nargin==3, lvl=0; end;
end;
if lvl==0,
  mfprintf(fid,'Comparing:\n(1) %s\n(2) %s\n---------------------------\n',dir1,dir2);
  LvlStr='';
else,
  LvlStr=['\n' repmat('  ',1,lvl)];
end;

if ~exist(dir1),
  if nargout>0,
    AnyDiff=1;
  end;
  mfprintf(fid,'Cannot find (1)\n');
  return;
elseif ~exist(dir2),
  if nargout>0,
    AnyDiff=1;
  end;
  mfprintf(fid,'Cannot find (2)\n');
  return;
end;

%
% compare subdirectories
%

D1=dir(dir1);
D2=dir(dir2);

Dirs1={D1([D1.isdir]).name};
Dirs2={D2([D2.isdir]).name};
Dirs1(strmatch('.',Dirs1,'exact'))=[];
Dirs1(strmatch('..',Dirs1,'exact'))=[];
Dirs2(strmatch('.',Dirs2,'exact'))=[];
Dirs2(strmatch('..',Dirs2,'exact'))=[];

Empty=1;
for i=1:length(Dirs1),
  Empty=0;
  k=strmatch(Dirs1{i},Dirs2,'exact');
  if ~isempty(k),
    Dirs2(k)=[];
    mfprintf(fid,[LvlStr 'subdirectory %s: '],Dirs1{i});
    LvlStr=repmat('  ',1,lvl);
    N=mfilecompare(fid,fullfile(dir1,Dirs1{i}),fullfile(dir2,Dirs1{i}),lvl+1);
  else,
    mfprintf(fid,[LvlStr 'subdirectory %s contained in (1) but not in (2).\n'],Dirs1{i});
    LvlStr=repmat('  ',1,lvl);
  end;
end;
for i=1:length(Dirs2),
  Empty=0;
  mfprintf(fid,[LvlStr 'subdirectory %s contained in (2) but not in (1).\n'],Dirs2{i});
  LvlStr=repmat('  ',1,lvl);
end;

%
% compare M files
%

D1=dir(fullfile(dir1,'*.m'));
D2=dir(fullfile(dir2,'*.m'));

if ~isempty(D1),
  MFls1={D1(~[D1.isdir]).name};
else,
  MFls1={};
end;
if ~isempty(D2),
  MFls2={D2(~[D2.isdir]).name};
else,
  MFls2={};
end;
for i=1:length(MFls1),
  Empty=0;
  k=strmatch(MFls1{i},MFls2,'exact');
  if ~isempty(k),
    MFls2(k)=[];
    mfprintf(fid,[LvlStr '%s ... '],MFls1{i});
    LvlStr=repmat('  ',1,lvl);
    fid1=fopen(fullfile(dir1,MFls1{i}));
    fid2=fopen(fullfile(dir2,MFls1{i}));
    lnr=0;
    while ~feof(fid1) & ~feof(fid2),
      line1=fgetl(fid1);
      line2=fgetl(fid2);
      lnr=lnr+1;
      if ~isequal(line1,line2),
        break;
      end;
    end;
    if ~isequal(line1,line2),
      mfprintf(fid,'different in line %i.\n',lnr);
    else,
      mfprintf(fid,'OK\n');
    end;
    fclose(fid1);
    fclose(fid2);
  else,
    mfprintf(fid,[LvlStr '%s contained in (1) but not in (2).\n'],MFls1{i});
    LvlStr=repmat('  ',1,lvl);
  end;
end;
for i=1:length(MFls2),
  Empty=0;
  mfprintf(fid,[LvlStr '%s contained in (2) but not in (1).\n'],MFls2{i});
  LvlStr=repmat('  ',1,lvl);
end;

if Empty & lvl>0,
  mfprintf(fid,'empty\n');
end;
if nargout>0,
  AnyDiff=N;
end;

function mfprintf(H,varargin),
if H>2,
  fprintf(1,varargin{:});
end;
fprintf(H,varargin{:});

