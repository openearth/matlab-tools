function x = wweibinv(F,a,c)
%WWEIBINV Inverse of the Weibull distribution function
%
% CALL:  x = wweibinv(F,a,c)
%
%        x = inverse cdf for the Weibull distribution evaluated at F
%     a, c = parameters
%
% The Weibull distribution is defined by its cdf
%
%  F(x;a,c) = 1 -  exp(-(x/a)^c), x>=0, a,b>0
%
% Example:
%   F = linspace(0,1,100);
%   x = wweibinv(F,10,5);
%   plot(F,x)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.


% Tested on: Matlab 5.3
% History: 
% revised pab 24.10.2000
% - added comnsize, nargchk
% rewritten ms 15.06.2000

error(nargchk(3,3,nargin))

[errorcode, F, a, c] = comnsize(F,a, c);
if (errorcode > 0)
  error ('F, a and c must be of common size or scalar');
end

x=zeros(size(F));

ok = ((c > 0)  & (a > 0));
  
k = find ((F == 1) & ok);
if any (k),
  tmp=inf;
  x(k) = tmp(ones (size(k)));
end
  
k1 = find ((F > 0) & (F < 1) & ok);
if any (k1),
  x(k1)=(-log(1-F(k1))).^(1./c(k1)).*a(k1);
end

k2 = find(F<0 | F>1 | ~ok);
if any(k2),
  tmp=NaN;
  x(k2)=tmp(ones(size(k2)));
end





