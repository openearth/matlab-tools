function [m,v]= wweibstat(a,c);
%WWEIBSTAT Mean and variance for the Weibull  distribution.
% 
% CALL:  [m,v] = wweibstat(a,c)
%
%   m, v = the mean and variance, respectively 
%   a, c = parameters of the Weibull distribution (see wweibcdf).
%
%  Mean (m) and variance (v) for the Weibull distribution is
%
%  m=a*gamma(1+1/c)  and  v=a^2*gamma(1+2/c)-m^2;
%
% Example:
%   [m,v] = wweibstat(4,0.5)
%
% See also  wweibcdf


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 25 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 23.10.2000
%   - added comnsize
% added ms 15.06.2000

error(nargchk(2,2,nargin))

[errorcode, a, c] = comnsize(a,c);

if errorcode > 0
    error('a and c must be of common size or scalar.');
end

%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

ok = (a > 0 & c > 0);
k = find(ok);
if any(k)
  m(k) =  a(k) .* gamma(1 + (1 ./ c(k)));
  v(k) = a(k) .^ 2 .* gamma(1 + (2 ./ c(k))) - m(k).^ 2;
end

k1 = find(~ok);
if any(k1)
    tmp = NaN;
    m(k1) = tmp(ones(size(k1)));
    v(k1) = m(k1);   
end
