function x = wgumbinv(F,a,b,trunc)
%WGUMBINV Inverse of the Gumbel distribution function.
%
% CALL:  x = wgumbinv(F,a,b,trunc) 
%
%   x    = Inverse Gumbel evaluated at F
%  a, b  = parameters of the Gumbel distribution.
%  trunc = 0  regular gumbel distribution (default)
%          1  truncated gumbel distribution 
%
%    Gumbel cdf  is given by :    
%            F(x) = exp(-exp(-(x-b)/a)    -inf < x < inf,  a>0
%    or the truncated
%           F(x) = [exp(-exp(-(x-b)/a)) -exp(-exp(b/a)) ]/(1-exp(-exp(b/a)))
%       0 < x < inf, a>0     
%
% Example: 
%   F = linspace(0,1,100);
%   x1 = wgumbinv(F,2,0); x2 = wgumbinv(F,1,1);
%   plot(F,x1,F,x2)
%
% See also  wgumbfit, wgumbrnd, wgumbpdf, wgumbinv, wgumbstat, wgumbplot

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


%  tested on: matlab 5.2
% history
% revised pab 8.11.1999
% updated header info
%   Per A. Brodtkorb 17.10.98
% rewritten ms 19.06.2000
% revised pab 25.10.2000
% - added nargchk+comnsize

error(nargchk(3,4,nargin))
if nargin<4|isempty(trunc), trunc=0;end

[errorcode F a b] = comnsize(F,a,b);
if errorcode > 0
    error('F, a and b must be of common size or scalar.');
end
x=zeros(size(F));

ok = (0<=F& F<=1 & a>0);

k1=find((F>0)&(F<1) & ok);

if any(k1)
  if trunc,
    tmp=exp(-exp(b(k1)./a(k1)));
    x(k1) =-a(k1).* log(-log((1-tmp).* F(k1) +tmp) ) + b(k1); 
  else
    x(k1) =-a(k1).* log(-log( F(k1)) ) + b(k1);
  end
end
tmp=Inf;
k2=find(F==0 & ok);
if any(k2)
  if trunc
    x(k2)=zeros(size(k2));
  else
    x(k2)=-tmp(ones(size(k2)));
  end
end
k3=find(F==1& ok);
if any(k3)
  x(k3)=tmp(ones(size(k3)));
end

k4= find(~ok);
if any(k4)
  x(k4)=NaN;
end
