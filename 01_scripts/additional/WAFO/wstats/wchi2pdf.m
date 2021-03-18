function f = wchi2pdf(x,p,disable);
%WCHI2PDF Chi squared probability density function
%
% CALL:  f = wchi2pdf(x,p);
%
%        f = density function evaluated at x
%        p = degrees of freedom
% 
% The Chi squared distribution is defined by its pdf
%   f(x)=x^(p/2-1)*exp(-x/2)/gamma(p/2)/2^(p/2), x>=0, p=1,2,3,...
% The CHI^2 is a special case of the gamma distribution, i.e.:
%   wchi2pdf(x,p)=wgampdf(x,p/2,2)
%
% Example: 
% x = linspace(0,7,200);
% p1 = wchi2pdf(x,2); p2 = wchi2pdf(x,3);
% plot(x,p1,x,p2)
%
% See also wgampdf

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 415 ff
% Wiley


% Tested on: Matlab 5.3
% History:
% revised pab 25.10.2000
%  - added comnsize, nargchk
%  - replaced code with a call to wggampdf -> made maintanence easier
% added ms 15.06.2000


error(nargchk(2,3,nargin))
% secret option in order to make ML estimation work
if nargin<3|isempty(disable), disable=0;end 

[errorcode,x,p,b,c] = comnsize(x,p,2,1);
if errorcode > 0
  error('x and p must be of common size or scalar.');
end

f=zeros(size(x));
if disable,
  ok = (p>0);
else
  ok = (p==round(p) & p>0)
end
k = find(ok);
if any(k),
  f(k) = wggampdf(x(k),p(k)/2,b(k),c(k));
  %f=x.^(p/2-1).*exp(-x/2)/gamma(p/2)/2^(p/2).*(x>=0);
end

k1=find(~ok);
if any(k1),
  warning('p should be a positive integer')
  f(k1)=NaN;
end






