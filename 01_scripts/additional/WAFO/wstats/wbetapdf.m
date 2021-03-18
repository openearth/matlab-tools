function f = wbetapdf(x,a,b)
%WBETAPDF   Beta probability density function
%
% CALL:  f = wbetapdf(x,a,b);
%
%    f = density function evaluated at x
%  x   = matrix
% a, b = distribution parameters
%
%  The PDF is defined by:
%
%   f = x^(a-1)*(1-x)^(b-1)/H(a,b)    0<= x <= 1, a>0, b>0
% 
% where H(a,b) is a normalization constant.
% Example: 
%   x = linspace(0,1,200);
%   p1 = wbetapdf(x,1,1); p2 = wbetapdf(x,2,2);
%   plot(x,p1,x,p2)


% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize
%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg




error(nargchk(3,3,nargin))
[errorcode x,a,b] = comnsize(x,a,b);
if errorcode>0,
  error('x, a and b must be of common size or scalar');
end

f = zeros(size(x));

ok = (a>0 & b>0);

k = find(x>=0&x<=1 & ok);
if any(k)
  f(k) = x(k).^(a(k)-1) .* (1-x(k)).^(b(k)-1) ./ beta(a(k),b(k));
end




k=find(~ok);
if (any(k)),
  F(k)=NaN;
end
