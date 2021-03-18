function f = wgampdf(x,a,b);
%WGAMPDF Gamma probability density function
%
% CALL:  f = wgampdf(x,a,b);
%
%        f = density function evaluated at x
%        a = parameter
%        b = parameter (default b=1)
%
% The Gamma distribution is defined by its pdf
% 
%        f(x)=x^(a-1)*exp(-x/b)/gamma(a)/b^a, a,b>0, x>=0.
%
% Example: 
%   x = linspace(0,7,200);
%   p1 = wgampdf(x,1); p2 = wgampdf(x,2);
%   plot(x,p1,x,p2)
%
% See also  wggampdf

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - replaced code with a call to wggampdf -> maintainance easier.
% added ms 26.06.2000
% added b parameter ms 23.08.2000

error(nargchk(2,3,nargin))

if nargin<3|isempty(b),  b=1; end

[errorcode x a b c] = comnsize(x,a,b,1);

if errorcode > 0
  error('x, a and b must be of common size or scalar.');
end
f = wggampdf(x,a,b,c);



