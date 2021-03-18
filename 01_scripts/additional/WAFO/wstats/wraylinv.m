function x = wraylinv(F,b)
%WRAYLINV Inverse of the Rayleigh distribution function
%
% CALL:  x = wraylinv(F,b)
%
%        x = inverse cdf for the Rayleigh distribution evaluated at F
%        b = parameter
% 
% The Rayleigh distribution is defined by its cdf
%
%  F(x;b) = 1 - exp(-x^2/(2b^2)), x>=0
%
%
% Example:
%   F = linspace(0,1,100);
%   x = wraylinv(F,1);
%   plot(F,x)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.

% Tested on: Matlab 5.3
% History: 
% revised pab 24.10.2000
% - added comnsize, nargchk
% added ms 15.06.2000


error(nargchk(2,2,nargin))

[errorcode, F, b] = comnsize(F,b);
if (errorcode > 0)
  error ('F and b must be of common size or scalar');
end

x=zeros(size(F));

  
k = find ((F == 1) & (b>0));
if any (k),
  tmp=inf;
  x(k) = tmp(ones (size(k)));
end
  
k1 = find ((F > 0) & (F < 1) & (b>0));
if any (k1),
  x(k1)=sqrt(-2*log(1-F(k1))).*b(k1);
end

k2 = find(F<0 | F>1 | (b<=0));
if any(k2),
  tmp=NaN;
  x(k2)=tmp(ones(size(k2)));
end


