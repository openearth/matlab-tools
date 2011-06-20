function varargout=qnhls(cmd,varargin),
% QNHLS read/write Quickin HLS file
%   Read/write Quickin HLS file and convert it
%   into/from RGB colormap.
%
%   [CMAP,LABEL]=QNHLS('read',FILENAME)
%   OK=QNHLS('write',FILENAME,CMAP,LABEL)
%
%   See also: RGB2HLS, HLS2RGB

%   [CMAP,LABEL]=QNHLS(FILENAME) % read assumed


switch lower(cmd),
case 'read',
  varargout=cell(1,max(1,nargout));
  [varargout{:}]=Local_read_hls(varargin{:});
case 'write',
  OK=Local_write_hls(varargin{:});
  if nargout>0,
    varargout={OK};
  end;
otherwise, % unknown command, possibly filename
  varargout=cell(1,max(1,nargout));
  [varargout{:}]=Local_read_hls(cmd,varargin{:});
end;


function [CMap,Label]=Local_read_hls(filename),
fid=fopen(filename,'r');
if fid<0,
  CMap=[];
  Label='';
  return;
end;
Label=fgetl(fid);
i=0;
Line=fgetl(fid);
X=sscanf(Line,'%i%i%i',[1 3]);
while isequal(size(X),[1 3]),
  i=i+1;
  CMap(i,:)=X;
  Line=fgetl(fid);
  if ~ischar(Line), break; end; %feof(fid)
  X=sscanf(Line,'%f%f%f',[1 3]);
end;
CMap(:,1)=CMap(:,1)/360;
CMap(:,2:3)=CMap(:,2:3)/100;
CMap=hls2rgb(CMap);
fclose(fid);


function OK=Local_write_hls(filename,CMap,Label),
OK=0;
if nargin<2,
  return;
elseif nargin<3,
  Label='';
end;
fid=fopen(filename,'w');
if fid<0,
  return;
end;
fprintf(fid,'%s\n',Label);
CMap=rgb2hls(CMap);
CMap(:,1)=round(360*CMap(:,1));
CMap(:,2:3)=round(100*CMap(:,2:3));
fprintf(fid,'%3i %3i %3i\n',transpose(CMap));
fclose(fid);
OK=1;


