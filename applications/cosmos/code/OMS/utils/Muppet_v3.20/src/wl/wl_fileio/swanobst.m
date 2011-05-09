function varargout=swanobst(cmd,varargin),
% SWANOBST File operations for SWAN obstacles
%     SWANOBST('write',FileName,XY)
%        Writes a the obstacles to file.

% (c) copyright 2000
%     WL | Delft Hydraulics, Delft, The Netherlands
%     H.R.A.Jagers

if nargout>0,
  varargout=cell(1,nargout);
end;
if nargin==0,
  return;
end;
switch cmd,
case 'read',
  error('Not yet implemented.');
case 'write',
  Out=Local_write_file(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;


function OK=Local_write_file(filename,Data);
OK=0;

if nargin==1,
  Data=filename;
  [fn,fp]=uiputfile('*.*');
  if ~ischar(fn),
    TklFileInfo=[];
    return;
  end;
  filename=[fp fn];
end;

I=[0; find(isnan(Data(:,1))); size(Data,1)+1];
j=0;
for i=1:(length(I)-1),
  if I(i+1)~=(I(i)+1), % remove lines of length 0
    j=j+1;
    T.Field(j).Size = I(i+1)-I(i)-1;
    T.Field(j).Data = Data((I(i)+1):(I(i+1)-1),:);
  end;
end;

fid=fopen(filename,'w');
fprintf(fid,'%i\n',length(T.Field));
for j=1:length(T.Field),
  fprintf(fid,'%i 0.0\n',T.Field(j).Size);
  fprintf(fid,'%12.5f %12.5f\n',T.Field(j).Data');
end;
fclose(fid);
OK=1;
