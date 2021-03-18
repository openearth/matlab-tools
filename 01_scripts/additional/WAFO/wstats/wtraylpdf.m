function f = wraylpdf(x,b,c);
%WTRAYLPDF Truncated Rayleigh probability density function
%
% CALL:  f = wtraylpdf(x,b,c);
%
%        f = density function evaluated at x
%        b = scale parameter
%        c = truncation parameter (default 0)
% 
% The Truncated Rayleigh distribution is defined by its cdf
%
%  F(x;b,c) = 1 - exp(-(x-c)^2/(2b^2)+c^2/(2*b^2)), x>=0, b>0
%
% Example: 
%   x = linspace(0,4,200);
%   p1 = wtraylpdf(x,1); p2 = wtraylpdf(x,0.5,-2);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 15.06.2000


error(nargchk(2,3,nargin))
if nargin<3|isempty(c),c=0;end
[errorcode, x, b,c] = comnsize (x,b,c);
if (errorcode > 0)
  error ('x, b and c must be of common size or scalar');
end

f=zeros(size(x));

k = find ((x>=0)&(b>0));
if any (k)  
  f(k)=(x(k)-c(k)).*exp(-((x(k)-c(k)).^2 -abs(c(k)).^2)./(2*b(k).^2))./b(k).^2;
end

k1 = find (b<=0);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end

