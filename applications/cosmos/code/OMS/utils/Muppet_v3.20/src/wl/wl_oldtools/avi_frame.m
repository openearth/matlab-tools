function avi_frame(H,RECT)
% AVI_FRAME captures a frame of an AVI movie.
%   AVI_FRAME(Handle)

global AVI_animation
if nargin<1,
  error('No handle specified');
end;

if nargin<2,
  RECT=[];
else,
  if ~ishandle(H),
    error('Invalid object handle. First argument must be a figure or axes handle.');
  end;
  switch get(H,'type'),
  case 'figure',
    if isempty(AVI_animation.X), % first time
      warning('RECT ignored for the first frame.');
      RECT=[];
    else, % not the first time
      RECT=round(RECT);
      if (RECT(1)<1) | (RECT(2)<2) | ((RECT(1)+RECT(3))>(1+size(AVI_animation.X,2))) | ((RECT(2)+RECT(4))>(2+size(AVI_animation.X,1))), % Note x and y axes in data!
        warning('RECT ignored. Corner outside initial domain.');
        RECT=[];
      end;
    end;
  case 'axes',
    warning('RECT ignored when an axes handle is specified.');
    RECT=[];
  otherwise,
    error('Invalid object handle. First argument must be a figure or axes handle.');
  end;
end;

if ~isstruct(AVI_animation),
  error('Please initiate AVI creation first using AVI_INIT');
else,
  if isempty(RECT),
    [X,map]=getframe(H);
  else,
    [X,map]=getframe(H,RECT);
  end;
  maxX=max(X(:));
  if maxX>size(map,1),
    maxXred=(maxX-1).*(maxX<=size(map,1))+1;
    fprintf(1,'* Correcting getframe BUG: %i->%i\n',maxX,maxXred);
    X=(X-1).*(X<=size(map,1))+1;
  end;
  minX=min(X(:));
  if minX<1,
    minXred=(minX-1).*(minX<1)+1;
    fprintf(1,'* Correcting getframe BUG: %i->%i\n',minX,minXred);
    X=(X-1).*(X<1)+1;
  end;
  if any(~isint(X(:))),
    fprintf(1,'* X contains non-integer values, please check ...\n');
    keyboard
  end;
  if isempty(AVI_animation.X) | isequal(size(AVI_animation.X),size(X)) | ~isempty(RECT),
    map=round(map*255);
    mapchanged=0;
    % match local colour map to global colour map
    if AVI_animation.sizemap==0,
      AVI_animation.map(1:size(map,1),:)=map;
      AVI_animation.sizemap=size(map,1);
      mapchanged=1;
      map=transpose(1:size(map,1))-1;
    else,
      for col=1:size(map,1),
        % find nearest colour in map
        diff=sum((AVI_animation.map(1:AVI_animation.sizemap,:)-ones(AVI_animation.sizemap,1)*map(col,:)).^2,2);
        [m,i]=min(diff);
        if m<0.1, % exact match
          map(col,1)=i-1;
        else, % no exact match
          if AVI_animation.sizemap<256, % space to add color
            AVI_animation.map(AVI_animation.sizemap+1,:)=map(col,:);
            AVI_animation.sizemap=AVI_animation.sizemap+1;
            map(col,1)=AVI_animation.sizemap-1;
            mapchanged=1;
          else,
            map(col,1)=i-1;
          end;
        end;
      end;
      map=map(:,1);
    end;
    % recolor image
    for j=1:size(X,2),
      X(:,j)=map(X(:,j));
    end;
    % goto end of file
    fseek(AVI_animation.fid,0,1);
    if AVI_animation.compressed,
      if isempty(AVI_animation.X),
        Diff=ones(size(X));
        fwrite(AVI_animation.fid,'00db','char');
      else,
        if isempty(RECT), % full image
          Diff=(X~=AVI_animation.X);
        else, % part of image
          xRange=RECT(1)+(1:RECT(3))-1;
          yRange=RECT(2)+(1:RECT(4))-2;
          Diff=zeros(size(AVI_animation.X));
          Diff(end-fliplr(yRange),xRange)=(X~=AVI_animation.X(end-fliplr(yRange),xRange)); % Note x and y axes in data!
        end;
        fwrite(AVI_animation.fid,'00dc','char');
      end;
      if isempty(RECT), % full image
        AVI_animation.X=X;
      else, % part of image
        xRange=RECT(1)+(1:RECT(3))-1;
        yRange=RECT(2)+(1:RECT(4))-2;
        AVI_animation.X(end-fliplr(yRange),xRange)=X; % Note x and y axes in data!
      end;
      CompDiff=comp_mrle8(AVI_animation.X,Diff);
      nbytes=prod(size(CompDiff));
      AVI_animation.nbytes=[AVI_animation.nbytes; nbytes];
      fwrite(AVI_animation.fid,nbytes,'int32');
      fwrite(AVI_animation.fid,CompDiff,'uint8');
    else,
      if isempty(RECT), % full image
        AVI_animation.X=X;
      else, % part of image
        xRange=RECT(1)+(1:RECT(3))-1;
        yRange=RECT(2)+(1:RECT(4))-2;
        AVI_animation.X(end-fliplr(yRange),xRange)=X; % Note x and y axes in data!
      end;
      % enlarge image to match four bytes per row
      if ceil(size(X,2)/4)*4~=size(X,2),
        X(1,4*ceil(size(X,2)/4))=0;
      end;
      nbytes=prod(size(X));
      AVI_animation.nbytes=[AVI_animation.nbytes; nbytes];
      fwrite(AVI_animation.fid,'00db','char');
      fwrite(AVI_animation.fid,nbytes,'int32');
      fwrite(AVI_animation.fid,transpose(flipud(X)),'uint8');
    end;
    if mapchanged,
      fseek(AVI_animation.fid,16,-1);
      fwrite(AVI_animation.fid,AVI_animation.sizemap,'int32');
      fwrite(AVI_animation.fid,AVI_animation.map,'int8');
    end;
  else,
    error('Frame size does not match earlier captured frames');
  end;
end;