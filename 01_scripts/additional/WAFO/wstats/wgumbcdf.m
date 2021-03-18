function F = wgumbcdf(x,a,b,trunc)
%WGUMBCDF Gumbel cumulative distribution function.
%
% CALL:  F = wgumbcdf(x,a,b,trunc) 
%   
%   F    = Gumbel cdf evaluated at x
%  a, b  = parameters of the Gumbel distribution.
%  trunc = 0  regular gumbel distribution (default)
%          1  truncated gumbel distribution 
%
%  Gumbel CDF  is given by :                           
%       F(x) = exp(-exp(-(x-b)/a))    -inf < x < inf, a>0
%  or the truncated 
%       F(x) = [exp(-exp(-(x-b)/a))-exp(-exp(b/a))]/(1-exp(-exp(b/a))) 
%           0 < x < inf,  a>0
%
%
% Example: 
%   x = linspace(-4,6,200);
%   p1 = wgumbcdf(x,2,0); p2 = wgumbcdf(x,1,1);
%   plot(x,p1,x,p2)
%
% See also  wgumbfit, wgumbrnd, wgumbpdf, wgumbinv, wgumbstat, wgumbplot



%  tested on: matlab 5.2
% history
% revised pab 8.11.1999
% updated header info
%   Per A. Brodtkorb 17.10.98
% rewritten ms 19.06.2000
% revised pab 25.10.2000
% - added nargchk+comnsize

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


error(nargchk(3,4,nargin))
if nargin<4|isempty(trunc), trunc=0;end

[errorcode x a b] = comnsize(x,a,b);
if errorcode > 0
    error('x, a and b must be of common size or scalar.');
end
F=zeros(size(x));
k1 = find(a>0);
if any(k1),
  F(k1)=exp(-exp(-(x(k1) -b(k1))./a(k1)) );
  if trunc,
    tmp=exp(-exp(b(k1)./a(k1)));
    F(k1)=(F(k1)-tmp)./(1-tmp).*(x(k1)>0);
  end
end

k2=find(a<=0);
if any(k2)
  F(k2)=NaN;
end



