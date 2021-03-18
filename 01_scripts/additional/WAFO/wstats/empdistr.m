function [Fz] = empdistr(z,varargin)
%EMPDISTR Computes and plots the empirical CDF 
%          and optionally compares it with distribution G.
%
%  CALL:  F = empdistr(X,G,plotflag,sym);
%
%        F  = empirical distribution of X, two column matrix.
%        X  = data vector.
%        G  = cdf, two column matrix (optional).
%  plotflag = 0  no plotting
%             1 plot cdf F(x) (default)
%             2 plot 1-F(x) on a semilog y-scale
%             3 plot 1-F(x) on a log log scale
%       sym = {s1,s2} cell array or comma separated list of plot 
%             symbols for F and G, respectively.
%             (default {'b','r--'})
% 
% NOTE:  SYM can be given anywhere after X
%
% Example:
%   R = wgevrnd(.8,1,11,1,100);
%   x = linspace(5,15,200);
%   empdistr(R,[x;wgevcdf(x,.8,1,11)]','g')
%
% See also  cumtrapz, cempdistr

% Tested on: Matlab 5.3, 5.2, 5.1
% History:
% revised pab 25.10.2000
%  - made call to cempdistr instead -> making maintainence easier.
% revised pab 07.03.2000
% - enabled so that f may be empty while plotflag is given 
% modified by Per A. Brodtkorb 10.11.98
% to accept both pdf and cdf's. Also enabled new plotting features,
% plotting of  probability of exceedances on a semilogy paper ....
% revised ms 13.06.2000
% - pdf usage removed (can't distinguish between a cdf and an increasing pdf)
% - changed axis labelling in figures
% - changed to staircaseplot when plotflag=2,3
% - revised header info
% - moved the conditional version to cempdistr


error(nargchk(1,5,nargin))
Fz1 = cempdistr(z,-inf,varargin{:});
if nargout>0
  Fz=Fz1;
end
return








