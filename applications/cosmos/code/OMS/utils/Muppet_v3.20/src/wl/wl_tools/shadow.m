function [xd,yd]=shadow(x,y,n,relsiz)
% SHADOW generates a line coordinates to shade one side of a line.
%    SHADOW(X,Y,N,R) generates the coordinates of N shadow lines
%    at the right side of the line and with the length of the
%    shadow lines equal to R times the distance between the lines.
%    Default values R=1, N=length(X)+1. N should be specified if R
%    is to be specified.
%
%    Note:
%      R=-1 generates shadow lines at the left side of the line.
%
%    Example:
%      x=0:.01:6.28; y=sin(x);
%      [x11,y11]=shadow(x,y,51);
%      [x3,y3]=shadow(x,y,26,-2);
%      plot([x11; x'],[y11; y'],'b',x3,y3,'r');
%      axis('equal');

% Copyright (c) 25 March 1997, H.R.A. Jagers, University of Twente, The Netherlands

if nargin>4,
  fprintf(1,'* Too many input arguments.\n');
  return;
elseif nargin<2,
  fprintf(1,'* Not enough input arguments.\n');
  return;
else
  if size(x,1)<size(x,2),
    x=x';
  end;
  if size(y,1)<size(y,2),
    y=y';
  end;
  if (size(x,2)~=1) | (size(x)~=size(y)) | (size(x,1)==1),
    fprintf(1,'* X and Y must be vectors of equal length.\n');
    return;
  end;
  if ~all(finite(x)) | ~all(finite(y)),
    fprintf(1,'* X and Y should contain neither NaN nor Inf values.\n');
    return;
  end;
  if nargin>=3,
    if (size(n)~=[1 1]) | ~all(n>1) | ~all(n==round(n)),
      fprintf(1,'* N must be an integer larger than 1.\n');
      return;
    end;
    if nargin==4,
      if size(relsiz)~=[1 1],
        fprintf(1,'* Argument must be a scalar.\n');
        return;
      end;
    end;
  else,
    n=size(x,1)+1;
  end;
end;

if nargin<4,
  relsiz=1;
end;

szx=size(x,1);

s=0;
for i=2:szx,
  s=s+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
end;
ds=s/(n-1);

xs=[];
ys=[];
s0=0;
s=0;
i=2;
j=0;
while round(i)<=szx,
  s1=s;
  s=s+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
  if s>=s0,
    l=(s0-s1)/(s-s1);
    dx=x(i)-x(i-1);
    dy=y(i)-y(i-1);
    x0=x(i-1)+l*dx;
    y0=y(i-1)+l*dy;
    delta=relsiz*ds/sqrt((dx^2+dy^2));
    xs=[xs; x0+delta*dy; x0; NaN];
    ys=[ys; y0-delta*dx; y0; NaN];
    s0=s0+ds;
    s=s1;
    j=j+1;
  else,
    i=i+1;
  end;
  if j==(n-1),
    dx=x(szx)-x(szx-1);
    dy=y(szx)-y(szx-1);
    x0=x(szx);
    y0=y(szx);
    delta=relsiz*ds/sqrt((dx^2+dy^2));
    xs=[xs; x0+delta*dy; x0; NaN];
    ys=[ys; y0-delta*dx; y0; NaN];
    break;
  end;
end;

if nargout>=2,
  if nargout>2,
    fprintf(1,'* Using first two output arguments.\n');
  end;
  xd=xs;
  yd=ys;
elseif nargout<2,
  xd=[xs,ys];
end;