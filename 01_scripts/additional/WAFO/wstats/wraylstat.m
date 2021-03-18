function [m,v]= wraylstat(b);
%WRAYLSTAT Mean and variance for the Rayleigh distribution.
% 
% CALL:  [m,v] = wraylstat(b)
%
%   m, v = the mean and variance, respectively 
%      b = parameter of the Rayleigh distribution (see wraylcdf)
%
%  Mean (m) and variance (v) for the Rayleigh distribution is
%
%  m=b*(pi/2)^(1/2)  and  v=(2-pi/2)*b^2;
%
% Example:
%   [m,v] = wraylstat(1/(pi/2)^(1/2))
%
% See also  wraylcdf

% Reference: Cohen & Whittle, (1988) "Parameter Estimation in Reliability
% and Life Span Models", p. 181 ff, Marcel Dekker.

%tested on: matlab 5.3
% history
% revised pab 24.10.2000
% Added checks on b



error(nargchk(1,1,nargin))

%   Initialize Mean and Variance to zero.
m = zeros(size(b));
v = zeros(size(b));

ok = (b > 0);
k = find(ok);
if any(k)
 m(k) = b(k) * sqrt(pi/2);
 v(k) = (2 - pi/2) * b(k) .^ 2;
end

k1 = find(~ok);
if any(k1)
    tmp = NaN;
    m(k1) = tmp(ones(size(k1)));
    v(k1) = m(k1);   
end





