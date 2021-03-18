function F = wweibcdf(x,a,c)
%WWEIBCDF Weibull cumulative distribution function
%
% CALL:  F = wweibcdf(x,a,c);
%
%        F = distribution function evaluated at x
%     a, c = parameters
%
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
%   p1 = wweibcdf(x,1,1); p2 = wweibcdf(x,2,2);
%   plot(x,p1,x,p2)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised oab 24.10.2000
%  - added comnsize
% rewritten ms 15.06.2000


error(nargchk(3,3,nargin))

[errorcode, x, a, c] = comnsize (x,a, c);
if (errorcode > 0)
  error ('x, a and c must be of common size or scalar');
end

F=zeros(size(x));

ok = ((c > 0)  & (a > 0));

k = find (x>=0&ok);
if any (k) 
  F(k)=1-exp(-(x(k)./a(k)).^c(k));
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  F(k1) = tmp(ones(size(k1)));
end








