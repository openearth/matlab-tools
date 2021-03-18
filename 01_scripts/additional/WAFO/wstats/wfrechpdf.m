function f = wfrechpdf(x,a,c)
%WFRECHPDF Frechet probability density function
%
% CALL:  f = wfrechpdf(x,a,c);
%
%        f = density function evaluated at x
%     a, c = parameters
%
% The Frechet distribution is defined by its cdf
%
%  F(x;a,c) = exp(-(x/a)^(-c)), x>=0, a,c>0
%
% Example: 
%   x = linspace(0,6,200);
%   p1 = wfrechpdf(x,1,1); p2 = wfrechpdf(x,2,2); p3 = wfrechpdf(x,2,5);
%   plot(x,p1,x,p2,x,p3)

% Reference: 

% Tested on; Matlab 5.3
% History: 
% Added PJ 10-May-2001


error(nargchk(3,3,nargin))

[errorcode, x, a, c] = comnsize (x,a, c);
if (errorcode > 0)
  error ('x, a and c must be of common size or scalar');
end

f=zeros(size(x));

ok = ((c > 0)  & (a > 0));

k = find (x>=0&ok);
if any (k)  
  f(k)=(a(k)./x(k)).^c(k).*c(k)./x(k).*exp(-(x(k)./a(k)).^(-c(k)));
%  f(k)=(x(k)./a(k)).^(c(k)-1).*c(k)./a(k).*exp(-(x(k)./a(k)).^c(k));
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end
