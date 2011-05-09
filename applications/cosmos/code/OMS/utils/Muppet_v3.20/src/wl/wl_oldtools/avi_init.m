function AVIid=avi_init(filename,compressed),
% AVI_INIT initiates the creation of an AVI movie
%       aviID=AVI_INIT(FileName)
%       aviID=AVI_INIT(FileName,FlagCompress)
%       where FlagCompress==1 to create compressed AVI (default),
%       and FlagCompress==0 to create non-compressed AVI

global AVI_animation
if ~isstruct(AVI_animation),
  if nargin==1,
    compressed=1;
  elseif nargin<1,
    error('Not enough input arguments');
  end;
  AVIid=fopen(filename,'w','ieee-le');
  if AVIid<0,
    fprintf(1,'Error opening the file\n');
    return;
  end;
  fwrite(AVIid,'RIFF','char');
  fwrite(AVIid,0,'int32');
  fwrite(AVIid,'AVI ','char');
  fwrite(AVIid,'TEMP','char');
  fwrite(AVIid,zeros(1,1020),'int32');
  fwrite(AVIid,'LIST','char');
  fwrite(AVIid,0,'int32');
  fwrite(AVIid,'movi','char');
  AVI_animation.fid=AVIid;
  AVI_animation.X  =[];
  AVI_animation.map=zeros(256,3);
  AVI_animation.sizemap=0;
  AVI_animation.nbytes=[];
  AVI_animation.compressed=compressed;
  AVI_animation.ncolbits=8;
else,
  AVIid=-1;
  fprintf(1,'Other AVI file creation in progress\n');
  return;
end;