function F = wchi2cdf(x,p);
%WCHI2CDF Chi squared cumulative distribution function
%
% CALL:  F = wchi2cdf(x,p);
%
%        F = distribution function evaluated at x
%        p = degrees of freedom
%
% The Chi squared distribution is defined by its pdf
%
%   f(x)=x^(p/2-1)*exp(-x/2)/gamma(p/2)/2^(p/2), x>=0, p=1,2,3,...
%
% Example: 
%   x = linspace(0,15,200);
%   p1 = wchi2cdf(x,2); p2 = wchi2cdf(x,3);
%   plot(x,p1,x,p2)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 415 ff
% Wiley

% Tested on; Matlab 5.3
% History:
% revised pab 25.10.2000
%  - added comnsize, nargchk
% added ms 26.06.2000

error(nargchk(2,2,nargin))
[errorcode,x,p] = comnsize(x,p);
if errorcode > 0
  error('x and p must be of common size or scalar.');
end


% old call
%F= gammainc(x/2,p/2).*(x>=0);
F = zeros(size(x));
ok= ((p >0)& p==round(p) );

k=find(x > 0 & ok);
if any(k),
  F(k)= gammainc(x(k)/2,p(k)/2);
end

%   Return NaN if the arguments are outside their respective limits.
k3 = find(~ok);     
if any(k3)
  warning('p should be a positive integer')
  tmp = NaN;
  F(k3) = tmp(ones(size(k3)));
end

