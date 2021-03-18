function F = wgevcdf(x,k,s,m);
%WGEVCDF Generalized Extreme Value cumulative distribution function
%
% CALL:  F = wgevcdf(x,k,s,m);
%
%        F = distribution function evaluated at x
%        k = shape parameter in the GEV 
%        s = scale parameter in the GEV, s>0 (default 1)
%        m = location parameter in the GEV   (default 0)
% 
% The Generalized Extreme Value distribution is defined by its cdf
%
%                exp( - (1 - k(x-m)/s))^1/k) ),  k~=0
%  F(x;k,s,m) =
%                exp( -exp(-(x-m)/s) ),  k==0
%
%  for x>s/k+m (when k<=0) and x<m+s/k (when k>0).
%
% Example: 
%   x = linspace(0,15,200);
%   p1 = wgevcdf(x,0.8,1,11); p2 = wgevcdf(x,0.8,2,11);
%   p3 = wgevcdf(x,0.5,1,11); p4 = wgevcdf(x,0.5,2,11);
%   plot(x,p1,x,p2,x,p3,x,p4)

% References
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on; Matlab 5.3
% History: 
% Revised by jr 22.12.1999
% revised ms 14.06.2000
% - updated header info
% - changed name to wgevcdf (from gevcdf)
% revised pab 24.10.2000
% - added  nargchk, comnsize and default values for m, s 
% revised jr 14.08.2001
% - a bug in the last if-statement condition fixed
%   (thanks to D Eddelbuettel <edd@debian.org>)

error(nargchk(2,4,nargin))

if nargin<4|isempty(m), m=0;end
if nargin<3|isempty(s), s=1;end

[errorcode x k s,m] = comnsize(x,k,s,m);
if errorcode > 0
  error('x, k, s and m must be of common size or scalar.');
end
  
epsilon=1e-4; % treshold defining k to zero

F = zeros(size(x));
%k0 = find(x>=m & abs(k)<=epsilon & s>0);
k0 = find( abs(k)<=epsilon & s>0);
if any(k0),
  F(k0) = exp(-exp(-(x(k0)-m(k0))./s(k0)));
end

%k1=find(x>m&(k.*x<s+k.*m)&(abs(k)>epsilon));
k1=find((k.*x<s+k.*m)&(abs(k)>epsilon));
if any(k1),
  tmp = (1-k(k1).*(x(k1)-m(k1))./s(k1));
  F(k1)=exp(-tmp.^(1./k(k1)));
end

k2=find((k.*x>=s+k.*m)&(k>epsilon));
if any(k2),
  F(k2)=ones(size(k2));
end

k3 = find(s<=0 );
if any(k3),
   tmp   = NaN;
   F(k3) = tmp(ones(size(k3)));
end
return

% old call
epsilon=1e-4;
if abs(k) < epsilon, 
  p = exp(-exp(-(x-m)/s));
else 
  if k>0 
    p=ones(size(x)); 
    p=p.*(x>=s/k+m)+(x<s/k+m).*...
	exp(-(1-k*(x-m)/s).^(1/k));
  else 
    p=zeros(size(x));
    p=(x>s/k+m).*...
	exp(-(1-k*(x-m)/s).^(1/k));
  end
end
