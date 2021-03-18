function R  = wgumbrnd(a,b,trunc, varargin)
%WGUMBRND Random matrices from a Gumbel distribution.
% 
% CALL:  R = wgumbrnd(a,b,trunc,sz) 
%  
%  R     = a matrix of random numbers from the Gumbel distribution
%  a, b  = parameters of the Gumbel distribution.
%  trunc = 0  regular gumbel distribution (default)
%          1  truncated gumbel distribution 
%     sz = size(R)    (Default common size of k,s and m0)
%          sz can be a comma separated list or a vector 
%          giving the size of R (see zeros for options). 
%
%   The size of R is the common size of a and b if both are matrices.
%   If either parameter is a scalar, the size of R is the size of the other
%   parameter. R = wgumbrnd(a,b,trunc,m,n) returns an m by n matrix. 
%
% Example:
%   R=wgumbrnd(5,10,[],1,100);
%   wgumbplot(R);
%
% See also  wgumbfit, wgumbpdf, wgumbcdf, wgumbinv, wgumbstat

% Reference: 
%  Johnson  N.L., Kotz S. and Balakrishnan, N. (1994)
%  Continuous Univariate Distributions, Volume 2. Wiley. 

% Tested on: matlab 5.2
% History:
% revised pab 8.11.1999
%  updated help header
% by Per A. Brodtkorb 26.10.98
% revised ms 13.06.2000
% - updated header info
% - changed name to wgumbrnd (from gumbrnd)
% - added w* to used WAFO-files 
% - enabled use of 5:th argument
% - removed stat-toolbox routines
% 
% revised pab 23.10.2000
%  - added comnsize, nargchk
%  - added greater flexibility on the sizing of R

error(nargchk(2,inf,nargin))
if nargin<3| isempty(trunc)
  trunc=0; %default is not truncated gumbel
end
if nargin<4,
  [errorcode a,b] = comnsize(a,b);
else
  [errorcode a,b] = comnsize(a,b,zeros(varargin{:}));
end
if errorcode > 0
  error('a and b must be of common size or scalar.');
end
R=wgumbinv(rand(size(a)),a,b,trunc);




