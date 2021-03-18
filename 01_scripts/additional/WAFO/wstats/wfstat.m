function [m,v]= wfstat(a,c);
%WFSTAT Mean and variance for the Snedecor's F distribution.
% 
% CALL:  [m,v] = wfstat(df1,df2)
%
%   m,  v   = the mean and variance, respectively 
%  df1, df2 = degrees of freedom of the F distribution
%
%  Mean (m) and variance (v) for the F distribution is
%
%      m = df2/(df2-1)                  if df2>2  
% and  
%      v=2*m^2*(df1+df2-2)/(df2-4)/df1  if df2>4
%
% See also  wfpdf


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% by pab 23.10.2000

error(nargchk(2,2,nargin))
[errorcode, a, c] = comnsize(a,c);
if errorcode > 0
    error('df1 and df2 must be of common size or scalar.');
end


%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

ok = (a > 0 & floor(a)==a & c > 0 & floor(c)==c );
k = find(c>2 & ok);
if any(k)
  m(k) = c(k)./(c(k)-2);
end

k = find(c>4 & ok);
if any(k)
  m(k) = 2*m(k).^2.*(c(k)+a(k)-2)./(c(k)-4)./a(k);
end

k1 = find(~ok | c<=2);
if any(k1)
  tmp = NaN;
  m(k1) = tmp(ones(size(k1)));
end
k1 = find(~ok | c<=4);
if any(k1)
  tmp = NaN;
  v(k1) = tmp(ones(size(k1)));   
end


