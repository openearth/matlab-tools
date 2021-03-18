function f = wnormpdf(x,m,v);
%WNORMPDF Normal probability density function
%
% CALL:  f = wnormpdf(x,m,v);
%
%        f = density function evaluated at x
%        m = mean     (default 0)
%        v = variance (default 1)
% 
% Example: 
%   x = linspace(-3,3,200);
%   p1 = wnormpdf(x,0,1); p2 = wnormpdf(x,.5,0.25);
%   plot(x,p1,x,p2)


% Tested on; Matlab 5.3
% History:
% revised pab 9Aug2003
%  fixed a bug: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
% added ms 15.06.2000

error(nargchk(1,3,nargin))
if nargin<2|isempty(m),  m=0;  end
if nargin<3|isempty(v),  v=1;  end

[errorcode, x, m, v] = comnsize (x,m, v);
if (errorcode > 0)
  error ('x, m and v must be of common size or scalar');
end

f=zeros(size(x));

k = find (v>0);
if any(k)    
  f(k)=1./sqrt(2*pi*v(k)).*exp(-0.5*(x(k)-m(k)).^2./v(k));
end

k1 = find (v<=0);
if any (k1)
  tmp=NaN;
  f(k1) = tmp(ones(size(k1)));
end

