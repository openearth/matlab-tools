function F = wtweibcdf(x,a,b,c)
%WTWEIBCDF Truncated Weibull cumulative distribution function
%
% CALL:  F = wtweibcdf(x,a,b,c);
%
%        F = distribution function evaluated at x
%    a,b,c = parameters
%
%
% The Truncated Weibull distribution is defined by its cdf
%
%  F(x;a,c) = 1 -  exp(-((x+c)/a)^b+abs(c/a)^b), x>=0, a>0,b>0
%
%   Some references refer to the Weibull distribution with
%   a single parameter, this corresponds to WWEIBPDF with a = 1.
%
% Example: 
%   x = linspace(0,6,200);
%   p1 = wtweibcdf(x,1,1,1); p2 = wtweibcdf(x,2,2,3);
%   plot(x,p1,x,p2)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize
% rewritten ms 15.06.2000


error(nargchk(3,4,nargin))
if nargin<4|isempty(c),c=0;end
[errorcode, x, a,b,c] = comnsize (x,a,b, abs(c));
if (errorcode > 0)
  error ('x, a, b and c must be of common size or scalar');
end

F=zeros(size(x));

ok = ((b > 0)  & (a > 0));

k = find (x>=0&ok);
if any (k) 
  F(k)=1-exp(-((x(k)+c(k))./a(k)).^b(k)+abs(c(k)./a(k)).^b(k));
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  F(k1) = tmp(ones(size(k1)));
end








