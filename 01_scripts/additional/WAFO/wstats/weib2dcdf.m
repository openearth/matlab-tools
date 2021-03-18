function [y ,tol1] = weib2dcdf(x1,x2,param,condon,tol)
%WEIB2DCDF Joint 2D Weibull cumulative distribution function  
%
%  CALL: [F tol]= weib2dcdf(x1,x2,param,condon,rtol)
%
%     F    = joint CDF, i.e., Prob(X1<x1 X2<x2)
%    tol   = estimated absolute tolerance
%    x1,x2 = coordinates
%    param = [ A1, B1,A2,B2,C12] the parameters of the distribution
%   condon = 0 it returns the the regular cdf of X1 and X2 (default)
%            1 it returns the conditional cdf given X1
%            2 it returns the conditional cdf given X2
%     rtol = specified relative tolerance (Default 1e-3) 
%
% The size of F is the common size of X1 and X2.
% The CDF is defined by its PDF:
%
%  f(X1,X2)=B1*B2*xn1^(B1-1)*xn2^(B2-1)/A1/B1/N*...
%           exp{-[xn1^B1 +xn2^B2 ]/N }*I0(2*C12*xn1^(B1/2)*xn2^(B2/2)/N) 
%   where 
%      N=1-C12^2, xn1=X1/A1,  xn2=X2/A2 and 
%      I0 is the modified  bessel function of zeroth order.
%
%  (The marginal distribution of X1 is weibull with parameters A1 and B1) 
%  (The marginal distribution of X2 is weibull with parameters A2 and B2) 
%
% Example:
%   x = linspace(0,6,200); [X1,X2] = meshgrid(x); 
%   phat = [2 2  3 2.5 .8];
%   f = weib2dpdf(X1,X2,phat);
%   contour(x,x,f), hold on,
%   plot( [0  2  2 0 0], [0 0 1 1 0],'g-'), hold off % Mark the region
%   weib2dcdf(2,1,phat)  % Calculate the probability of marked region
% 
% See also  weib2dpdf, wweibpdf, quad2dg, gaussq

% tested on: matlab5.1
%history:
% revised pab Dec2003
%  call weibstat -> wweibstat
% revised pab 29.10.2000
% - updated to wstats
% - added example
%  Per A. Brodtkorb 17.11.98

% NB! weibpdf must be modified to correspond to
% pdf=x^(b-1)/a^b*exp(-(x/a)^b) 


error(nargchk(3,5,nargin))
if (nargin <5)| isempty(tol),   tol=1e-3; end
if (nargin <4)| isempty(condon),  condon=0;end
if nargin < 3, 
  error('Requires 3 input arguments.'); 
elseif prod(size((param)))~=5|isempty(param),
   error('input argument 3 must have 5 entries.'); 
else
  a1=param(1);  b1=param(2); 
  a2=param(3);  b2=param(4);    c12=param(5); 
end

[errorcode x1 x2 ] = comnsize(x1,x2);
if  errorcode > 0
  error('Requires non-scalar arguments to match in size.');
end
y = zeros(size(x1));
tol1=y;

if 0
  % This is a trick to get the html documentation correct.
  k = weib2dpdf(1,1,2,3);
end

switch condon
  case 0,% regular cdf   
    k = find( x1 > 0 & x2>0);
    if 1, 
       if any(k), 
	 [y(k) tol1(k)]= quad2dg('weib2dpdf',0,x1(k),0 , x2(k),  tol,a1,b1,a2,b2,c12,condon);  
       end
       
       
     else% divide the integral in to several parts this is not correct yet
      [m1 v1]=wweibstat(a1,b1); [m2 v2]=wweibstat(a2,b2);
       x1s=min(m1,x1); x2s=min(m2,x2);
       if any(k)
	 [y(k) tol1(k)]=quad2dg('weib2dpdf',0,x1s(k),0 , x2s(k),tol/2,param,condon);
       end
       k1=find( x1(k)>m1& x2(k)<=m2);
       if any(k1),
	 [tmp1 tmp2]=quad2dg('weib2dpdf',x1s(k(k1)),  x1(k(k1)),0,   x2s(k(k1)), tol/4,param,condon);
	 y(k(k1)) =y(k(k1))+tmp1;tol1(k(k1))=tol1(k(k1))+tmp2;
       end
       k1=find( x1(k)<=m1& x2(k)>m2);
       if any(k1),
	 [tmp1 tmp2]=quad2dg('weib2dpdf',0,x1s(k(k1)), x2s(k(k1)),   x2(k(k1)),   tol/4,param,condon);
	 y(k(k1)) =y(k(k1)) +tmp1;tol1(k(k1))=tol1(k(k1))+tmp2;
       end
       k1=find(m1<x1(k)& m2<x2(k));
       if any(k1),
	 [tmp1 tmp2]=quad2dg('weib2dpdf',x1s(k(k1)),x1(k(k1)), x2s(k(k1)),   x2(k(k1)),   tol/4,param,condon);
	 y(k(k)) =y(k(k)) +tmp1;tol1(k(k))=tol1(k(k))+tmp2;
       end
     end
   case 1,%conditional CDF given x1  
     k = find( (x1 > 0) & (x2>0) & (c12(ones(size(x2))) ~=0 ));
     if any(k),
       [y(k) tol1(k)]=gaussq('weib2dpdf',0,x2(k),tol,[],x1(k),a2,b2,a1,b1,c12,2);%param([3:4 1:2 5]),2);   
     end
     k = find( (x1==0)| (c12(ones(size(x2))) ==0));
     if any(k),
       y(k) =wweibcdf(x2(k),param(3),param(4)); 
     end
     %for ix=1:length(x1(:)),      
     %[y(ix) tol1(ix)]=quadg('weib2dpdf',0,x2(ix),tol,[],x1(ix),param([3:4 1:2 5]),2);      
     %end
   case 2,%conditional CDF given x2  
     k = find( (x1 > 0) & (x2>0) & (c12(ones(size(x2))) ~=0));
     if any(k),
       [y(k) tol1(k)]=gaussq('weib2dpdf',0,x1(k),tol,[],x2(k),a1,b1,a2,b2,c12,2);%param,2); 
     end
     k = find( (x2==0)| (c12(ones(size(x2))) ==0));
      if any(k),
       y(k) =wweibcdf(x1(k),param(1),param(2)); 
     end
     %for ix=1:length(x2(:)), 
      % [y(ix) tol1(ix)]=quadg('weib2dpdf',0,x1(ix),tol,[],x2(ix),param,2);      
     %end
 end    
 
% make sure 0 <= y<=1 
k2=find(y<0);
if any(k2)
  y(k2)=zeros(size(k2));
end
k2=find(y>1);
if any(k2)
  y(k2)=ones(size(k2));
end
if any(isnan(y)),
  disp(['Warning: there are : ', num2str(sum(isnan(y))),' NaNs']);
end
