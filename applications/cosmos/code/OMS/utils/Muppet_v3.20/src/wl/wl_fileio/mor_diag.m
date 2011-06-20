function Out=mor_diag(cmd,varargin);
% MOR_DIAG File operations for a MORSYS mor-diag file.
%        FileData = mor_diag('read',filename);
%          reads data from a mor-diag file.
%
%        AxesHandle = mor_diag('plot',FileData);
%          plots the process scheduling of a mor-diag file.
%
%        mor_diag('simperiods',FileData);
%          plots the elementary simulation periods.
%        mor_diag('flowiter',FileData);
%          plots the number of iterations spend in each flow
%          iteration loop.

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'read',
  Structure=Local_read_file(varargin{:});
  if nargout>0,
    if ~isstruct(Structure),
      Out=[];
    else,
      Out=Structure;
    end;
  end;
case 'plot',
  if nargin==1,
    ax=[];
  else,
    ax=Local_plot_file(varargin{:});
  end;
  if nargout>0,
    Out=ax;
  end;
case 'simperiods',
  if nargin==1,
    ax=[];
  else,
    ax=Local_SimPeriods(varargin{:});
  end;
  if nargout>0,
    Out=ax;
  end;
case 'flowiter',
  if nargin==1,
    handle=[];
  else,
    handle=Local_FlowIter(varargin{:});
  end;
  if nargout>0,
    Out=handle;
  end;
end;

function Structure=Local_read_file(filename),
Structure.Check='NotOK';

if nargin==0,
  [fn,fp]=uigetfile('mor-diag.*');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'rt');
while ~feof(fid),
  Line=fgetl(fid);
  if ~isempty(findstr(Line,'time unit')),
    Structure.TScale=sscanf(Line,'%*[timeunit ]= %f');
  end;
  if ~isempty(findstr(Line,'Begin time')),
    break;
  end;
end;
for i=1:5, % skip next four lines
  Line=fgetl(fid);
end;
Block=0;
EmptyModule(1).Name='';
EmptyModule(1).BeginTime=[];
EmptyModule(1).EndTime=[];
EmptyModule(1,:)=[];

nBlock=100;
nBlockInc=100;
Structure.Node(nBlock).Controller=[];
% Structure.Node(nBlock).InitRun=[];
Structure.Node(nBlock).BeginTime=[];
% Structure.Node(nBlock).EndTime=[];
Structure.Node(nBlock).CurrentTime=[];
Structure.Node(nBlock).Module=EmptyModule;

while ~feof(fid),
  [X,Cnt]=sscanf(Line,'%i',[1 5]);
  if Cnt==0,
    if findstr(Line,'restart')
      break
    end
    % skip caption:
    % Module      Time interval
    %             from       to
    for i=1:2, % skip next two lines
      Line=fgetl(fid);
    end;
    ElmBlock=0;
    Structure.Node(Block).Module=EmptyModule;
    [X,Cnt]=sscanf(Line,'%i',[1 5]);
    while ~feof(fid) & Cnt==0,
      ElmBlock=ElmBlock+1;
      [Data,N]=sscanf(Line,'%s %i %i',[1 3]);
      if N<3,
        fclose(fid);
        return;
      end;
      Structure.Node(Block).Module(ElmBlock,1).Name=char(Data(1:(length(Data)-2)));
      Structure.Node(Block).Module(ElmBlock,1).BeginTime=Data(end-1);
      Structure.Node(Block).Module(ElmBlock,1).EndTime=Data(end);
      Line=fgetl(fid);
      [X,Cnt]=sscanf(Line,'%i',[1 5]);
    end;
  else,
    if Cnt<5,
      break;
    end;
    Block=Block+1;
    if Block>nBlock,
      nBlock=nBlock+nBlockInc;
      Structure.Node(nBlock).Controller=[];
      % Structure.Node(nBlock).InitRun=[];
      Structure.Node(nBlock).BeginTime=[];
      % Structure.Node(nBlock).EndTime=[];
      Structure.Node(nBlock).CurrentTime=[];
      Structure.Node(nBlock).Module=EmptyModule;
    end;
    Structure.Node(Block).Controller=X(1);
%    Structure.Node(Block).InitRun=X(2);
    Structure.Node(Block).BeginTime=X(3);
%    Structure.Node(Block).EndTime=X(4);
    Structure.Node(Block).CurrentTime=X(5);
    Structure.Node(Block).Module=EmptyModule;
    Line=fgetl(fid);
  end;
end;
fclose(fid);
Structure.Node((Block+1):nBlock)=[];

function ax=Local_plot_file(Structure,ax),
if nargin==0,
  ax=[];
  return;
elseif ~isstruct(Structure),
  ax=[];
  return;
end;
if nargin==1,
  ax=gca;
  set(ax,'ylim',[0 1], ...
       'box','on', ...
       'yticklabel','manual', ...
       'ycolor',[1 1 1], ...
       'ytick',[], ...
       'yticklabel',[]);
  set(get(ax,'xlabel'),'string','relative time [sec] \rightarrow');
else, % ax specified
end;

% Start analysis of Structure

