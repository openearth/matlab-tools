function x = wgpdinv(F,k,s,m)
%WGPDINV Inverse of the Generalized Pareto distribution function
%
% CALL:  x = wgpdinv(F,k,s,m)
%
%           x = inverse cdf for the GPD evaluated at F		 
%           k = shape parameter in the GPD
%           s = scale parameter in the GPD    (default 1)
%           m = location parameter in the GPD (Default 0)
%
% The Generalized Pareto distribution is defined by its cdf
%
%                1 - (1-k(x-m)/s)^1/k,  k~=0
%  F(x;k,s,m) =
%                1 - exp(-(x-m)/s),  k==0
% 
%  for x>m (when k<=0) and m<x<s/k (when k>0), s>0.
%
% Example:
%   F = linspace(0,1,100);
%   x = wgpdinv(F,0.3,2);
%   plot(F,x)
%
% See also  wgpdrnd, wgpdfit

% References 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 1. Wiley. 

% Tested on: Matlab 5.3
% History: 
% Revised by jr 22.12.1999
% revised ms 14.06.2000
% - updated header info
% - changed name to wgpdinv (from gpdinv)
% revised pab 25.10.2000
% - adde nargchk + comnsize
error(nargchk(2,4,nargin))

if nargin<4|isempty(m), m=0;end
if nargin<3|isempty(s), s=1;end

[errorcode F k s,m] = comnsize(F,k,s,m);
if errorcode > 0
  error('x, k, s and m must be of common size or scalar.');
end

epsilon=1e-4;
% Initialize  x to zero.
x = zeros(size(k));

epsilon=1e-4;

ok = (F>=0 & F<=1 & s>0);

k1 = find(abs(k)<= epsilon & ok);
if any(k1)
  x(k1) = m(k1) - s(k1).*log(1-F(k1));
end

k2 = find(abs(k)> epsilon & ok);
if any(k2)
  x(k2) = m(k2) + s(k2).*(1-(1-F(k2)).^k(k2))./k(k2);
end

k6=find(~ok);
if any(k6),
  tmp=NaN;
  x(k6)=tmp(ones(size(k6)));
end
