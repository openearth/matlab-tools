function x = wfinv(F,a,b)
%WFINV  Inverse of the Snedecor's F distribution function
%
% CALL:  x = wfinv(F,df1,df2)
%
%   x      = inverse cdf for the F distribution evaluated at F.
% df1, df2 = degrees of freedom (1,2,....)
%
% Example:
%   F = linspace(0,1,100);
%   x = wfinv(F,1,2);
%   plot(F,x)


% tested on matlab 5.3
%History:
%revised pab 29.10.2000
% adapted from stixbox
% -added nargchk, comnsize
%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg

error(nargchk(3,3,nargin))
[errorcode F,a,b] = comnsize(F,a,b);
if errorcode>0,
  error('x, df1 and df2 must be of common size or scalar');
end

x = zeros(size(F));

ok = (a>0 & b>0 & floor(a)==a & floor(b)==b);

k = find(F>0&F<1 & ok);
if any(k)
  tmp = wbetainv(F(k),a(k)/2,b(k)/2);
  x(k) = tmp.*b(k)./((1-tmp).*a(k));
end


k2=find(F==1&ok);
if any(k2)
  x(k2)=inf;
end


k3=find(~ok);
if any(k3)
  tmp=NaN;
  x(k3)=tmp(ones(size(k3)));
end
