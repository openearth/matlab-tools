function [xn,yn,cn]=segthread2(x,y,eps1)
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

if nargin==2
  eps2=0;
else
  eps2=eps1^2;
end

c=find(x);

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

i=1;
while i<length(xf)
  x0=xf(i);
  y0=yf(i);
  [min1 c1]=(min((xf(i+1:end)-x0).^2+(yf(i+1:end)-y0).^2));
  [min2 c2]=(min((xl(i+1:end)-x0).^2+(yl(i+1:end)-y0).^2));
  x0=xl(i);
  y0=yl(i);
  [min3 c3]=(min((xf(i+1:end)-x0).^2+(yf(i+1:end)-y0).^2));
  [min4 c4]=(min((xl(i+1:end)-x0).^2+(yl(i+1:end)-y0).^2));
  
  [min0 swex]=min([min1 min2 min3 min4 eps2]);
  if (((xl(i)-xf(i)).^2+(yl(i)-yf(i)).^2)<eps)
      swex=5;
  end
  switch(swex)
      case(1)
      j=c1+i; j=j(1);
      X{i}=[X{j}(end:-1:2);X{i}];
      Y{i}=[Y{j}(end:-1:2);Y{i}];
      X(j)=[];
      Y(j)=[];
      xf(j)=[];
      yf(j)=[];
      xl(j)=[];
      yl(j)=[];
      xf(i)=X{i}(1);
      yf(i)=Y{i}(1);
      case(2)
      j=c2+i; j=j(1);
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
      case(3)
      j=c3+i; j=j(1);
      X{i}=[X{i};X{j}(1:end)];
      Y{i}=[Y{i};Y{j}(1:end)];
      X(j)=[];
      Y(j)=[];
      xf(j)=[];
      yf(j)=[];
      xl(j)=[];
      yl(j)=[];
      xl(i)=X{i}(end);
      yl(i)=Y{i}(end);
      case(4)
      j=c4+i; j=j(1);
      X{i}=[X{i};X{j}(end-1:-1:1)];
      Y{i}=[Y{i};Y{j}(end-1:-1:1)];
      X(j)=[];
      Y(j)=[];
      xf(j)=[];
      yf(j)=[];
      xl(j)=[];
      yl(j)=[];
      xl(i)=X{i}(end);
      yl(i)=Y{i}(end);
      case(5)
      i=i+1;
      end
  end
[Xc,Yc,Cc] = close(X,Y,eps1);
%[Xt,Yt,Ct] = limts(Xc,Yc);


xn=cat(1,Xc{:});
xn(end)=[];
yn=cat(1,Yc{:});
yn(end)=[];
cn=cat(1,Cc{:});
cn(end)=[];
