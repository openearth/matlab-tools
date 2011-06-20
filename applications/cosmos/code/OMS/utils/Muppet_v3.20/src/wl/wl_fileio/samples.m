function [x,y,z]=samples(cmd,varargin),
% SAMPLES Read/write sample data from file
%
%   Read:
%     [x,y,z]=SAMPLES('read',filename)
%     xyz=SAMPLES('read',filename)
%
%   Write:
%     SAMPLES('write',filename,xyz)
%     SAMPLES('write',filename,x,y,z)

% (c) copyright, 1/7/2000, H.R.A. Jagers, WL | Delft Hydraulics

switch lower(cmd),
case 'read',
  xyz=Local_read_samples(varargin{:});
  if nargout>1,
    x=xyz(:,1);
    y=xyz(:,2);
    z=xyz(:,3);
  else,
    x=xyz;
  end;
case 'write',
  if ~ischar(varargin{1}),
    Local_write_samples('?',varargin{:});
  else,
    Local_write_samples(varargin{:}); 
  end;
otherwise,
  uiwait(msgbox('unknown command','modal'));
end;

function xyz=Local_read_samples(filename),
if (nargin==0) | strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.xyz','Select sample file');
  if ~ischar(fname),
    xyz=zeros(0,3);
    return;
  end;
  filename=[fpath,fname];
end;

if exist(filename)~=2,
  error(['Cannot open ',filename,'.']);
end;
try,
  xyz=load(filename);
catch,
  error(['Error reading data from ',filename,'.']);
end;
if size(xyz,2)~=3,
  error([filename,' does not contain samples.']);
end


function Local_write_samples(filename,x,y,z),
if strcmp(filename,'?'),
  [fn,fp]=uiputfile('*.xyz');
  if ~ischar(fn),
    return;
  end;
  filename=[fp fn];
end;
fid=fopen(filename,'wt');
if fid<0,
  error(['Could not create or open: ',filename]);
end;

if nargin==4,
  if size(x,2)==1, % column vectors
    xyz=transpose([x y z]);
  else, % row vectors
    xyz=[x;y;z];
  end;
  fprintf(fid,'%f %f %f\n',xyz);
else,
  if size(x,2)==3, % column vector (3x)
    x=transpose(x);
  end;
  fprintf(fid,'%f %f %f\n',x);
end;
fclose(fid);

