function y = weib2dpdf(x1,x2,a1,b1,a2,b2,c12,condon)
%WEIB2DPDF 2D Weibull probability density function (pdf).
%
%  CALL:  f = weib2dpdf(x1,x2,param,condon)
%
%     f    = PDF evaluated at x1 and x2.
%    x1,x2 = coordinates
%    param = [ A1, B1,A2,B2,C12] the parameters of the distribution
%   condon = 0 it returns the the regular pdf of X1 and X2 (default)
%            1 it returns the conditional pdf given X1
%            2 it returns the conditional pdf given X2
%
%   The size of f is the common size of the input arguments X1 and X2. A scalar input
%   functions as a constant matrix of the same size as the other inputs.
%   The PDF is defined by:
%
%  f(X1,X2)=B1*B2*xn1^(B1-1)*xn2^(B2-1)/A1/B1/N*...
%           exp{-[xn1^B1 +xn2^B2 ]/N }*I0(2*C12*xn1^(B1/2)*xn2^(B2/2)/N) 
%   where 
%      N=1-C12^2, xn1=X1/A1,  xn2=X2/A2 and 
%      I0 is the modified  bessel function of zeroth order.
%
%  (The marginal distribution of X1 is weibull with parameters A1 and B1) 
%  (The marginal distribution of X2 is weibull with parameters A2 and B2) 
%  (C12 is the interaction parameter between X1 and X2)
%
%Example: 
%  x = linspace(0,6,200); [X1 X2]=meshgrid(x);
%  f = weib2dpdf(X1,X2,[2 2  3 2.5 .8]);
%  mesh(x,x,f),
%  figure(2), contour(x,x,f)
%
% See also  weib2dcdf, wweibpdf, besseli

 

%   References:
%     Dag Myrhaug & Håvard Rue
%  Journal of Ship Research, Vol 42, No3, Sept 1998, pp 199-205 

%Tested on: matlab 5.2
% History:
%  by Per A. Brodtkorb 13.11.98



error(nargchk(3,8,nargin))
if nargin < 3, 
  error('Requires 3 input arguments.'); 
elseif ((nargin < 7) &(prod(size((a1)))~=5)|isempty(a1)),
  error('Requires either 7 input arguments or that input argument 3 must have 5 entries .'); 
elseif (nargin < 5) &prod(size((a1)))==5,
  if nargin<4|isempty(b1),  condon=0;else  condon=b1;  end
  b1=a1(2);
  a2=a1(3);  b2=a1(4);    
  c12=a1(5); a1=a1(1); 
elseif (nargin < 8)|isempty(condon), 
  condon=0; %
end


  
[errorcode x1, x2, a1,b1,a2, b2, c12] = comnsize(x1,x2,a1,b1,a2,b2,c12);
if errorcode > 0
  error('Requires non-scalar arguments to match in size.');
end
xs=size(x1); 
%if ndims(x1)>2, % make sure they have the right shape
%  a1=reshape(a1,xs);a2=reshape(a2,xs);b1=reshape(b1,xs);b2=reshape(b2,xs);
%  c12=reshape(c12,xs);
%end

y = zeros(xs);

ok = ((a1 > 0) .*(b1 > 0).*(a2 > 0).*(b2 > 0).*(abs(c12)<1));
  
k1 = find(~ok);
if any(k1)
   tmp   = NaN;
   y(k1) = tmp(ones(size(k1)));
end

