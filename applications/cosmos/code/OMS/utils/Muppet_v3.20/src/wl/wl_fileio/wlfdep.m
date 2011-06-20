function varargout=wlfdep(cmd,varargin),
% WLFDEP read/write Delft3D-MOR field files
%    WLFDEP can be used to read and write Delft3D-MOR
%    field files.
%
%    FIELD=WLFDEP('read',FILENAME)
%
%    WLFDEP('write',FILENAME,FIELD)

% (c) copyright, Delft Hydraulics, 2000
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin==0,
  if nargout>0,
    varargout=cell(1,nargout);
  end;
  return;
end;

switch cmd,
case 'read',
  Dep=Local_depread(varargin{:});
  varargout={Dep};
case 'write',
  Out=Local_depwrite(varargin{:});
  if nargout>0,
    varargout{1}=Out;
  end;
otherwise,
  error('Unknown command');
end;


function DP=Local_depread(filename),
% DEPREAD reads field data from a given filename
%    DEPTH=DEPREAD('FILENAME.DEP')

DP=[];

if strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.*','Select Delft3D-MOR field file');
  if ~ischar(fname),
    return;
  end;
  filename=[fpath,fname];
end;

fid=fopen(filename);
if fid<0,
  error(['Cannot open ',filename,'.']);
end;
fgetl(fid);
dim=fscanf(fid,'%i',[1 2]);
DP=fscanf(fid,'%f',dim)';
fclose(fid);


function OK=Local_depwrite(filename,DP),
% DEPWRITE writes field data to a given filename
%
% Usage: depwrite('filename',Matrix)

OK=0;
if DP(end,end)~=-999,
  switch input('Negate date points? (Y/N) ','s'),
  case {'Y','y'},
    DP=-DP;
  otherwise,
  end;
  switch input('Grid extension: 9 (-999 values)/B (boundary values) /N (Don''t extend) ','s'),
  case {'9'},
    DP=[DP -999*ones(size(DP,1),1); ...
      -999*ones(1,size(DP,2)+1)];
  case {'B','b'},
    DP=[DP DP(:,end); ...
        DP(end,:) DP(end,end)];
  otherwise,
  end;
end;

DP(isnan(DP))=-999;

fid=fopen(filename,'w');
fprintf(fid,'%s\n',filename);
fprintf(fid,'%i %i\n',fliplr(size(DP)));
fprintf(fid,strcat('%f',repmat(' %f',1,size(DP,2)-1),'\n'),DP');
fclose(fid);
OK=1;
