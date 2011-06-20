function Out=avi_write(FrameRateNum,FrameRateDen),
%AVI_WRITE finishes the creation of the AVI movie.

if nargin==0,
  FrameRateDen=10;
  FrameRateNum=40; % 40/10 = 4 frames per second
elseif nargin==1, % Frames Per Second was specified
  FrameRateDen=1;
  FrameRateNum=round(FrameRateNum);
end;

if nargout>0,
  Out=[];
end;

global AVI_animation
if ~isstruct(AVI_animation),
  if nargout==0,
    error('No AVI creation in progress. Use AVI_INIT to start.');
  else,
    Out=-1;
    return;
  end;
elseif isempty(AVI_animation.nbytes),
  if nargout==0,
    error('No frames grabbed.');
  else,
    Out=-1;
    return;
  end;
end;

fid=AVI_animation.fid;
% go to beginning of file
fseek(fid,0,-1);

% write header of AVI file
NumFrames=size(AVI_animation.nbytes,1);
MemOneFrame=max(AVI_animation.nbytes);

szStrH=56;
szStrF=40+4*AVI_animation.sizemap;
szHeaderLIST=12+szStrH+8+szStrF;
szAviH=56;
szHeader=12+szAviH+8+szHeaderLIST;
szJUNK=1024-5-szHeader/4-2;

szIdx1=NumFrames*16;

ByteRate=FrameRateNum/FrameRateDen*MemOneFrame;
MicroSecPerFrame=round(FrameRateDen/FrameRateNum*1000000);

fwrite(fid,'RIFF','char');
fwrite(fid,0,'int32');
fwrite(fid,'AVI ','char');
  fwrite(fid,'LIST','char');
  fwrite(fid,szHeader,'int32');
  fwrite(fid,'hdrl','char');
    fwrite(fid,'avih','char');
    fwrite(fid,[szAviH MicroSecPerFrame ByteRate 0 2064 NumFrames 0 1 MemOneFrame size(AVI_animation.X,2) size(AVI_animation.X,1) 0 0 0 0],'int32');
    fwrite(fid,'LIST','char');
    fwrite(fid,szHeaderLIST,'int32');
    fwrite(fid,'strl','char');
      fwrite(fid,'strh','char');
      fwrite(fid,szStrH,'int32');
      fwrite(fid,'vids','char');
      if AVI_animation.compressed,
        fwrite(fid,'mrle','char');
      else,
        fwrite(fid,'dib ','char');
      end;
      fwrite(fid,[0 0 0 FrameRateDen FrameRateNum 0 NumFrames MemOneFrame 10000 0],'int32');
      fwrite(fid,[0 0 size(AVI_animation.X,2) size(AVI_animation.X,1)],'int16');
      fwrite(fid,'strf','char');
      fwrite(fid,[szStrF 40 size(AVI_animation.X,2) size(AVI_animation.X,1)],'int32');
      fwrite(fid,[1 8],'int16');
      fwrite(fid,[AVI_animation.compressed MemOneFrame 0 0 AVI_animation.sizemap 0],'int32');
      fwrite(fid,transpose([fliplr(AVI_animation.map(1:AVI_animation.sizemap,:)) zeros(AVI_animation.sizemap,1)]),'uint8');
  fwrite(fid,'JUNK','char');
  fwrite(fid,[4*szJUNK zeros(1,szJUNK)],'int32');
  fwrite(fid,'LIST','char');
  szLISTloc=ftell(fid);

  % write end of file
  fseek(fid,0,1);
  fwrite(fid,'idx1','char');
  fwrite(fid,szIdx1,'int32');
  for frame=1:NumFrames,
    if AVI_animation.compressed & (frame~=1),
      fwrite(fid,'00dc','char');
      fwrite(fid,0,'int32');
    else,
      fwrite(fid,'00db','char');
      fwrite(fid,16,'int32');
    end;
    fwrite(fid,[sum(AVI_animation.nbytes(1:(frame-1))+8)+4 AVI_animation.nbytes(frame)],'int32');
  end;
  fsz=ftell(fid);
  JUNK=256*ceil(fsz/256)-fsz;
  fwrite(fid,zeros(1,JUNK),'uint8');

  % write filesize
  fseek(fid,4,-1);
  fwrite(fid,fsz-8,'int32');

  % write LIST
  fseek(fid,szLISTloc,-1);
  fwrite(fid,4+sum(AVI_animation.nbytes+8),'int32');

fclose(fid);

clear global AVI_animation

if nargout>0,
  Out=NumFrames;
end;