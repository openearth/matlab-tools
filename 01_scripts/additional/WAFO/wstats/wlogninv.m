function x = wlogninv(F,m,v)
%WLOGNINV Inverse of the Lognormal distribution function
%
% CALL:  x = wlogninv(F,m,v)
%
%        x = inverse cdf for the Lognormal distribution evaluated at F
%      m,v = parameters     (default 0 and 1, respectively)
%
% Example:
%   F = linspace(0,1,100);
%   x = wlogninv(F,0,1);
%   plot(F,x)


% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 59 ff, Marcel Dekker.


% Tested on; Matlab 5.3
% History: 
% revised pab 24.10.2000
%  - added comnsize, nargchk
%  - added default values
%  - fixed a bug: the inversion was not correct 
% added ms 10.08.2000

error(nargchk(1,3,nargin))
if nargin<2|isempty(m),  m=0;  end
if nargin<3|isempty(v),  v=1;  end

[errorcode, F, m, v] = comnsize (F,m, v);
if (errorcode > 0)
  error ('F, m and v must be of common size or scalar');
end
x=exp(wnorminv(F,m,v));

