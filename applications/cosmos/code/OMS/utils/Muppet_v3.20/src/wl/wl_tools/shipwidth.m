function [width,xl,yl,xr,yr]=shipwidth(X,Y,Zb,Zw,HCrit,xin,yin,Weirs)
%[width,xl,yl,xr,yr]=shipwidth(X,Y,Zb,Zw,HCrit,xin,yin,Weirs)
% X,Y     : Co-ordinates of bed level points.
% Zb      : Bed levels (positive upward!).
% Zw      : Water level.
% HCrit   : Critical shipping depth (e.g. 2.5 or 2.8 m).
% xin,yin : Co-ordinates of a point known to lie within
%           the shipping lane (optional).
% Weirs   : Flag to indicate that a weir is adjacent to the
%           bed level point: 2D field (optional).

if nargin<5
  error('Not enough input arguments.')
end
if nargin<8
  Weirs=[];
end
if nargin<7
  xin=[];
  yin=[];
end
if sum(size(Zw)>1)>1
  error('Water level data set should be one dimensional.')
end
if length(Zw)~=size(X,1) & length(Zw)==size(X,2)
  X=X';
  Y=Y';
  Zb=Zb';
  if nargin>=8
    Weirs=Weirs';
  end
end
M=size(X,1);
width=zeros(M,1);
xl=zeros(M,1);
yl=zeros(M,1);
xr=zeros(M,1);
yr=zeros(M,1);
if isempty(Weirs)
  Weirs=zeros(size(X));
end
for m=1:M
  if isempty(xin)
    xin_m=[]; yin_m=[];
  else
    xin_m=xin(m); yin_m=yin(m);
  end
  [width(m),xl(m),yl(m),xr(m),yr(m)]= ...
    shipwidth1(X(m,:),Y(m,:),Zb(m,:),Zw(m),HCrit,xin_m,yin_m,Weirs(m,:));
end

function [Width,xLow,yLow,xHigh,yHigh]=shipwidth1(x,y,Zb,Zw,HCrit,xin,yin,Weirs)
x=x(:);
y=y(:);
Zb=Zb(:);
Zb(abs(Zb)==999)=NaN;
Weirs=Weirs(:);
H=Zw-Zb;
Suff=H>HCrit;
imax=length(x);
icenter=floor(imax/2); % something more general for asymmetric floodplains?
if ~any(Suff),
  Width=0;
  xLow=x(icenter);
  yLow=y(icenter);
  xHigh=xLow;
  yHigh=yLow;
  return
end

i=icenter;
while i>1 & ~isnan(Zb(i)) & H(i)>0.1 & ~Weirs(i)
  i=i-1;
end
while i<imax
  if Suff(i), break, end
  i=i+1;
end
WeirDistLow=0;
if Weirs(i) | i==1 | isnan(Zb(i-1)),
  WeirDistLow=25;
  ds=sqrt((x(i)-x(i+1))^2+(y(i)-y(i+1))^2);
  while ds<WeirDistLow
    WeirDistLow=WeirDistLow-ds;
    i=i+1;
    ds=sqrt((x(i)-x(i+1))^2+(y(i)-y(i+1))^2);
  end
  xLow=x(i)+(x(i+1)-x(i))*WeirDistLow/ds;
  yLow=y(i)+(y(i+1)-y(i))*WeirDistLow/ds;
else
  lamb=(HCrit-H(i-1))/(H(i)-H(i-1));
  xLow=x(i-1)+lamb*(x(i)-x(i-1));
  yLow=y(i-1)+lamb*(y(i)-y(i-1));
end

i=icenter;
while i<imax & ~isnan(Zb(i)) & H(i)>0.1 & ~Weirs(i)
  i=i+1;
end
while i>1
  if Suff(i), break, end
  i=i-1;
end
WeirDistHigh=0;
if Weirs(i) | i==imax | isnan(Zb(i+1)),
  WeirDistHigh=25;
  ds=sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
  while ds<WeirDistLow
    WeirDistLow=WeirDistLow-ds;
    i=i-1;
    ds=sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
  end
  xHigh=x(i)+(x(i-1)-x(i))*WeirDistLow/ds;
  yHigh=y(i)+(y(i-1)-y(i))*WeirDistLow/ds;
else
  lamb=(HCrit-H(i+1))/(H(i)-H(i+1));
  xHigh=x(i+1)+lamb*(x(i)-x(i+1));
  yHigh=y(i+1)+lamb*(y(i)-y(i+1));
end

Width=sqrt((xLow-xHigh)^2+(yLow-yHigh)^2);