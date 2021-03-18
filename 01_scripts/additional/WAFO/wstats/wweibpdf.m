function f = wweibpdf(x,a,c)
%WWEIBPDF Weibull probability density function
%
% CALL:  f = wweibpdf(x,a,c);
%
%        f = density function evaluated at x
%     a, c = parameters
%
% The Weibull distribution is defined by its cdf
%
%  F(x;a,c) = 1 -  exp(-(x/a)^c), x>=0, a,b>0
%
%   Some references refer to the Weibull distribution with
%   a single parameter, this corresponds to WWEIBPDF with a = 1.
%
% Example: 
%   x = linspace(0,6,200);
%   p1 = wweibpdf(x,1,1); p2 = wweibpdf(x,2,2); p3 = wweibpdf(x,2,5);
%   plot(x,p1,x,p2,x,p3)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% rewritten ms 15.06.2000


error(nargchk(3,3,nargin))

[errorcode, x, a, c] = comnsize (x,a, c);
if (errorcode > 0)
  error ('x, a and c must be of common size or scalar');
end

f=zeros(size(x));

ok = ((c > 0)  & (a > 0));

k = find (x>=0&ok);
if any (k)  
  f(k)=(x(k)./a(k)).^(c(k)-1).*c(k)./a(k).*exp(-(x(k)./a(k)).^c(k));
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end






