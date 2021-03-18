function F = wraylcdf(x,b,c,a);
%WTRAYLCDF Truncated Rayleigh cumulative distribution function
%
% CALL:  F = wtraylcdf(x,b,c);
%
%        F = distribution function evaluated at x
%        b = scale parameter
%        c = truncation parameter (default 0)  
% The truncated Rayleigh distribution is defined by its cdf
%
%  F(x;b,c) = 1 - exp(-(x-c)^2/(2b^2)+c^2/(2b^2)), x>=0
%
% Example: 
%   x = linspace(0,4,200);
%   p1 = wtraylcdf(x,1); p2 = wtraylcdf(x,0.5,-2);
%   plot(x,p1,x,p2)

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.


% Tested on: Matlab 5.3
% History:
% by pab 03.12.2000
% based on wraylpdf

error(nargchk(2,4,nargin))
if nargin<3|isempty(c),c=0;end
if nargin<4|isempty(a),a=2;end
[errorcode, x, b,c] = comnsize (x,b,c);
if (errorcode > 0)
  error ('x, b and c must be of common size or scalar');
end

F = zeros(size(x));

k = find ((x>=0)&(b>0));

if any(k)  
  F(k)=(1-exp(-(x(k)-c(k)).^a./(2*b(k).^a)+abs(c(k)).^a./(2*b(k).^a)));
end

k1 = find (b<=0);
if any(k1)
  tmp=NaN;
  F(k1) = tmp(ones(size(k1)));
end




