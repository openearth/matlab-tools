function Out=areafile(cmd,varargin);
% AREAFILE File operations for an area file.
%        Matrix = areafile('read',filename);
%           reads a matrix from an area file.
%
%        areafile('write',Matrix,filename);
%          writes a matrix to an area file.

if nargin==0,
  if nargout>0,
    Out=[];
  end;
  return;
end;
switch cmd,
case 'read',
  Out=Local_read_file(varargin{:});
case 'write',
  if nargin==1,
    error('Not enough input arguments.');
  end;
  Local_write_file(varargin{:});
end;


function Data=Local_read_file(filename),

if nargin==0,
  [fn,fp]=uigetfile('area.*');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'r');
if fid<0,
  return;
end;
Size=fscanf(fid,'%i',2);
Data=fscanf(fid,'%1i',Size);
fclose(fid);


function Local_write_file(Data,filename),

if any(Data(:)>9) | any(Data(:)<0) | any(Data(:)~=round(Data(:))),
  error('Can only write numbers 0 t/m 9 to area file.');
end;
if nargin==1,
  [fn,fp]=uiputfile('area.*');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'wt');
if fid<0,
  error(['Could not create or open: ',filename]);
end;
fprintf(fid,'%12i%12i\n',size(Data));
NewLine=transpose(sprintf('\n'));
Data=char(Data+48);
Data(end+(1:length(NewLine)),:)=NewLine*ones(1,size(Data,2));
fprintf(fid,'%s',Data);
fclose(fid);

