function I=reducepntsq(thresh,x,y,z)
%REDUCEPNTSQ Filters a set points using a distance threshold.
%      I = REDUCEPNTSQ(Thresh_Dist,X,Y,Z)
%      selects per hypercube of size Thresh_Dist (a square in 2D)
%      one point of the X,Y,Z set. The functions returns an array
%      I containing the indices of the selected points. The
%      function works in 1 (X), 2 (X and Y) and 3 (X, Y and Z)
%      dimensions.
%
%      This method is quicker but results in a less elegant
%      solution than REDUCEPOINTS.
%
%      See also REDUCEPOINTS.

% Copyright (c) 19/5/2000 by H.R.A. Jagers
%               WL | Delft Hydraulics, The Netherlands

if nargin<2,
  error('At least two input arguments expected.');
elseif nargin==2, % 1D
  if thresh==0, I=1:prod(size(x)); end;

  xmin=min(x(:));

  I=floor((x(:)-xmin)/thresh);

  [B,I]=unique(I,'rows');
elseif nargin==3, % 2D
  if thresh==0, I=1:prod(size(x)); end;

  xmin=min(x(:));
  ymin=min(y(:));

  I=[floor((x(:)-xmin)/thresh) floor((y(:)-ymin)/thresh)];

  [B,I]=unique(I,'rows');
else, % nargin==4 % 3D
  if thresh==0, I=1:prod(size(x)); end;

  xmin=min(x(:));
  ymin=min(y(:));
  zmin=min(z(:));

  I=[floor((x(:)-xmin)/thresh) floor((y(:)-ymin)/thresh) floor((z(:)-zmin)/thresh)];

  [B,I]=unique(I,'rows');
end;

