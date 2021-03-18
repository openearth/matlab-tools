function x = wexpinv(F,m)
%WEXPINV Inverse of the Exponential distribution function
%
% CALL:  x = wexpinv(F,m)
%
%        x = inverse cdf for the Exponential distribution evaluated at F
%        m = mean, m>0
%
% Example:
%   F = linspace(0,1,100);
%   x = wexpinv(F,1);
%   plot(F,x)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 494 ff
% Wiley


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
% added ms 10.08.2000

error(nargchk(2,2,nargin))
%if nargin<2|isempty(m),  m=0;  end

[errorcode, F, m] = comnsize (F,m);
if (errorcode > 0)
  error ('F and m must be of common size or scalar');
end

x=zeros(size(F));
ok = ((m>0)&(F>=0)&(F<=1));
k = find (F<1& ok);
if any(k)
  x(k)=-m(k).*log(1-F(k));
end


k1 = find (~ok);
if any (k1)
  tmp=NaN;
  x(k1) = tmp(ones(size(k1)));
end
k2 = find (ok & F==1);
if any (k2)
  tmp=inf;
  x(k2) = tmp(ones(size(k2)));
end
