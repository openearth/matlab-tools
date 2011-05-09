function outmap=clrmap(S,m,Swrite)
%CLRMAP creates a colormap based on a few colors
%
%  ColorMap=clrmap(Colors,M)
%    where Colors is a Kx3 matrix of (R,G,B) color triplets.
%  creates a Mx3 ColorMap with the K colors at equal distances
%  in the colormap; that is, in case of three colors; the first
%  color at m=1, the second color at m=M/2, and the last color
%  at m=M.
%
%  ColorMap=clrmap(Colors) uses the length of the colormap of
%  the current figure.
%
%  clrmap(...) updates the colormap in the current figure.

if ischar(S)
  switch lower(S)
  case 'write'
    % m=filename
    if ~isstruct(Swrite)
      Stemp.Space='RGB';
      Stemp.Colors=Swrite;
      Swrite=Stemp;
    end
    writeclrmap(m,Swrite);
    if nargout>0
      outmap=Swrite;
    end
    return
  case 'read'
    % m=filename
    outmap=readclrmap(m);
    return
  otherwise
     S=clrmap('read',S);
  end
end
if nargin > 2
  error('Too many input arguments.')
elseif nargin < 2,
  h=get(0,'currentfigure');
  if isempty(h),
    m = size(get(0,'defaultfigurecolormap'),1);
  else,
    m = size(get(h,'colormap'),1);
  end;
end

if m<=1,
   mrange=m;
else
   mrange=(0:(m-1))/(m-1);
end
if isstruct(S)
   clrs=S.Colors;
else
   clrs=S;
end
AlternatingColors=0;
if isfield(S,'AlternatingColors') & isequal(S.AlternatingColors,1)
  AlternatingColors=1;
end
N=size(clrs,1);
index=(0:(N-1))/(N-1);
if AlternatingColors & m<=1
  AlternatingColors=0;
  clrs=clrs([end 1:end 1],:);
  S.Index=[];
  index=(0.5+(-1:N))/N;
  N=N+2;
end
if isstruct(S)
   if AlternatingColors
     switch upper(S.Space)
     case 'RGB'
       %clrs=clrs;
     case 'HSV'
       clrs=hsv2rgb(clrs);
     case 'HLS'
       clrs=hls2rgb(clrs);
     case 'CMY'
       clrs=1-clrs;
     otherwise
       error('Unknown colour space.')
     end
     map = repmat(clrs,ceil(m/N),1);
     map = map(1:m,:);
   else
     if isfield(S,'Index') & ~isempty(S.Index)
       index=S.Index;
       if index(1)~=0 | index(end)~=1
         error('Colourmap indices should start at 0 and end at 1')
       elseif length(index)~=N
         error('Colourmap index array length should match number of reference colours.')
       end
     end
     switch upper(S.Space)
     case 'RGB'
       map=interp1(index,clrs,mrange);
     case 'CMY'
       map=1-interp1(index,clrs,mrange);
     case 'HSV'
       clrs=unwraphue(clrs,N,1);
       map=interp1(index,clrs,mrange);
       map(:,1)=mod(map(:,1),1);
       map=hsv2rgb(map);
     case 'HLS'
       clrs=unwraphue(clrs,N,1);
       map=interp1(index,clrs,mrange);
       map(:,1)=mod(map(:,1),1);
       map=hls2rgb(map);
     otherwise
       error('Unknown colour space.')
     end
   end
else
   % default backward compatible RGB
   map=interp1(index,clrs,mrange);
end
map=max(min(map,1),0);

if nargout==1,
  outmap=map;
else,
  set(gcf,'colormap',map);
end

function clrs=unwraphue(clrs,N,ihue)
diffHue=diff(clrs(:,ihue));
for i=1:N-1
  if diffHue(i)>0.5
    clrs(i+1:end,ihue)=clrs(i+1:end,ihue)-1;
  elseif diffHue(i)<-0.5
    clrs(i+1:end,ihue)=clrs(i+1:end,ihue)+1;
  end
end


function S=readclrmap(filename)
fid=fopen(filename,'r');
if fid<0
  error('Error opening input file.');
