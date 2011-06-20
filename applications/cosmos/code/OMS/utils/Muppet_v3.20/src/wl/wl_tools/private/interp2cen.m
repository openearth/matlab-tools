function X=interp2cen(x,flag)
%INTERP2CEN interpolate to center
%      X=INTERP2CEN(x)
%      Interpolates data from cell corners to centers (NM dirs).
%      x is a N x M matrix
%
%      X=INTERP2CEN(x,flag)
%      Interpolates data from cell corners to centers (NM dirs).
%      x is a nTim x N x M x ... matrix

% (c) 2000 WL | Delft Hydraulics
%     Author: H.R.A.Jagers
%     Version 1.0
%     Date: Nov. 5, 2000

switch nargin,
case 1,
  if isempty(x)
    X=x;
    return
  end
  if ndims(x)==3
    m=2:size(x,2);
    n=2:size(x,3);
    X(:,m,n)=(x(:,m,n)+x(:,m-1,n)+x(:,m,n-1)+x(:,m-1,n-1))/4;
    X(:,1,:)=NaN;
    X(:,:,1)=NaN;
  else
    m=2:size(x,1);
    n=2:size(x,2);
    X(m,n)=(x(m,n)+x(m-1,n)+x(m,n-1)+x(m-1,n-1))/4;
    X(1,:)=NaN;
    X(:,1)=NaN;
  end
case 2,
  X=x;
  if isempty(x)
    return
  end
  
  for i=1:ndims(x),
    idx{i}=1:size(x,i);
  end
  
  idx{2}=2:size(x,2);
  idx{3}=2:size(x,3);
  idd=idx; idd{2}=idx{2}-1;
  X(idx{:})=X(idx{:})+x(idd{:});
  idd{3}=idx{3}-1;
  X(idx{:})=X(idx{:})+x(idd{:});
  idd{2}=idx{2};
  X(idx{:})=X(idx{:})+x(idd{:});
  X(idx{:})=X(idx{:})/4;
  X(:,1,:,:)=NaN;
  X(:,:,1,:)=NaN;
end
