function Out=delft3d(cmd,varargin);
% DELFT3D File operations for DELFT3D files.
%        FileData = delft3d('readout',filename);
%          reads data from a morsys???.out file.

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'readout',
  Structure=Local_read_outfile(varargin{:});
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
end;

function Structure=Local_read_outfile(filename),

Structure.Check='NotOK';
Structure.Process=[];

if nargin==0,
  [fn,fp]=uigetfile('morsys???.out');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
NFreq=filestr(filename,'itb ite');

Structure.Process(NFreq(1)).Name='';
Structure.Process(NFreq(1)).Info=[];
Structure.BeginTime=zeros(1,NFreq(1));
Structure.EndTime=zeros(1,NFreq(1));
Structure.CPUTime=zeros(1,NFreq(1));
Structure.First=zeros(1,NFreq(1));
Structure.Type=zeros(1,NFreq(1));

mygetl(filename);
Cnt=0;
lasterr('');
try,
while 1,
  [n,Line]=mygetl('itb ite','Epsa','Fmax','Optimal time step','cputyd','normp');
  switch n,
  case 1, % PROCES itb ite
    X1=min(findstr(Line,'itb ite'));
    X=sscanf(Line(X1+7:end),'%i',2);
    Cnt=Cnt+1;
    Structure.Process(Cnt).Name=deblank(Line(1:(X1-1)));
    Structure.BeginTime(Cnt)=X(1);
    Structure.EndTime(Cnt)=X(2);
    Structure.Process(Cnt).Info.Epsa=[];
    Structure.Process(Cnt).Info(1,:)=[];
    switch Structure.Process(Cnt).Name,
    case 'TRISULA',
      Structure.Type(Cnt)=2;
    case {'TRSGRA','TRSTOT','TRSSUS'},
      Structure.Type(Cnt)=3;
      Structure.Process(Cnt).Info.NormP=0;
    case 'BOTTOM',
      Structure.Type(Cnt)=4;
    otherwise,
      Structure.Type(Cnt)=NaN;
    end;
    if Cnt==1,
      Structure.First(Cnt)=1;
    else,
      Structure.First(Cnt)=Structure.Type(Cnt)~=Structure.Type(Cnt-1);
    end;
  case 2,
    [n,Line]=mygetl('');
    X=sscanf(Line,'%f',[1 5]);
    Structure.Process(Cnt).Info.Epsa=X;
  case 3,
    [n,Line]=mygetl('');
    X=sscanf(Line,'%f',[1 3]);
    Structure.Process(Cnt).Info.Fmax=X;
  case 4,
    X=sscanf(Line(21:end),'%f',1);
    Structure.Process(Cnt).Info.OptimalTimeStep=X;
  case 5,
    X=sscanf(Line(13:end),'%f',1);
    Structure.CPUTime(Cnt)=X;
  case 6,
    Structure.Process(Cnt).Info.NormP=Structure.Process(Cnt).Info.NormP+1;
  case -1, % EOF
    return;
  end;
end;
catch,
  % make sure I get the Structure no matter what error
  warning(lasterr);
end;


function Structure=MATLABLocal_read_outfile(filename),
% Read from a morsys???.out file
Structure.Check='NotOK';
Structure.Process=[];
lasterr('');
try,
if nargin==0,
  [fn,fp]=uigetfile('morsys???.out');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'rt');
Line=fgetl(fid);
while ischar(Line),
  if length(Line)>16 & ~isempty(findstr(Line,'itb ite')), % PROCES itb ite
    X1=min(findstr(Line,'itb ite'));
    X=sscanf(Line(X1+7:end),'%i',2);
    Structure.Process(end+1).Name=deblank(Line(1:(X1-1)));
    Structure.Process(end).BeginTime=X(1);
    Structure.Process(end).EndTime=X(2);
    Structure.Process(end).CPUTime=0;
    Structure.Process(end).Info.Epsa=[];
    Structure.Process(end).Info(1,:)=[];
    switch Structure.Process(end).Name,
    case 'TRISULA',
      Structure.Process(end).Type=1;
    case 'TRSGRA',
      Structure.Process(end).Type=3;
      Structure.Process(end).Info.NormP=0;
    case 'BOTTOM',
      Structure.Process(end).Type=4;
    otherwise,
      Structure.Process(end).Type=NaN;
    end;
    if length(Structure.Process)==1,
      Structure.Process.First=1;
    else,
      Structure.Process(end).First=Structure.Process(end).Type~=Structure.Process(end-1).Type;
    end;
  elseif ~isempty(findstr('Epsa',Line)),
    Line=fgetl(fid);
    X=sscanf(Line,'%f',[1 5]);
    Structure.Process(end).Info.Epsa=X;
  elseif ~isempty(findstr('Fmax',Line)),
    Line=fgetl(fid);
    X=sscanf(Line,'%f',[1 3]);
    Structure.Process(end).Info.Fmax=X;
  elseif ~isempty(findstr('Optimal time step',Line)),
    X=sscanf(Line(21:end),'%f',1);
    Structure.Process(end).Info.OptimalTimeStep=X;
  elseif ~isempty(findstr('cputyd',Line)),
    X=sscanf(Line(13:end),'%f',1);
    Structure.Process(end).CPUTime=X;
  elseif ~isempty(findstr('normp',Line)),
    Structure.Process(end).Info.NormP=Structure.Process(end).Info.NormP+1;
  end;
  Line=fgetl(fid);
end;
catch,
  % make sure I get the Structure no matter what error
  warning(lasterr);
end;
