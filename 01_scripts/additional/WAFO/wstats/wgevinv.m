function x = wgevinv(F,k,s,m)
%WGEVINV Inverse of the Generalized Extreme Value distribution function
%
% CALL:  x = wgevinv(F,k,s,m)
%
%        x = inverse cdf for the GEV distribution evaluated at F
%        k = shape parameter in the GEV 
%        s = scale parameter in the GEV, s>0  (default 1)
%        m = location parameter in the GEV    (default 0)
%
%
% The Generalized Extreme Value distribution is defined by its cdf
%
%                exp( - (1 - k(x-m)/s)^1/k) ),  k~=0
%  F(x;k,s,m) =
%                exp( -exp(-(x-m)/s) ),  k==0
%
%  for x>s/k+m (when k<=0) and x<m+s/k (when k>0).
%
% Example:
%   F = linspace(0,1,100);
%   x = wgevinv(F,0.8,2,11);
%   plot(F,x)

% References 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on: Matlab 5.3
% History: 
% Revised by jr 22.12.1999
% revised ms 14.06.2000
% - updated header info
% - changed name to wgevinv (from gevinv)
% revised pab 24.10.2000
% - added  nargchk, comnsize and default values for m, s

error(nargchk(2,4,nargin))
if nargin<3,  s=1;end
if nargin<4,  m=0;end
[errorcode F k,s,m] = comnsize(F,k,s,m);
if errorcode > 0
    error('k s and m must be of common size or scalar.');
end

% Initialize  x to zero.
x = zeros(size(k));

epsilon=1e-4;

ok = (F>=0 & F<=1 & s>0);

k1 = find(abs(k)< epsilon & ok);
if any(k1)
  x(k1) = m(k1) - s(k1).*log(-log(F(k1)));
end

k2 = find(abs(k)>= epsilon & ok);
if any(k2)
  x(k2) = m(k2) + s(k2).*(1-(-log(F(k2))).^k(k2))./k(k2);
end


tmp=Inf;
k3 = find(abs(k) < epsilon & F==1&ok);
if any(k3)
  x(k3)=tmp(ones(size(k3)));
end
k4 = find(abs(k) >= epsilon & F==1&ok);
if any(k4)
  x(k4)=m(k4)+s(k4)./k(k4);
end

k5=find(F==0&ok);
if any(k5),
  x(k5)=-tmp(ones(size(k5)));
end

k6=find(~ok);
if any(k6),
  tmp=NaN;
  x(k6)=tmp(ones(size(k6)));
end



