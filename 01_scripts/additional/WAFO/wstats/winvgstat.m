function [m,v]= winvgstat(m0,l0);
%WINVGSTAT Mean and variance for the Inverse Gaussian distribution.
% 
% CALL:  [m,v] = winvgstat(m0,l0)
%
%   m, v = the mean and variance, respectively 
% m0, l0 = parameters of the Inverse Gaussian distribution (see winvgpdf)
%
%  Mean (m) and variance (v) for the Inverse Gaussian distribution is
%
%  m=m0  and  v=m0^3/l0;
%
% Example:
%   [m,v] = winvgstat(10,100)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 259 ff, Marcel Dekker.

% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 14.08.2000

error(nargchk(2,2,nargin))
%if nargin<1|isempty(m0),  m0=0;  end
%if nargin<2|isempty(l0),  l0=1;  end

[errorcode, m0, l0] = comnsize (m0, l0);
if (errorcode > 0)
  error ('m and l must be of common size or scalar');
end

m = zeros(size(m0));
v = m;

ok =((m0>0)&(l0>0));  
k = find(ok);
if any(k),
  m(k) = m0(k);
  v(k) = m0(k).^3./l0(k);
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  m(k1) = tmp(ones(size(k1)));
  v(k1)=m(k1);
end
