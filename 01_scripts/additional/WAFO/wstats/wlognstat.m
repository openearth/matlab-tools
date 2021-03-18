function [m,v]= wlognstat(m0,v0);
%WLOGNSTAT Mean and variance for the Lognormal distribution.
% 
% CALL:  [m,v] = wlognstat(m0,v0)
%
%   m, v = the mean and variance, respectively 
% m0, v0 = parameters of the Lognormal distribution.
%
%  Mean (m) and variance (v) for the Lognormal distribution is
%
%  m=exp(m0+v0/2)  and  v=exp(2*m0+v0)*(exp(v0)-1);
%
% Example:
%   [m,v] = wlognstat(0,1)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.



% Tested on; Matlab 5.3
% History:
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
% added ms 10.08.2000

error(nargchk(0,2,nargin))
if nargin<1|isempty(m0),  m0=0;  end
if nargin<2|isempty(v0),  v0=1;  end

[errorcode, m0, v0] = comnsize (m0, v0);
if (errorcode > 0)
  error ('m and v must be of common size or scalar');
end

m = zeros(size(m0));
v = m;
k = find(v0>=0);
if any(k),
  m(k) = exp(m0(k)+v0(k)/2);
  v(k) = exp(2*m0(k)+v0(k)).*(exp(v0(k))-1);
end
k1 = find(v0<0);
if any(k1),
  tmp=NaN;
  m(k1) = tmp(ones(size(k1)));
  v(k1) = m(k1);
end


