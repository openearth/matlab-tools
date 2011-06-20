function c=curvat(x,y)
% CURVAT computes the curvature in every point of a line
%    defined as function C=CURVAT(X,Y)

% (c) copyright, H.R.A. Jagers, 2000
%       created by H.R.A. Jagers, Delft Hydraulics

if nargin~=2,
  error('Two input arguments required.');
end;

if ~isnumeric(x) | ~isnumeric(y),
  error('Numeric input arguments required.');
end;

if any(size(x)~=size(y)) | (min(size(x))~=1),
  error('Two non-empty vectors of equal size expected as input arguments.');
end;

c=zeros(size(x));
i=2:(length(x)-1);
x12=x(i-1)-x(i);
y12=y(i-1)-y(i);
x23=x(i)-x(i+1);
y23=y(i)-y(i+1);
x31=x(i+1)-x(i-1);
y31=y(i+1)-y(i-1);
tel=x23.*x31+y23.*y31;
noem=x12.*y23-y12.*x23;
  %xc2=(x12-tel*y12/noem)/2;
  %yc2=(y12+tel*x12/noem)/2;
  %xc=x2+xc2;
  %yc=y2+yc2;
  %rad=sqrt(xc2^2+yc2^2);
tel(noem==0)=inf; noem(noem==0)=-1;
l=tel./noem;
rad=sqrt((x12.^2+y12.^2).*(1+l.^2))/2;
c(i)=-sign(noem)./rad;
c(end)=c(end-1);
c(1)=c(2);