function f = wgumbpdf(x,a,b,trunc)
%WGUMBPDF Gumbel probability density function.
%
% CALL:  f = wgumbpdf(x,a,b,trunc) 
%   
%   f    = Gumbel pdf evaluated at x
%  a, b  = parameters of the Gumbel distribution.
%  trunc = 0  regular gumbel distribution (default)
%          1  truncated gumbel distribution 
%
%  Gumbel PDF  is given by :                           
%      f(x) = exp(-(x-b)/a)*exp(-exp(-(x-b)/a))/a    -inf < x < inf, a>0
%  or the truncated
%      f(x) = exp(-(x-b)/a)*exp(-exp(-(x-b)/a))/a/(1-exp(-exp(b/a)))
%          0 < x < inf, a>0 
%
% Example: 
%   x = linspace(-4,8,200);
%   p1 = wgumbpdf(x,2,0); p2 = wgumbpdf(x,1,1);
%   plot(x,p1,x,p2)
%
% See also  wgumbfit, wgumbrnd, wgumbcdf, wgumbinv, wgumbstat

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


%  tested on: matlab 5.2
% history
% revised pab 24.10.2000
% - reimplemented comnsize
% revised pab 8.11.1999
% updated header info
%   Per A. Brodtkorb 17.10.98

error(nargchk(3,4,nargin))
if nargin < 4 | isempty(trunc),
    trunc=0; % default value is not truncated
end

[errorcode x a b] = comnsize(x,a,b);
if errorcode > 0
    error('x, a and b must be of common size or scalar.');
end

f = zeros(size(x));


if trunc,
  k = find(x > 0 & a>0);
else 
  k = find(a>0);
end

if any(k),
  tmp=exp(-(x(k) -b(k))./a(k)  );
  f(k) =  tmp.* exp(-tmp)./a(k);
  if trunc,
    f(k)=f(k)./(1-exp(-exp(b(k)./a(k)  )));
  end
end

k1 = find(a <= 0 );
if any(k1)
   tmp   = NaN;
   f(k1) = tmp(ones(size(k1)));
end
