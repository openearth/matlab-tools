function varargout=wlenc(cmd,varargin),
% WLENC read/write a grid enclosure file
%       MN=WLENC('read',FILENAME)
%       [M,N]=WLENC('read',FILENAME)
%       reads the ENCLOSURE
%
%       WLENC('write',FILENAME,MN)
%       WLENC('write',FILENAME,[M,N])
%       writes the ENCLOSURE

% reads the GRID from
%       files that can be used by Delft3D and TRISULA.
%       GRID=WLGRID('read',FILENAME) returns a structure with
%       X, Y, and Enclosure fields.
%
%       OK=WLGRID('write',FILENAME,X,Y,ENC) writes the GRID to
%       files that can be used by Delft3D and TRISULA.

% (c) copyright, Delft Hydraulics, 1997
%       created by H.R.A. Jagers, Delft Hydraulics / University of Twente

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch lower(cmd),
case {'r','re','rea','read'},
  Enc=Local_read_enclosure(varargin{:});
  if nargout<=1,
    varargout{1}=Enc;
  else,
    varargout{1}=Enc(:,1);
    varargout{2}=Enc(:,2);
  end;
case {'w','wr','wri','writ','write'},
  Out=Local_write_enclosure(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  error('Unknown command');
end;


function Out=Local_read_enclosure(filename),
% read an enclosure file
Out=[];

if (nargin==0) | strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.*','Select enclosure file');
  if ~ischar(fname),
    return;
  end;
  filename=fullfile(fpath,fname);
end;

% Grid enclosure file
fid=fopen(filename);
if fid>0,
  while 1,
    line=fgetl(fid);
    if ~isstr(line), break; end;
    Out=[Out; sscanf(line,'%i',[1 2])];
  end;
  fclose(fid);
else,
  error('Error opening file.');
end;


function OK=Local_write_enclosure(filename,M,N),
% write an enclosure file
OK=0;

if nargin==2,
  ENC=M;
else,
  ENC=[M N];
end;

fid=fopen(filename,'w');
if fid<0,
  error('* Could not open output file.');
end;
fprintf(fid,'%5i%5i\n',transpose(ENC));
fclose(fid);

OK=1;