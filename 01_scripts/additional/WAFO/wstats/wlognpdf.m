function f = wlognpdf(x,m,v);
%WLOGNPDF Lognormal probability density function
%
% CALL:  f = wlognpdf(x,m,s);
%
%        f = density function evaluated at x
%        m = mean of log(x)     (default 0)
%        v = variance of log(x) (default 1)
%
% The Lognormal distribution is defined by its pdf
%
%     f(x) = exp(-(log(x)-m)^2/(2*v))/sqrt(v*2*pi*x^2), x>=0.
%
% Example: 
%   x = linspace(0,3,200);
%   p1 = wlognpdf(x,0,1); p2 = wlognpdf(x,.5,0.25);
%   plot(x,p1,x,p2)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.

% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
%  - fixed a bug in the parameterization
% added ms 10.08.2000

error(nargchk(1,3,nargin))
if nargin<2|isempty(m),  m=0;  end
if nargin<3|isempty(v),  v=1;  end

[errorcode, x, m, v] = comnsize (x,m, v);
if (errorcode > 0)
  error ('x, m and v must be of common size or scalar');
end

f=zeros(size(x));

k = find (x>0&v>0);
if any(k)    
  f(k)=1./sqrt(2*pi*v(k)).*exp(-0.5*(log(x(k))-m(k)).^2./v(k))./x(k);
end

k1 = find (v<=0);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end




