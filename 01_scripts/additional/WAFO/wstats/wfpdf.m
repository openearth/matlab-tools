function f = wfpdf(x,a,b)
%WFPDF Snedecor's F probability density function
%
% CALL:  f = wfpdf(x,df1,df2);
%
%       f = PDF evaluated at x
%       x = matrix
% df1,df2 = degrees of freedom (1,2,....)
% 
% Example:
%   x  = linspace(0,6,200);
%   p1 = wfpdf(x,1,1); p2 = wfpdf(x,2,2);
%   plot(x,p1,x,p2)

% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize + a check that df1,df2 are positive integers
%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg


error(nargchk(3,3,nargin))
[errorcode x,a,b] = comnsize(x,a,b);
if errorcode>0,
  error('x, df1 and df2 must be of common size or scalar');
end

f = zeros(size(x));

ok = (a>0 & b>0 & floor(a)==a & floor(b)==b);

k = find(x>=0 & ok);
if any(k)
  c = b(k)./a(k);
  xx = x(k)./(x(k)+c(k));
  tmp = wbetapdf(xx,a(k)/2,b(k)/2);
  f(k) = tmp./(x(k)+c(k)).^2.*c(k);
end


k3=find(~ok);
if any(k3)
  tmp=NaN;
  xf(k3)=tmp(ones(size(k3)));
end







