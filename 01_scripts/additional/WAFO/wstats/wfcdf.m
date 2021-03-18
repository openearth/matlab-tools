function F = wfcdf(x,a,b)
%WFCDF  Snedecor's F cumulative distribution function
%
% CALL:  F = wfcdf(x,df1,df2);
%
%        F = distribution function evaluated at x
%        x = matrix
%  df1,df2 = degrees of freedom (1,2,....)
%
% Example:
%   x  = linspace(0,6,200);
%   p1 = wfcdf(x,1,1); p2 = wfcdf(x,2,2);
%   plot(x,p1,x,p2)

% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize +  check on floor(df)==df
%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg


error(nargchk(3,3,nargin))
[errorcode x,a,b] = comnsize(x,a,b);
if errorcode>0,
  error('x, df1 and df2 must be of common size or scalar');
end

F = zeros(size(x));

ok = (a>0 & b>0 & floor(a)==a & floor(b)==b);
k=find(ok & x>=0 & x<inf);
if any(k),
  F(k) = wbetacdf(x(k)./(x(k)+b(k)./a(k)),a(k)/2,b(k)/2);
end

k1=find(ok &  x==inf);
if any(k1),
  F(k1) =ones(size(k1));
end

  
k2 = find(~ok);
if any(k2)
  warning('df1 and df1 must be positive integers.')
  f(k2)=NaN;
end

