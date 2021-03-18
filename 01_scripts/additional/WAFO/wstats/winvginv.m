function x = winvginv(F,m,l)
%WINVGINV Inverse of the Inverse Gaussian distribution function
%
% CALL:  x = winvginv(F,m,l)
%
%        x = inverse cdf for the Inverse Gaussian distribution evaluated at F
%     m,l  = parameters (see winvgpdf)
%
% Example:
%   x = linspace(0,1,200);
%   p1 = winvginv(x,1,1); p2 = winvginv(x,1,.25);
%   plot(x,p1,x,p2)

% Reference: 
% Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 259 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% adapted from stixbox ms 14.08.2000
% ad hoc solutions to improve convergence added ms 15.08.2000
% revised pab 25.10.2000
% - added nargchk + comnsize
% - changed the ad hoc solutions a bit

error(nargchk(3,3,nargin))
%if nargin<2|isempty(m),  m=0;  end
%if nargin<3|isempty(l),  l=1;  end

[errorcode, F, m, l] = comnsize (F,m, l);
if (errorcode > 0)
  error ('F, m and l must be of common size or scalar');
end

x=zeros(size(F));
ok=(F>=0 & F<=1 &(m>0&(l>0)));

k=find((F>0)&(F<1) & ok);
if any(k)
  mk=m(k);lk=l(k);  Fk=F(k);
  % Need  a better starting guess here for 
  %  1) l<1 and F close to 1
  %  2) l>5 and F close to 1 or 0
  % Supply a starting guess
  [mk,v]=winvgstat(mk,lk);
  temp = log(v + mk .^ 2); 
  mu = 2 * log(mk) - 0.5 * temp;
  sa = -2 * log(mk) + temp;
  xk = wlogninv(Fk,mu,sa);
  if 0, % old starting guess
    x1=linspace(0.01*v^(1/2),4*v^(1/2),100);
    F1=winvgcdf(x1,mk,lk);
    for i=1:length(Fk);
      k3=find(Fk(i)<F1);
      if ~isempty(k3)
	xstart(i)=x1(min(k3));
      else
	xstart(i)=4*v^(1/2);
      end
    end
  end
  
  
  dx = ones(size(xk));
  iy=0;
  ix =find(xk);
  count=1;  max_count=100;
  mstep=2*sqrt(v); % maximum step in each iteration
  while (any(ix)&(count<max_count));
    count=count+1;
    xi=xk(ix);mi=mk(ix);li=lk(ix);
    dx(ix) = (winvgcdf(xi,mi,li) - Fk(ix))./winvgpdf(xi,mi,li);
    dx(ix) = min(abs(dx(ix)),mstep(ix)/count).*sign(dx(ix)); 
    xi = xi - dx(ix);
    % Make sure that the current guess is larger than zero.
    xk(ix) = xi + 0.5*(dx(ix) - xi) .* (xi<=0);
    
    ix=find((abs(dx) > sqrt(eps)*abs(xk))  &  abs(dx) > sqrt(eps));
    disp(['Iteration ',num2str(count),...
    '  Number of points left:  ' num2str(length(ix)) ]),
  end

  if (count==max_count)
    disp('Warning: WINVGINV did not converge!')
    disp(['The last steps were all less than: ' num2str(max(abs(dx(ix))))])
    k(ix) % index to 
  end

  x(k)=xk;
end

k1=find(F==1&ok);
if any(k1)
  tmp=Inf;
  x(k1)=tmp(ones(size(k1)));
end

k2=find(~ok);
if any(k1)
  tmp=NaN;
  x(k2)=tmp(ones(size(k2)));
end




