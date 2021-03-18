function F = wexpcdf(x,m);
%WEXPCDF Exponential cumulative distribution function
%
% CALL:  F = wexpcdf(x,m);
%
%        F = distribution function evaluated at x
%        m = mean
%
% The Exponential distribution is defined by its cdf
%
%        F(x)=1-exp(-x/m), x>=0, m>0.
% 
% Example: 
%   x = linspace(0,6,200);
%   p1 = wexpcdf(x,1); p2 = wexpcdf(x,2);
%   plot(x,p1,x,p2)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab Dec2003
% fixed abug: k1 ->k3
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 15.06.2000

error(nargchk(2,2,nargin))
[errorcode x m] = comnsize(x,m);
if errorcode > 0
    error('x and m must be of common size or scalar.');
end

% Initialize f to zero.
F = zeros(size(x));

k=find(x >= 0 & m>0);
if any(k),
  F(k)=1-exp(-x(k)./m(k));
end

k3 = find(m<=0);     
if any(k3)
  tmp = NaN;
  F(k3) = tmp(ones(size(k3)));
end
