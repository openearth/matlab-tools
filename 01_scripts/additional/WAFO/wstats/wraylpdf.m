function f = wraylpdf(x,b);
%WRAYLPDF Rayleigh probability density function
%
% CALL:  f = wraylpdf(x,b);
%
%        f = density function evaluated at x
%        b = parameter
% 
% The Rayleigh distribution is defined by its cdf
%
%  F(x;b) = 1 - exp(-x^2/(2b^2)), x>=0, b>0
%
% Example: 
%   x = linspace(0,4,200);
%   p1 = wraylpdf(x,1); p2 = wraylpdf(x,0.5);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 15.06.2000


error(nargchk(2,2,nargin))
[errorcode, x, b] = comnsize (x,b);
if (errorcode > 0)
  error ('x and b must be of common size or scalar');
end

f=zeros(size(x));

k = find ((x>=0)&(b>0));
if any (k)  
  f(k)=x(k).*exp(-x(k).^2./(2*b(k).^2))./b(k).^2;
end

k1 = find (b<=0);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end

