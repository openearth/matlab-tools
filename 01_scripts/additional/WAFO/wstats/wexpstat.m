function [m,v]= wexpstat(m0);
%WEXPSTAT Mean and variance for the Exponential distribution.
% 
% CALL:  [m,v] = wexpstat(m0)
%
%   m, v = the mean and variance, respectively 
%     m0 = parameter of the Exponential distribution, m0>0.
%
%  Mean (m) and variance (v) for the Exponential distribution is
%
%  m=m0  and  v=m0^2;
%
% Example:
%   [m,v] = wexpstat(5)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History:
% revised pab Dec2003
% fixed a bug k1->k3
% revised pab 24.10.2000
%  - added  nargchk
% added ms 15.06.2000

error(nargchk(1,1,nargin))

% Initialize fm to zero.
m = zeros(size(m0));
v=m;

k=find(m0 > 0);
if any(k),
  m(k) =  m0(k);
  v(k) = m0(k).^2;
end

k3 = find(m0<0 );     
if any(k3)
  tmp = NaN;
  m(k3) = tmp(ones(size(k3)));
  v(k3)=m(k3);
end

