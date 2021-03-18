function F = wbetacdf(x,a,b)
%WBETACDF   Beta cumulative distribution function
%
% CALL:  F = wbetacdf(x,a,b);
%
%        F = distribution function evaluated at x
%        x = matrix
%      a,b = distribution parameters
%
%  It is defined by its PDF:
%
%   f = x^(a-1)*(1-x)^(b-1)/H(a,b)    0<= x <= 1, a>0, b>0
% 
% where H(a,b) is a normalization constant.
%   
% Example: 
%   x = linspace(0,1,200);
%   p1 = wbetacdf(x,1,1); p2 = wbetacdf(x,2,2);
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

F = zeros(size(x));

ok = (a>0 & b>0);

Ii = find(x>0&x<1 & ok);
if any(Ii)
   F(Ii) = betainc(x(Ii),a(Ii),b(Ii));
end

Iu = find(x>=1);
if any(Iu)
  F(Iu) = ones(size(Iu));
end

k=find(~ok);
if (any(k)),
  F(k)=NaN;
end





