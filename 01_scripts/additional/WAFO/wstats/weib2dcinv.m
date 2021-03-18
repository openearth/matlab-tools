function [x, k2]= weib2dcinv(x1,p,a1,b1,a2,b2,c12,tol);
%WEIB2DCINV Inverse of the conditional 2D weibull cdf of X2 given X1.
%
% CALL: X2 =  weib2dcinv(X1 ,P,param,rtol)  
% 
%   X2    = inverse of the conditional weib2dcdf given X1 at the
%           probabilities in P.
%   X1    = conditional variable 
%   param = [A1 B2 A2 B2 C12] distribution parameters
%
%   The size of X is the common size of the input arguments X1 and P. A scalar input  
%   functions as a constant matrix of the same size as the other inputs.    
%
%   WEIB2DCINV uses Newton's method to converge to the solution.
%
% See also  weib2dcdf, weib2dstat, norminv
%

% Tested on: matlab 5.2
%History
% revised pab 13.11.2000, minor fixes
% By Per A. Brodtkorb 19.11.98

if nargin < 3, 
  error('Requires 3 input arguments.'); 
elseif (nargin < 4) &prod(size((a1)))~=5|isempty(a1),
  error('Requires either 5 input arguments or that input argument 1 must have 5 entries .'); 
elseif (nargin < 5) &prod(size((a1)))==5,
  if (nargin <4)|isempty(b1),  tol=1e-3; else tol=b1; end;
   b1=a1(2);
  a2=a1(3);  b2=a1(4);    c12=a1(5); a1=a1(1); 
elseif (nargin <8)|isempty(tol),  tol=1e-3;  
end
parm=[a1 b1 a2 b2 c12];

[errorcode  x1 p a1 b1 a2 b2 c12 ] = comnsize(x1,p,a1,b1,a2, b2, c12);
if errorcode > 0
    error('Requires non-scalar arguments to match in size.');
end

%   Initialize X to zero.
x = zeros(size(p));

 ok =(0<=p & p<=1 &  a1 > 0 & b1 > 0 & a2 > 0 & b2 > 0 &  abs(c12)<1);
k = find(p<0 | p>1 | ~ok);
if any(k),
    tmp  = NaN;
    x(k) = tmp(ones(size(k))); 
end

% The inverse cdf of 0 is 0, and the inverse cdf of 1 is inf.  
k0 = find(p == 0 & ok);
if any(k0),
    x(k0) = zeros(size(k0)); 
end

k1 = find((p == 1| isinf(x1) )& ok );
if any(k1), 
  tmp = Inf;
    x(k1) = tmp(ones(size(k1))); 
end

% Newton's Method
% Permit no more than maxcount interations.
maxcount = 100;
count = 0;

k = find(~isinf(x1) & p > 0  &  p < 1 & ok);

if ~any(k),return,end

pk = p(k);

% Supply a starting guess for the iteration.
cvar=linspace(0,max(x1(k)),20); % make sure that the comp. of mn and v do 
                                % not consume valuable time
[mn v ]=weib2dstat(parm,1,cvar); %slow
mn = interp1(cvar,mn,x1(k),'linear'); %fast
v = interp1(cvar,v,x1(k),'linear'); %fast

switch 2, %method
  case 1,%Use a lognormal distribution. 
  temp = log(v + mn .^ 2); 
  mu = 2 * log(mn) - 0.5 * temp;
  sa = -2 * log(mn) + temp;
  xk = exp(wnorminv(pk,mu,sa.^2));
case 2, %   Use a normal distribution. probably the fastest choice
  xk=abs(wnorminv(pk,mn,v));
  %xk((xk<=0))=1e-3;
    if any(isnan(xk))
      disp(['Warning: NaNs   ' num2str(sum(isnan(xk)))])
    end
case 3, % use weibull distribution slowest choice
	%   beta=fsolve('gamma(1+1./x).^2./gamma(1+2./x)-P1.^2./(P2+P1.^2)',parm(4).*ones(size(mn)),[],[],mn,v);
	%   alpha=mn./gamma(1+1./beta);
	%   xk=wweibinv(pk,alpha,beta); 
end
%x(k)=xk;
%return
h = ones(size(pk)); 

% Break out of the iteration loop for three reasons:
%  1) the last update is very small (compared to x)
%  2) the last update is very small (compared to sqrt(eps))
%  3) There are more than 100 iterations. 

k2=find((abs(h) > sqrt(eps)*abs(xk))  &  abs(h) > sqrt(eps));
while(any(k2) & count < maxcount), 
                                 
    count = count + 1;
    h(k2)  = (weib2dcdf(x1(k(k2)),xk(k2),parm,1,tol) - pk(k2)) ./ weib2dpdf(x1(k(k2)),xk(k2),parm,1);
   
    xnew = xk(k2) - h(k2);
    % Make sure that the current xnew>0.
    ix = find(xnew <= 0);
    if any(ix),
        xnew(ix) = xk(k2(ix)) / 10;
        h(k2(ix)) = xk(k2(ix))-xnew(ix);
    end
    xk(k2) = xnew;
     disp(['Iteration  'num2str(count) , '  Number of points left:  ' ...
	   num2str(length(k2)) ]),
    %if any(isnan(xk)),  disp(['Warning: values out of range   '...
    %  num2str(sum(isnan(xk)))]),   end
    
    % if not converged decrease the relative tolerance in the calculation of cdf
    if length(k2)<length(k)/4 & count>maxcount/4, tol=tol/10;,end
    k2=find((abs(h) > sqrt(eps)*abs(xk))  &  abs(h) > sqrt(eps));   
end


% Store the converged value in the correct place
x(k) = xk;

if count == maxcount, 
    disp('Warning: WEIB2DCINV did not converge.');
    str = ['The last steps were all less than:  ' num2str(max(abs(h(k2))))];
    disp(str)
    ind=k(k2);
  else
    ind=[];
end
