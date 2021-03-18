function F = wgpdcdf(x,k,s,m);
%WGPDCDF Generalized Pareto cumulative distribution function
%
% CALL:  F = wgpdcdf(x,k,s,m);
% 
%        F = distribution function evaluated at x
%        k = shape parameter in the GPD
%        s = scale parameter in the GPD    (default 1)
%        m = location parameter in the GPD (default 0)
% 
% The Generalized Pareto distribution is defined by its cdf
%
%                1 - (1-k(x-m)/s)^1/k,  k~=0
%  F(x;k,s,m) =
%                1 - exp(-(x-m)/s),  k==0
%
% for x>=m (when k<=0) and 0 <= x-m < s/k (when k>0), s>0.
%
% Example: 
%   x = linspace(0,2,200);
%   p1 = wgpdcdf(x,1.25,1); p2 = wgpdcdf(x,1,1);
%   p3 = wgpdcdf(x,0.75,1); p4 = wgpdcdf(x,0.5,1);
%   plot(x,p1,x,p2,x,p3,x,p4)
 
% References
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on: Matlab 5.3
% History: 
% Revised pab oct 2005
% - limits m<x<s/k replaced with 0 <= x-m < s/k in help header.
% revised pab June 2005
% - distribution for k==0 was wrong, now fixed
% Revised by jr 22.12.1999
% Modified by PJ 08-Mar-2000
%   Hjälptext
% revised ms 14.06.2000
% - updated header info
% - changed name to wgpdcdf (from gpdcdf)
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
  
epsilon = 1e-4; % treshold defining k to zero


F  = zeros(size(x));
xm = x-m;
k0 = find((0 < xm) & (abs(k)<=epsilon) & (0<s));
if any(k0),
  F(k0) = 1-exp(-xm(k0)./s(k0));
end

k1 = find((0<xm) & (k.*xm < s ) & (abs(k)>epsilon) & (0<s));
if any(k1),
  F(k1) = 1-(1-k(k1).*xm(k1)./s(k1)).^(1./k(k1));
end

k2 = find((k.*xm>=s) & (k>epsilon));
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
if abs(k) < epsilon,  
    p = (x>0).*(1-exp(-x/s));
  elseif k>0, 
    p=(x>=s/k)+(x>0).*(x<s/k).*...
	(1-(1-k*x/s).^(1/k));
  else 
    p=zeros(size(x));
    p=(x>0).*(1-(1-k*x/s).^(1/k));
end;




