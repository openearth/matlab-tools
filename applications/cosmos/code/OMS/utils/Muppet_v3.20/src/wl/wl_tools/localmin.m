function LMIN=localmin(X),
%LOCALMIN Locally smallest component (1D)
%
%  LOCALMIN(X) returns a vector indicating whether or not
%  a value is a local minimum.

LMIN=logical(ones(X));
DX=diff(X);
LMIN(1:end-1)=DX>0;
LMIN(2:end)=LMIN(2:end) & DX<0;

