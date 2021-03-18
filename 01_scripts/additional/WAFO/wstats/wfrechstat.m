function [m,v]= wfrechstat(a,c);
%WFRECHSTAT Mean and variance for the Frechet distribution.
% 
% CALL:  [m,v] = wfrechstat(a,c)
%
%   m, v = the mean and variance, respectively 
%   a, c = parameters of the Frechet distribution (see wfrechcdf).
%
%  Mean (m) and variance (v) for the Frechet distribution is
%
%  m=a*gamma(1-1/c)  (if c>1) and  v=a^2*(gamma(1-2/c))-m^2  (if c>2)
%
% Example:
%   [m,v] = wweibstat(4,0.5)
%
% See also  wfrechcdf


% Reference: 


% Tested on; Matlab 5.3
% History: 
% Added PJ 10-May-2001

error(nargchk(2,2,nargin))

[errorcode, a, c] = comnsize(a,c);

if errorcode > 0
    error('a and c must be of common size or scalar.');
end

%   Initialize Mean and Variance to zero.
m = zeros(size(a));
v = zeros(size(a));

%ok = (a > 0 & c > 0);
ok1 = (a > 0 & c > 1);
ok2 = (a > 0 & c > 2);

k = find(ok1);
if any(k)
  m(k) =  a(k) .* gamma(1 - (1 ./ c(k)));
end

k = find(ok2);
if any(k)
  v(k) = a(k) .^ 2 .* gamma(1 - (2 ./ c(k))) - m(k).^ 2;
end

k1 = find(~ok1);
if any(k1)
    tmp = NaN;
    m(k1) = tmp(ones(size(k1)));
end

k1 = find(~ok2);
if any(k1)
    tmp = NaN;
    v(k1) = tmp(ones(size(k1)));
end
