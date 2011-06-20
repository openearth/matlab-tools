function CW=clockwise(x,y)
%CLOCKWISE polygon clockwise or anticlockwise
%       CW=CLOCKWISE(X,Y)
%       returns 1 if the polygon (X,Y) is
%       clockwise and -1 if the polygon is
%       anticlockwise.

if length(x)<=2
  CW=0;
  return;
end
%CW2=clockwise2(x,y);
%
% select left most points ...
%
x0=min(x);
i=x==x0;
%
% select lowest left most point ...
%
y0=min(y(i));
i=find(y==y0 & x==min(x));
i=i(1);
%
% find point before ...
%
if i==1
  ip=length(x);
  while x(ip)==x0 & y(ip)==y0
    ip=ip-1;
  end
else
  ip=i-1;
end
%
% find point after ...
%
in=i+1;
if in>length(x)
  in=1;
end
while x(in)==x0 & y(in)==y0
  in=in+1;
end
%I=[ip i in];
%
% if point after lies above point before
%   the orientation is clockwise ...
%
an=atan2(y(in)-y(i),x(in)-x(i));
ap=atan2(y(ip)-y(i),x(ip)-x(i));
CW=an>ap;
if ~CW, CW=-1; end

function CW=clockwise2(x,y)
% <INCORRECT IMPLEMENTATION>
%
% compute relative directions
%
at=atan2(y-y(1),x-x(1));
%
%at(1)=NaN;
%
N=length(at);
while x(N)==x(1) & y(N)==y(1)
    N=N-1;
    if N==0, CW=0; return; end
end
%
% compute angle changes (difference
% in direction)
%
dat=diff(at(2:N));
%
% Limit angle change to range
% between -pi and +pi
%
% Explicit:
% dat(dat>pi)=dat(dat>pi)-2*pi;
% dat(dat<-pi)=dat(dat<-pi)+2*pi;
%
% Fancy one liner:
dat=mod(dat+pi,2*pi)-pi;
%
% sum the angle changes to get
% the overall direction of rotation
%
CW=sign(-sum(dat));
