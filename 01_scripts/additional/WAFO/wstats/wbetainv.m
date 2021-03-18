function x = wbetainv(F,a,b)
%WBETAINV  Inverse of the Beta distribution function
%
% CALL:  x = wbetainv(F,a,b)
%
%  x   = inverse cdf for the Beta distribution evaluated at F.
% a, b = distribution parameters
%
% Example:
%   F = linspace(0,1,100);
%   x = wbetainv(F,1,2);
%   plot(F,x)

% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize
% -refined the Newton-Raphson method
%       Anders Holtsberg, 27-07-95
%       Copyright (c) Anders Holtsberg

error(nargchk(3,3,nargin))
[errorcode F,a,b] = comnsize(F,a,b);
if errorcode>0,
  error('x, a and b must be of common size or scalar');
end

x = zeros(size(F));

ok = (a>0 & b>0);

k = find(F>0 & F<1 & ok);
if any(k)
 
  bk = b(k); %min(b(k),100000);
  if any(bk>10^5), warning('b is too large'),end
  ak = a(k);
  Fk = F(k);
  xk = max(min(ak ./ (ak+bk),1-sqrt(eps)),sqrt(eps));
 
  dx = ones(size(xk));
  max_count=100;
  ix = find(xk); iy=0;
  while (any(ix) & iy<max_count),
    iy=iy+1;
    xi=xk(ix);ai=ak(ix);bi=bk(ix);
    dx(ix) = (wbetacdf(xi,ai,bi) - Fk(ix)) ./wbetapdf(xi,ai,bi);
    dx(ix)= min(abs(dx(ix)),.5/iy).*sign(dx(ix));
    xi = xi - dx(ix);
    
    % Make sure that the current guess is larger than zero and less than 1
    xk(ix) = xi + 0.1*(dx(ix) - 9*xi).*(xi<=0) +...
	0.38*(dx(ix)-6.2*xi +6.2).*(xi>=1) ;
    
    ix=find((abs(dx) > sqrt(eps)*abs(xk))  &  abs(dx) > sqrt(eps));
        disp(['Iteration ',num2str(iy),...
        '  Number of points left:  ' num2str(length(ix)) ]),
  end
 
  x(k)=xk;
  if iy == max_count, 
    warning('wbetainv did not converge.');
    str = ['The last step was less than:  ' num2str( max(abs(dx(ix))) )];
    disp(str);
    k(ix)
  end
end


k2=find(F==1&ok);
if any(k2)
  x(k2)=ones(size(k2));
end

k3=find(~ok);
if any(k3)
  tmp=NaN;
  x(k3)=tmp(ones(size(k3)));
end






