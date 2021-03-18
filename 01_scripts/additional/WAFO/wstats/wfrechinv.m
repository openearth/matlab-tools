function x = wfrechinv(F,a,c)
%WFRECHINV Inverse of the Frechet distribution function
%
% CALL:  x = wfrechinv(F,a,c)
%
%        x = inverse cdf for the Frechet distribution evaluated at F
%     a, c = parameters
%
% The Frechet distribution is defined by its cdf
%
%  F(x;a,c) = exp(-(x/a)^(-c)), x>=0, a,c>0
%
% Example:
%   F = linspace(0,1,100);
%   x = wweibinv(F,10,5);
%   plot(F,x)

% Reference: 


% Tested on: Matlab 5.3
% History: 
% Added PJ 10-May-2001

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
  x(k1)=(-log(F(k1))).^(-1./c(k1)).*a(k1);
end

k2 = find(F<0 | F>1 | ~ok);
if any(k2),
  tmp=NaN;
  x(k2)=tmp(ones(size(k2)));
end
