function [yy,coefs]= smooth(x,y,p,xx,LinExtrap,d2)
%SMOOTH Calculates a smoothing spline.
% 
%  CALL:  yy = smooth(x,y,p,xx,def,v)
%
%         x  = x-coordinates of data. (vector)
%         y  = y-coordinates of data. (vector)
%         p  = [0...1] is a smoothing parameter:
%              0 -> LS-straight line
%              1 -> cubic spline interpolant
%         xx = the x-coordinates in which to calculate the smoothed function.
%         yy = the calculated y-coordinates of the smoothed function if
%              xx is given. If xx is not given then yy contain the
%              pp-form of the spline, for use with PPVAL.
%        def = 0 regular smoothing spline (default)
%              1 a smoothing spline with a constraint on the ends to 
%                ensure linear extrapolation outside the range of the data
%          v = variance of each y(i) (default  ones(length(X),1)) 
%
%  Given the approximate values 
%  
%                y(i) = g(x(i))+e(i) 
%  
%  of some smooth function, g, where e(i) is the error. SMOOTH tries to 
%  recover g from y by constructing a function, f, which  minimizes
%
%              p * sum (Y(i) - f(X(i)))^2/d2(i)  +  (1-p) * int (f'')^2
%
%  The call  pp = smooth(x,y,p)  gives the pp-form of the spline, 
%  for use with PPVAL. 
%
% Example:%
%  x = linspace(0,1).';
%  y = exp(x)+1e-1*randn(size(x));
%  pp = smooth(x,y,.9); 
%  plot(x,y,x,smooth(x,y,.99,x),'g',x,ppval(pp,x),'k',x,exp(x),'r')
%
% See also  lc2tr, dat2tr, ppval


%References:
% Carl de Boor (1978)
% 'Practical Guide to Splines'
%  Springer Verlag
%  Uses EqXIV.6--9, pp 239

% tested on: Matlab 4.x 5.x
%History:
% revised pab  26.11.2000
% - added example
% - fixed a bug: n=2 is now possible
% revised by pab 21.09.99
%    - added d2
% revised by pab 29.08.99
%    -new extrapolation: ensuring that
%     the smoothed function has contionous derivatives
%     in the first and last knot
% modified by Per A. Brodtkorb  23.09.98 
%  secret option forcing linear extrapolation outside the ends when p>0
%  used in lc2tr

if (nargin<5)|(isempty(LinExtrap)),
  LinExtrap=0; %do not force linear extrapolation in the ends (default)
end


[xi,ind]=sort(x(:));
n = length(xi);
y = y(:);
if n<2,
   error('There must be >=2 data points.')
elseif any(diff(xi)<=0),
   error('Two consecutive values in x can not be equal.')
elseif n~=length(y),
   error('x and y must have the same length.')
end

if nargin<6|isempty(d2), 
  d2 = ones(n,1);  %not implemented yet
else
  d2=d2(:);
end

    
yi=y(ind); %yi=yi(:);

dx = diff(xi);
dydx = diff(yi)./dx;

if (n==2)  % straight line
  coefs=[dydx yi(1)];
else
  if LinExtrap & n==3, p = 0;end % Force LS-fit
  dx1=1./dx;
  Q = spdiags([dx1(1:n-2) -(dx1(1:n-2)+dx1(2:n-1)) dx1(2:n-1)],0:-1:-2,n,n-2);
  D = spdiags(d2,0,n,n);  % The variance
  R = spdiags([dx(1:n-2) 2*(dx(1:n-2)+dx(2:n-1)) dx(2:n-1)],-1:1,n-2,n-2);
  
  QQ = (6*(1-p))*(Q.'*D*Q)+p*R;
  % Make sure Matlab uses symmetric matrix solver
  u  = 2*((QQ+QQ')\diff(dydx));                     % faster than u=QQ\(Q'*yi);
  ai = yi-6*(1-p)*D*diff([0;diff([0;u;0]).*dx1;0]); % faster than yi-6*(1-p)*Q*u
  
  % The piecewise polynominals are written as
  % fi=ai+bi*(x-xi)+ci*(x-xi)^2+di*(x-xi)^3 
  % where the derivatives in the knots according to Carl de Boor are:
  %    ddfi  = 6*p*[0;u] = 2*ci;
  %    dddfi = 2*diff([ci;0])./dx = 6*di;
  %    dfi   = diff(ai)./dx-(ci+di.*dx).*dx = bi;
 
  ci = 3*p*[0;u];
   
  
  if LinExtrap & p~=0& n>3, %Forcing linear extrapolation in the ends 
    ci([2,  end]) = 0;  
  % New call
  % fixing the coefficients so that we have continous 
  % derivatives everywhere
    ai(1) = -(ai(3)-ai(2))*dx(1)/dx(2) +ai(2)+ ci(3)*dx(1)*dx(2)/3;
    ai(n) = (ai(n-1)-ai(n-2))*dx(n-1)/dx(n-2) +ai(n-1)+ ci(n-2)*dx(n-2)*dx(n-1)/3;  
  end
  
  di    = diff([ci;0]).*dx1/3;
  bi    = diff(ai).*dx1-(ci+di.*dx).*dx;
  coefs = [di ci bi ai(1:n-1)]; 
end

pp = mkpp(xi,coefs);
if (nargin<4)|(isempty(xx)),
  yy = pp;
else
  yy = ppval(pp,xx);
end


return
% old call: linear extrapolation
% crude the derivatives are not necessarily continous
% where we force ci and di to zero
if LinExtrap, %forcing linear extrapolation in the ends 
  ci([2,  end])=0;  % could be done better
  di([1 end])=0;
end
% Old call for LinExtrap
if 0 %LinExtrap & n>6 & (p~=0), %forcing linear extrapolation in the ends 
    Q = Q(2:end-1,2:end-1);
    D = D(2:end-1,2:end-1);
    R = R(2:end-1,2:end-1);
    % new call : so ci(1:2)=ci(n-1:n)=di(1)=di(n)=0
      
    QQ=(6*(1-p))*(Q.'*D*Q)+p*R;
    % Make sure Matlab uses symmetric matrix solver
    u=2*((QQ+QQ')\diff(dydx(2:n-2))); %faster than 2*(QQ+QQ.'')\(Q'*yi);

    % The piecewise polynominals are written as
    % fi=ai+bi*(x-xi)+ci*(x-xi)^2+di*(x-xi)^3 
    ai=yi(2:n-1)-(6*(1-p)*D*diff([0;diff([0;u;0])./dx(2:n-2);0]));%faster than yi-6*(1-p)*D*Q*u ;
    ci=3*p*[0;0;u;0];
    % fixing the coefficients so that we have continous 
    % derivatives everywhere
    a1=-(ai(2)-ai(1))*dx(1)/dx(2) +ai(1)+ ci(3)*dx(1)*dx(2)/3;
    an=(ai(n-2)-ai(n-3))*dx(n-1)/dx(n-2) +ai(n-2)+ ci(n-2)*dx(n-2)*dx(n-1)/3;  
    ai=[a1;ai; an];
  
  else
    
  end


