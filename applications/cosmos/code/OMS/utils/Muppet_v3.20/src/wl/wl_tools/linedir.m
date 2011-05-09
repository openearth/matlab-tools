function [xd,yd]=linedir(x,y,n,arlen)
% LINEDIR generates a small arrow point to indicate direction along a line
%    LINEDIR(X,Y) generates an arrow half way of the line given X and Y.
%    LINEDIR(X,Y,N) generates N arrows at splitting the line given by
%      X and Y in N+1 sections of equal length.
%    LINEDIR(X,Y,0) generates an arrow at the end of the line given by
%      X and Y.
%    LINEDIR(X,Y,N,L) generates N arrows at splitting the line given by
%      X and Y in N+1 sections of equal length. The length of the arrow
%      sides are given by L. The default length depends on the line length.
%
%    Example:
%      x=0:.01:6.28; y=sin(x);
%      [x11,y11]=linedir(x,y,11,.1);
%      [x3,y3]=linedir(x,y,3,.3);
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
    if (size(n)~=[1 1]) | ~all(n>=0) | ~all(n==round(n)),
      fprintf(1,'* N must be an integer.\n');
      return;
    end;
    if nargin==4,
      if size(arlen)~=[1 1],
        fprintf(1,'* Argument must be a scalar.\n');
        return;
      end;
    end;
  else,
    n=1;
  end;
end;

szx=size(x,1);
s=0;
for i=2:szx,
  s=s+sqrt((x(i)-x(i-1))^2+(y(i)-y(i-1))^2);
end;
ds=s/(n+1);

if nargin<4,
  arlen=s/10;
end;

xs=[];
ys=[];
s0=ds;
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
    delta=arlen/sqrt(2*(dx^2+dy^2));
    xs=[xs; x0-delta*dx+delta*dy; x0; x0-delta*dx-delta*dy; NaN];
    ys=[ys; y0-delta*dy-delta*dx; y0; y0-delta*dy+delta*dx; NaN];
    s0=s0+ds;
    s=s1;
    j=j+1;
    if j==n,
      break;
    end;
  else,
    i=i+1;
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