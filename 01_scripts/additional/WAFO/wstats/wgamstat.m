function [m,v]= wgamstat(a,b);
%WGAMSTAT Mean and variance for the Gamma distribution.
% 
% CALL:  [m,v] = wgamstat(a,b)
%
%   m, v = the mean and variance, respectively 
%      a = parameter, a>0
%      b = parameter, b>0 (default b=1)
%
%  Mean (m) and variance (v) for the Gamma distribution is
%
%  m=ab  and  v=ab^2;
%
% Example:
%   [m,v] = wgamstat(5,2)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab Dec2003
% fixed a bug: k1 -> k3
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 26.06.2000
% added b parameter ms 23.08.2000

error(nargchk(1,2,nargin))
if nargin<2,  b=1;end
[errorcode a b] = comnsize(a,b);
if errorcode > 0
    error('a and b must be of common size or scalar.');
end

% Initialize  m  and v to zero.
m = zeros(size(a));
v=m;

k=find(a > 0 & b>0);
if any(k),
  m(k) =  a(k).*b(k);
  v(k) = m(k).*b(k);
end

k3 = find(a<=0 | b<=0 );     
if any(k3)
  tmp = NaN;
  m(k3) = tmp(ones(size(k3)));
  v(k3)=m(k3);
end



