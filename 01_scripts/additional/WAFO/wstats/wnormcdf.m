function F = wnormcdf(x,m,v);
%WNORMCDF Normal cumulative distribution function
%
% CALL:  F = wnormcdf(x,m,v);
%
%        F = distribution function evaluated at x
%        m = mean     (default 0)
%        v = variance (default 1)
% 
% Example: 
%   x = linspace(-3,3,200);
%   p1 = wnormcdf(x,0,1); p2 = wnormcdf(x,.5,0.25);
%   plot(x,p1,x,p2)


% Tested on; Matlab 5.3
% History:
% revised pab 23.03.2003
% -changed call from erf to erfc in order 
%  to get more accurate lower probabilities
% -added a fix up for a bug in erfcore   
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

F=zeros(size(x));

k = find (v>0);
if any(k) 
  z    = -(x(k)-m(k))./sqrt(2*v(k));
  F(k) = 0.5.*erfc(z);
  % fix up for a bug in erfcore (Matlab R11 and earlier)
  F(k(isnan(z))) = NaN;
end

k1 = find (v<=0);
if any (k1)
  tmp=NaN;
  F(k1) = tmp(ones(size(k1)));
end
