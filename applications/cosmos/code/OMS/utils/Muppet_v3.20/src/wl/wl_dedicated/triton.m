function varargout=triton(cmd,varargin),
% TRITON read TRITON animation files
%
%    FileInfo=TRITON('open',FILENAME)
%
%    Data=TRITON('read',FileInfo,t)
%

% (c) copyright, Delft Hydraulics, 2001
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch cmd,
case 'open',
  Info=Local_open(varargin{:});
  varargout={Info};
case 'read',
  [Data,Info]=Local_read(varargin{:});
  if nargout>0,
    varargout{1}=Data;
    varargout{2}=Info;
  end;
otherwise,
  error('Unknown command');
end;

function Info=Local_open(filename)
% MODEL: triton1.06; RUNID: rif3; DATE: 15-10-2001; STARTING TIME: 09:21
%     0.00000
%     0.50000
%   66   32
%    2.500 -250.000
%    2.500 -235.000
%    :
%  977.500  200.000
%  977.500  215.000
%     0.00000
%     0.00000     0.00000     0.00000     0.00000     0.00000
%     0.00000     0.00000     0.00000     0.00000     0.00000
%     :
%     0.00000     0.00000     0.00000     0.00000     0.00000
%     0.00000     0.00000
%     0.50000
%     0.00367     0.00399     0.00399     0.00398     0.00398
%     0.00398     0.00398     0.00398     0.00398     0.00398
%     :
Info.Check='NotOK';
fid=fopen(filename,'r');
if fid<0, return, end
Str=fgetl(fid);
if length(Str)<14 | ~strcmp(lower(Str(1:14)),' model: triton')
  fclose(fid);
  return
end
Info.FileName=filename;
Info.FileType='TritonANI';
Info.T0=fscanf(fid,'%f',1);
Info.TimeStep=fscanf(fid,'%f',1);
Info.NM=fliplr(fscanf(fid,'%i',[1 2]));
Tmp=fscanf(fid,'%f',[2 prod(Info.NM)]);
Info.Grid.X=reshape(Tmp(1,:),Info.NM);
Info.Grid.Y=reshape(Tmp(2,:),Info.NM);
Info.DataOffset=[];
Info.Time=[];
while ~feof(fid)
  Loc=ftell(fid);
  Tmp=fscanf(fid,'%f',1);
  if feof(fid), break; end
  fscanf(fid,'%*f',Info.NM);
  if feof(fid), break; end
  Info.DataOffset(end+1)=Loc;
  Info.Time(end+1)=Tmp;
end
fclose(fid);
Info.Check='OK';

function [Data,Info]=Local_read(Info,t)
fid=fopen(Info.FileName,'r');
i=sum(Info.Time<=t);
fseek(fid,Info.DataOffset(i),-1);
Time=fscanf(fid,'%f',1);
Data=fscanf(fid,'%f',Info.NM);
fclose(fid);