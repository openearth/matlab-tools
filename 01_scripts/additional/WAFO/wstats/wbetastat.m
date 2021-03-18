function [m,v]= wbetastat(a,c);
%WBETASTAT Mean and variance for the Beta distribution.
% 
% CALL:  [m,v] = wbetastat(df1,df2)
%
%   m,  v = the mean and variance, respectively 
%   a,  b = parameters of the Beta distribution
%
%  Mean (m) and variance (v) for the Beta distribution is
%
%      m = a/(a+b) and v = a*b/(a+b)^2/(a+b+1)  if a>0, b>0
%
% See also  wbetapdf


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% by pab 23.10.2000

error(nargchk(2,2,nargin))
[errorcode, a, c] = comnsize(a,c);
if errorcode > 0
    error('a and b must be of common size or scalar.');
end


%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

ok = (a > 0  & c > 0 );
k = find(ok);
if any(k)
  m(k) = a(k)./(a(k)+c(k));
  v(k) = m(k).*c(k)./(a(k)+c(k))./(a(k)+c(k)+1);
end

k1 = find(~ok);
if any(k1)
  warning('a and b should be positive')
  tmp = NaN;
  v(k1) = tmp(ones(size(k1)));
  m(k) = v(k1);
end


