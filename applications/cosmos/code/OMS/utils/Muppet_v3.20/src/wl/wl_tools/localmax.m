function I=localmax(X)
%LOCALMAX Find local maxima in a matrix
%    I=LOCALMAX(X)
%    returns a logical array containing 1 for
%    a local maximum of X and 0 otherwise.

% (c) Copyright 2000
%     H.R.A. Jagers, WL | Delft Hydraulics, The Netherlands

MX=repmat(min(X(:)),size(X));
N=size(X,1);
M=size(X,2);
for i=-1:1,
  switch i,
  case -1,
    nd=2:N;
  case 0,
    nd=1:N;
  case 1,
    nd=1:N-1;
  end;
  for j=-1:1,
    if i | j,
      switch j,
      case -1,
        md=2:M;
      case 0,
        md=1:M;
      case 1,
        md=1:M-1;
      end;
      MX(nd,md)=max(MX(nd,md),X(nd+i,md+j));
    end;
  end;
end;
I=X>=MX;