end
Str=fgetl(fid);
if ~isequal(Str,'COLORMAP')
   fclose(fid);
   error('Invalid input file.')
end

ploc=ftell(fid);
Str=fgetl(fid);
NAME=0;
ALTC=0;
SPACE=0;
while 1
  if strmatch('NAME=',Str)
    if NAME==1
      fclose(fid);
      error('Multiple NAME records.');
    end
    NAME=1;
    S.Name=deblank2(Str(6:end));
  elseif strmatch('SPACE=',Str)
    if SPACE==1
      fclose(fid);
      error('Multiple SPACE records.');
    end
    SPACE=1;
    S.Space=upper(deblank(Str(7:end)));
    if isempty(strmatch(S.Space,{'RGB','HSV','HLS','CMY'},'exact'))
      fclose(fid);
      error('Unknown colour space.');
    end
  elseif strmatch('ALTERNATING COLORS',Str,'exact')
    if ALTC==1
      fclose(fid);
      error('Multiple ALTERNATING COLORS records.');
    end

    ALTC=1;
    S.AlternatingColors=1;
  else
    [Vals,Nr,Err,i]=sscanf(Str,' %f');
    if ~isempty(Err)
      fclose(fid);
      error(sprintf('Error interpreting line: %s.',Str));
    end
    if SPACE~=1
      fclose(fid);
      error('Colour space record is missing.');
    end
    if Nr~=3 & Nr~=4
      fclose(fid);
      error(sprintf('Unexpected number of values in line: %s.',Str));
    elseif Nr==4 & ALTC
      fclose(fid);
      error('No index array expected in case of ALTERNATING COLORS.');
    end
    fseek(fid,ploc,-1);
    if Nr==3
      data=fscanf(fid,'%d %d %d',[3 inf]);
      S.Colors=data';
    elseif Nr==4
      data=fscanf(fid,'%f %d %d %d',[4 inf]);
      S.Index=data(1,:);
      S.Colors=data(2:4,:)';
    end
    if ~feof(fid)
      Str=fgetl(fid);
      fclose(fid);
      error(sprintf('Unexpected string when reading colours: %s.',Str)) 
    end
    break
  end
  ploc=ftell(fid);
  Str=fgetl(fid);
end
fclose(fid);
if ~isfield(S,'Colors')
  error('Missing colour data.')
else
  if any(S.Colors(:)<0) | any(S.Colors(:)>255)
     error('Colour value out of range [0,255].')
  else
    S.Colors=S.Colors/255;
 end
end
if isfield(S,'Index')
  if max(S.Index)>1
     error('Index value too large.');
  elseif S.Index(end)~=1
     error('Last index should be equal to 1.');
  end
  if min(S.Index)<0
    error('Index value too small.');
  elseif S.Index(1)~=0
     error('First index should be equal to 0.');
  end
  if any(diff(S.Index)<0)
    error('Index not increasing.');
  end
  i=length(S.Index)-1;
  while S.Index(i)==1
    S.Index(i)=S.Index(i+1)-eps;
    i=i-1;
  end
  for i=2:length(S.Index)-1
    if S.Index(i)<=S.Index(i-1)
       S.Index(i)=S.Index(i-1)+eps;
    end
  end
end

function writeclrmap(filename,S)
fid=fopen(filename,'wt');
if fid<0
  error('Error opening output file.');
end
fprintf(fid,'COLORMAP\n');
if isfield(S,'Name') & ~isempty(S.Name)
  fprintf(fid,'NAME=%s\n',S.Name);
end
fprintf(fid,'SPACE=%s\n',upper(S.Space));
if isfield(S,'AlternatingColors') & isequal(S.AlternatingColors,1)
  fprintf(fid,'ALTERNATING COLORS\n');
else
   S.AlternatingColors=0;
end
if isfield(S,'Index') & ~isempty(S.Index) & ~S.AlternatingColors
  fprintf(fid,'%6.4f %3i %3i %3i\n',[S.Index(:) round(255*S.Colors)]');
else
  fprintf(fid,'%3i %3i %3i\n',round(255*S.Colors)');
end
fclose(fid);