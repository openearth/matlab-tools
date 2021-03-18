function x = wchi2inv(F,p)
%WCHI2INV Inverse of the Chi squared distribution function
%
% CALL:  x = wchi2inv(F,p)
%
%        x = inverse cdf for the Chi squared distribution evaluated at F
%        p = degrees of freedom
%
%
% Example:
%     F = linspace(0,1,100);
%     x = wchi2inv(F,1);
%     plot(F,x)

% Reference: Johnson, Kotz and Balakrishnan (1994)
% "Continuous Univariate Distributions, vol. 1", p. 415 ff
% Wiley

% Tested on; Matlab 5.3
% History: 
% revised pab 25.10.2000
%  - added comnsize, nargchk
% added ms 26.06.2000
error(nargchk(2,2,nargin))

if any(p~=round(p)),
  warning('p should be an integer')
end
[errorcode,F,p2,b] = comnsize(F,p/2,2);
if errorcode > 0
  error('F and p must be of common size or scalar.');
end

x=wgaminv(F,p/2,2);
