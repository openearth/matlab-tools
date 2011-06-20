function [varargout]=aukepc(cmd,varargin)
%AUKEPC Read AUKE/pc files
%
%     FileInfo = AUKEPC('open','FileName');
%
%     Data = AUKEPC('read',FileInfo,Channel,UseZeroLevel);
%          where Channel is either a channel name or one or
%          more channel numbers. If UseZeroLevel is 0 the
%          zerolevel is not used, otherwise it is used (default).

% (c) copyright 12/10/2000
%     H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

switch lower(cmd),
case 'open',
  varargout=cell(1,max(nargout,1));
  [varargout{:}]=Local_aukepc_open(varargin{:});
case 'read',
  varargout=cell(1,max(nargout,1));
  [varargout{:}]=Local_aukepc_read(varargin{:});
end;

function Data=Local_aukepc_open(filename)
% Open AUKE/pc file
% INPUT: filename
% OUTPUT: FileInfo about the sequences in the data file.

if nargin<1,
  [fn,pn]=uigetfile('*.seq');
  if ~ischar(fn),
    Data=[];
    return;
  end;
  filename=[pn fn];
end;

% By now we should have the final filename. Has it an extension?
lastdot=max(findstr(filename,'.'));
lastsep=max(findstr(filename,filesep));
if ~isempty(lastdot) & (isempty(lastsep) | (lastdot>lastsep)), % has extension!
  filebase=filename(1:(lastdot-1));
else,
  filebase=filename;
end;
Data.FileName=filebase;
fid=fopen(strcat(filebase,'.seq'),'r');
Conv0=0;
Conv1=1;
zerolev=0;

Ch=0;

while ~feof(fid)
  Line=upper(fgetl(fid));
  if length(Line)>=6,
    switch Line(1:6),
    case 'A/D-CO', % A/D-CONV
      Data.LowStored=Local_getseq(Line,'LOWSTORED');
      Data.HighStored=Local_getseq(Line,'HIGHSTORED');
      Data.LowUsed=Local_getseq(Line,'LOWUSED');
      Data.HighUsed=Local_getseq(Line,'HIGHUSED');
    case 'DATATY', % DATATYPE
      if ~isempty(findstr('R4',Line)),
        Data.Type='R4';
        Data.Frmt='float32';
      elseif ~isempty(findstr('I2',Line)),
        Data.Type='I2';
        Data.Frmt='int16';
      end
    case 'EQ,SER', % EQ,SERIES
      Data.StartTime=Local_getseq(Line,'LOW');
      Data.EndTime=Local_getseq(Line,'HIGH');
      Data.Freq=Local_getseq(Line,'FREQ');
      if ~isempty(Data.Freq),
        Data.Dt=1/Data.Freq;
      else
        Data.Dt=Local_getseq(Line,'STEP');
      end;
    case 'SERIES', % SERIES
      Ch=Ch+1;
      Data.Channel(Ch).Name=strtok(Line(8:end));
    case 'CALIBR', % CALIBR
      if Ch==0, error('Reading CALIBR before SERIES'); end;
      Data.Channel(Ch).Conv1=Local_getseq(Line,'C1');
      Data.Channel(Ch).Conv0=Local_getseq(Line,'C0');
    case 'ZEROLE', % ZEROLEVEL
      if Ch==0, error('Reading ZEROLEVEL before SERIES'); end;
      Data.Channel(Ch).ZeroLvl=sscanf(Line(111:end),'%f',1);
    end
  end
end
for Ch=1:length(Data.Channel),
  if ~strcmp(Data.Type,'R4'),
    Data.Channel(Ch).Conv1 = Data.Channel(Ch).Conv1 * (Data.HighUsed-Data.LowUsed) / ...
                                                      (Data.HighStored-Data.LowStored);
    Data.Channel(Ch).Conv0 = Data.Channel(Ch).Conv0 + 0.5 *( ...
                             - (Data.LowStored + Data.HighStored) * Data.Channel(Ch).Conv1 ...
                             + Data.LowUsed + Data.HighUsed);
  else
    Data.Channel(Ch).Conv1=1;
    Data.Channel(Ch).Conv0=0;
  end;
end;
fclose(fid);


function x=Local_getseq(Str,keyword)
i=min(findstr(keyword,Str));
if isempty(i), x=[]; return; end
j=min(findstr('=',Str(i:end)));
if isempty(j), x=[]; return; end
i=i+j;
x=sscanf(Str(i:end),'%f',1);


function Data=Local_aukepc_read(FI,Channel,UseZLvl)
% Read AUKE/pc file
% INPUT: FI = FileInfo as obtained from AUKEPC('open',...)
%        Channel = Channel number(s) to be read
%        UseZLvl = Correct zerolevel

if nargin<3,
  UseZLvl=[];
end;
if ischar(Channel),
  Channels={FI.Channel.Name};
  i=ustrcmpi(Channel,Channels);
  if i<0,
    error(sprintf('Channel %s does not exist',Channel));
  end
  Ch=i;
elseif (Channel>length(FI.Channel)) | (Channel<=0),
  error('Channel number invalid');
else,
  Ch=Channel;
end;
Ch=Ch(:);
fid=fopen(strcat(FI.FileName,'.dat'),'r');

nsamp=round((FI.EndTime-FI.StartTime)/FI.Dt+1);
nCh=length(FI.Channel);
nChRead=length(Ch);

if strcmp(FI.Type,'R4'), %16384/4
  SegL=4046;
else %16384/2
  SegL=8192;
end

i=0;
Data=zeros(nsamp,nChRead);
while i<nsamp,
  jMax=min(nsamp-i,SegL);
  r=fread(fid,[nCh jMax],FI.Frmt);
  Data(i+1:i+jMax,:)=r(Ch,:)';
  i=i+jMax;
end;

fclose(fid);

for i=1:nChRead,
  if ~strcmp(FI.Type,'R4'),
    Data(:,i)=Data(:,i)*FI.Channel(Ch(i)).Conv1+FI.Channel(Ch(i)).Conv0;
  end;
  if isempty(UseZLvl) | UseZLvl,
    if isfield(FI.Channel(Ch(i)),'ZeroLevel'),
      Data(:,i)=Data(:,i)-FI.Channel(Ch(i)).ZeroLevel;
    end;
  end;
end;
