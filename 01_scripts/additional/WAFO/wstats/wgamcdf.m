function F = wgamcdf(x,a,b);
%WGAMCDF Gamma cumulative distribution function
%
% CALL:  F = wgamcdf(x,a,b);
%
%        F = distribution function evaluated at x
%        a = parameter
%        b = parameter (default b=1)
%
% The Gamma distribution is defined by its pdf
%
%        f(x)=x^(a-1)*exp(-x/b)/gamma(a)/b^a, a,b>0, x>=0.
%
% Example: 
%   x = linspace(0,7,200);
%   p1 = wgamcdf(x,1); p2 = wgamcdf(x,2);
%   plot(x,p1,x,p2)
%
% See also  wggamcdf

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History:
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 26.06.2000
% added b parameter ms 23.08.2000


error(nargchk(2,3,nargin))

if nargin<3|isempty(b),  b=1; end

[errorcode x a b] = comnsize(x,a,b);

if errorcode > 0
  error('x, a and b must be of common size or scalar.');
end
F = zeros(size(x));

ok= ((a >0) & (b> 0));


k=find(x > 0 & ok);
if any(k),
  F(k)= gammainc(x(k)./b(k),a(k));
end

%   Return NaN if the arguments are outside their respective limits.
k3 = find(~ok);     
if any(k3)
  tmp = NaN;
  F(k3) = tmp(ones(size(k3)));
end