k = find((x2 > 0).*(x1 > 0) & ok);
if any(k),
  %scales bessel with exp(-abs(x))  to avoid overflow 
  [y(k) ierr] =besseli(0,2*c12(k).*((x1(k)./a1(k)).^(b1(k)/2).*....
      (x2(k)./a2(k)).^(b2(k)/2))./(1-c12(k).^2),1 );
  
  switch ierr(1),
    case 0, %computation OK
    case 1, error('Illegal arguments.')
    case 2, disp('Overflow.  Return Inf.')
    case 3, disp('Some loss of accuracy in argument reduction.')
    case 4, error('Complete loss of accuracy, z or nu too large.')
    case 5, error('No convergence.  Return NaN.')
  end
  y(k)=log(y(k));
  
  switch condon
    case 0,%regular pdf
      y(k)=exp(- ((x1(k)./a1(k)).^b1(k) +(x2(k)./a2(k)).^b2(k) ...
	  -abs(2*c12(k).*((x1(k)./a1(k)).^(b1(k)/2).*...
	  (x2(k)./a2(k)).^(b2(k)/2))))./(1-c12(k).^2)  +y(k) ) ...
	  .*b1(k).*(x1(k)./a1(k)).^(b1(k)-1)./a1(k).*b2(k).*...
	  (x2(k)./a2(k)).^(b2(k) - 1) ./a2(k)./(1-c12(k).^2);
    case 1, %pdf conditioned on x1 ie. p(x2|x1)     
       y(k) =exp(- (c12(k).*(x1(k)./a1(k)).^(b1(k)/2) - ...
	   (x2(k)./a2(k)).^(b2(k)/2)).^2./(1-c12(k).^2 ) +y(k)  )...
	   .*(b2(k)./(a2(k).*(1-c12(k).^2))).*(x2(k)./a2(k)).^(b2(k) - 1);
     case 2,%pdf conditioned on x2 ie. p(x1|x2)
        y(k)=exp(- ((x1(k)./a1(k)).^(b1(k)/2) -c12(k).*...
	    (x2(k)./a2(k)).^(b2(k)/2)).^2./(1-c12(k).^2)  +y(k) )...
	  .*(b1(k)./(a1(k).*(1-c12(k).^2))).*(x1(k)./a1(k)).^(b1(k)-1);
    case 3, % secret option  used by weib2dstat: returns x1*p(x1|x2) 
      y(k)=x1(k).*exp(- ((x1(k)./a1(k)).^(b1(k)/2) -c12(k).*...
	  (x2(k)./a2(k)).^(b2(k)/2)).^2./(1-c12(k).^2)  +y(k) )...
	  .*(b1(k)./(a1(k).*(1-c12(k).^2))).*(x1(k)./a1(k)).^(b1(k)-1);
    case 4, % secret option  used by weib2dstat: returns x1^2*p(x1|x2) 
      y(k)=x1(k).^2.*exp(- ((x1(k)./a1(k)).^(b1(k)/2) -c12(k).*...
	  (x2(k)./a2(k)).^(b2(k)/2)).^2./(1-c12(k).^2)  +y(k) )...
	  .*(b1(k)./(a1(k).*(1-c12(k).^2))).*(x1(k)./a1(k)).^(b1(k)-1);
    otherwise , error('Illegal value for CONDON')
  end

  kc=find(isinf(y(k)));
  if any(kc), 
    disp('Computational problem occured: returning NaNs') ;   
    y(k(kc))=NaN;
  end
end

% Special case for asymptotes.
switch condon
  case 0,k1 = find( (x1 == 0 & b1 < 1& x2>0)|( x2 == 0 & b2 < 1& x1>0 )|  ...
	( x1==0 & x2 == 0 & b1 < 1& b2+b1-2<0)    );
  case 1, k1 = find( x2 == 0 & b2 < 1 );
  case {2},  k1 = find( x1 == 0 & b1 < 1 );
  case {3,4}, k1=[]; %do nothing
end
if any(k1)
  tmp   = Inf;
  y(k1) = tmp(ones(size(k1)));
end

% Special case when the marginal Weibull is the same as exponential. 
switch condon,
  case 0, 
    k2 = find((x1 == 0 & b1 == 1&x2>0)  );
    if any(k2),
      y(k2) =  b2(k2) .* (x2(k2)./a2(k2)).^ (b2(k2) - ...
	  1)./a2(k2)./(1-c12(k2).^2)./a1(k2).*....
	  exp(- (  (x2(k2)./a2(k2)) .^ b2(k2) )./(1-c12(k2).^2)   );
    end
    k3 = find((x2 == 0 & b2 == 1&x1>0)  );
    if any(k3),
      y(k3) = b1(k3) .* (x1(k3)./a1(k3)).^ (b1(k3) - ...
	  1)./a1(k3)./a2(k3)./(1-c12(k3).^2).*...
	  exp(- ((x1(k3)./a1(k3)) .^ b1(k3)  )./(1-c12(k3).^2)   );
    end
    k4 = find( x1==0 & x2==0 & b1 == 1& b2==1)   ;
    if any(k4),
      y(k4) = 1./(a1(k4).*a2(k4).*(1-c12(k4).^2));
    end
    
  case 1, 
    k3 = find(x2 == 0 & b2 == 1  ); 
    if any(k3),
      y(k3) = exp(- (c12(k3).^2.*(x1(k3)./a1(k3)) .^ b1(k3) ...
	  )./(1-c12(k3).^2)   )./a2(k3)./(1-c12(k3).^2) ;
    end
    
  case {2}, 
    k3 = find(x1 == 0 & b1 == 1  ); 
    if any(k3),
      y(k3) = exp(- (c12(k3).^2.*(x2(k3)./a2(k3)) .^ b2(k3) ...
	  )./(1-c12(k3).^2)   )./a1(k3)./(1-c12(k3).^2) ;
    end
  case {3,4}, %do nothing
end






  