ModuleNames='';
Module.Name='TEMP';
Module=Module([]);
for Block=1:length(Structure.Node),
  if ~isempty(Structure.Node(Block).Module),
    for SubBlock=1:length(Structure.Node(Block).Module),
      if isempty(ModuleNames),
        M=length(Module)+1;
        Module(M).Name=Structure.Node(Block).Module(SubBlock).Name;
        Module(M).Freq=1;
        ModuleNames=Module(M).Name;
      else
        M=strmatch(Structure.Node(Block).Module(SubBlock).Name,ModuleNames,'exact');
        if isempty(M),
          M=length(Module)+1;
          Module(M).Name=Structure.Node(Block).Module(SubBlock).Name;
          Module(M).Freq=1;
          ModuleNames=str2mat(ModuleNames,Module(M).Name);
        else,
          Module(M).Freq=Module(M).Freq+1;
        end;
      end;
    end;
  end;
end;

% Construct plot data

for M=1:length(Module),
  Module(M).XData=NaN*ones(1,3*Module(M).Freq);
  Module(M).YData=M/(length(Module)+1)*ones(1,3*Module(M).Freq);
  Module(M).NextPoint=1;
end;

for Block=1:length(Structure.Node),
  if ~isempty(Structure.Node(Block).Module),
    for SubBlock=1:length(Structure.Node(Block).Module),
      M=strmatch(Structure.Node(Block).Module(SubBlock).Name,ModuleNames,'exact');
      Module(M).XData(Module(M).NextPoint)=Structure.Node(Block).Module(SubBlock).BeginTime;
      Module(M).XData(Module(M).NextPoint+1)=Structure.Node(Block).Module(SubBlock).EndTime;
      Module(M).NextPoint=Module(M).NextPoint+3;
    end;
  end;
end;

Xmin=min([Module.XData]);
Xmax=max([Module.XData]);
TScale=Structure.TScale;
% Plot to axes ax
for M=1:length(Module),
  text(TScale*Xmin,Module(M).YData(1),Module(M).Name, ...
      'horizontalalignment','left', ...
      'verticalalignment','bottom', ...
      'parent',ax);
  line(TScale*Module(M).XData,Module(M).YData, ...
      'linewidth',0.5, ...
      'marker','.', ...
      'markersize',1, ...
      'parent',ax);
end;
set(ax,'xlim',[TScale*Xmin TScale*max(Xmax,Xmin+1)]);


function ax=Local_SimPeriods(Structure,ax),
if nargin==0,
  ax=[];
  return;
elseif ~isstruct(Structure),
  ax=[];
  return;
end;
if nargin==1,
  ax=gca;
else, % ax specified
end;

% Start analysis of Structure

ModuleNames='';
Module.Name='TEMP';
Module=Module([]);
for Block=1:length(Structure.Node),
  if ~isempty(Structure.Node(Block).Module),
    for SubBlock=1:length(Structure.Node(Block).Module),
      if isempty(ModuleNames),
        M=length(Module)+1;
        Module(M).Name=Structure.Node(Block).Module(SubBlock).Name;
        Module(M).Freq=1;
        ModuleNames=Module(M).Name;
      else
        M=strmatch(Structure.Node(Block).Module(SubBlock).Name,ModuleNames,'exact');
        if isempty(M),
          M=length(Module)+1;
          Module(M).Name=Structure.Node(Block).Module(SubBlock).Name;
          Module(M).Freq=1;
          ModuleNames=str2mat(ModuleNames,Module(M).Name);
        else,
          Module(M).Freq=Module(M).Freq+1;
        end;
      end;
    end;
  end;
end;

% Construct plot data

for M=1:length(Module),
  Module(M).XData=NaN*ones(1,Module(M).Freq);
  Module(M).YData=NaN*ones(1,Module(M).Freq);
  Module(M).NextPoint=1;
end;

for Block=1:length(Structure.Node),
  if ~isempty(Structure.Node(Block).Module),
    for SubBlock=1:length(Structure.Node(Block).Module),
      M=strmatch(Structure.Node(Block).Module(SubBlock).Name,ModuleNames,'exact');
      Module(M).XData(Module(M).NextPoint)=Structure.Node(Block).Module(SubBlock).BeginTime;
      Module(M).YData(Module(M).NextPoint)=Structure.Node(Block).Module(SubBlock).EndTime-Structure.Node(Block).Module(SubBlock).BeginTime;
      Module(M).NextPoint=Module(M).NextPoint+1;
    end;
  end;
end;

%Xmin=min([Module.XData]);
% Plot to axes ax
CO=get(gca,'colororder');
for M=1:length(Module),
  h(M)=line(Module(M).XData,Module(M).YData, ...
      'linewidth',0.5, ...
      'color',CO(mod(M-1,size(CO,1))+1,:), ...
      'parent',ax);
end;
xlabel('relative time [TSCALE]');
ylabel('time step [TSCALE]');
legend(h,Module.Name)


function handle=Local_FlowIter(Structure);
Md2=[Structure.Node.Module];
Nm={Md2.Name};
TRI=zeros(1,length(Nm));
for i=1:length(TRI), if strcmp('TRISULA',Nm{i}), TRI(i)=1; end; end;
TRI(end+1)=0;
Transition=find(diff([0 TRI]));
Flow=TRI(Transition)==1;
LenSeq=diff(Transition);
StartFlow=Transition(Flow); % -> time in TSCALE? [Md2(StartFlow).BeginTime] all zeros -> Index into Structure.Node ?
LenFlow=LenSeq(Flow);
handle=plot(LenSeq(Flow))
