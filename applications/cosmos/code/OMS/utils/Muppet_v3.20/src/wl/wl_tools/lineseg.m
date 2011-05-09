function [xout,yout,varargout]=lineseg(thr,x,y,varargin),
%LINESEG break a set of points into subreaches.
%      [X,Y]=LINESEG(THRESH,x,y)
%      breaks the line (sample points) given by x,y
%      into segments at locations when points are
%      spaced with a distance larger than THRESH.
%      Returns cell arrays X and Y containing the
%      coordinates of the resulting line segments.
%
%      [X,Y]=LINESEG([THRESH ANGLE],x,y)
%      breaks the line (sample points) given by x,y
%      into segments at locations when points are
%      spaced with a distance larger than THRESH and
%      a change in direction larger than ANGLE (in
%      degrees). Returns cell arrays X and Y containing
%      the coordinates of the resulting line segments.
% 
%      [X,Y,Data1,Data2,...]= ...
%         LINESEG([THRESH ANGLE],x,y,data1,data2,...)
%      Applies same segmentation to the datasets.
%
%      Example: Reconstruct cross-sections from
%      sample data formed by combining cross-sections.
%      Note: the data points of the cross-sections
%      should be successive points of x and y.

% (c) Copyright 2000 H.R.A. Jagers
%     WL | Delft Hydraulics, The Netherlands

xout={};
yout={};

if length(thr)==1 % maxthr
  d=pathdistance(x,y);
  d(2:end)=diff(d);
  d(1)=inf;
  breaks=find(d>thr);
else % length(thr)==2 % [lowthr angle]
  %
  % convert angle threshold from degrees into radians
  %
  thr(2)=thr(2)*pi/180;
  %
  %     *--*-*--*-*i-1 - - *i
  %                  , - '
  %            , - '
  %       i+1* - - - - *-*--*--*-*
  %
  %  d = distance between point i-1 and i
  %      The first point is located far enough from "all previous points".
  %
  d=pathdistance(x,y);
  d(2:end)=diff(d);
  d(1)=inf;
  %
  %  a = direction of the line segment from point i-1 to i
  %
  a=d; % force same orientation: column or row vector
  a(2:end)=atan2(diff(y),diff(x));
  a(1)=a(2);
  %
  % dam1 = change in direction at point i-1
  %        Change in direction is assumed to be very large at virtual point 0.
  %
  dam1=a;
  dam1(2:end)=diff(a);
  dam1(1)=pi;
  %
  % da = change in direction at point i
  %      Change in direction is assumed to be very large at the last point.
  %      Change in direction is assumed to be very large at point 1.
  %
  da=a;
  da(1:end-1)=dam1(2:end);
  da(1)=pi;
  da(end)=pi;
  %
  % a new line starts when the distance between point i-1 and i is large
  % and the direction of the line changes significantly at the point i-1
  % and the direction of the line changes significantly at the point i
  %
  %[(d>thr(1))   (abs(dam1)>thr(2)) & (abs(dam1)<(2*pi-thr(2)))   (abs(da)>thr(2)) & (abs(da)<(2*pi-thr(2)))]
  breaks=find((d>thr(1)) & (abs(dam1)>thr(2)) & (abs(dam1)<(2*pi-thr(2))) & (abs(da)>thr(2)) & (abs(da)<(2*pi-thr(2))));
end

for i=1:length(breaks)-1,
  xout{i}=x(breaks(i):breaks(i+1)-1);
  yout{i}=y(breaks(i):breaks(i+1)-1);
  for j=1:length(varargin),
    varargout{j}{i}=varargin{j}(breaks(i):breaks(i+1)-1);
  end;
end;
xout{end+1}=x(breaks(end):end);
yout{end+1}=y(breaks(end):end);
for j=1:length(varargin),
  varargout{j}{end+1}=varargin{j}(breaks(end):end);
end;

