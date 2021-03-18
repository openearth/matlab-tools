function f = wgevpdf(x,k,s,m);
%WGEVPDF Generalized Extreme Value probability density function
%
% CALL:  f = wgevpdf(x,k,s,m);
%
%        f = density function evaluated at x
%        k = shape parameter in the GEV 
%        s = scale parameter in the GEV, s>0  (default 1) 
%        m = location parameter in the GEV    (default 0)
% 
% The Generalized Extreme Value distribution is defined by its cdf
%
%                exp( - (1 - k(x-m)/s)^1/k) ),  k~=0
%  F(x;k,s,m) =
%                exp( -exp(-(x-m)/s) ),  k==0
%
% for x>s/k+m (when k<=0) and x<m+s/k (when k>0).
%
% Example: 
%   x = linspace(0,15,200);
%   p1 = wgevpdf(x,0.8,1,11); p2 = wgevpdf(x,0.8,2,11);
%   p3 = wgevpdf(x,0.5,1,11); p4 = wgevpdf(x,0.5,2,11);
%   plot(x,p1,x,p2,x,p3,x,p4)

% References
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on; Matlab 5.3
% History: 
% revised jr 14.08.2001
% - a bug in the last if-statement condition fixed
%   (thanks to D Eddelbuettel <edd@debian.org>)
% revised pab 24.10.2000
% - added  nargchk, comnsize and default values for m, s
% added ms 14.06.2000

error(nargchk(2,4,nargin))

if nargin<4|isempty(m), m=0;end
if nargin<3|isempty(s), s=1;end

[errorcode x k s,m] = comnsize(x,k,s,m);
if errorcode > 0
  error('x, k, s and m must be of common size or scalar.');
end
  
epsilon=1e-4; % treshold defining k to zero

f = zeros(size(x));
k0 = find(x>=m & abs(k)<=epsilon & s>0);
if any(k0),
  tmp=exp(-(x(k0)-m(k0))./s(k0));
  f(k0) = exp(-tmp).*tmp./s(k0);
end

k1=find((k.*x<s+k.*m)&(abs(k)>epsilon));
if any(k1),
  tmp = (1-k(k1).*(x(k1)-m(k1))./s(k1));
  f(k1)=exp(-tmp.^(1./k(k1))).*tmp.^(1./k(k1)-1)./s(k1);
end
  
%k2=find((k.*x>=s+k.*m)&(k>epsilon));
%if any(k2),
%  f(k2)=ones(size(k2));
%end

k3 = find(s<=0 );
if any(k3),
   tmp   = NaN;
   f(k3) = tmp(ones(size(k3)));
end
return




