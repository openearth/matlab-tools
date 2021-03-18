function F = wtcdf(x,df)
%WTCDF  Student's T  cumulative distribution function
%
% CALL:  F = wtcdf(x,df);
%
%    F = distribution function evaluated at x
%    x = matrix
%   df = degrees of freedom (1,2,....)
%
% Example:
%   x = linspace(-5,5,200);
%   p1 = wtcdf(x,1); p2 = wtcdf(x,5);
%   plot(x,p1,x,p2)

% tested on matlab 5.3
%History:
%revised pab 22.05.2003
% -added new methods for df==1 or df==2 and for region1= x^2<df^2
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize, mxdf +  check on floor(df)==df
%by      Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg


error(nargchk(2,2,nargin))
[errorcode x,df] = comnsize(x,df);
if errorcode>0,
  error('x and df must be of common size or scalar');
end

F = zeros(size(x));

%df = min(df,1000000); % make it converge and also accept Inf.
mxdf = 10^6;

k1 = find(df==1 );
if any(k1)
 F(k1) =  ( 1 + 2*atan(x(k1))/pi )/2;
end
k2 = find(df==2);
if any(k2)
  x2= x(k2);
  F(k2) = ( 1 + x2./sqrt( 2 + x2.*x2 ))/2;
end

ok      = (0<df & df==floor(df));
region1 = (abs(x)<sqrt(abs(df)));
k3 = find(ok & region1 & (2 < df) & (df<mxdf) );
if (any(k3)),
  dfk = df(k3);
  xk = x(k3);
  xk2 = xk.*xk;
  cssthe = 1./( 1 + xk2./dfk );
  nuVec = unique(dfk(:));
  Fk = zeros(size(dfk));
  for nu = nuVec(:).'
    knu = find(dfk==nu);
    Fk(knu) = evalPoly(nu,xk(knu),xk2(knu),cssthe(knu));
  end
  F(k3) = Fk;
end

k = find(ok & ~region1 & (2<df) & df<mxdf );
if any(k),
  neg = x(k)<0;
  tmp = 1-(1-wfcdf(x(k).^2,1,df(k)))/2;
  F(k) = tmp + (1-2*tmp).*neg;
end

k1=find(ok & df>=mxdf);
if any(k1)
  F(k1) = wnormcdf(x(k1),0,1);
end

  
k2 = find(~ok);
if any(k2)
  F(k2)=NaN;
end

return
function F = evalPoly(nu,t,tt,cssthe)
  
  polyn = 1;
  for j = nu-2 : -2 : 2
    polyn = 1 + ( j - 1 )*cssthe.*polyn/j;
  end 
  if ( mod( nu, 2 ) == 1 ) 
    ts = t/sqrt(nu);
    F = ( 1 + 2*( atan(ts) + ts.*cssthe.*polyn )/pi )/2;
  else
    snthe = t./sqrt( nu + tt );
    F = ( 1 + snthe.*polyn )/2;
  end
  F = max(0, min(F, 1) );
  return