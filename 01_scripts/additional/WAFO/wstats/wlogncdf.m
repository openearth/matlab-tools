function F = wlogncdf(x,m,v);
%WLOGNCDF Lognormal cumulative distribution function
%
% CALL:  F = wlogncdf(x,m,s);
%
%        F = distribution function evaluated at x
%      m,v =parameters
%
% The Lognormal distribution is defined by its pdf
%
%        f(x)=(v*2*pi*x^2)^(-1)*exp(-(log(x)-m)^2/(2*v)), x>=0.
%
% Example: 
%   x = linspace(0,6,200);
%   p1 = wlogncdf(x,0,1); p2 = wlogncdf(x,.5,0.25);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.



% Tested on; Matlab 5.3
% History:
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
% added ms 10.08.2000

error(nargchk(1,3,nargin))
if nargin<2|isempty(m),  m=0;  end
if nargin<3|isempty(v),  v=1;  end

[errorcode, x, m, v] = comnsize (x,m, v);
if (errorcode > 0)
  error ('x, m and v must be of common size or scalar');
end
F=zeros(size(x));
k=find(x>0); % avoid log(0)
if any(k)
  F(k)=wnormcdf(log(x(k)),m(k),v(k));
end

