function f = wgpdpdf(x,k,s,m);
%WGPDPDF Generalized Pareto probability density function
%
% CALL:  f = wgpdpdf(x,k,s,m);
% 
%        f = density function evaluated at x
%        k = shape parameter in the GPD
%        s = scale parameter in the GPD    (default 1)
%        m = location parameter in the GPD (default 0)  
% 
% The Generalized Pareto distribution is defined by its cdf
%
%                1 - (1-k(x-m)/s)^1/k,  k~=0
%  F(x;k,s) =
%                1 - exp(-(x-m)/s),  k==0
%
% for x>=m (when k<=0) and 0 <= x-m < s/k (when k>0), s>0.
%
% Example: 
%   x = linspace(0,2,200);
%   p1 = wgpdpdf(x,1.25,1); p2 = wgpdpdf(x,1,1);
%   p3 = wgpdpdf(x,0.75,1); p4 = wgpdpdf(x,0.5,1);
%   plot(x,p1,x,p2,x,p3,x,p4)
 
% References
%  Johnson N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on: Matlab 5.3
% History: 
% Revised pab oct 2005
% - limits m<x<s/k replaced with 0 < x-m < s/k in help header.
% -fixed a bug for k<0 
% revised pab June 2005
% fixed bug for k==0 now fixed
% revised jr 14.08.2001
%  - a bug in the last if-statement condition fixed
%    (thanks to D Eddelbuettel <edd@debian.org>)
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added extra check on the scale parameter s
%  - added m + default values on m and s
% added ms 14.06.2000

error(nargchk(2,4,nargin))

if nargin<4|isempty(m), m=0;end
if nargin<3|isempty(s), s=1;end

[errorcode x k s m] = comnsize(x,k,s,m);
if errorcode > 0
    error('x, k s and m must be of common size or scalar.');
end
epsilon=1e-4; % treshold defining k to zero

xm = x-m;
f = zeros(size(x));

k0 = find((xm>=0) & (abs(k)<=epsilon) & (s>0));
if any(k0), 
   f(k0) = exp(-xm(k0)./s(k0))./s(k0);
end

k1=find((xm>=0) & (k.*xm < s) & (abs(k)>epsilon) & (s>0));
if any(k1),
  f(k1) = (1-k(k1).*xm(k1)./s(k1)).^(1./k(k1)-1)./s(k1);
end

  
k3 = find(s<=0);
if any(k3),
   tmp   = NaN;
   f(k3) = tmp(ones(size(k3)));
end












