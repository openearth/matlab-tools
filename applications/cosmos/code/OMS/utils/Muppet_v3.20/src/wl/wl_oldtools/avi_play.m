function avi_play(filename),
%AVI_PLAY writes the created AVI movie.
%       AVI_PLAY(FileName)

if strcmp(filename,'?'),
  [fname,fpath]=uigetfile('*.avi','Select output file');
  filename=[fpath,fname];
end;

fid=fopen(filename,'r','ieee-le');
if fid<0,
  error('Could not open input file.');
end;

% read header and colour definition
if ~strcmp(char(fread(fid,[1 4],'char')),'RIFF'),
  fclose(fid);
  error('Not an AVI file.');
end;
FileSize=fread(fid,1,'int32');
AVI=fread(fid,[1 4],'char');
  LIST=fread(fid,[1 4],'char');
  szHeader=fread(fid,1,'int32');
  hdrl=fread(fid,[1 4],'char');
    avih=fread(fid,[1 4],'char');
    szAviH=fread(fid,1,'int32');
    avih_val=fread(fid,[1 14],'int32');
    % MicroSecPerFrame ByteRate 0 2064 NumFrames 0 1 MemOneFrame szFrames(2) szFrames(1) 0 0 0 0
    NumFrames=avih_val(5);
    szFrames=avih_val(9:10);
    LIST=char(fread(fid,[1 4],'char'));
    szHeaderLIST=fread(fid,1,'int32');
    strl=char(fread(fid,[1 4],'char'));
      strh=char(fread(fid,[1 4],'char'));
      szStrH=fread(fid,1,'int32');
      vids=char(fread(fid,[1 4],'char'));
      compression=char(fread(fid,[1 4],'char'));
      vids_val=fread(fid,10,'int32');
      % 0 0 0 FrameRateDen FrameRateNum 0 NumFrames MemOneFrame -1 0
      rect=fread(fid,[1 4],'int16');
      strf=char(fread(fid,[1 4],'char'));
      strf_val=fread(fid,4,'int32');
      % szStrF 40 szFrames(2) szFrames(1)
      strf_val2=fread(fid,2,'int16');
      % 1 8
      strf_val3=fread(fid,6,'int32');
      % compressed imagesize 0 0 size(map,1) 0
      compressed=strf_val3(1);
      len_map=strf_val3(5);
      map=transpose(fread(fid,[4 len_map],'uint8'));
      map=map(:,3:-1:1)/255;
  LIST=char(fread(fid,[1 4],'char'));
  while ~feof(fid) & ~strcmp(LIST,'LIST'),
    szJUNK=fread(fid,1,'int32');
    JUNK=fread(fid,szJUNK/4,'int32');
    LIST=char(fread(fid,[1 4],'char'));
  end;
  szLIST=fread(fid,1,'int32');
  pos=get(0,'screensize');
  pos(1)=(pos(3)-szFrames(1))/2;
  pos(2)=(pos(4)-szFrames(2))/2;
  pos(3)=szFrames(1);
  pos(4)=szFrames(2);
  fig=figure('menu','none','name',filename,'integerhandle','off','numbertitle','off','units','pixels','position',pos,'resize','off');
  axs=axes('units','normalized','position',[0 0 1 1],'visible','off','xlim',[0.5 szFrames(2)+0.5],'ylim',[0.5 szFrames(1)+0.5]);
  txt=text(szFrames(2)/2,szFrames(1)/2,'Loading ...','horizontalalignment','center','verticalalignment','middle');
  colormap(map);
  drawnow;
  delete(txt);
  img=image(ones(szFrames(2),szFrames(1)),'parent',axs,'erasemode','none');
  set(axs,'visible','off');
  movi=fread(fid,[1 4],'char');
    X(szFrames(2),szFrames(1))=0;
    for frame=1:NumFrames,
      chanlabel=char(fread(fid,[1 4],'char'));
      MemFrame=fread(fid,1,'int32');
      if compressed,
        mrle=fread(fid,[1 MemFrame],'uint8');
        X=decomp_mrle8(mrle,X);
      else,
        szData=[4*ceil(szFrames(1)/4) szFrames(2)];
        X=flipud(transpose(fread(fid,szData,'uint8')));
      end;
      set(img,'cdata',X(1:szFrames(2),1:szFrames(1))+1);
      drawnow;
    end;
  idx1=fread(fid,[1 4],'char');
  szIdx1=fread(fid,1,'int32');
  for frame=1:NumFrames,
    chanlabel=fread(fid,[1 4],'char');
    db_val=fread(fid,3,'int32');
    % 1 (frame-1)*(8+MemOneFrame)+4 MemOneFrame
  end;
fclose(fid);
