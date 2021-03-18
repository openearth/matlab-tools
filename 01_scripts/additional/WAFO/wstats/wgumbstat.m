function [m,v]= wgumbstat(a,b,trunc);
%WGUMBSTAT Mean and variance for the Gumbel distribution.
% 
% CALL:  [m,v] = wgumbstat(a,b,trunc)
%
%   m, v = the mean and variance, respectively 
%   a, b = parameters of the Gumbel distribution (see wgumbcdf)
%  trunc = 0  regular gumbel distribution (default)
%          1  truncated gumbel distribution (not available)
%
%  Mean (m) and variance (v) for the Gumbel distribution is
%
%  m=Euler*a+b  and  v=(a*pi)^2/6  where Euler is Euler's
%  constant 0.5772...
%
% Example:
%   X = wgumbrnd(5,10,[],1000,1);
%   [mean(X) var(X)]        % Estimated mean and variance
%   [m,v] = wgumbstat(5,10) % True mean and variance
%
% See also  gumbfit, gumbpdf, gumbcdf, gumbinv, gumbpdf

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 


%  tested on: matlab 5.2
% history
% revised pab 8.11.1999
% updated header info
%   Per A. Brodtkorb 17.10.98
% revised ms 14.06.2000
% - changed name to wgumbstat (from gumbstat)
% - revised header info
% - noted that calculations are wrong for trunc=1 (not corrected)

error(nargchk(2,3,nargin))

[errorcode a b] = comnsize(a,b);
if errorcode > 0,
  error('a and b  must be of common size or scalar.');
end
if nargin < 3 | isempty(trunc),
    trunc=0; % default value is not truncated
end


m = 0.5772*a+b; %mean
v = pi^2/6*a.^2; %variance

if trunc, %This is not correct (ms)
  tmp=1-exp(-exp( b./a));
  m=m./tmp;
  v=v./tmp;
end
% Return NaN if A is negative or zero.
k = find(a <= 0);
if any(k)
    tmp = NaN;
    m(k) = tmp(ones(size(k))); 
    v(k) = m(k);
end

