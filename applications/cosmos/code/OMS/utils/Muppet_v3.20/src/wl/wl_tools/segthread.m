function [xn,yn]=segthread(varargin)
%SEGTHREAD Threads line segments together.
%      [xn,yn]=SEGTHREAD(x,y)
%      Combines NaN separated line segments in x
%      together into longer NaN separated line
%      segments.
%
%      [xn,yn]=SEGTHREAD(x,y,eps)
%      Uses an accuracy of eps for checking
%      whether line segment ends match.

% (c) 5 Oct. 2001, H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands
%     bert.jagers@wldelft.nl

eps2=0;
algorithm=2;

VA=varargin;
i=1;
while i<=length(VA)
  if ischar(VA{i})
    switch lower(VA{i})
    case 'greedy'
      algorithm=1;
    otherwise
      error(sprintf('Unknown option: %s',VA{i}));
    end
    VA(i)=[];
  else
    i=i+1;
  end
end
x=VA{1};
y=VA{2};
if length(VA)>2, eps2=VA{3}.^2; end

lngdim=1;
cellin=1;
if iscell(x)
  X=x;
  Y=y;

  [dummy,lngdim]=max(size(X{1}));
  for i=length(X):-1:1
    X{i}=X{i}(:);
    Y{i}=Y{i}(:);
    xf(i,1)=X{i}(1);
    yf(i,1)=Y{i}(1);
    xl(i,1)=X{i}(end);
    yl(i,1)=Y{i}(end);
  end
else
  cellin=0;
  [dummy,lngdim]=max(size(x));
  if lngdim>1
    x=reshape(x,[size(x,lngdim) 1]);
    y=reshape(y,[size(y,lngdim) 1]);
  end
    
  idx=find(isnan([NaN;x;NaN]) | isnan([NaN;y;NaN]));
  frst=idx(1:end-1);
  last=idx(2:end)-2;
  idx=frst>last;
  frst(idx)=[];
  last(idx)=[];

  for i=1:length(frst)
    X{i}=x(frst(i):last(i));
    Y{i}=y(frst(i):last(i));
  end

  xf=x(frst);
  yf=y(frst);
  xl=x(last);
  yl=y(last);
end

if algorithm==1
  % GREEDY ALGORITHM:
  % Connect to the first segment, the first segment that
  % is located within a distance of eps. Only if no such
  % segment exists, consider connections to the second
  % segment (and so on ...)
  % Connect in the following order: head-head match
  %                                 head-tail match
  %                                 tail-head match
  %                                 tail-tail match

  i=1;
  while i<length(xf)
    x0=xf(i);
    y0=yf(i);
    d=((xf(i+1:end)-x0).^2+(yf(i+1:end)-y0).^2)<=eps2;
    if any(d) %First-First
      j=find(d)+i; j=j(1);
      X{i}=[X{j}(end:-1:1);X{i}];
      Y{i}=[Y{j}(end:-1:1);Y{i}];
      X(j)=[];
      Y(j)=[];
      xf(j)=[];
      yf(j)=[];
      xl(j)=[];
      yl(j)=[];
      xf(i)=X{i}(1);
      yf(i)=Y{i}(1);
    else
      d=((xl(i+1:end)-x0).^2+(yl(i+1:end)-y0).^2)<=eps2;
      if any(d) %First-Last
        j=find(d)+i; j=j(1);
        X{i}=[X{j}(1:end);X{i}];
        Y{i}=[Y{j}(1:end);Y{i}];
        X(j)=[];
        Y(j)=[];
        xf(j)=[];
        yf(j)=[];
        xl(j)=[];
        yl(j)=[];
        xf(i)=X{i}(1);
        yf(i)=Y{i}(1);
      else
        x0=xl(i);
        y0=yl(i);
        d=((xf(i+1:end)-x0).^2+(yf(i+1:end)-y0).^2)<=eps2;
        if any(d) %Last-First
          j=find(d)+i; j=j(1);
          X{i}=[X{i};X{j}(1:end)];
          Y{i}=[Y{i};Y{j}(1:end);];
          X(j)=[];
          Y(j)=[];
          xf(j)=[];
          yf(j)=[];
          xl(j)=[];
          yl(j)=[];
          xl(i)=X{i}(end);
          yl(i)=Y{i}(end);
        else
          d=((xl(i+1:end)-x0).^2+(yl(i+1:end)-y0).^2)<=eps2;
          if any(d) %Last-Last
            j=find(d)+i; j=j(1);
            X{i}=[X{i};X{j}(end:-1:1)];
            Y{i}=[Y{i};Y{j}(end:-1:1)];
            X(j)=[];
            Y(j)=[];
            xf(j)=[];
            yf(j)=[];
            xl(j)=[];
            yl(j)=[];
            xl(i)=X{i}(end);
            yl(i)=Y{i}(end);
          else
            i=i+1;
          end
        end
      end
    end
  end
