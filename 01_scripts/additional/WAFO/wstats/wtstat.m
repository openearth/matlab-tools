function [m,v]= wtstat(a);
%WTSTAT Mean and variance for the Student's T  distribution.
% 
% CALL:  [m,v] = wtstat(df)
%
%   m, v = the mean and variance, respectively 
%   df   = degrees of freedom of the Student's T distribution
%
%  Mean (m) and variance (v) for the T distribution is
%
%  m=0 if df>1  and  v=df/(df-2) if df>2
%
% See also  wtpdf


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% by pab 23.10.2000

error(nargchk(1,1,nargin))

%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

ok = (a > 0 & floor(a)==a);
k = find(a>2 & ok);
if any(k)
  v(k) = a(k)./(a(k)-2);
end

k1 = find(~ok | a<=1);
if any(k1)
  tmp = NaN;
  m(k1) = tmp(ones(size(k1)));
end
  k1 = find(~ok | a<=2);
if any(k1)
  tmp = NaN;
  v(k1) = tmp(ones(size(k1)));   
end


