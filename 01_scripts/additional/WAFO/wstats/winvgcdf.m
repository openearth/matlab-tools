function F = winvgcdf(x,m,l);
%WINVGCDF Inverse Gaussian cumulative distribution function
%
% CALL:  F = winvgcdf(x,m,l);
%
%        F = distribution function evaluated at x
%      m,l =parameters
%
% The Inverse Gaussian distribution is defined by its pdf
%
%        f(x)=(l/(2*pi*x^3))^(1/2)*exp(-l*(x-m)^2/(2*m^2*x)), x>0.
%
% Example: 
%   x = linspace(0,3,200);
%   p1 = winvgcdf(x,1,1); p2 = winvgcdf(x,1,.25);
%   plot(x,p1,x,p2)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 259 ff, Marcel Dekker.



% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 14.08.2000

error(nargchk(3,3,nargin))
%if nargin<2|isempty(m),  m=0;  end
%if nargin<3|isempty(l),  l=1;  end

[errorcode, x, m, l] = comnsize (x,m, l);
if (errorcode > 0)
  error ('x, m and l must be of common size or scalar');
end

F=zeros(size(x));
ok=((m>0)&(l>0));

k=find(x>0& ok);
if any(k)
  F(k)=(wnormcdf((l(k)./x(k)).^(1/2).*(x(k)./m(k)-1),0,1)+...
      exp(2*l(k)./m(k)).*wnormcdf(-(l(k)./x(k)).^(1/2).*(x(k)./m(k)+1),0,1));
end

k1 = find (~ok);
if any (k1)
  tmp=NaN;
  F(k1) = tmp(ones(size(k1)));
end