elseif algorithm==2
  XN={};
  YN={};
  N=length(X);
  AUTO=(xf-xl).^2+(yf-yl).^2;
  LEN=cellfun('length',X);
  [FFLL,FLLF]=ComputeFFLL(xf,xl,yf,yl);
  %
  while 1,
    closest=min(min(FFLL(:)),min(FLLF(:)));
    if closest>eps2, break; end
    [i,j]=find(FFLL==closest);
    if ~isempty(i),
      i=i(1); j=j(1);
      if i<j, %Upper-right triangle: First-First
        FirstI=1;
        FirstJ=1;
      else %Lower-left triangle: Last-Last
        FirstI=0;
        FirstJ=0;
      end
    else
      [i,j]=find(FLLF==closest);
      i=i(1); j=j(1);
      FirstI=1;
      FirstJ=0;
    end
    % Check whether the distance between the first
    % and last point of the segments to be connected
    % is larger than the distance between the segments
    %if AUTO(i)<closest
    %  % Define i as closed
    %elseif AUTO(j)<closest
    %  % Define j as closed
    %end
    if FirstI
      if FirstJ %First-First, i<j, new first(i) := old last(j)
        X{i}=[X{j}(end:-1:1);X{i}];
        Y{i}=[Y{j}(end:-1:1);Y{i}];
        xf(i)=xl(j);
        yf(i)=yl(j);
        FFLL(1:i,i)=FLLF(1:i,j);
        FFLL(i,i:end)=FLLF(i:end,j)';
        FLLF(i,1:j)=FFLL(j,1:j);
        FLLF(i,j:end)=FFLL(j:end,j)';
      else % First-Last, j<i, new first(i) := old first(j)
        X{i}=[X{j}(1:end);X{i}];
        Y{i}=[Y{j}(1:end);Y{i}];
        xf(i)=xf(j);
        yf(i)=yf(j);
        FFLL(1:j,i)=FFLL(1:j,j);
        FFLL(j:i,i)=FFLL(j,j:i)';
        FFLL(i,i:end)=FFLL(j,i:end);
        FLLF(i,:)=FLLF(j,:);
      end
    else
%      if FirstJ %Last-First, i<j, new last(i) := old last(j)
%        X{i}=[X{i};X{j}(1:end)];
%        Y{i}=[Y{i};Y{j}(1:end)];
%        xl(i)=xl(j);
%        yl(i)=yl(j);
%        FFLL(i,1:i)=FFLL(j,1:i);
%        FFLL(i,i:j)=FFLL(i:j,j)';
%        FFLL(j:end,i)=FFLL(j:end,j);
%        FLLF(:,i)=FLLF(:,j);
%      else % Last-Last, j<i, new last(i) := old first(j)
        X{i}=[X{i};X{j}(end:-1:1)];
        Y{i}=[Y{i};Y{j}(end:-1:1)];
        xl(i)=xf(j);
        yl(i)=yf(j);
        FFLL(i,1:i)=FLLF(j,1:i);
        FFLL(i:end,i)=FLLF(j,i:end)';
        FLLF(1:j,i)=FFLL(1:j,j);
        FLLF(j:end,i)=FFLL(j,j:end)';
%      end
    end

%    XX=X;
%    YY=Y;
%    for ii=1:length(XX)
%      XX{ii}(end+1,1)=NaN;
%      YY{ii}(end+1,1)=NaN;
%    end
%    XX=cat(1,XX{:});
%    YY=cat(1,YY{:});
%    figure(1); plot(XX,YY,'-');
    
    FLLF(i,i)=inf;
    FFLL(i,i)=inf;
    AUTO(i)=(xf(i)-xl(i))^2+(yf(i)-yl(i))^2;
    LEN(i)=length(X{i});
    xf(j)=[];
    xl(j)=[];
    yf(j)=[];
    yl(j)=[];
    X(j)=[];
    Y(j)=[];
    AUTO(j)=[];
    LEN(j)=[];
    II=1:N; II(j)=[];
    FFLL=FFLL(II,II);
    FLLF=FLLF(II,II);
%    FFLL(j,:)=[];
%    FFLL(:,j)=[];
%    FLLF(j,:)=[];
%    FLLF(:,j)=[];
    N=N-1;
    
%    for ii=1:length(X)
%      xf(ii)=X{ii}(1);
%      yf(ii)=Y{ii}(1);
%      xl(ii)=X{ii}(end);
%      yl(ii)=Y{ii}(end);
%    end
%    [FFLL,FLLF]=ComputeFFLL(xf,xl,yf,yl);
%    figure(2); subplot(1,2,1); imagesc(FFLL==FFLLx); set(gca,'da',[1 1 1]); title(sprintf('%i %i',i,j)); colorbar; subplot(1,2,2); imagesc(FLLF==FLLFx); set(gca,'da',[1 1 1]); title(sprintf('%i %i',FirstI,FirstJ)); colorbar;

  end
else
  error(sprintf('No algorithm %i implemented',algorithm));
end


if ~cellin
  for i=1:length(X)
    X{i}(end+1,1)=NaN;
    Y{i}(end+1,1)=NaN;
  end
  xn=cat(1,X{:});
  yn=cat(1,Y{:});
  if lngdim>1
    sz=ones(1,lngdim); sz(lngdim)=length(xn);
    xn=reshape(xn,sz);
    yn=reshape(yn,sz);
  end
else
  if lngdim>1
    sz=ones(1,lngdim);
    for i=1:length(X)
      sz(lngdim)=length(X{i});
      X{i}=reshape(X{i},sz);
      Y{i}=reshape(Y{i},sz);
    end
  end
  xn=X;
  yn=Y;
end


function [FFLL,FLLF]=ComputeFFLL(xf,xl,yf,yl);
  N=length(xl);
  FFLL=repmat(inf,N,N);
  FLLF=repmat(inf,N,N);
  for i=1:N-1
    % Store FFLL (First-First distances stored in rows)
    %            (Last-Last distances stored in columns)
    FFLL(i,i+1:end)=((xf(i+1:end)-xf(i)).^2+(yf(i+1:end)-yf(i)).^2)';
    FFLL(i+1:end,i)=(xl(i+1:end)-xl(i)).^2+(yl(i+1:end)-yl(i)).^2;
    % Store FLLF (First-Last distances stored in rows)
    %            (Last-First distances stored in columns)
    FLLF(:,i)=(xf-xl(i)).^2+(yf-yl(i)).^2;
    FLLF(i,i)=inf;
  end
  FLLF(:,N)=(xf-xl(N)).^2+(yf-yl(N)).^2;
  FLLF(N,N)=inf;
