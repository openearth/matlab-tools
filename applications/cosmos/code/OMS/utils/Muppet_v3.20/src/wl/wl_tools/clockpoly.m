function rot=clockpoly(x,y)
%CLOCKPOLY Determine drawing direction of a simple polygon
%    rot=CLOCKPOLY(x,y)
%    Determines whether the point x,y of the polygon
%    have been specified in clockwise or counter-
%    clockwise direction.
%    Returns 1 for clockwise, -1 for counter-clockwise
%    and 0 for indeterminate.
%    If the direction is not defined (e.g. in case of a
%    polygon describing the shape 8) the routine gives a
%    random answer.

x=x(:);
y=y(:);
xc=mean(x);

xd=diff([x;x(1)]);
yd=diff([y;y(1)]);
x=x;
y=y;

mark=xd==0;
xd(mark)=NaN;
a=(xc-x)./xd;
mark2=a<0 | a>1;
yc=y+a.*yd;
yc(mark & xc~=x)=-inf; % parallel to x=xc -> not crossing -> remove
yc(mark2)=-inf; % crossing outside range -> remove
mark=mark & xc==x;
yc(mark)=y(mark)+max(0,yd(mark)); % on the line x=xc -> take maximum

ycm=max(yc); % highest crossing of x=xc somewhere between i and i+1
i=find(yc==ycm);

Rot=0;
if all(xd(i)>=0) & any(xd(i)>0) % going right
  Rot=1;
elseif all(xd(i)<=0) & any(xd(i)<0) % going left
  Rot=-1;
elseif any(xd(i)>0) & any(xd(i)<0) % going both left and right
  % indeterminate
else, % xd=0 % going straight up or down
  % indeterminate
end

if nargout==0
  switch Rot
  case -1
    fprintf('Counter-clockwise polygon\n');
  case 0
    fprintf('Indeterminate polygon\n');
  case 1
    fprintf('Clockwise polygon\n');
  end
else
  rot=Rot;
end